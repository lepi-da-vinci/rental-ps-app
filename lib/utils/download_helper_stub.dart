/// Stub implementation for non-web platforms.
void downloadFileImpl({required List<int> bytes, required String fileName}) {
  // On native platforms, this is a no-op for now.
  // Can be extended to use dart:io File for desktop platforms.
}
