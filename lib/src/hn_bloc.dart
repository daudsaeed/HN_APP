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

//Class for the HackerNews
class HackerNewsBloc {
  // Reference to the Stream and reference ti add method to the stream
  final _newsSubject = BehaviorSubject<UnmodifiableListView<News>>();
  Stream<UnmodifiableListView<News>> get news => _newsSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isLoading => _isLoadingSubject.stream;


  // Sink is used to add the data to the controller......
  final _storiesTypeController = StreamController<StoriesType>();
  Sink<StoriesType> get storiesType => _storiesTypeController.sink;

  // Give the last element pushed to the stream
  var _news = <News>[];

  //Constructor................
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

  // Get the articles and update it

  getTheRequiredNews(StoriesType storiesType) async{
    //  Adding data to the Stream (True)
    _isLoadingSubject.add(true);
    //This Will assign a List to the ( _news ) List and then we will put that data to the stream
    await _getNews(storiesType);
    _newsSubject.add(UnmodifiableListView(_news));

    //After The Stream Is ready
    _isLoadingSubject.add(false);

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
    // final itemRes = await http.get(urlForTheItem);


    // if (itemRes.statusCode == 200) {
    //   news = parseItem(itemRes.body);
    // }

    await http.get(urlForTheItem).then((itemRes) {
      if (itemRes.statusCode == 200) {
        news = parseItem(itemRes.body);
      }
    }).catchError((error){
      print("Connection Error");
    });

    return news;
  }


  //Integrate both the getTheListOfIds and _getTheNews Method to get the list of new
  Future<Null> _getNews(StoriesType storiesType) async {
    var listOfIds = await _getTheListOfId(storiesType);
    var newsList = listOfIds.map((e) => _getTheNews(e));
    // For for the multiple futures to complete and te collect their result
    var finalNewsList = Future.wait(newsList);

    var news = await finalNewsList;

    _news = news;
  }
}
