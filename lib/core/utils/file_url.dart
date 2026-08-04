/// The file name a URL points at: `https://host/path/resume.pdf` → `resume.pdf`.
///
/// Returns `null` for an empty URL, and the URL itself when it carries no path
/// to read a name from — either way the caller has something to show.
String? fileNameFromUrl(String? url) {
  if (url == null || url.isEmpty) return null;

  final segments = Uri.tryParse(url)?.pathSegments;
  if (segments == null || segments.isEmpty) return url;

  return segments.last.isEmpty ? url : segments.last;
}
