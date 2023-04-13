import 'package:url_launcher/url_launcher.dart';

// Try casting an object and return null if it fails
T? tryCast<T>(dynamic object) => object is T ? object : null;

// Try cast a dynamic list to a specific type
List<T> tryCastList<T>(dynamic object) {
  final list = tryCast<List<dynamic>>(object) ?? [];
  return list
      .map(
        (element) => tryCast<T>(element),
      )
      .where(
        (element) => element != null,
      )
      .cast<T>()
      .toList();
}

Future<void> openExternally(String urlString) async {
  Uri? url = Uri.tryParse(urlString);

  if (url == null) {
    return;
  }

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
