import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news.dart';

class NewsService {
  static const String _baseUrl = 'https://api.marketaux.com/v1';
  static const String _apiKey = 'sECsQdM1tcfV2zt1RVE1YfjYLRYnSI6vKEdqgYKK';

  Future<NewsResponse> getNews({
    List<String>? symbols,
    String language = 'es',
    int limit = 10,
    int page = 1,
  }) async {
    try {
      final symbolsParam = symbols?.join(',') ?? 'AAPL,TSLA,MSFT,GOOGL';
      final uri = Uri.parse(
        '$_baseUrl/news/all?symbols=$symbolsParam&language=$language&limit=$limit&page=$page&api_token=$_apiKey',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return NewsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}



