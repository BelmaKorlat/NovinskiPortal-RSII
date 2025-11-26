import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:novinskiportal_mobile/core/api_error.dart';
import 'package:novinskiportal_mobile/models/news_report/news_report_models.dart';
import 'package:novinskiportal_mobile/services/news_report_service.dart';

class NewsReportProvider extends ChangeNotifier {
  NewsReportProvider();

  final NewsReportService _service = NewsReportService();

  bool _isSubmitting = false;
  String? _error;

  final List<PlatformFile> _files = [];

  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  List<PlatformFile> get files => List.unmodifiable(_files);

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        _files
          ..clear()
          ..addAll(result.files);
        notifyListeners();
      }
    } catch (_) {}
  }

  void removeFileAt(int index) {
    if (index < 0 || index >= _files.length) return;
    _files.removeAt(index);
    notifyListeners();
  }

  Future<bool> submit({required String text, required String? email}) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      final uploads = <NewsReportFileUpload>[];

      for (final f in _files) {
        Uint8List? bytes = f.bytes;

        if (bytes == null && f.path != null) {
          bytes = await File(f.path!).readAsBytes();
        }

        if (bytes == null) continue;

        uploads.add(NewsReportFileUpload(fileName: f.name, bytes: bytes));
      }

      final cleanedEmail = (email != null && email.trim().isNotEmpty)
          ? email.trim()
          : null;

      final req = CreateNewsReportRequest(
        text: text,
        email: cleanedEmail,
        files: uploads,
      );

      await _service.create(req);

      _files.clear();

      _isSubmitting = false;
      notifyListeners();
      return true;
    } on ApiException catch (ex) {
      _error = ex.message;
      _isSubmitting = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Došlo je do greške pri slanju dojave.';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
