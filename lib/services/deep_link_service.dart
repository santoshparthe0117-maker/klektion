import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;

  void init() {
    // 1) when app is cold-launched by a link
    _appLinks
        .getInitialLink()
        .then((uri) {
          if (uri != null) _handleUri(uri);
        })
        .catchError((e) => print("getInitialAppLink error: $e"));

    // 2) while app is running or in background
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        if (uri != null) _handleUri(uri);
      },
      onError: (err) {
        print("uriLinkStream error: $err");
      },
    );
  }

  void dispose() {
    _sub?.cancel();
  }

  void _handleUri(Uri uri) {
    print("Deep link: $uri");
    final segments = uri.pathSegments; // e.g. ["item","123"]
    if (segments.isEmpty) return;

    if (segments[0] == 'item' && segments.length >= 2) {
      final id = segments[1];
      // navigate using Get (or Navigator)
      Get.toNamed('/itemDetail', arguments: {'id': id});
    } else if (segments[0] == 'user' && segments.length >= 2) {
      final id = segments[1];
      Get.toNamed('/userProfile', arguments: {'id': id});
    }
  }
}
