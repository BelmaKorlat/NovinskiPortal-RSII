import 'dart:typed_data';
import 'package:dio/dio.dart';

class NewsReportFileUpload {
  final String fileName;
  final Uint8List bytes;

  NewsReportFileUpload({required this.fileName, required this.bytes});
}

class CreateNewsReportRequest {
  final String? email;
  final String text;
  final List<NewsReportFileUpload> files;

  CreateNewsReportRequest({
    required this.text,
    this.email,
    List<NewsReportFileUpload>? files,
  }) : files = files ?? const [];

  FormData toFormData() {
    final map = <String, dynamic>{};

    if (email != null && email!.trim().isNotEmpty) {
      map['email'] = email!.trim();
    }
    map['text'] = text.trim();
    if (files.isNotEmpty) {
      map['files'] = files
          .map((f) => MultipartFile.fromBytes(f.bytes, filename: f.fileName))
          .toList();
    }

    return FormData.fromMap(map);
  }
}
