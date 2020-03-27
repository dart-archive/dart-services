import 'package:mock_request/mock_request.dart';

main() async {
  var rq = MockHttpRequest('GET', Uri.parse('/foo'));
  await rq.close();
}
