import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:charcode/ascii.dart';
import 'connection_info.dart';
import 'lockable_headers.dart';

class MockHttpResponse extends Stream<List<int>> implements HttpResponse {
  BytesBuilder _buf = BytesBuilder();
  bool _bufferOutput = true;
  final Completer _done = Completer();
  final LockableMockHttpHeaders _headers = LockableMockHttpHeaders();
  final StreamController<List<int>> _stream = StreamController<List<int>>();

  @override
  final List<Cookie> cookies = [];

  @override
  HttpConnectionInfo connectionInfo =
      MockHttpConnectionInfo(remoteAddress: InternetAddress.anyIPv4);

  /// [copyBuffer] corresponds to `copy` on the [BytesBuilder] constructor.
  MockHttpResponse(
      {bool copyBuffer = true,
      this.statusCode,
      this.reasonPhrase,
      this.contentLength,
      this.deadline,
      this.encoding,
      this.persistentConnection,
      bool bufferOutput}) {
    _buf = BytesBuilder(copy: copyBuffer != false);
    _bufferOutput = bufferOutput != false;
    statusCode ??= 200;
  }

  @override
  bool get bufferOutput => _bufferOutput;

  void set bufferOutput(bool value) {}

  @override
  int contentLength;

  @override
  Duration deadline;

  @override
  bool persistentConnection;

  @override
  String reasonPhrase;

  @override
  int statusCode;

  @override
  Encoding encoding;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future get done => _done.future;

  @override
  void add(List<int> data) {
    if (_done.isCompleted)
      throw StateError('Cannot add to closed MockHttpResponse.');
    else {
      _headers.lock();
      if (_bufferOutput == true)
        _buf.add(data);
      else
        _stream.add(data);
    }
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    if (_done.isCompleted)
      throw StateError('Cannot add to closed MockHttpResponse.');
    else
      _stream.addError(error, stackTrace);
  }

  @override
  Future addStream(Stream<List<int>> stream) {
    var c = Completer();
    stream.listen(add, onError: addError, onDone: c.complete);
    return c.future;
  }

  @override
  Future close() async {
    _headers.lock();
    await flush();
    _stream.close();
    _done.complete();
    //return await _done.future;
  }

  @override
  Future<Socket> detachSocket({bool writeHeaders = true}) {
    throw UnsupportedError('MockHttpResponses have no socket to detach.');
  }

  @override
  Future flush() async {
    _stream.add(_buf.takeBytes());
  }

  @override
  Future redirect(Uri location,
      {int status = HttpStatus.movedTemporarily}) async {
    statusCode = status ?? HttpStatus.movedTemporarily;
  }

  @override
  void write(Object obj) {
    obj?.toString()?.codeUnits?.forEach(writeCharCode);
  }

  @override
  void writeAll(Iterable objects, [String separator = ""]) {
    write(objects.join(separator ?? ""));
  }

  @override
  void writeCharCode(int charCode) {
    add([charCode]);
  }

  @override
  void writeln([Object obj = ""]) {
    write(obj ?? "");
    add([$cr, $lf]);
  }

  @override
  StreamSubscription<List<int>> listen(void onData(List<int> event),
          {Function onError, void onDone(), bool cancelOnError}) =>
      _stream.stream.listen(onData,
          onError: onError,
          onDone: onDone,
          cancelOnError: cancelOnError == true);
}
