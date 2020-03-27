import 'dart:convert';
import 'dart:io';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/http.dart';
import 'package:mock_request/mock_request.dart';
import 'package:test/test.dart';

main() {
  var uri = Uri.parse('http://localhost:3000');
  var app = Angel()
    ..get('/foo', (req, res) => 'Hello, world!')
    ..post('/body',
        (req, res) => req.parseBody().then((_) => req.bodyAsMap.length))
    ..get('/session', (req, res) async {
      req.session['foo'] = 'bar';
    })
    ..get('/conn', (RequestContext req, res) async {
      res.serialize(req.ip == InternetAddress.loopbackIPv4.address);
    });

  var http = AngelHttp(app);

  test('receive a response', () async {
    var rq = MockHttpRequest('GET', uri.resolve('/foo'));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(utf8.decoder).join(),
        equals(json.encode('Hello, world!')));
  });

  test('send a body', () async {
    var rq = MockHttpRequest('POST', uri.resolve('/body'));
    rq
      ..headers.set(HttpHeaders.contentTypeHeader, ContentType.json.mimeType)
      ..write(json.encode({'foo': 'bar', 'bar': 'baz', 'baz': 'quux'}));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(rs.statusCode, equals(200));
    expect(await rs.transform(utf8.decoder).join(), equals(json.encode(3)));
  });

  test('session', () async {
    var rq = MockHttpRequest('GET', uri.resolve('/session'));
    await rq.close();
    await http.handleRequest(rq);
    expect(rq.session.keys, contains('foo'));
    expect(rq.session['foo'], equals('bar'));
  });

  test('connection info', () async {
    var rq = MockHttpRequest('GET', uri.resolve('/conn'));
    await rq.close();
    await http.handleRequest(rq);
    var rs = rq.response;
    expect(await rs.transform(utf8.decoder).join(), equals(json.encode(true)));
  });

  test('requested uri', () {
    var rq = MockHttpRequest('GET', uri.resolve('/mock'));
    expect(rq.uri.path, '/mock');
    expect(rq.requestedUri.toString(), 'http://example.com/mock');
  });
}
