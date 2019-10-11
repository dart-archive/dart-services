// Synced 2019-05-30T14:20:57.803608.
import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_web/foundation.dart';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/rendering.dart';
import 'package:flutter_web_ui/ui.dart';
import 'package:flutter_web/services.dart';
import 'package:flutter_web_ui/ui.dart' as ui;
import 'package:meta/meta.dart';
import 'package:test_api/src/frontend/async_matcher.dart'; // ignore: implementation_imports
import 'package:test/test.dart' hide TypeMatcher;
import 'package:test/test.dart' as test_package show TypeMatcher;

import 'accessibility.dart';
import 'binding.dart';
import 'finders.dart';
import 'widget_tester.dart' show WidgetTester;

/// Asserts that the [Finder] matches no widgets in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNothing);
/// ```
///
/// See also:
///
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsNothing = _FindsWidgetMatcher(null, 0);

/// Asserts that the [Finder] locates at least one widget in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsWidgets);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsWidgets = _FindsWidgetMatcher(1, null);

/// Asserts that the [Finder] locates at exactly one widget in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsOneWidget);
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsNWidgets], when you want the finder to find a specific number of widgets.
const Matcher findsOneWidget = _FindsWidgetMatcher(1, 1);

/// Asserts that the [Finder] locates the specified number of widgets in the widget tree.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save'), findsNWidgets(2));
/// ```
///
/// See also:
///
///  * [findsNothing], when you want the finder to not find anything.
///  * [findsWidgets], when you want the finder to find one or more widgets.
///  * [findsOneWidget], when you want the finder to find exactly one widget.
Matcher findsNWidgets(int n) => _FindsWidgetMatcher(n, n);

/// Asserts that the [Finder] locates the a single widget that has at
/// least one [Offstage] widget ancestor.
///
/// It's important to use a full finder, since by default finders exclude
/// offstage widgets.
///
/// ## Sample code
///
/// ```dart
/// expect(find.text('Save', skipOffstage: false), isOffstage);
/// ```
///
/// See also:
///
///  * [isOnstage], the opposite.
const Matcher isOffstage = _IsOffstage();

/// Asserts that the [Finder] locates the a single widget that has no
/// [Offstage] widget ancestors.
///
/// See also:
///
///  * [isOffstage], the opposite.
const Matcher isOnstage = _IsOnstage();

/// Asserts that the [Finder] locates the a single widget that has at
/// least one [Card] widget ancestor.
///
/// See also:
///
///  * [isNotInCard], the opposite.
const Matcher isInCard = _IsInCard();

/// Asserts that the [Finder] locates the a single widget that has no
/// [Card] widget ancestors.
///
/// This is equivalent to `isNot(isInCard)`.
///
/// See also:
///
///  * [isInCard], the opposite.
const Matcher isNotInCard = _IsNotInCard();

/// Asserts that an object's toString() is a plausible one-line description.
///
/// Specifically, this matcher checks that the string does not contains newline
/// characters, and does not have leading or trailing whitespace, is not
/// empty, and does not contain the default `Instance of ...` string.
const Matcher hasOneLineDescription = _HasOneLineDescription();

/// Asserts that an object's toStringDeep() is a plausible multi-line
/// description.
///
/// Specifically, this matcher checks that an object's
/// `toStringDeep(prefixLineOne, prefixOtherLines)`:
///
///  * Does not have leading or trailing whitespace.
///  * Does not contain the default `Instance of ...` string.
///  * The last line has characters other than tree connector characters and
///    whitespace. For example: the line ` │ ║ ╎` has only tree connector
///    characters and whitespace.
///  * Does not contain lines with trailing white space.
///  * Has multiple lines.
///  * The first line starts with `prefixLineOne`
///  * All subsequent lines start with `prefixOtherLines`.
const Matcher hasAGoodToStringDeep = _HasGoodToStringDeep();

/// A matcher for functions that throw [FlutterError].
///
/// This is equivalent to `throwsA(isInstanceOf<FlutterError>())`.
///
/// If you are trying to test whether a call to [WidgetTester.pumpWidget]
/// results in a [FlutterError], see [TestWidgetsFlutterBinding.takeException].
///
/// See also:
///
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [throwsArgumentError], to test if a functions throws an [ArgumentError].
///  * [isFlutterError], to test if any object is a [FlutterError].
final Matcher throwsFlutterError = throwsA(isFlutterError);

/// A matcher for functions that throw [AssertionError].
///
/// This is equivalent to `throwsA(isInstanceOf<AssertionError>())`.
///
/// If you are trying to test whether a call to [WidgetTester.pumpWidget]
/// results in an [AssertionError], see
/// [TestWidgetsFlutterBinding.takeException].
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [throwsArgumentError], to test if a functions throws an [ArgumentError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
final Matcher throwsAssertionError = throwsA(isAssertionError);

/// A matcher for [FlutterError].
///
/// This is equivalent to `isInstanceOf<FlutterError>()`.
///
/// See also:
///
///  * [throwsFlutterError], to test if a function throws a [FlutterError].
///  * [isAssertionError], to test if any object is any kind of [AssertionError].
final Matcher isFlutterError = isInstanceOf<FlutterError>();

/// A matcher for [AssertionError].
///
/// This is equivalent to `isInstanceOf<AssertionError>()`.
///
/// See also:
///
///  * [throwsAssertionError], to test if a function throws any [AssertionError].
///  * [isFlutterError], to test if any object is a [FlutterError].
final Matcher isAssertionError = isInstanceOf<AssertionError>();

/// A matcher that compares the type of the actual value to the type argument T.
// TODO(ianh): Remove this once https://github.com/dart-lang/matcher/issues/98 is fixed
Matcher isInstanceOf<T>() => test_package.TypeMatcher<T>();

/// Asserts that two [double]s are equal, within some tolerated error.
///
/// Two values are considered equal if the difference between them is within
/// 1e-10 of the larger one. This is an arbitrary value which can be adjusted
/// using the `epsilon` argument. This matcher is intended to compare floating
/// point numbers that are the result of different sequences of operations, such
/// that they may have accumulated slightly different errors.
///
/// See also:
///
///  * [closeTo], which is identical except that the epsilon argument is
///    required and not named.
///  * [inInclusiveRange], which matches if the argument is in a specified
///    range.
Matcher moreOrLessEquals(double value, {double epsilon = 1e-10}) {
  return _MoreOrLessEquals(value, epsilon);
}

/// Asserts that two [Rect]s are equal, within some tolerated error.
///
/// Two values are considered equal if the difference between them is within
/// 1e-10 of the larger one. This is an arbitrary value which can be adjusted
/// using the `epsilon` argument. This matcher is intended to compare floating
/// point numbers that are the result of different sequences of operations, such
/// that they may have accumulated slightly different errors.
///
/// See also:
///
///  * [moreOrLessEquals], which is for [double]s.
///  * [within], which offers a generic version of this functionality that can
///    be used to match [Rect]s as well as other types.
Matcher rectMoreOrLessEquals(Rect value, { double epsilon = 1e-10 }) {
  return _IsWithinDistance<Rect>(_rectDistance, value, epsilon);
}

/// Asserts that two [String]s are equal after normalizing likely hash codes.
///
/// A `#` followed by 5 hexadecimal digits is assumed to be a short hash code
/// and is normalized to #00000.
///
/// See Also:
///
///  * [describeIdentity], a method that generates short descriptions of objects
///    with ids that match the pattern #[0-9a-f]{5}.
///  * [shortHash], a method that generates a 5 character long hexadecimal
///    [String] based on [Object.hashCode].
///  * [TreeDiagnosticsMixin.toStringDeep], a method that returns a [String]
///    typically containing multiple hash codes.
Matcher equalsIgnoringHashCodes(String value) {
  return _EqualsIgnoringHashCodes(value);
}

/// A matcher for [MethodCall]s, asserting that it has the specified
/// method [name] and [arguments].
///
/// Arguments checking implements deep equality for [List] and [Map] types.
Matcher isMethodCall(String name, {@required dynamic arguments}) {
  return _IsMethodCall(name, arguments);
}

/// Asserts that 2 paths cover the same area by sampling multiple points.
///
/// Samples at least [sampleSize]^2 points inside [areaToCompare], and asserts
/// that the [Path.contains] method returns the same value for each of the
/// points for both paths.
///
/// When using this matcher you typically want to use a rectangle larger than
/// the area you expect to paint in for [areaToCompare] to catch errors where
/// the path draws outside the expected area.
Matcher coversSameAreaAs(Path expectedPath,
        {@required Rect areaToCompare, int sampleSize = 20}) =>
    _CoversSameAreaAs(expectedPath,
        areaToCompare: areaToCompare, sampleSize: sampleSize);

/// Asserts that a [Finder], [Future<ui.Image>], or [ui.Image] matches the
/// golden image file identified by [key].
///
/// For the case of a [Finder], the [Finder] must match exactly one widget and
/// the rendered image of the first [RepaintBoundary] ancestor of the widget is
/// treated as the image for the widget.
///
/// [key] may be either a [Uri] or a [String] representation of a URI.
///
/// This is an asynchronous matcher, meaning that callers should use
/// [expectLater] when using this matcher and await the future returned by
/// [expectLater].
///
/// ## Sample code
///
/// ```dart
/// await expectLater(find.text('Save'), matchesGoldenFile('save.png'));
/// await expectLater(image, matchesGoldenFile('save.png'));
/// await expectLater(imageFuture, matchesGoldenFile('save.png'));
/// ```
///
/// See also:
///
///  * [goldenFileComparator], which acts as the backend for this matcher.
///  * [matchesReferenceImage], which should be used instead if you want to
///    verify that two different code paths create identical images.
///  * [flutter_test] for a discussion of test configurations, whereby callers
///    may swap out the backend for this matcher.
AsyncMatcher matchesGoldenFile(dynamic key, {int version}) {
  throw UnimplementedError('matchesGoldenFile is not yet supported on the Web');
}

/// Asserts that a [Finder], [Future<ui.Image>], or [ui.Image] matches a
/// reference image identified by [image].
///
/// For the case of a [Finder], the [Finder] must match exactly one widget and
/// the rendered image of the first [RepaintBoundary] ancestor of the widget is
/// treated as the image for the widget.
///
/// This is an asynchronous matcher, meaning that callers should use
/// [expectLater] when using this matcher and await the future returned by
/// [expectLater].
///
/// ## Sample code
///
/// ```dart
/// final ui.Paint paint = ui.Paint()
///   ..style = ui.PaintingStyle.stroke
///   ..strokeWidth = 1.0;
/// final ui.PictureRecorder recorder = ui.PictureRecorder();
/// final ui.Canvas pictureCanvas = ui.Canvas(recorder);
/// pictureCanvas.drawCircle(Offset.zero, 20.0, paint);
/// final ui.Picture picture = recorder.endRecording();
/// ui.Image referenceImage = picture.toImage(50, 50);
///
/// await expectLater(find.text('Save'), matchesReferenceImage(referenceImage));
/// await expectLater(image, matchesReferenceImage(referenceImage);
/// await expectLater(imageFuture, matchesReferenceImage(referenceImage));
/// ```
///
/// See also:
///
///  * [matchesGoldenFile], which should be used instead if you need to verify
///    that a [Finder] or [ui.Image] matches a golden image.
AsyncMatcher matchesReferenceImage(ui.Image image) {
  return _MatchesReferenceImage(image);
}

/// Asserts that a [SemanticsNode] contains the specified information.
///
/// If either the label, hint, value, textDirection, or rect fields are not
/// provided, then they are not part of the comparison.  All of the boolean
/// flag and action fields must match, and default to false.
///
/// To retrieve the semantics data of a widget, use [tester.getSemantics]
/// with a [Finder] that returns a single widget. Semantics must be enabled
/// in order to use this method.
///
/// ## Sample code
///
/// ```dart
/// final SemanticsHandle handle = tester.ensureSemantics();
/// expect(tester.getSemantics(find.text('hello')), matchesSemanticsNode(label: 'hello'));
/// handle.dispose();
/// ```
///
/// See also:
///
///   * [WidgetTester.getSemantics], the tester method which retrieves semantics.
Matcher matchesSemantics({
  String label,
  String hint,
  String value,
  String increasedValue,
  String decreasedValue,
  TextDirection textDirection,
  Rect rect,
  Size size,
  double elevation,
  double thickness,
  int platformViewId,
  // Flags //
  bool hasCheckedState = false,
  bool isChecked = false,
  bool isSelected = false,
  bool isButton = false,
  bool isFocused = false,
  bool isTextField = false,
  bool hasEnabledState = false,
  bool isEnabled = false,
  bool isInMutuallyExclusiveGroup = false,
  bool isHeader = false,
  bool isObscured = false,
  bool namesRoute = false,
  bool scopesRoute = false,
  bool isHidden = false,
  bool isImage = false,
  bool isLiveRegion = false,
  bool hasToggledState = false,
  bool isToggled = false,
  bool hasImplicitScrolling = false,
  // Actions //
  bool hasTapAction = false,
  bool hasLongPressAction = false,
  bool hasScrollLeftAction = false,
  bool hasScrollRightAction = false,
  bool hasScrollUpAction = false,
  bool hasScrollDownAction = false,
  bool hasIncreaseAction = false,
  bool hasDecreaseAction = false,
  bool hasShowOnScreenAction = false,
  bool hasMoveCursorForwardByCharacterAction = false,
  bool hasMoveCursorBackwardByCharacterAction = false,
  bool hasMoveCursorForwardByWordAction = false,
  bool hasMoveCursorBackwardByWordAction = false,
  bool hasSetSelectionAction = false,
  bool hasCopyAction = false,
  bool hasCutAction = false,
  bool hasPasteAction = false,
  bool hasDidGainAccessibilityFocusAction = false,
  bool hasDidLoseAccessibilityFocusAction = false,
  bool hasDismissAction = false,
  // Custom actions and overrides
  String onTapHint,
  String onLongPressHint,
  List<CustomSemanticsAction> customActions,
  List<Matcher> children,
}) {
  final List<SemanticsFlag> flags = <SemanticsFlag>[];
  if (hasCheckedState) flags.add(SemanticsFlag.hasCheckedState);
  if (isChecked) flags.add(SemanticsFlag.isChecked);
  if (isSelected) flags.add(SemanticsFlag.isSelected);
  if (isButton) flags.add(SemanticsFlag.isButton);
  if (isTextField) flags.add(SemanticsFlag.isTextField);
  if (isFocused) flags.add(SemanticsFlag.isFocused);
  if (hasEnabledState) flags.add(SemanticsFlag.hasEnabledState);
  if (isEnabled) flags.add(SemanticsFlag.isEnabled);
  if (isInMutuallyExclusiveGroup)
    flags.add(SemanticsFlag.isInMutuallyExclusiveGroup);
  if (isHeader) flags.add(SemanticsFlag.isHeader);
  if (isObscured) flags.add(SemanticsFlag.isObscured);
  if (namesRoute) flags.add(SemanticsFlag.namesRoute);
  if (scopesRoute) flags.add(SemanticsFlag.scopesRoute);
  if (isHidden) flags.add(SemanticsFlag.isHidden);
  if (isImage) flags.add(SemanticsFlag.isImage);
  if (isLiveRegion) flags.add(SemanticsFlag.isLiveRegion);
  if (hasToggledState) flags.add(SemanticsFlag.hasToggledState);
  if (isToggled) flags.add(SemanticsFlag.isToggled);
  if (hasImplicitScrolling) flags.add(SemanticsFlag.hasImplicitScrolling);

  final List<SemanticsAction> actions = <SemanticsAction>[];
  if (hasTapAction) actions.add(SemanticsAction.tap);
  if (hasLongPressAction) actions.add(SemanticsAction.longPress);
  if (hasScrollLeftAction) actions.add(SemanticsAction.scrollLeft);
  if (hasScrollRightAction) actions.add(SemanticsAction.scrollRight);
  if (hasScrollUpAction) actions.add(SemanticsAction.scrollUp);
  if (hasScrollDownAction) actions.add(SemanticsAction.scrollDown);
  if (hasIncreaseAction) actions.add(SemanticsAction.increase);
  if (hasDecreaseAction) actions.add(SemanticsAction.decrease);
  if (hasShowOnScreenAction) actions.add(SemanticsAction.showOnScreen);
  if (hasMoveCursorForwardByCharacterAction)
    actions.add(SemanticsAction.moveCursorForwardByCharacter);
  if (hasMoveCursorBackwardByCharacterAction)
    actions.add(SemanticsAction.moveCursorBackwardByCharacter);
  if (hasSetSelectionAction) actions.add(SemanticsAction.setSelection);
  if (hasCopyAction) actions.add(SemanticsAction.copy);
  if (hasCutAction) actions.add(SemanticsAction.cut);
  if (hasPasteAction) actions.add(SemanticsAction.paste);
  if (hasDidGainAccessibilityFocusAction)
    actions.add(SemanticsAction.didGainAccessibilityFocus);
  if (hasDidLoseAccessibilityFocusAction)
    actions.add(SemanticsAction.didLoseAccessibilityFocus);
  if (customActions != null && customActions.isNotEmpty)
    actions.add(SemanticsAction.customAction);
  if (hasDismissAction) actions.add(SemanticsAction.dismiss);
  if (hasMoveCursorForwardByWordAction)
    actions.add(SemanticsAction.moveCursorForwardByWord);
  if (hasMoveCursorBackwardByWordAction)
    actions.add(SemanticsAction.moveCursorBackwardByWord);
  SemanticsHintOverrides hintOverrides;
  if (onTapHint != null || onLongPressHint != null)
    hintOverrides = SemanticsHintOverrides(
      onTapHint: onTapHint,
      onLongPressHint: onLongPressHint,
    );

  return _MatchesSemanticsData(
    label: label,
    hint: hint,
    value: value,
    increasedValue: increasedValue,
    decreasedValue: decreasedValue,
    actions: actions,
    flags: flags,
    textDirection: textDirection,
    rect: rect,
    size: size,
    elevation: elevation,
    thickness: thickness,
    platformViewId: platformViewId,
    customActions: customActions,
    hintOverrides: hintOverrides,
    children: children,
  );
}

/// Asserts that the currently rendered widget meets the provided accessibility
/// `guideline`.
///
/// This matcher requires the result to be awaited and for semantics to be
/// enabled first.
///
/// ## Sample code
///
/// ```dart
/// final SemanticsHandle handle = tester.ensureSemantics();
/// await meetsGuideline(tester, meetsGuideline(textContrastGuideline));
/// handle.dispose();
/// ```
///
/// Supported accessibility guidelines:
///
///   * [androidTapTargetGuideline], for Android minimum tapable area guidelines.
///   * [iOSTapTargetGuideline], for iOS minimum tapable area guidelines.
///   * [textContrastGuideline], for WCAG minimum text contrast guidelines.
AsyncMatcher meetsGuideline(AccessibilityGuideline guideline) {
  return _MatchesAccessibilityGuideline(guideline);
}

/// The inverse matcher of [meetsGuideline].
///
/// This is needed because the [isNot] matcher does not compose with an
/// [AsyncMatcher].
AsyncMatcher doesNotMeetGuideline(AccessibilityGuideline guideline) {
  return _DoesNotMatchAccessibilityGuideline(guideline);
}

class _FindsWidgetMatcher extends Matcher {
  const _FindsWidgetMatcher(this.min, this.max);

  final int min;
  final int max;

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    assert(min != null || max != null);
    assert(min == null || max == null || min <= max);
    matchState[Finder] = finder;
    int count = 0;
    final Iterator<Element> iterator = finder.evaluate().iterator;
    if (min != null) {
      while (count < min && iterator.moveNext()) count += 1;
      if (count < min) return false;
    }
    if (max != null) {
      while (count <= max && iterator.moveNext()) count += 1;
      if (count > max) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    assert(min != null || max != null);
    if (min == max) {
      if (min == 1)
        return description.add('exactly one matching node in the widget tree');
      return description.add('exactly $min matching nodes in the widget tree');
    }
    if (min == null) {
      if (max == 0)
        return description.add('no matching nodes in the widget tree');
      if (max == 1)
        return description.add('at most one matching node in the widget tree');
      return description.add('at most $max matching nodes in the widget tree');
    }
    if (max == null) {
      if (min == 1)
        return description.add('at least one matching node in the widget tree');
      return description.add('at least $min matching nodes in the widget tree');
    }
    return description.add(
        'between $min and $max matching nodes in the widget tree (inclusive)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    final Finder finder = matchState[Finder];
    final int count = finder.evaluate().length;
    if (count == 0) {
      assert(min != null && min > 0);
      if (min == 1 && max == 1)
        return mismatchDescription
            .add('means none were found but one was expected');
      return mismatchDescription
          .add('means none were found but some were expected');
    }
    if (max == 0) {
      if (count == 1)
        return mismatchDescription
            .add('means one was found but none were expected');
      return mismatchDescription
          .add('means some were found but none were expected');
    }
    if (min != null && count < min)
      return mismatchDescription.add('is not enough');
    assert(max != null && count > min);
    return mismatchDescription.add('is too many');
  }
}

bool _hasAncestorMatching(Finder finder, bool predicate(Widget widget)) {
  final Iterable<Element> nodes = finder.evaluate();
  if (nodes.length != 1) return false;
  bool result = false;
  nodes.single.visitAncestorElements((Element ancestor) {
    if (predicate(ancestor.widget)) {
      result = true;
      return false;
    }
    return true;
  });
  return result;
}

bool _hasAncestorOfType(Finder finder, Type targetType) {
  return _hasAncestorMatching(
      finder, (Widget widget) => widget.runtimeType == targetType);
}

class _IsOffstage extends Matcher {
  const _IsOffstage();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    return _hasAncestorMatching(finder, (Widget widget) {
      if (widget is Offstage) return widget.offstage;
      return false;
    });
  }

  @override
  Description describe(Description description) => description.add('offstage');
}

class _IsOnstage extends Matcher {
  const _IsOnstage();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    final Iterable<Element> nodes = finder.evaluate();
    if (nodes.length != 1) return false;
    bool result = true;
    nodes.single.visitAncestorElements((Element ancestor) {
      final Widget widget = ancestor.widget;
      if (widget is Offstage) {
        result = !widget.offstage;
        return false;
      }
      return true;
    });
    return result;
  }

  @override
  Description describe(Description description) => description.add('onstage');
}

class _IsInCard extends Matcher {
  const _IsInCard();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) =>
      _hasAncestorOfType(finder, Card);

  @override
  Description describe(Description description) => description.add('in card');
}

class _IsNotInCard extends Matcher {
  const _IsNotInCard();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) =>
      !_hasAncestorOfType(finder, Card);

  @override
  Description describe(Description description) =>
      description.add('not in card');
}

class _HasOneLineDescription extends Matcher {
  const _HasOneLineDescription();

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    final String description = object.toString();
    return description.isNotEmpty &&
        !description.contains('\n') &&
        !description.contains('Instance of ') &&
        description.trim() == description;
  }

  @override
  Description describe(Description description) =>
      description.add('one line description');
}

class _EqualsIgnoringHashCodes extends Matcher {
  _EqualsIgnoringHashCodes(String v) : _value = _normalize(v);

  final String _value;

  static final Object _mismatchedValueKey = Object();

  // TODO(flutter_web): upstream so that uppercase ending runtimeType is
  // correctly matched.
  static String _normalize(String s) {
    return s.replaceAll(RegExp(r'#[0-9a-fA-F]{5}'), '#00000');
  }

  @override
  bool matches(dynamic object, Map<dynamic, dynamic> matchState) {
    final String description = _normalize(object);
    if (_value != description) {
      matchState[_mismatchedValueKey] = description;
      return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('multi line description equals $_value');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (matchState.containsKey(_mismatchedValueKey)) {
      final String actualValue = matchState[_mismatchedValueKey];
      // Leading whitespace is added so that lines in the multi-line
      // description returned by addDescriptionOf are all indented equally
      // which makes the output easier to read for this case.

      // TODO(flutter_web): upstream Mismatch snippet to flutter.
      int valueLength = _value.length;
      int actualLength = actualValue.length;
      int i = 0;
      for (; i < valueLength && i < actualLength; i++) {
        if (_value[i] != actualValue[i]) {
          break;
        }
      }
      if (i < valueLength && i < actualLength) {
        const int snippetLength = 20;
        int len = math.min(
            math.min(valueLength - i, actualLength - i), snippetLength);
        String before = _EqualsIgnoringHashCodes._normalize(_value.substring(i, i + len));
        String after = _EqualsIgnoringHashCodes._normalize(actualValue.substring(i, i + len));
        mismatchDescription.add('Mismatch at offset $i '
            '[$before] => '
            '[$after]');
      }
      return mismatchDescription
          .add('expected normalized value\n  ')
          .addDescriptionOf(_value)
          .add('\nbut got\n  ')
          .addDescriptionOf(actualValue);
    }
    return mismatchDescription;
  }
}

/// Returns true if [c] represents a whitespace code unit.
bool _isWhitespace(int c) => (c <= 0x000D && c >= 0x0009) || c == 0x0020;

/// Returns true if [c] represents a vertical line Unicode line art code unit.
///
/// See [https://en.wikipedia.org/wiki/Box-drawing_character]. This method only
/// specifies vertical line art code units currently used by Flutter line art.
/// There are other line art characters that technically also represent vertical
/// lines.
bool _isVerticalLine(int c) {
  return c == 0x2502 || c == 0x2503 || c == 0x2551 || c == 0x254e;
}

/// Returns whether a [line] is all vertical tree connector characters.
///
/// Example vertical tree connector characters: `│ ║ ╎`.
/// The last line of a text tree contains only vertical tree connector
/// characters indicates a poorly formatted tree.
bool _isAllTreeConnectorCharacters(String line) {
  for (int i = 0; i < line.length; ++i) {
    final int c = line.codeUnitAt(i);
    if (!_isWhitespace(c) && !_isVerticalLine(c)) return false;
  }
  return true;
}

class _HasGoodToStringDeep extends Matcher {
  const _HasGoodToStringDeep();

  static final Object _toStringDeepErrorDescriptionKey = Object();

  @override
  bool matches(dynamic object, Map<dynamic, dynamic> matchState) {
    final List<String> issues = <String>[];
    String description = object.toStringDeep();
    if (description.endsWith('\n')) {
      // Trim off trailing \n as the remaining calculations assume
      // the description does not end with a trailing \n.
      description = description.substring(0, description.length - 1);
    } else {
      issues.add('Not terminated with a line break.');
    }

    if (description.trim() != description)
      issues.add('Has trailing whitespace.');

    final List<String> lines = description.split('\n');
    if (lines.length < 2) issues.add('Does not have multiple lines.');

    if (description.contains('Instance of '))
      issues.add('Contains text "Instance of ".');

    for (int i = 0; i < lines.length; ++i) {
      final String line = lines[i];
      if (line.isEmpty) issues.add('Line ${i + 1} is empty.');

      if (line.trimRight() != line)
        issues.add('Line ${i + 1} has trailing whitespace.');
    }

    if (_isAllTreeConnectorCharacters(lines.last))
      issues.add('Last line is all tree connector characters.');

    // If a toStringDeep method doesn't properly handle nested values that
    // contain line breaks it can fail to add the required prefixes to all
    // lined when toStringDeep is called specifying prefixes.
    const String prefixLineOne = 'PREFIX_LINE_ONE____';
    const String prefixOtherLines = 'PREFIX_OTHER_LINES_';
    final List<String> prefixIssues = <String>[];
    String descriptionWithPrefixes = object.toStringDeep(
        prefixLineOne: prefixLineOne, prefixOtherLines: prefixOtherLines);
    if (descriptionWithPrefixes.endsWith('\n')) {
      // Trim off trailing \n as the remaining calculations assume
      // the description does not end with a trailing \n.
      descriptionWithPrefixes = descriptionWithPrefixes.substring(
          0, descriptionWithPrefixes.length - 1);
    }
    final List<String> linesWithPrefixes = descriptionWithPrefixes.split('\n');
    if (!linesWithPrefixes.first.startsWith(prefixLineOne))
      prefixIssues.add('First line does not contain expected prefix.');

    for (int i = 1; i < linesWithPrefixes.length; ++i) {
      if (!linesWithPrefixes[i].startsWith(prefixOtherLines))
        prefixIssues.add('Line ${i + 1} does not contain the expected prefix.');
    }

    final StringBuffer errorDescription = StringBuffer();
    if (issues.isNotEmpty) {
      errorDescription.writeln('Bad toStringDeep():');
      errorDescription.writeln(description);
      errorDescription.writeAll(issues, '\n');
    }

    if (prefixIssues.isNotEmpty) {
      errorDescription.writeln(
          'Bad toStringDeep(prefixLineOne: "$prefixLineOne", prefixOtherLines: "$prefixOtherLines"):');
      errorDescription.writeln(descriptionWithPrefixes);
      errorDescription.writeAll(prefixIssues, '\n');
    }

    if (errorDescription.isNotEmpty) {
      matchState[_toStringDeepErrorDescriptionKey] =
          errorDescription.toString();
      return false;
    }
    return true;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (matchState.containsKey(_toStringDeepErrorDescriptionKey)) {
      return mismatchDescription
          .add(matchState[_toStringDeepErrorDescriptionKey]);
    }
    return mismatchDescription;
  }

  @override
  Description describe(Description description) {
    return description.add('multi line description');
  }
}

/// Computes the distance between two values.
///
/// The distance should be a metric in a metric space (see
/// https://en.wikipedia.org/wiki/Metric_space). Specifically, if `f` is a
/// distance function then the following conditions should hold:
///
/// - f(a, b) >= 0
/// - f(a, b) == 0 if and only if a == b
/// - f(a, b) == f(b, a)
/// - f(a, c) <= f(a, b) + f(b, c), known as triangle inequality
///
/// This makes it useful for comparing numbers, [Color]s, [Offset]s and other
/// sets of value for which a metric space is defined.
typedef DistanceFunction<T> = num Function(T a, T b);

/// The type of a union of instances of [DistanceFunction<T>] for various types
/// T.
///
/// This type is used to describe a collection of [DistanceFunction<T>]
/// functions which have (potentially) unrelated argument types. Since the
/// argument types of the functions may be unrelated, the only thing that the
/// type system can statically assume about them is that they accept null (since
/// all types in Dart are nullable).
///
/// Calling an instance of this type must either be done dynamically, or by
/// first casting it to a [DistanceFunction<T>] for some concrete T.
typedef AnyDistanceFunction = num Function(Null a, Null b);

const Map<Type, AnyDistanceFunction> _kStandardDistanceFunctions =
    <Type, AnyDistanceFunction>{
  Color: _maxComponentColorDistance,
  HSVColor: _maxComponentHSVColorDistance,
  HSLColor: _maxComponentHSLColorDistance,
  Offset: _offsetDistance,
  int: _intDistance,
  double: _doubleDistance,
  Rect: _rectDistance,
  Size: _sizeDistance,
};

int _intDistance(int a, int b) => (b - a).abs();
double _doubleDistance(double a, double b) => (b - a).abs();
double _offsetDistance(Offset a, Offset b) => (b - a).distance;

double _maxComponentColorDistance(Color a, Color b) {
  int delta = math.max<int>((a.red - b.red).abs(), (a.green - b.green).abs());
  delta = math.max<int>(delta, (a.blue - b.blue).abs());
  delta = math.max<int>(delta, (a.alpha - b.alpha).abs());
  return delta.toDouble();
}

// Compares hue by converting it to a 0.0 - 1.0 range, so that the comparison
// can be a similar error percentage per component.
double _maxComponentHSVColorDistance(HSVColor a, HSVColor b) {
  double delta = math.max<double>(
      (a.saturation - b.saturation).abs(), (a.value - b.value).abs());
  delta = math.max<double>(delta, ((a.hue - b.hue) / 360.0).abs());
  return math.max<double>(delta, (a.alpha - b.alpha).abs());
}

// Compares hue by converting it to a 0.0 - 1.0 range, so that the comparison
// can be a similar error percentage per component.
double _maxComponentHSLColorDistance(HSLColor a, HSLColor b) {
  double delta = math.max<double>(
      (a.saturation - b.saturation).abs(), (a.lightness - b.lightness).abs());
  delta = math.max<double>(delta, ((a.hue - b.hue) / 360.0).abs());
  return math.max<double>(delta, (a.alpha - b.alpha).abs());
}

double _rectDistance(Rect a, Rect b) {
  double delta =
      math.max<double>((a.left - b.left).abs(), (a.top - b.top).abs());
  delta = math.max<double>(delta, (a.right - b.right).abs());
  delta = math.max<double>(delta, (a.bottom - b.bottom).abs());
  return delta;
}

double _sizeDistance(Size a, Size b) {
  final Offset delta = b - a;
  return delta.distance;
}

/// Asserts that two values are within a certain distance from each other.
///
/// The distance is computed by a [DistanceFunction].
///
/// If `distanceFunction` is null, a standard distance function is used for the
/// `runtimeType` of the `from` argument. Standard functions are defined for
/// the following types:
///
///  * [Color], whose distance is the maximum component-wise delta.
///  * [Offset], whose distance is the Euclidean distance computed using the
///    method [Offset.distance].
///  * [Rect], whose distance is the maximum component-wise delta.
///  * [Size], whose distance is the [Offset.distance] of the offset computed as
///    the difference between two sizes.
///  * [int], whose distance is the absolute difference between two integers.
///  * [double], whose distance is the absolute difference between two doubles.
///
/// See also:
///
///  * [moreOrLessEquals], which is similar to this function, but specializes in
///    [double]s and has an optional `epsilon` parameter.
///  * [rectMoreOrLessEquals], which is similar to this function, but
///    specializes in [Rect]s and has an optional `epsilon` parameter.
///  * [closeTo], which specializes in numbers only.
Matcher within<T>({
  @required num distance,
  @required T from,
  DistanceFunction<T> distanceFunction,
}) {
  distanceFunction ??= _kStandardDistanceFunctions[from.runtimeType];

  if (distanceFunction == null) {
    throw ArgumentError(
        'The specified distanceFunction was null, and a standard distance '
        'function was not found for type ${from.runtimeType} of the provided '
        '`from` argument.');
  }

  return _IsWithinDistance<T>(distanceFunction, from, distance);
}

class _IsWithinDistance<T> extends Matcher {
  const _IsWithinDistance(this.distanceFunction, this.value, this.epsilon);

  final DistanceFunction<T> distanceFunction;
  final T value;
  final num epsilon;

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    if (object is! T) return false;
    if (object == value) return true;
    final T test = object;
    final num distance = distanceFunction(test, value);
    if (distance < 0) {
      throw ArgumentError(
          'Invalid distance function was used to compare a ${value.runtimeType} '
          'to a ${object.runtimeType}. The function must return a non-negative '
          'double value, but it returned $distance.');
    }
    matchState['distance'] = distance;
    return distance <= epsilon;
  }

  @override
  Description describe(Description description) =>
      description.add('$value (±$epsilon)');

  @override
  Description describeMismatch(
    Object object,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    mismatchDescription
        .add('was ${matchState['distance']} away from the desired value.');
    return mismatchDescription;
  }
}

class _MoreOrLessEquals extends Matcher {
  const _MoreOrLessEquals(this.value, this.epsilon);

  final double value;
  final double epsilon;

  @override
  bool matches(Object object, Map<dynamic, dynamic> matchState) {
    if (object is! double) return false;
    if (object == value) return true;
    final double test = object;
    return (test - value).abs() <= epsilon;
  }

  @override
  Description describe(Description description) =>
      description.add('$value (±$epsilon)');
}

class _IsMethodCall extends Matcher {
  const _IsMethodCall(this.name, this.arguments);

  final String name;
  final dynamic arguments;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    if (item is! MethodCall) return false;
    if (item.method != name) return false;
    return _deepEquals(item.arguments, arguments);
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is List) return b is List && _deepEqualsList(a, b);
    if (a is Map) return b is Map && _deepEqualsMap(a, b);
    return false;
  }

  bool _deepEqualsList(List<dynamic> a, List<dynamic> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }

  bool _deepEqualsMap(Map<dynamic, dynamic> a, Map<dynamic, dynamic> b) {
    if (a.length != b.length) return false;
    for (dynamic key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description
        .add('has method name: ')
        .addDescriptionOf(name)
        .add(' with arguments: ')
        .addDescriptionOf(arguments);
  }
}

/// Asserts that a [Finder] locates a single object whose root RenderObject
/// is a [RenderClipRect] with no clipper set, or an equivalent
/// [RenderClipPath].
const Matcher clipsWithBoundingRect = _ClipsWithBoundingRect();

/// Asserts that a [Finder] locates a single object whose root RenderObject is
/// not a [RenderClipRect], [RenderClipRRect], [RenderClipOval], or
/// [RenderClipPath].
const Matcher hasNoImmediateClip = _MatchAnythingExceptClip();

/// Asserts that a [Finder] locates a single object whose root RenderObject
/// is a [RenderClipRRect] with no clipper set, and border radius equals to
/// [borderRadius], or an equivalent [RenderClipPath].
Matcher clipsWithBoundingRRect({@required BorderRadius borderRadius}) {
  return _ClipsWithBoundingRRect(borderRadius: borderRadius);
}

/// Asserts that a [Finder] locates a single object whose root RenderObject
/// is a [RenderClipPath] with a [ShapeBorderClipper] that clips to
/// [shape].
Matcher clipsWithShapeBorder({@required ShapeBorder shape}) {
  return _ClipsWithShapeBorder(shape: shape);
}

/// Asserts that a [Finder] locates a single object whose root RenderObject
/// is a [RenderPhysicalModel] or a [RenderPhysicalShape].
///
/// - If the render object is a [RenderPhysicalModel]
///    - If [shape] is non null asserts that [RenderPhysicalModel.shape] is equal to
///   [shape].
///    - If [borderRadius] is non null asserts that [RenderPhysicalModel.borderRadius] is equal to
///   [borderRadius].
///     - If [elevation] is non null asserts that [RenderPhysicalModel.elevation] is equal to
///   [elevation].
/// - If the render object is a [RenderPhysicalShape]
///    - If [borderRadius] is non null asserts that the shape is a rounded
///   rectangle with this radius.
///    - If [borderRadius] is null, asserts that the shape is equivalent to
///   [shape].
///    - If [elevation] is non null asserts that [RenderPhysicalModel.elevation] is equal to
///   [elevation].
Matcher rendersOnPhysicalModel({
  BoxShape shape,
  BorderRadius borderRadius,
  double elevation,
}) {
  return _RendersOnPhysicalModel(
    shape: shape,
    borderRadius: borderRadius,
    elevation: elevation,
  );
}

/// Asserts that a [Finder] locates a single object whose root RenderObject
/// is [RenderPhysicalShape] that uses a [ShapeBorderClipper] that clips to
/// [shape] as its clipper.
/// If [elevation] is non null asserts that [RenderPhysicalShape.elevation] is
/// equal to [elevation].
Matcher rendersOnPhysicalShape({
  ShapeBorder shape,
  double elevation,
}) {
  return _RendersOnPhysicalShape(
    shape: shape,
    elevation: elevation,
  );
}

abstract class _FailWithDescriptionMatcher extends Matcher {
  const _FailWithDescriptionMatcher();

  bool failWithDescription(
      Map<dynamic, dynamic> matchState, String description) {
    matchState['failure'] = description;
    return false;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(matchState['failure']);
  }
}

class _MatchAnythingExceptClip extends _FailWithDescriptionMatcher {
  const _MatchAnythingExceptClip();

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    final Iterable<Element> nodes = finder.evaluate();
    if (nodes.length != 1)
      return failWithDescription(
          matchState, 'did not have a exactly one child element');
    final RenderObject renderObject = nodes.single.renderObject;

    switch (renderObject.runtimeType) {
      case RenderClipPath:
      case RenderClipOval:
      case RenderClipRect:
      case RenderClipRRect:
        return failWithDescription(matchState,
            'had a root render object of type: ${renderObject.runtimeType}');
      default:
        return true;
    }
  }

  @override
  Description describe(Description description) {
    return description.add('does not have a clip as an immediate child');
  }
}

abstract class _MatchRenderObject<M extends RenderObject,
    T extends RenderObject> extends _FailWithDescriptionMatcher {
  const _MatchRenderObject();

  bool renderObjectMatchesT(Map<dynamic, dynamic> matchState, T renderObject);
  bool renderObjectMatchesM(Map<dynamic, dynamic> matchState, M renderObject);

  @override
  bool matches(covariant Finder finder, Map<dynamic, dynamic> matchState) {
    final Iterable<Element> nodes = finder.evaluate();
    if (nodes.length != 1)
      return failWithDescription(
          matchState, 'did not have a exactly one child element');
    final RenderObject renderObject = nodes.single.renderObject;

    if (renderObject.runtimeType == T)
      return renderObjectMatchesT(matchState, renderObject);

    if (renderObject.runtimeType == M)
      return renderObjectMatchesM(matchState, renderObject);

    return failWithDescription(matchState,
        'had a root render object of type: ${renderObject.runtimeType}');
  }
}

class _RendersOnPhysicalModel
    extends _MatchRenderObject<RenderPhysicalShape, RenderPhysicalModel> {
  const _RendersOnPhysicalModel({
    this.shape,
    this.borderRadius,
    this.elevation,
  });

  final BoxShape shape;
  final BorderRadius borderRadius;
  final double elevation;

  @override
  bool renderObjectMatchesT(
      Map<dynamic, dynamic> matchState, RenderPhysicalModel renderObject) {
    if (shape != null && renderObject.shape != shape)
      return failWithDescription(
          matchState, 'had shape: ${renderObject.shape}');

    if (borderRadius != null && renderObject.borderRadius != borderRadius)
      return failWithDescription(
          matchState, 'had borderRadius: ${renderObject.borderRadius}');

    if (elevation != null && renderObject.elevation != elevation)
      return failWithDescription(
          matchState, 'had elevation: ${renderObject.elevation}');

    return true;
  }

  @override
  bool renderObjectMatchesM(
      Map<dynamic, dynamic> matchState, RenderPhysicalShape renderObject) {
    if (renderObject.clipper.runtimeType != ShapeBorderClipper)
      return failWithDescription(
          matchState, 'clipper was: ${renderObject.clipper}');
    final ShapeBorderClipper shapeClipper = renderObject.clipper;

    if (borderRadius != null &&
        !assertRoundedRectangle(shapeClipper, borderRadius, matchState))
      return false;

    if (borderRadius == null &&
        shape == BoxShape.rectangle &&
        !assertRoundedRectangle(shapeClipper, BorderRadius.zero, matchState)) {
      return false;
    }

    if (borderRadius == null &&
        shape == BoxShape.circle &&
        !assertCircle(shapeClipper, matchState)) {
      return false;
    }

    if (elevation != null && renderObject.elevation != elevation)
      return failWithDescription(
          matchState, 'had elevation: ${renderObject.elevation}');

    return true;
  }

  bool assertRoundedRectangle(ShapeBorderClipper shapeClipper,
      BorderRadius borderRadius, Map<dynamic, dynamic> matchState) {
    if (shapeClipper.shape.runtimeType != RoundedRectangleBorder)
      return failWithDescription(
          matchState, 'had shape border: ${shapeClipper.shape}');
    final RoundedRectangleBorder border = shapeClipper.shape;
    if (border.borderRadius != borderRadius)
      return failWithDescription(
          matchState, 'had borderRadius: ${border.borderRadius}');
    return true;
  }

  bool assertCircle(
      ShapeBorderClipper shapeClipper, Map<dynamic, dynamic> matchState) {
    if (shapeClipper.shape.runtimeType != CircleBorder)
      return failWithDescription(
          matchState, 'had shape border: ${shapeClipper.shape}');
    return true;
  }

  @override
  Description describe(Description description) {
    description.add('renders on a physical model');
    if (shape != null) description.add(' with shape $shape');
    if (borderRadius != null)
      description.add(' with borderRadius $borderRadius');
    if (elevation != null) description.add(' with elevation $elevation');
    return description;
  }
}

class _RendersOnPhysicalShape
    extends _MatchRenderObject<RenderPhysicalShape, RenderPhysicalModel> {
  const _RendersOnPhysicalShape({
    this.shape,
    this.elevation,
  });

  final ShapeBorder shape;
  final double elevation;

  @override
  bool renderObjectMatchesM(
      Map<dynamic, dynamic> matchState, RenderPhysicalShape renderObject) {
    if (renderObject.clipper.runtimeType != ShapeBorderClipper)
      return failWithDescription(
          matchState, 'clipper was: ${renderObject.clipper}');
    final ShapeBorderClipper shapeClipper = renderObject.clipper;

    if (shapeClipper.shape != shape)
      return failWithDescription(
          matchState, 'shape was: ${shapeClipper.shape}');

    if (elevation != null && renderObject.elevation != elevation)
      return failWithDescription(
          matchState, 'had elevation: ${renderObject.elevation}');

    return true;
  }

  @override
  bool renderObjectMatchesT(
      Map<dynamic, dynamic> matchState, RenderPhysicalModel renderObject) {
    return false;
  }

  @override
  Description describe(Description description) {
    description.add('renders on a physical model with shape $shape');
    if (elevation != null) description.add(' with elevation $elevation');
    return description;
  }
}

class _ClipsWithBoundingRect
    extends _MatchRenderObject<RenderClipPath, RenderClipRect> {
  const _ClipsWithBoundingRect();

  @override
  bool renderObjectMatchesT(
      Map<dynamic, dynamic> matchState, RenderClipRect renderObject) {
    if (renderObject.clipper != null)
      return failWithDescription(
          matchState, 'had a non null clipper ${renderObject.clipper}');
    return true;
  }

  @override
  bool renderObjectMatchesM(
      Map<dynamic, dynamic> matchState, RenderClipPath renderObject) {
    if (renderObject.clipper.runtimeType != ShapeBorderClipper)
      return failWithDescription(
          matchState, 'clipper was: ${renderObject.clipper}');
    final ShapeBorderClipper shapeClipper = renderObject.clipper;
    if (shapeClipper.shape.runtimeType != RoundedRectangleBorder)
      return failWithDescription(
          matchState, 'shape was: ${shapeClipper.shape}');
    final RoundedRectangleBorder border = shapeClipper.shape;
    if (border.borderRadius != BorderRadius.zero)
      return failWithDescription(
          matchState, 'borderRadius was: ${border.borderRadius}');
    return true;
  }

  @override
  Description describe(Description description) =>
      description.add('clips with bounding rectangle');
}

class _ClipsWithBoundingRRect
    extends _MatchRenderObject<RenderClipPath, RenderClipRRect> {
  const _ClipsWithBoundingRRect({@required this.borderRadius});

  final BorderRadius borderRadius;

  @override
  bool renderObjectMatchesT(
      Map<dynamic, dynamic> matchState, RenderClipRRect renderObject) {
    if (renderObject.clipper != null)
      return failWithDescription(
          matchState, 'had a non null clipper ${renderObject.clipper}');

    if (renderObject.borderRadius != borderRadius)
      return failWithDescription(
          matchState, 'had borderRadius: ${renderObject.borderRadius}');

    return true;
  }

  @override
  bool renderObjectMatchesM(
      Map<dynamic, dynamic> matchState, RenderClipPath renderObject) {
    if (renderObject.clipper.runtimeType != ShapeBorderClipper)
      return failWithDescription(
          matchState, 'clipper was: ${renderObject.clipper}');
    final ShapeBorderClipper shapeClipper = renderObject.clipper;
    if (shapeClipper.shape.runtimeType != RoundedRectangleBorder)
      return failWithDescription(
          matchState, 'shape was: ${shapeClipper.shape}');
    final RoundedRectangleBorder border = shapeClipper.shape;
    if (border.borderRadius != borderRadius)
      return failWithDescription(
          matchState, 'had borderRadius: ${border.borderRadius}');
    return true;
  }

  @override
  Description describe(Description description) => description.add(
      'clips with bounding rounded rectangle with borderRadius: $borderRadius');
}

class _ClipsWithShapeBorder
    extends _MatchRenderObject<RenderClipPath, RenderClipRRect> {
  const _ClipsWithShapeBorder({@required this.shape});

  final ShapeBorder shape;

  @override
  bool renderObjectMatchesM(
      Map<dynamic, dynamic> matchState, RenderClipPath renderObject) {
    if (renderObject.clipper.runtimeType != ShapeBorderClipper)
      return failWithDescription(
          matchState, 'clipper was: ${renderObject.clipper}');
    final ShapeBorderClipper shapeClipper = renderObject.clipper;
    if (shapeClipper.shape != shape)
      return failWithDescription(
          matchState, 'shape was: ${shapeClipper.shape}');
    return true;
  }

  @override
  bool renderObjectMatchesT(
      Map<dynamic, dynamic> matchState, RenderClipRRect renderObject) {
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('clips with shape: $shape');
}

class _CoversSameAreaAs extends Matcher {
  _CoversSameAreaAs(
    this.expectedPath, {
    @required this.areaToCompare,
    this.sampleSize = 20,
  })  : maxHorizontalNoise = areaToCompare.width / sampleSize,
        maxVerticalNoise = areaToCompare.height / sampleSize {
    // Use a fixed random seed to make sure tests are deterministic.
    random = math.Random(1);
  }

  final Path expectedPath;
  final Rect areaToCompare;
  final int sampleSize;
  final double maxHorizontalNoise;
  final double maxVerticalNoise;
  math.Random random;

  @override
  bool matches(covariant Path actualPath, Map<dynamic, dynamic> matchState) {
    for (int i = 0; i < sampleSize; i += 1) {
      for (int j = 0; j < sampleSize; j += 1) {
        final Offset offset = Offset(
          i * (areaToCompare.width / sampleSize),
          j * (areaToCompare.height / sampleSize),
        );

        if (!_samplePoint(matchState, actualPath, offset)) return false;

        final Offset noise = Offset(
          maxHorizontalNoise * random.nextDouble(),
          maxVerticalNoise * random.nextDouble(),
        );

        if (!_samplePoint(matchState, actualPath, offset + noise)) return false;
      }
    }
    return true;
  }

  bool _samplePoint(
      Map<dynamic, dynamic> matchState, Path actualPath, Offset offset) {
    if (expectedPath.contains(offset) == actualPath.contains(offset))
      return true;

    if (actualPath.contains(offset))
      return failWithDescription(matchState,
          '$offset is contained in the actual path but not in the expected path');
    else
      return failWithDescription(matchState,
          '$offset is contained in the expected path but not in the actual path');
  }

  bool failWithDescription(
      Map<dynamic, dynamic> matchState, String description) {
    matchState['failure'] = description;
    return false;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(matchState['failure']);
  }

  @override
  Description describe(Description description) =>
      description.add('covers expected area and only expected area');
}

Future<ui.Image> _captureImage(Element element) {
  RenderObject renderObject = element.renderObject;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent;
    assert(renderObject != null);
  }
  assert(!renderObject.debugNeedsPaint);
  final OffsetLayer layer = renderObject.layer;
  return layer.toImage(renderObject.paintBounds);
}

int _countDifferentPixels(Uint8List imageA, Uint8List imageB) {
  assert(imageA.length == imageB.length);
  int delta = 0;
  for (int i = 0; i < imageA.length; i += 4) {
    if (imageA[i] != imageB[i] ||
        imageA[i + 1] != imageB[i + 1] ||
        imageA[i + 2] != imageB[i + 2] ||
        imageA[i + 3] != imageB[i + 3]) {
      delta++;
    }
  }
  return delta;
}

class _MatchesReferenceImage extends AsyncMatcher {
  const _MatchesReferenceImage(this.referenceImage);

  final ui.Image referenceImage;

  @override
  Future<String> matchAsync(dynamic item) async {
    Future<ui.Image> imageFuture;
    if (item is Future<ui.Image>) {
      imageFuture = item;
    } else if (item is ui.Image) {
      imageFuture = Future<ui.Image>.value(item);
    } else {
      final Finder finder = item;
      final Iterable<Element> elements = finder.evaluate();
      if (elements.isEmpty) {
        return 'could not be rendered because no widget was found';
      } else if (elements.length > 1) {
        return 'matched too many widgets';
      }
      imageFuture = _captureImage(elements.single);
    }

    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    return binding.runAsync<String>(() async {
      final ui.Image image = await imageFuture;
      final ByteData bytes = await image
          .toByteData()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (bytes == null) {
        return 'Failed to generate an image from engine within the 10,000ms timeout.';
      }

      final ByteData referenceBytes = await referenceImage
          .toByteData()
          .timeout(const Duration(seconds: 10), onTimeout: () => null);
      if (referenceBytes == null) {
        return 'Failed to generate an image from engine within the 10,000ms timeout.';
      }

      if (referenceImage.height != image.height ||
          referenceImage.width != image.width) {
        return 'does not match as width or height do not match. $image != $referenceImage';
      }

      final int countDifferentPixels = _countDifferentPixels(
        Uint8List.view(bytes.buffer),
        Uint8List.view(referenceBytes.buffer),
      );
      return countDifferentPixels == 0
          ? null
          : 'does not match on $countDifferentPixels pixels';
    }, additionalTime: const Duration(seconds: 21));
  }

  @override
  Description describe(Description description) {
    return description.add(
        'rasterized image matches that of a $referenceImage reference image');
  }
}

class _MatchesSemanticsData extends Matcher {
  _MatchesSemanticsData({
    this.label,
    this.value,
    this.increasedValue,
    this.decreasedValue,
    this.hint,
    this.flags,
    this.actions,
    this.textDirection,
    this.rect,
    this.size,
    this.elevation,
    this.thickness,
    this.platformViewId,
    this.customActions,
    this.hintOverrides,
    this.children,
  });

  final String label;
  final String value;
  final String hint;
  final String increasedValue;
  final String decreasedValue;
  final SemanticsHintOverrides hintOverrides;
  final List<SemanticsAction> actions;
  final List<CustomSemanticsAction> customActions;
  final List<SemanticsFlag> flags;
  final TextDirection textDirection;
  final Rect rect;
  final Size size;
  final double elevation;
  final double thickness;
  final int platformViewId;
  final List<Matcher> children;

  @override
  Description describe(Description description) {
    description.add('has semantics');
    if (label != null) description.add(' with label: $label');
    if (value != null) description.add(' with value: $value');
    if (hint != null) description.add(' with hint: $hint');
    if (increasedValue != null)
      description.add(' with increasedValue: $increasedValue ');
    if (decreasedValue != null)
      description.add(' with decreasedValue: $decreasedValue ');
    if (actions != null)
      description.add(' with actions: ').addDescriptionOf(actions);
    if (flags != null) description.add(' with flags: ').addDescriptionOf(flags);
    if (textDirection != null)
      description.add(' with textDirection: $textDirection ');
    if (rect != null) description.add(' with rect: $rect');
    if (size != null) description.add(' with size: $size');
    if (elevation != null) description.add(' with elevation: $elevation');
    if (thickness != null) description.add(' with thickness: $thickness');
    if (platformViewId != null)
      description.add(' with platformViewId: $platformViewId');
    if (customActions != null)
      description.add(' with custom actions: $customActions');
    if (hintOverrides != null)
      description.add(' with custom hints: $hintOverrides');
    if (children != null) {
      description.add(' with children:\n');
      for (_MatchesSemanticsData child in children) child.describe(description);
    }
    return description;
  }

  @override
  bool matches(dynamic node, Map<dynamic, dynamic> matchState) {
    // TODO(jonahwilliams): remove dynamic once we have removed getSemanticsData.
    if (node == null)
      return failWithDescription(
          matchState,
          'No SemanticsData provided. '
          'Maybe you forgot to enable semantics?');
    final SemanticsData data =
        node is SemanticsNode ? node.getSemanticsData() : node;
    if (label != null && label != data.label)
      return failWithDescription(matchState, 'label was: ${data.label}');
    if (hint != null && hint != data.hint)
      return failWithDescription(matchState, 'hint was: ${data.hint}');
    if (value != null && value != data.value)
      return failWithDescription(matchState, 'value was: ${data.value}');
    if (increasedValue != null && increasedValue != data.increasedValue)
      return failWithDescription(
          matchState, 'increasedValue was: ${data.increasedValue}');
    if (decreasedValue != null && decreasedValue != data.decreasedValue)
      return failWithDescription(
          matchState, 'decreasedValue was: ${data.decreasedValue}');
    if (textDirection != null && textDirection != data.textDirection)
      return failWithDescription(
          matchState, 'textDirection was: $textDirection');
    if (rect != null && rect != data.rect)
      return failWithDescription(matchState, 'rect was: ${data.rect}');
    if (size != null && size != data.rect.size)
      return failWithDescription(matchState, 'size was: ${data.rect.size}');
    if (elevation != null && elevation != data.elevation)
      return failWithDescription(
          matchState, 'elevation was: ${data.elevation}');
    if (thickness != null && thickness != data.thickness)
      return failWithDescription(
          matchState, 'thickness was: ${data.thickness}');
    if (platformViewId != null && platformViewId != data.platformViewId)
      return failWithDescription(
          matchState, 'platformViewId was: ${data.platformViewId}');
    if (actions != null) {
      int actionBits = 0;
      for (SemanticsAction action in actions) actionBits |= action.index;
      if (actionBits != data.actions) {
        final List<String> actionSummary = <String>[];
        for (SemanticsAction action in SemanticsAction.values.values) {
          if ((data.actions & action.index) != 0)
            actionSummary.add(describeEnum(action));
        }
        return failWithDescription(matchState, 'actions were: $actionSummary');
      }
    }
    if (customActions != null || hintOverrides != null) {
      final List<CustomSemanticsAction> providedCustomActions =
          data.customSemanticsActionIds.map((int id) {
        return CustomSemanticsAction.getAction(id);
      }).toList();
      final List<CustomSemanticsAction> expectedCustomActions =
          customActions?.toList() ?? <CustomSemanticsAction>[];
      if (hintOverrides?.onTapHint != null)
        expectedCustomActions.add(CustomSemanticsAction.overridingAction(
            hint: hintOverrides.onTapHint, action: SemanticsAction.tap));
      if (hintOverrides?.onLongPressHint != null)
        expectedCustomActions.add(CustomSemanticsAction.overridingAction(
            hint: hintOverrides.onLongPressHint,
            action: SemanticsAction.longPress));
      if (expectedCustomActions.length != providedCustomActions.length)
        return failWithDescription(
            matchState, 'custom actions where: $providedCustomActions');
      int sortActions(CustomSemanticsAction left, CustomSemanticsAction right) {
        return CustomSemanticsAction.getIdentifier(left) -
            CustomSemanticsAction.getIdentifier(right);
      }

      expectedCustomActions.sort(sortActions);
      providedCustomActions.sort(sortActions);
      for (int i = 0; i < expectedCustomActions.length; i++) {
        if (expectedCustomActions[i] != providedCustomActions[i])
          return failWithDescription(
              matchState, 'custom actions where: $providedCustomActions');
      }
    }
    if (flags != null) {
      int flagBits = 0;
      for (SemanticsFlag flag in flags) flagBits |= flag.index;
      if (flagBits != data.flags) {
        final List<String> flagSummary = <String>[];
        for (SemanticsFlag flag in SemanticsFlag.values.values) {
          if ((data.flags & flag.index) != 0)
            flagSummary.add(describeEnum(flag));
        }
        return failWithDescription(matchState, 'flags were: $flagSummary');
      }
    }
    bool allMatched = true;
    if (children != null) {
      int i = 0;
      node.visitChildren((SemanticsNode child) {
        allMatched = children[i].matches(child, matchState) && allMatched;
        i += 1;
        return allMatched;
      });
    }
    return allMatched;
  }

  bool failWithDescription(
      Map<dynamic, dynamic> matchState, String description) {
    matchState['failure'] = description;
    return false;
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    return mismatchDescription.add(matchState['failure']);
  }
}

class _MatchesAccessibilityGuideline extends AsyncMatcher {
  _MatchesAccessibilityGuideline(this.guideline);

  final AccessibilityGuideline guideline;

  @override
  Description describe(Description description) {
    return description.add(guideline.description);
  }

  @override
  Future<String> matchAsync(covariant WidgetTester tester) async {
    final Evaluation result = await guideline.evaluate(tester);
    if (result.passed) return null;
    return result.reason;
  }
}

class _DoesNotMatchAccessibilityGuideline extends AsyncMatcher {
  _DoesNotMatchAccessibilityGuideline(this.guideline);

  final AccessibilityGuideline guideline;

  @override
  Description describe(Description description) {
    return description.add('Does not ' + guideline.description);
  }

  @override
  Future<String> matchAsync(covariant WidgetTester tester) async {
    final Evaluation result = await guideline.evaluate(tester);
    if (result.passed) return 'Failed';
    return null;
  }
}
