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

    print(_newsList);
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
        body: FutureBuilder<List<News?>>(
          future: _newsList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                itemBuilder: (context, index) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ExpansionTile(
                      title: Text(
                        snapshot.data![index]!.title!,
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
                              Text(
                                  "Comments : ${snapshot.data![index]!.descendants!}"),
                              IconButton(
                                  onPressed: () {
                                    // ignore: avoid_print
                                    // canLaunchUrl(Uri.parse(_newsList[index].url)).then((canRun) => print(canRun));
                                    launchUrl(Uri.parse(
                                      snapshot.data![index]!.url!,
                                    ));
                                  },
                                  icon: (const Icon(Icons.launch)))
                            ],
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
                itemCount: 10,
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
