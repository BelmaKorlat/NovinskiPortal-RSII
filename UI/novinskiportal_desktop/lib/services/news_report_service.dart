import 'package:dio/dio.dart';
import 'package:novinskiportal_desktop/models/news_report_models.dart';
import 'package:novinskiportal_desktop/services/base_service.dart';
import '../core/api_error.dart';
import '../core/paging.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsReportService extends BaseService {
  static const String _base = '/api/NewsReport';

  Future<PagedResult<NewsReportDto>> getPage(NewsReportSearch s) async {
    try {
      final res = await dio.get(_base, queryParameters: s.toQuery());

      return mapPagedResponse<NewsReportDto>(
        res.data,
        (m) => NewsReportDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri učitavanju dojava.');
    } catch (_) {
      throw ApiException(message: 'Neočekivan oblik odgovora za dojave.');
    }
  }

  Future<NewsReportDto> getById(int id) async {
    try {
      final res = await dio.get('$_base/$id');

      if (res.data is Map<String, dynamic>) {
        return NewsReportDto.fromJson(res.data as Map<String, dynamic>);
      }

      throw ApiException(message: 'Neočekivan oblik odgovora za dojavu.');
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri učitavanju detalja dojave.');
    }
  }

  Future<void> updateStatus(int id, UpdateNewsReportStatusRequest r) async {
    try {
      await dio.put('$_base/$id/status', data: r.toJson());
    } on DioException catch (e) {
      throw asApi(e, fallback: 'Greška pri ažuriranju statusa dojave.');
    }
  }

  Future<int> getPendingCount() async {
    final res = await dio.get('$_base/pending-count');
    final data = res.data;
    if (data is int) return data;
    return int.tryParse(data.toString()) ?? 0;
  }

  Future<void> openFile(NewsReportFileDto file) async {
    final base = dio.options.baseUrl;

    late final String root;
    if (base.endsWith('/api') || base.endsWith('/api/')) {
      root = base.replaceFirst(RegExp(r'/api/?$'), '');
    } else {
      root = base;
    }

    String url;
    if (file.filePath.startsWith('http')) {
      url = file.filePath;
    } else if (file.filePath.startsWith('/')) {
      url = '$root${file.filePath}';
    } else {
      url = '$root/${file.filePath}';
    }

    final uri = Uri.parse(url);

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok) {
      throw ApiException(message: 'Ne može se otvoriti fajl.');
    }
  }
}
