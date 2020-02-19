// GENERATED CODE - DO NOT MODIFY BY HAND

part of services.common_server_proto;

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$CommonServerProtoRouter(CommonServerProto service) {
  final router = Router();
  router.add('POST', r'/api2/analyze', service.analyze);
  router.add('POST', r'/api2/compile', service.compile);
  router.add('POST', r'/api2/compileDDC', service.compileDDC);
  router.add('POST', r'/api2/complete', service.complete);
  router.add('POST', r'/api2/fixes', service.fixes);
  router.add('POST', r'/api2/assists', service.assists);
  router.add('POST', r'/api2/format', service.format);
  router.add('POST', r'/api2/document', service.document);
  router.add('POST', r'/api2/version', service.version);
  return router;
}
