import 'dart:convert';
import 'package:http/http.dart' as http;

enum RequestType { POST, PUT, DELETE }

class TokenUtils {
  static Future<http.Response?> makeAuthenticatedRequest({
    required Uri requestUri,
    required String token,
    required String refreshToken,
    required String hostUrl,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
    required Function saveNewToken,
    required RequestType requestType,
  }) async {
    Future<http.Response> makeRequest(String token) {
      headers['Authorization'] = 'Bearer $token';
      switch (requestType) {
        case RequestType.POST:
          return http.post(requestUri, headers: headers, body: jsonEncode(body));
        case RequestType.PUT:
          return http.put(requestUri, headers: headers, body: jsonEncode(body));
        case RequestType.DELETE:
          return http.delete(requestUri, headers: headers, body: jsonEncode(body));
        default:
          throw Exception("Unsupported request type");
      }
    }

    var response = await makeRequest(token);

    if (response.statusCode == 403) {
      final String radixUrl = hostUrl.replaceAll(RegExp(r'^https?://'), '');
      final Uri refreshUri = Uri.http(radixUrl, 'refresh-token');

      final refreshResponse = await http.post(
        refreshUri,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (refreshResponse.statusCode == 200) {
        final newToken = jsonDecode(refreshResponse.body)['authToken'];
        saveNewToken(newToken);
        response = await makeRequest(newToken);
      } else {
        return null;
      }
    }

    return response;
  }
}
