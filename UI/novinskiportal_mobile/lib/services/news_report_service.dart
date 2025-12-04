import 'package:dio/dio.dart';
import 'package:novinskiportal_mobile/models/news_report/news_report_models.dart';
import 'package:novinskiportal_mobile/services/base_service.dart';

class NewsReportService extends BaseService {
  static const String _base = '/api/NewsReport';

  Future<void> create(CreateNewsReportRequest r) async {
    try {
      await dio.post(
        _base,
        data: r.toFormData(),
        options: Options(
          contentType: 'multipart/form-data',
          headers: {'Accept': 'application/json'},
        ),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška prilikom slanja dojave.');
    }
  }
}
