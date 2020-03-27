import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:charcode/ascii.dart';
import 'connection_info.dart';
import 'lockable_headers.dart';
import 'response.dart';
import 'session.dart';

class MockHttpRequest
    implements HttpRequest, StreamSink<List<int>>, StringSink {
  int _contentLength = 0;
  BytesBuilder _buf;
  final Completer _done = Completer();
  final LockableMockHttpHeaders _headers = LockableMockHttpHeaders();
  Uri _requestedUri;
  MockHttpSession _session;
  final StreamController<Uint8List> _stream = StreamController<Uint8List>();

  @override
  final List<Cookie> cookies = [];

  @override
  HttpConnectionInfo connectionInfo =
      MockHttpConnectionInfo(remoteAddress: InternetAddress.loopbackIPv4);

  @override
  MockHttpResponse response = MockHttpResponse();

  @override
  HttpSession get session => _session;

  @override
  final String method;

  @override
  final Uri uri;

  @override
  bool persistentConnection = true;

  /// [copyBuffer] corresponds to `copy` on the [BytesBuilder] constructor.
  MockHttpRequest(this.method, this.uri,
      {bool copyBuffer = true,
      String protocolVersion,
      String sessionId,
      this.certificate,
      this.persistentConnection}) {
    _buf = BytesBuilder(copy: copyBuffer != false);
    _session = MockHttpSession(id: sessionId ?? 'mock-http-session');
    this.protocolVersion =
        protocolVersion?.isNotEmpty == true ? protocolVersion : '1.1';
  }

  @override
  int get contentLength => _contentLength;

  @override
  HttpHeaders get headers => _headers;

  @override
  Uri get requestedUri {
    if (_requestedUri != null)
      return _requestedUri;
    else
      return _requestedUri = Uri(
        scheme: 'http',
        host: 'example.com',
        path: uri.path,
        query: uri.query,
      );
  }

  void set requestedUri(Uri value) {
    _requestedUri = value;
  }

  @override
  String protocolVersion;

  @override
  X509Certificate certificate;

  @override
  void add(List<int> data) {
    if (_done.isCompleted)
      throw StateError('Cannot add to closed MockHttpRequest.');
    else {
      _headers.lock();
      _contentLength += data.length;
      _buf.add(data);
    }
  }

  @override
  void addError(error, [StackTrace stackTrace]) {
    if (_done.isCompleted)
      throw StateError('Cannot add to closed MockHttpRequest.');
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
    await flush();
    _headers.lock();
    _stream.close();
    _done.complete();
    return await _done.future;
  }

  @override
  Future get done => _done.future;

  // @override
  Future flush() async {
    _contentLength += _buf.length;
    _stream.add(_buf.takeBytes() as Uint8List);
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
  Future<bool> any(bool test(Uint8List element)) {
    return _stream.stream.any((List<int> e) {
      return test(Uint8List.fromList(e));
    });
  }

  @override
  Stream<Uint8List> asBroadcastStream({
    void onListen(StreamSubscription<Uint8List> subscription),
    void onCancel(StreamSubscription<Uint8List> subscription),
  }) {
    return _stream.stream
        .asBroadcastStream(onListen: onListen, onCancel: onCancel);
  }

  @override
  Stream<E> asyncExpand<E>(Stream<E> convert(Uint8List event)) =>
      _stream.stream.asyncExpand(convert);

  @override
  Stream<E> asyncMap<E>(FutureOr<E> convert(Uint8List event)) =>
      _stream.stream.asyncMap(convert);

  @override
  Future<bool> contains(Object needle) => _stream.stream.contains(needle);

  @override
  Stream<Uint8List> distinct(
          [bool equals(Uint8List previous, Uint8List next)]) =>
      _stream.stream.distinct(equals);

  @override
  Future<E> drain<E>([E futureValue]) => _stream.stream.drain(futureValue);

  @override
  Future<Uint8List> elementAt(int index) => _stream.stream.elementAt(index);

  @override
  Future<bool> every(bool test(Uint8List element)) =>
      _stream.stream.every(test);

  @override
  Stream<S> expand<S>(Iterable<S> convert(Uint8List value)) =>
      _stream.stream.expand(convert);

  @override
  Future<Uint8List> get first => _stream.stream.first;

  @override
  Future<Uint8List> firstWhere(bool test(Uint8List element),
          {List<int> orElse()}) =>
      _stream.stream
          .firstWhere(test, orElse: () => Uint8List.fromList(orElse()));

  @override
  Future<S> fold<S>(S initialValue, S combine(S previous, Uint8List element)) =>
      _stream.stream.fold(initialValue, combine);

  @override
  Future forEach(void action(Uint8List element)) =>
      _stream.stream.forEach(action);

  @override
  Stream<Uint8List> handleError(Function onError, {bool test(error)}) =>
      _stream.stream.handleError(onError, test: test);

  @override
  bool get isBroadcast => _stream.stream.isBroadcast;

  @override
  Future<bool> get isEmpty => _stream.stream.isEmpty;

  @override
  Future<String> join([String separator = ""]) =>
      _stream.stream.join(separator ?? "");

  @override
  Future<Uint8List> get last => _stream.stream.last;

  @override
  Future<Uint8List> lastWhere(bool test(Uint8List element),
          {List<int> orElse()}) =>
      _stream.stream
          .lastWhere(test, orElse: () => Uint8List.fromList(orElse()));

  @override
  Future<int> get length => _stream.stream.length;

  @override
  StreamSubscription<Uint8List> listen(
    void onData(Uint8List event), {
    Function onError,
    void onDone(),
    bool cancelOnError,
  }) {
    return _stream.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError == true,
    );
  }

  @override
  Stream<S> map<S>(S convert(Uint8List event)) => _stream.stream.map(convert);

  @override
  Future pipe(StreamConsumer<List<int>> streamConsumer) =>
      _stream.stream.cast<List<int>>().pipe(streamConsumer);

  @override
  Future<Uint8List> reduce(
      List<int> combine(Uint8List previous, Uint8List element)) {
    return _stream.stream.reduce((Uint8List previous, Uint8List element) {
      return Uint8List.fromList(combine(previous, element));
    });
  }

  @override
  Future<Uint8List> get single => _stream.stream.single;

  @override
  Future<Uint8List> singleWhere(bool test(Uint8List element),
          {List<int> orElse()}) =>
      _stream.stream
          .singleWhere(test, orElse: () => Uint8List.fromList(orElse()));

  @override
  Stream<Uint8List> skip(int count) => _stream.stream.skip(count);

  @override
  Stream<Uint8List> skipWhile(bool test(Uint8List element)) =>
      _stream.stream.skipWhile(test);

  @override
  Stream<Uint8List> take(int count) => _stream.stream.take(count);

  @override
  Stream<Uint8List> takeWhile(bool test(Uint8List element)) =>
      _stream.stream.takeWhile(test);

  @override
  Stream<Uint8List> timeout(Duration timeLimit,
          {void onTimeout(EventSink<Uint8List> sink)}) =>
      _stream.stream.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<List<Uint8List>> toList() => _stream.stream.toList();

  @override
  Future<Set<Uint8List>> toSet() => _stream.stream.toSet();

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) =>
      _stream.stream.cast<List<int>>().transform(streamTransformer);

  @override
  Stream<Uint8List> where(bool test(Uint8List event)) =>
      _stream.stream.where(test);

  @override
  Stream<R> cast<R>() => Stream.castFrom<List<int>, R>(this);
}
