import 'package:flutter/material.dart';
import 'package:hacker_new/src/json_parsing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const BasicApp());
}

class BasicApp extends StatefulWidget {
  const BasicApp({super.key});

  @override
  State<BasicApp> createState() => _BasicAppState();
}

class _BasicAppState extends State<BasicApp> {
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

  late Future<List<int>> _listOfId;

  @override
  void didChangeDependencies() {
    _listOfId = _getTheListOfId();
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
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hacker News '),
        ),
        body: FutureBuilder<List<int>>(
          future: _listOfId,

          // For the IDS #################
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!.asMap().values.toList().map((e) {
                  // For the News ...............
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FutureBuilder<News?>(
                      future: _getTheNews(e),
                      builder:
                          (BuildContext context, AsyncSnapshot newsSnapshot) {
                        if (newsSnapshot.connectionState ==
                            ConnectionState.done) {
                          return Text(newsSnapshot.data.title);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }).toList(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
