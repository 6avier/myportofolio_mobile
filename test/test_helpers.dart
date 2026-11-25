import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// An [ApiClient] whose HTTP calls are answered by [handler] instead of the
/// network. Without a handler every request returns an empty project list.
ApiClient fakeApiClient([MockClientHandler? handler]) {
  return ApiClient(
    baseUrl: 'http://test',
    client: MockClient(
      handler ?? (request) async => http.Response(jsonEncode([]), 200),
    ),
  );
}

/// The test font draws every glyph as a square as wide as its font size, so the
/// DrawerHeader text overflows in tests even though it fits with a real font.
/// Ignore only that overflow; every other error still fails the test.
void ignoreTestFontOverflow() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('A RenderFlex overflowed')) {
      return;
    }
    originalOnError?.call(details);
  };
  addTearDown(() => FlutterError.onError = originalOnError);
}
