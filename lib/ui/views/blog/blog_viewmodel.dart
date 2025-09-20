import 'package:dio/dio.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../app/app.locator.dart';

class BlogViewModel extends BaseViewModel {
  final navigationService = locator<NavigationService>();

  final String _newsApiUrl = 'https://newsapi.org/v2/everything';
  final String _apiKey = '7b4c75f7c8db469995be3eacfed13eda';

  Dio dio = Dio();

  // List to store the fetched news articles
  List<Article> articles = [];
  bool isLoading = false;

  // Fetch news related to subscriptions
  Future<void> fetchSubscriptionNews() async {
    setBusy(true);
    isLoading = true;
    notifyListeners();

    // Get the current date (today)
    DateTime now = DateTime.now();

    DateTime threeMonthsAgo = DateTime(now.year, now.month - 1, now.day);

    String formattedFromDate =
        "${threeMonthsAgo.year}-${threeMonthsAgo.month.toString().padLeft(2, '0')}-${threeMonthsAgo.day.toString().padLeft(2, '0')}";
    String formattedToDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      final response = await dio.get(_newsApiUrl, queryParameters: {
        'q': 'dayfi',
        'from': formattedFromDate,
        'to': formattedToDate,
        'sortBy': 'popularity',
        'apiKey': _apiKey,
        // 'domains': 'polygon.com,gamespot.com'
      });

      // ,openculture.com,
      // ,makeuseof.com
      // ,cnet.com
      // ,digitaltrends.com
      // ,gamespot.com

      if (response.statusCode == 200) {
        final newsResponse = NewsResponse.fromJson(response.data);

        // Filter out duplicate articles by title
        final uniqueArticles =
            <String, Article>{}; // Use a map to ensure uniqueness by title
        for (var article in newsResponse.articles) {
          if (!uniqueArticles.containsKey(article.title)) {
            uniqueArticles[article.title] = article;
          }
        }

        // Assign the unique articles to the articles list
        articles = uniqueArticles.values.toList();

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
    }

    setBusy(false); // Set the view model back to idle (no longer loading)
  }

  // Function to calculate the minimum number of reads
  int calculateMinReads(int wordsPerSession, {int targetWords = 10000}) {
    if (wordsPerSession <= 0) {
      throw ArgumentError("Words per session must be greater than zero.");
    }

    // Calculate the number of sessions required, rounding up if needed.
    return (targetWords / wordsPerSession).ceil();
  }
}

int calculateMinReads(int wordsPerSession, {int targetWords = 10000}) {
  if (wordsPerSession <= 0) {
    throw ArgumentError("Words per session must be greater than zero.");
  }

  // Calculate the number of sessions required, rounding up if needed.
  return (targetWords / wordsPerSession).ceil();
}

class NewsResponse {
  final String status;
  final int totalResults;
  final List<Article> articles;

  NewsResponse({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      status: json['status'] as String,
      totalResults: json['totalResults'] as int,
      articles: (json['articles'] as List<dynamic>)
          .map((articleJson) =>
              Article.fromJson(articleJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'totalResults': totalResults,
      'articles': articles.map((article) => article.toJson()).toList(),
    };
  }
}

class Article {
  final Source source;
  final String? author;
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final String publishedAt;
  final String content;

  Article({
    required this.source,
    this.author,
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source'] as Map<String, dynamic>),
      author: json['author'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      url: json['url'] as String,
      urlToImage: json['urlToImage'] as String?,
      publishedAt: json['publishedAt'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'author': author,
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'content': content,
    };
  }
}

class Source {
  final String? id;
  final String name;

  Source({
    this.id,
    required this.name,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String?,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
