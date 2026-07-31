// Conditional import: use web implementation on web, stub on native
import 'download_helper_stub.dart'
    if (dart.library.js_interop) 'download_helper_web.dart' as impl;

/// Cross-platform file download utility.
/// On web: triggers browser download via anchor element.
/// On native: currently a no-op (can be extended with dart:io).
void downloadFile({required List<int> bytes, required String fileName}) {
  impl.downloadFileImpl(bytes: bytes, fileName: fileName);
}
