import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:novinskiportal_desktop/core/api_error.dart';
import 'package:novinskiportal_desktop/core/notification_service.dart';
import 'package:novinskiportal_desktop/models/admin_dashboard_models.dart';
import 'package:novinskiportal_desktop/services/admin_dashboard_service.dart';
import 'package:file_selector/file_selector.dart';

class AdminDashboardProvider extends ChangeNotifier {
  final AdminDashboardService _service = AdminDashboardService();

  bool _isLoading = false;
  String? _error;
  DashboardSummary? _summary;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardSummary? get summary => _summary;

  bool _isTopLoading = false;
  String? _topError;
  List<DashboardTopArticle> _topArticles = [];

  bool get isTopLoading => _isTopLoading;
  String? get topError => _topError;
  List<DashboardTopArticle> get topArticles => List.unmodifiable(_topArticles);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _service.getSummary();
      _summary = data;

      _topArticles = data.topArticles;
      _topError = null;
      _isTopLoading = false;
    } on ApiException catch (ex) {
      _error = ex.message;
      NotificationService.error('Greška', ex.message);
    } catch (e, s) {
      if (kDebugMode) {
        print('AdminDashboardProvider.load error: $e');
        print(s);
      }
      _error = 'Greška pri učitavanju dashboard podataka.';
      NotificationService.error(
        'Greška',
        'Greška pri učitavanju dashboard podataka.',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTopArticles({
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int take = 15,
  }) async {
    _isTopLoading = true;
    _topError = null;
    notifyListeners();

    try {
      final list = await _service.getTopArticles(
        categoryId: categoryId,
        from: from,
        to: to,
        take: take,
      );
      _topArticles = list;
    } on ApiException catch (ex) {
      _topError = ex.message;
      NotificationService.error('Greška', ex.message);
    } catch (e, s) {
      if (kDebugMode) {
        print('AdminDashboardProvider.loadTopArticles error: $e');
        print(s);
      }
      _topError = 'Greška pri učitavanju najčitanijih članaka.';
      NotificationService.error(
        'Greška',
        'Greška pri učitavanju najčitanijih članaka.',
      );
    } finally {
      _isTopLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load();
  }

  String utcTimestamp() {
    final nowUtc = DateTime.now().toUtc();
    return DateFormat('yyyyMMddHHmm').format(nowUtc);
  }

  Future<void> exportTopArticlesReport({
    int? categoryId,
    DateTime? from,
    DateTime? to,
    int take = 15,
  }) async {
    try {
      final Uint8List bytes = await _service.downloadTopArticlesReport(
        categoryId: categoryId,
        from: from,
        to: to,
        take: take,
      );

      final ts = utcTimestamp();
      final suggestedName = 'najcitaniji_clanci_$ts.pdf';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );

      if (location == null) {
        return;
      }

      final XFile pdfFile = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: suggestedName,
      );

      await pdfFile.saveTo(location.path);

      NotificationService.success(
        'Izvještaj preuzet',
        'PDF izvještaj je uspješno snimljen.',
      );
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (e, s) {
      if (kDebugMode) {
        print('AdminDashboardProvider.exportTopArticlesReport error: $e');
        print(s);
      }
      NotificationService.error(
        'Greška',
        'Greška pri preuzimanju PDF izvještaja.',
      );
    }
  }

  Future<void> exportCategoryViewsReport() async {
    try {
      final Uint8List bytes = await _service.downloadCategoryViewsReport();

      final ts2 = utcTimestamp();
      final suggestedName = 'citanost_po_kategorijama_$ts2.pdf';

      final FileSaveLocation? location = await getSaveLocation(
        suggestedName: suggestedName,
        acceptedTypeGroups: const [
          XTypeGroup(label: 'PDF', extensions: ['pdf']),
        ],
      );

      if (location == null) {
        return;
      }

      final XFile pdfFile = XFile.fromData(
        bytes,
        mimeType: 'application/pdf',
        name: suggestedName,
      );

      await pdfFile.saveTo(location.path);

      NotificationService.success(
        'Izvještaj preuzet',
        'PDF izvještaj po kategorijama je uspješno snimljen.',
      );
    } on ApiException catch (ex) {
      NotificationService.error('Greška', ex.message);
    } catch (e, s) {
      if (kDebugMode) {
        print('AdminDashboardProvider.exportCategoryViewsReport error: $e');
        print(s);
      }
      NotificationService.error(
        'Greška',
        'Greška pri preuzimanju PDF izvještaja po kategorijama.',
      );
    }
  }
}
