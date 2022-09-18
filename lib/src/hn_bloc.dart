import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import './json_parsing.dart';

// Stories Type Enum
enum StoriesType {
  topStories,
  newStories,
}

class HackerNewsBloc {
  // Refrence to the Stream and refrence ti add method to the stream
  final _newsSubject = BehaviorSubject<UnmodifiableListView<News>>();
  Stream<UnmodifiableListView<News>> get news => _newsSubject.stream;

  // Sink is used to add the data to the controller......
  final _storiesTypeController = StreamController<StoriesType>();
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  // Give the last element pushed to the stream
  var _news = <News>[];

  HackerNewsBloc() {
    getTheRequiredNews(StoriesType.topStories);

    // Listener
    _storiesTypeController.stream.listen((storiesType) {
      if (storiesType == StoriesType.topStories) {
        getTheRequiredNews(StoriesType.topStories);
      } else {
        getTheRequiredNews(StoriesType.newStories);
      }
    });
  }

  // Get the artlces and update it

  getTheRequiredNews(StoriesType storiesType) {
    _getNews(storiesType).then((value) {
      _newsSubject.add(UnmodifiableListView(_news));
    });
  }

  // Get the ids.............
  Future<List<int>> _getTheListOfId(StoriesType storyType) async {
    // For the top stories................
    if (storyType == StoriesType.topStories) {
      final url1 =
          Uri.parse("https://hacker-news.firebaseio.com/v0/beststories.json");
      // Getting the response.........
      final res = await http.get(url1);

      // Checking if got back the response.........
      if (res.statusCode == 200) {
        // returning the list of ids.......
        return topStoryParse(res.body);
      }

      // For the New Stories...................
    } else if (storyType == StoriesType.newStories) {
      final url =
          Uri.parse("https://hacker-news.firebaseio.com/v0/newstories.json");
      // Getting the response.........
      final res = await http.get(url);

      // Checking if got back the response.........
      if (res.statusCode == 200) {
        // returning the list of ids.......
        return topStoryParse(res.body);
      }
    } else {
      throw Exception("Didnt get The url");
    }

    // returning of we didnt get the 200 response back
    return [];
  }

  // Get the news article
  Future<News> _getTheNews(int id) async {
    late News news;
    final urlForTheItem =
        Uri.parse('https://hacker-news.firebaseio.com/v0/item/${id}.json');
    final itemRes = await http.get(urlForTheItem);
    if (itemRes.statusCode == 200) {
      news = parseItem(itemRes.body);
    }

    return news;
  }

  Future<Null> _getNews(StoriesType storiesType) async {
    var listOfIds = await _getTheListOfId(storiesType);
    var newsList = listOfIds.map((e) => _getTheNews(e));
    // For for the multiple futures to complete and te collect their result
    var finalNewsList = Future.wait(newsList);

    var news = await finalNewsList;

    _news = news;
  }
}
