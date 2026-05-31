import 'export_service_stub.dart'
    if (dart.library.html) 'export_service_web.dart'
    as impl;

class ExportService {
  const ExportService._();

  static Future<void> copyJson(Object value) => impl.copyJson(value);

  static void downloadJson(String fileName, Object value) {
    impl.downloadJson(fileName, value);
  }
}
