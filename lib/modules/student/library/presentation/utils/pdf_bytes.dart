import 'dart:typed_data';

import 'package:dio/dio.dart';

/// Resolves a research paper's `fileUrl` to raw PDF bytes.
///
/// Self-published papers (see `publish_research_screen.dart`) store the file
/// as an inline `data:application/pdf;base64,...` URI rather than an HTTP
/// URL, so it must be decoded locally instead of fetched.
Future<Uint8List> fetchPdfBytes(String url) async {
  if (url.startsWith('data:')) {
    return UriData.parse(url).contentAsBytes();
  }
  final response = await Dio().get<List<int>>(
    url,
    options: Options(responseType: ResponseType.bytes),
  );
  return Uint8List.fromList(response.data ?? const []);
}
