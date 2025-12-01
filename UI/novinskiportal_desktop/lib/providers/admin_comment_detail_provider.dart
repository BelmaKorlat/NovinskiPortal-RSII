import 'package:flutter/material.dart';
import 'package:novinskiportal_desktop/core/api_error.dart';
import 'package:novinskiportal_desktop/models/admin_comment_models.dart';
import 'package:novinskiportal_desktop/services/admin_comment_service.dart';

class AdminCommentDetailProvider extends ChangeNotifier {
  final AdminCommentService _service = AdminCommentService();

  AdminCommentDetailReportResponse? detail;
  bool isLoading = false;
  String? error;

  Future<void> load(int commentId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.getDetail(commentId);
      detail = result;
    } on ApiException catch (ex) {
      error = ex.message;
    } catch (_) {
      error = 'Došlo je do greške prilikom učitavanja detalja komentara.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
