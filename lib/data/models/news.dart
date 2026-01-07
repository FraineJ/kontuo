class NewsResponse {
  final NewsMeta meta;
  final List<NewsArticle> data;

  NewsResponse({
    required this.meta,
    required this.data,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      meta: NewsMeta.fromJson(json['meta']),
      data: (json['data'] as List)
          .map((item) => NewsArticle.fromJson(item))
          .toList(),
    );
  }
}

class NewsMeta {
  final int found;
  final int returned;
  final int limit;
  final int page;

  NewsMeta({
    required this.found,
    required this.returned,
    required this.limit,
    required this.page,
  });

  factory NewsMeta.fromJson(Map<String, dynamic> json) {
    return NewsMeta(
      found: json['found'] ?? 0,
      returned: json['returned'] ?? 0,
      limit: json['limit'] ?? 0,
      page: json['page'] ?? 0,
    );
  }
}

class NewsArticle {
  final String uuid;
  final String title;
  final String description;
  final String? keywords;
  final String snippet;
  final String url;
  final String? imageUrl;
  final String language;
  final DateTime publishedAt;
  final String source;
  final double? relevanceScore;
  final List<NewsEntity> entities;
  final List<dynamic> similar;

  NewsArticle({
    required this.uuid,
    required this.title,
    required this.description,
    this.keywords,
    required this.snippet,
    required this.url,
    this.imageUrl,
    required this.language,
    required this.publishedAt,
    required this.source,
    this.relevanceScore,
    required this.entities,
    required this.similar,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      uuid: json['uuid'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      keywords: json['keywords'],
      snippet: json['snippet'] ?? '',
      url: json['url'] ?? '',
      imageUrl: json['image_url'],
      language: json['language'] ?? 'es',
      publishedAt: DateTime.parse(json['published_at'] ?? DateTime.now().toIso8601String()),
      source: json['source'] ?? '',
      relevanceScore: json['relevance_score']?.toDouble(),
      entities: (json['entities'] as List? ?? [])
          .map((item) => NewsEntity.fromJson(item))
          .toList(),
      similar: json['similar'] ?? [],
    );
  }
}

class NewsEntity {
  final String symbol;
  final String name;
  final String? exchange;
  final String? exchangeLong;
  final String? country;
  final String? type;
  final String? industry;
  final double? matchScore;
  final double? sentimentScore;
  final List<NewsHighlight> highlights;

  NewsEntity({
    required this.symbol,
    required this.name,
    this.exchange,
    this.exchangeLong,
    this.country,
    this.type,
    this.industry,
    this.matchScore,
    this.sentimentScore,
    required this.highlights,
  });

  factory NewsEntity.fromJson(Map<String, dynamic> json) {
    return NewsEntity(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      exchange: json['exchange'],
      exchangeLong: json['exchange_long'],
      country: json['country'],
      type: json['type'],
      industry: json['industry'],
      matchScore: json['match_score']?.toDouble(),
      sentimentScore: json['sentiment_score']?.toDouble(),
      highlights: (json['highlights'] as List? ?? [])
          .map((item) => NewsHighlight.fromJson(item))
          .toList(),
    );
  }
}

class NewsHighlight {
  final String highlight;
  final double? sentiment;
  final String? highlightedIn;

  NewsHighlight({
    required this.highlight,
    this.sentiment,
    this.highlightedIn,
  });

  factory NewsHighlight.fromJson(Map<String, dynamic> json) {
    return NewsHighlight(
      highlight: json['highlight'] ?? '',
      sentiment: json['sentiment']?.toDouble(),
      highlightedIn: json['highlighted_in'],
    );
  }
}



