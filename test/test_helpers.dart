import 'dart:convert';

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
