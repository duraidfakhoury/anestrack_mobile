import 'dart:typed_data';

import 'package:anestrack_mobile/core/constants/app_colors.dart';
import 'package:anestrack_mobile/generated/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:printing/printing.dart';

class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({super.key, required this.title, required this.url});

  final String title;
  final String url;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late Future<Uint8List> _bytesFuture;

  @override
  void initState() {
    super.initState();
    _bytesFuture = _download();
  }

  Future<Uint8List> _download() async {
    final response = await Dio().get<List<int>>(
      widget.url,
      options: Options(responseType: ResponseType.bytes),
    );
    return Uint8List.fromList(response.data ?? const []);
  }

  void _retry() {
    setState(() => _bytesFuture = _download());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: AppColors.studentPrimary,
        foregroundColor: AppColors.white,
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: FutureBuilder<Uint8List>(
        future: _bytesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    LocaleKeys.library_pdf_viewer_loading.tr(),
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.circleAlert,
                      size: 44,
                      color: AppColors.red600,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      LocaleKeys.library_pdf_viewer_error.tr(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      child: Text(LocaleKeys.library_retry.tr()),
                    ),
                  ],
                ),
              ),
            );
          }
          final bytes = snapshot.data!;
          return PdfPreview(
            build: (format) async => bytes,
            canChangeOrientation: false,
            canChangePageFormat: false,
            canDebug: false,
            allowSharing: false,
          );
        },
      ),
    );
  }
}
