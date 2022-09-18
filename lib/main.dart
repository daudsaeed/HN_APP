import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hacker_new/src/json_parsing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import './src/hn_bloc.dart';

void main() {
  final HackerNewsBloc hcBloc = HackerNewsBloc();
  runApp(
    BasicApp(
      bloc: hcBloc,
    ),
  );
}

class BasicApp extends StatefulWidget {
  final HackerNewsBloc bloc;
  const BasicApp({super.key, required this.bloc});

  @override
  State<BasicApp> createState() => _BasicAppState();
}

class _BasicAppState extends State<BasicApp> {
  int currentIndex = 0;
  // Get a list of ids
  Future<List<int>> _getTheListOfId() async {
    final url =
        Uri.parse("https://hacker-news.firebaseio.com/v0/beststories.json");
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return topStoryParse(res.body);
    }

    return [];
  }

  // Get the news article
  Future<News?> _getTheNews(int id) async {
    final urlForTheItem =
        Uri.parse('https://hacker-news.firebaseio.com/v0/item/${id}.json');
    final itemRes = await http.get(urlForTheItem);
    if (itemRes.statusCode == 200) {
      return parseItem(itemRes.body);
    }

    return null;
  }

  Future<List<News?>> _getTheListOfNews(Future<List<int>> listOfIds) async {
    final ids = await listOfIds;
    List<News?> listOfNews = [];
    var newsList = ids.map((id) async {
      News? news = await _getTheNews(id);
      listOfNews.add(news);
      return news;
    }).toList();

    return listOfNews;
  }

  late Future<List<int>> _listOfId;
  late Future<List<News?>> _newsList;
  @override
  void didChangeDependencies() {
    _listOfId = _getTheListOfId();
    _newsList = _getTheListOfNews(_listOfId);

    super.didChangeDependencies();
  }

  // Future<void> removeItem() async {
  //   setState(() {
  //     _newsList.removeAt(0);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    // ignore: no_leading_underscores_for_local_identifiers

    return MaterialApp(
      theme: ThemeData(
        fontFamily: "Jost",
        appBarTheme: const AppBarTheme(color: Colors.pink),
      ),
      home: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            if (value == 0) {
              widget.bloc.storiesType.add(StoriesType.topStories);
              setState(() {
                currentIndex = 0;
              });
            } else {
              widget.bloc.storiesType.add(StoriesType.newStories);
              setState(() {
                currentIndex = 1;
              });
            }
          },
          elevation: 13,
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          selectedIconTheme: const IconThemeData(color: Colors.pink),
          selectedItemColor: Colors.pink,
          items: const [
            BottomNavigationBarItem(
              label: "Top Stories",
              icon: Icon(Icons.arrow_upward),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases),
              label: "New Stories",
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text('HackerNews'),
        ),
        body: StreamBuilder<UnmodifiableListView<News>>(
          stream: widget.bloc.news,
          initialData: UnmodifiableListView<News>([]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active &&
                snapshot.data != null) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _customNewsWidget(snapshot.data![index]),
                  );
                },
                itemCount: snapshot.data!.length,
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  // Custom News Widget..............
  Widget _customNewsWidget(News news) {
    return ExpansionTile(
      title: Text(
        news.title!,
        style: const TextStyle(fontSize: 19),
      ),
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Comments : ${news.descendants!}"),
              IconButton(
                  onPressed: () {
                    // ignore: avoid_print
                    // canLaunchUrl(Uri.parse(_newsList[index].url)).then((canRun) => print(canRun));
                    launchUrl(Uri.parse(
                      news.url!,
                    ));
                  },
                  icon: (const Icon(Icons.launch)))
            ],
          ),
        )
      ],
    );
  }
}
