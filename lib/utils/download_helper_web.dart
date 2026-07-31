import 'dart:convert';
import 'package:web/web.dart' as web;

/// Web implementation: triggers a browser file download.
void downloadFileImpl({required List<int> bytes, required String fileName}) {
  final base64Data = base64Encode(bytes);
  final mimeType = fileName.endsWith('.pdf')
      ? 'application/pdf'
      : fileName.endsWith('.csv')
          ? 'text/csv;charset=utf-8'
          : 'application/octet-stream';

  final dataUrl = 'data:$mimeType;base64,$base64Data';
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
}
