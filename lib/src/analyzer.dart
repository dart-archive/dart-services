// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library services.analyzer;

import 'dart:async';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/src/generated/constant.dart';
import 'package:analyzer/src/generated/element.dart';
import 'package:analyzer/src/generated/engine.dart' hide Logger;
import 'package:analyzer/src/generated/error.dart';
import 'package:analyzer/src/generated/java_engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/parser.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:logging/logging.dart';

import 'api_classes.dart';
import 'common.dart';
import 'pub.dart';

Logger _logger = new Logger('analyzer');

class Analyzer {
  final Pub pub;

  StringSource _source;
  AnalysisContext _context;

  Analyzer(String sdkPath, [this.pub]) {
    DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(sdkPath),
        /*useDart2jsPaths*/ true);
    _context = AnalysisEngine.instance.createAnalysisContext();
    _context.analysisOptions = new AnalysisOptionsImpl()..cacheSize = 512;
    List<UriResolver> resolvers = [
      new DartUriResolver(sdk),
      // TODO: Create a new UriResolver.
      //new PackageUriResolver([new JavaFile(project.packagePath)
    ];
    _context.sourceFactory = new SourceFactory(resolvers);
    AnalysisEngine.instance.logger = new NullLogger();

    _source = new StringSource('', 'main.dart');

    ChangeSet changeSet = new ChangeSet();
    changeSet.addedSource(_source);
    _context.applyChanges(changeSet);
    _context.computeErrors(_source);
    _context.getErrors(_source);
  }

  Future warmup([bool useHtml = false]) =>
      analyze(useHtml ? sampleCodeWeb : sampleCode);

  Future<AnalysisResults> analyze(String source) {
    try {
      _source.updateSource(source);

      ChangeSet changeSet = new ChangeSet();
      changeSet.addedSource(_source);
      _context.applyChanges(changeSet);

      List<AnalysisErrorInfo> errorInfos = [];

      _context.computeErrors(_source);
      errorInfos.add(_context.getErrors(_source));

      List<_Error> errors = errorInfos
        .expand((AnalysisErrorInfo info) {
          return info.errors.map((error) => new _Error(error, info.lineInfo));
        })
        .where((_Error error) => error.errorType != ErrorType.TODO)
        .toList();

      List<AnalysisIssue> issues = errors.map((_Error error) {
        return new AnalysisIssue.fromIssue(
            error.severityName, error.line, error.message,
            location: error.location,
            charStart: error.offset, charLength: error.length,
            hasFixes: error.probablyHasFix);
      }).toList();

      issues.sort();

      return new Future.value(new AnalysisResults(issues));
    } catch (e, st) {
      return new Future.error(e, st);
    }
  }

  Future<Map<String, String>> dartdoc(String source, int offset) {
    try {
      _source.updateSource(source);

      ChangeSet changeSet = new ChangeSet();
      changeSet.addedSource(_source);
      _context.applyChanges(changeSet);

      LibraryElement library = _context.computeLibraryElement(_source);
      CompilationUnit unit = _context.resolveCompilationUnit(_source, library);
      return new Future.value(_computeDartdocInfo(unit, offset));
    } catch (e, st) {
      return new Future.error(e, st);
    }
  }

  Map<String, String> _computeDartdocInfo(CompilationUnit unit, int offset) {
    AstNode node = new NodeLocator.con1(offset).searchWithin(unit);
    Map info = {};
    AstNode argument = node;

    if (node.parent is TypeName &&
        node.parent.parent is ConstructorName &&
        node.parent.parent.parent is InstanceCreationExpression) {
      node = node.parent.parent.parent;
    }

    if (node.parent is ConstructorName &&
        node.parent.parent is InstanceCreationExpression) {
      node = node.parent.parent;
    }

    if (node is Expression) {
      Expression expression = node;

      // element
      Element element = ElementLocator.locateWithOffset(expression, offset);

      if (element != null) {
        // variable, if synthetic accessor
        if (element is PropertyAccessorElement) {
          PropertyAccessorElement accessor = element;
          if (accessor.isSynthetic) element = accessor.variable;
        }

        // Name and description.
        if (element.name != null) info['name'] = element.name;
        info['description'] = '${_prettifyElement(element)}';
        info['kind'] = element.kind.displayName;

        // Only defined if there is an enclosing class.
        if (element.enclosingElement is ClassElement) {
          info['enclosingClassName'] = '${element.enclosingElement}';
        } else {
          info['enclosingClassName'] = null;
        }

        // Parameters for functions and methods.
        if (element is ExecutableElement) {
          List<String> list = [];
          ExecutableElement el = element;
          el.parameters.forEach((par)
            => list.add('${_prettifyElement(par)}'));
          info['parameters'] = list;
        }

        // library
        LibraryElement library = element.library;

        if (library != null) {
          if (library.name != null && library.name.isNotEmpty) {
            // TODO(lukechurch) remove this once this bug is fixed
            if (library.location.toString() != "utf-8") {
              info['libraryName'] = '${library.location}';
            } else {
              info['libraryName'] = library.name;
            }
          }
          if (library.location.toString() == "dart:html") {
            for (ElementAnnotationImpl e in element.metadata) {
              if (e.toString().startsWith("@DomName")) {
                EvaluationResultImpl evaluationResult = e.evaluationResult;
                if (evaluationResult != null && evaluationResult.value.fields["name"] != null) {
                  info["DomName"] = evaluationResult.value.fields["name"].value;
                } else {
                  _logger.fine("WARNING: Unexpected null, aborting");
                }
                break;
              }
            }
          }
          //info['libraryPath'] = library.source.shortName;
        }

        // documentation
        String dartDoc = element.computeDocumentationComment();
        dartDoc = cleanDartDoc(dartDoc);
        if (dartDoc != null) info['dartdoc'] = dartDoc;
      }

      // types
      if (expression.staticType != null) {
        info['staticType'] = '${_prettifyType(expression.staticType)}';
      }

      if (expression.propagatedType != null) {
        info['propagatedType'] = '${_prettifyType(expression.propagatedType)}';
      }
    }
    Map infoAsArgument = _computeArgumentInfo(argument);
    if (infoAsArgument != null) {
      info['infoAsArgument'] = infoAsArgument;
    }
    if (info.isEmpty) {
      return null;
    } else {
      return info;
    }
  }

  Map _computeArgumentInfo(AstNode argument) {
    var method;

    bool emptyArguments = false;
    while (true) {
      if (argument == argument.parent) {
        throw 'self-cyclic AST';
      } else if (argument.parent == null || argument.parent.parent == null) {
        argument = null;
        method = null;
        break;
      } else if (argument.parent is ArgumentList) {
        method = argument.parent.parent;
        break;
      } else if (argument is ArgumentList) {
        emptyArguments = true;
        method = argument.parent;
        break;
      }
      argument = argument.parent;
    }

    if (method == null
        || !(method is MethodInvocation || method is InstanceCreationExpression))
      return null;

    // method is either InstanceCreationExpression or MethodInvocation
    // both have the getter argumentList
    ArgumentList argList = method.argumentList;

    var e = ElementLocator.locateWithOffset(method, method.offset);
    if (!(e is ExecutableElement)) {
      return null;
    }
    ExecutableElement methodElement = e as ExecutableElement;
    // list of parameters associated with the method
    List<ParameterElement> parameters = methodElement.parameters;

    int index;
    if (emptyArguments) {
      index = 0;
    } else if (argument is NamedExpression) {
      NamedExpression namedArgument = argument;
      String nameOfArgument = namedArgument.name.label.toString();
      //check if we can find the namedArgument in the list of parameters
      try {
        var activeParameter = parameters.firstWhere(
                (parameter) => parameter.name == nameOfArgument);
        index = parameters.indexOf(activeParameter);
      } on StateError {
        index = null;
      }
      // if we can't find a match, index will be null
      // which means that the user has misspelled the named parameter
    } else if (argument is Expression){
      Expression arg = argument;
      // so if it is a positional argument
      if (arg.propagatedParameterElement == null && arg.staticParameterElement == null) {
        index = null;
      } else {
        index = argList.arguments.indexOf(argument);
      }
    }

    if (index != null && index >= parameters.length) {
      index = null;
    }

    return  {
      "name" : emptyArguments ? "" : argument.toString(),
      "kind" : index == null ? null : parameters[index].parameterKind.toString(),
      "indexActiveArgument" : index,
      "parameters" :  parameters.map((param) => '${param}').toList(),
      "lParenOffset" : argList.leftParenthesis.offset,
      "rParenOffset" : argList.rightParenthesis.offset,
    };
  }

  // TODO(lukechurch): Determine whether we can change this in the Analyzer.
  static String _prettifyElement(Element e) {
    String returnString = "${e}";
    returnString = returnString.replaceAll("Future<dynamic>", "Future");
    return returnString;
  }

  static String _prettifyType(DartType dt) {
    String returnString = "${dt}";
    returnString = returnString.replaceAll("Future<dynamic>", "Future");
    return returnString;
  }
}

/// An implementation of [Source] that is based on an in-memory string.
class StringSource implements Source {
  final String fullName;

  int _modificationStamp;
  String _contents;

  StringSource(this._contents, this.fullName)
      : _modificationStamp = new DateTime.now().millisecondsSinceEpoch;

  void updateSource(String newSource) {
    _contents = newSource;
    _modificationStamp = new DateTime.now().millisecondsSinceEpoch;
  }

  int get modificationStamp => _modificationStamp;

  bool operator==(Object object) {
    if (object is StringSource) {
      StringSource ssObject = object;
      return ssObject._contents == _contents && ssObject.fullName == fullName;
    }
    return false;
  }

  bool exists() => true;

  TimestampedData<String> get contents => new TimestampedData(modificationStamp, _contents);

  String get encoding => 'utf-8';

  String get shortName => fullName;

  UriKind get uriKind => UriKind.FILE_URI;

  int get hashCode => fullName.hashCode;

  bool get isInSystemLibrary => false;

  Uri get uri => throw new UnsupportedError("StringSource doesn't support uri.");

  Uri resolveRelativeUri(Uri relativeUri) =>
      throw new AnalysisException("Cannot resolve a URI: ${relativeUri}");

  @override
  Source get source => this;
}

class _Error {
  static final _HAS_FIXES_WHITELIST = [
    HintCode.UNUSED_IMPORT,
    ParserErrorCode.EXPECTED_TOKEN,
    StaticWarningCode.UNDEFINED_IDENTIFIER,
    StaticWarningCode.UNDEFINED_CLASS,
    StaticWarningCode.UNDEFINED_CLASS_BOOLEAN,
  ];

  final AnalysisError error;
  final LineInfo lineInfo;

  _Error(this.error, this.lineInfo);

  ErrorType get errorType => error.errorCode.type;
  String get severityName => error.errorCode.errorSeverity.displayName;
  String get message => error.message;

  int get line => lineInfo.getLocation(error.offset).lineNumber;
  int get offset => error.offset;
  int get length => error.length;

  String get location => error.source.fullName;

  /// Heurestic for whether there is going to be a fix offered for this
  /// issue
  bool get probablyHasFix => _HAS_FIXES_WHITELIST.contains(error.errorCode);

  String toString() => '${message} at ${location}, line ${line}.';
}

/**
 * Converts [str] from a Dartdoc string with slashes and stars to a plain text
 * representation of the comment.
 */
String cleanDartDoc(String str) {
  if (str == null) return null;

  // Remove /** */.
  str = str.trim();
  if (str.startsWith('/**')) str = str.substring(3);
  if (str.endsWith("*/")) str = str.substring(0, str.length - 2);
  str = str.trim();

  // Remove leading '* '.
  StringBuffer sb = new StringBuffer();
  bool firstLine = true;

  for (String line in str.split('\n')) {
    line = line.trim();

    // Remove leading '* ' and '///'; don't remove a leading '*' if there is a
    // matching '*' in the line.
    if (line.startsWith('* ')) {
      line = line.substring(2);
    } else if (line.startsWith("*") && line.lastIndexOf('*') == 0) {
      line = line.substring(1);
      if (line.startsWith(" ")) line = line.substring(1);
    } else if (line.startsWith("///")) {
      line = line.substring(3);
      if (line.startsWith(" ")) line = line.substring(1);
    }

    if (!firstLine) sb.write('\n');
    firstLine = false;
    sb.write(line);
  }

  return sb.toString();
}
