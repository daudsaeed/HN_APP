import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hacker_new/src/json_parsing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  int _currentIndex = 0;
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
          onTap: (index) {
            if (index == 0) {
              widget.bloc.storiesType.add(StoriesType.topStories);
            } else {
              widget.bloc.storiesType.add(StoriesType.newStories);
            }
            //  Setting the State......
            setState(() {
              _currentIndex = index;
            });
          },
          elevation: 13,
          backgroundColor: Colors.white,
          currentIndex: _currentIndex,
          selectedIconTheme: const IconThemeData(color: Colors.pink),
          selectedItemColor: Colors.pink,
          items: const [
            BottomNavigationBarItem(
              label: "Top Stories",
              icon: Icon(Icons.arrow_drop_up),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.new_releases),
              label: "New Stories",
            ),
          ],
        ),
        appBar: AppBar(
          title: const Text('HackerNews'),
          leading: IsLoadingWidget(widget.bloc.isLoading),
        ),
        body: StreamBuilder<UnmodifiableListView<News>>(
          stream: widget.bloc.news,
          initialData: UnmodifiableListView<News>([]),
          builder: (context, snapshot) {
            return StreamBuilder(
                stream: widget.bloc.isLoading,
                builder:
                    (BuildContext context, AsyncSnapshot<bool> snapshotBool) {
                  if (snapshotBool.hasData && snapshotBool.data!) {
                    print(snapshotBool);
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    print(snapshotBool);
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _customNewsWidget(snapshot.data![index]),
                        );
                      },
                      itemCount: snapshot.data!.length,
                    );
                  }
                });
          },
        ),
      ),
    );
  }

  // News Widget..............
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

//Custom IsloadingWidget ............
class IsLoadingWidget extends StatefulWidget {
  final Stream<bool> isLoading;

  IsLoadingWidget(this.isLoading);

  @override
  State<IsLoadingWidget> createState() => _IsLoadingWidgetState();
}

class _IsLoadingWidgetState extends State<IsLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    //To manage the animation (object of animation) Default range 0.1 to 1.0
    _controller = AnimationController(
      //When offscreen resources wont be wasted on the animation tickproviderStateMixin is needed for it
      vsync: this,
      duration: const Duration(
        seconds: 12,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.isLoading,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          //To start the animation remember it will return the tickerFuture
          if (snapshot.hasData && snapshot.data!) {
            _controller.forward().then((value) => _controller.reverse());
            return FadeTransition(
              //Cause _controller only provide default range of 0.1 to 1.0 But we wanted to start from 0.5 opacity
              //Tween is stateless doesnt store any state use animate to animate
              opacity: Tween(begin: 0.2, end: 1.5).animate(
                //By default animation is linear
                CurvedAnimation(
                  parent: _controller,
                  curve: Curves.easeIn,
                ),
              ),
              child: const Icon(FontAwesomeIcons.hackerNewsSquare),
            );
          } else {
            return const Icon(FontAwesomeIcons.hackerNewsSquare);
          }
        });
  }
}
