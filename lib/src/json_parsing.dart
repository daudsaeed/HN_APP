import 'dart:convert' as json;
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:hacker_new/serializers.dart';
import 'package:meta/meta.dart';

import './news.dart';

// Provide the implementation of the abstract class
part 'json_parsing.g.dart';

// Abstract Class
abstract class News implements Built<News, NewsBuilder> {
  // fields
  static Serializer<News> get serializer => _$newsSerializer;
  int get id;

  bool? get deleted;

  /// This is the type of the article.
  ///
  /// It can be any of these: "job", "story", "comment", "poll", or "pollopt".
  String get type;

  String get by;

  int get time;

  String? get text;

  bool? get dead;

  int? get parent;

  int? get poll;

  BuiltList<int>? get kids;

  String? get url;

  int? get score;

  String? get title;

  BuiltList<int>? get parts;

  int? get descendants;

  News._();
  factory News([void Function(NewsBuilder) updates]) = _$News;
}

// parsing top stories which only have (IDS)
List<int> topStoryParse(String jsonString) {
  var encodedList = json.jsonDecode(jsonString);
  var listOfIntegers = List<int>.from(encodedList);
  return listOfIntegers;

  // return [];
}

// Parsing a single JSON item ......

News parseItem(String jsonString) {
  var encodedData = json.jsonDecode(jsonString);
  News news =
      standardSerializers.deserializeWith(News.serializer, encodedData)!;
  return news;
}
