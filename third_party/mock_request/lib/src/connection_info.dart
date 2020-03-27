import 'dart:io';

class MockHttpConnectionInfo implements HttpConnectionInfo {
  final InternetAddress remoteAddress;
  final int localPort, remotePort;

  MockHttpConnectionInfo({this.remoteAddress, this.localPort, this.remotePort});
}
