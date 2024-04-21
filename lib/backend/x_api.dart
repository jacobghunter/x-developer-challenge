import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dart_openai/dart_openai.dart';

const String baseUrl = 'https://api.twitter.com/2/tweets/sample/stream';
const bearerToken = 'AAAAAAAAAAAAAAAAAAAAALGRtQEAAAAAaQubTUgfpHVDhmEwq2rh3YLdUKc%3D6teN3XZzrYsEqOkluWS7e5s8Zl10nCfDj8ZmM9Nb92js7M52Y0';  // Replace with your actual token
const joeToken = 'AAAAAAAAAAAAAAAAAAAAAKuQtQEAAAAAY5W1SmHNhxXbzE8ELDpQUrAN2vI%3DH8uqDBss0h5nJELS2ydJgs80ONpuSqdp0xbEbuKlDNYYLuQaUG';

final client = TwitterApi(
  bearerToken: joeToken, 
    );

Future<TwitterResponse<List<TweetData>, TweetMeta>> getCityTweets(String location) async {
  var data = await client.tweets.searchRecent(maxResults: 30, expansions: [TweetExpansion.authorId, TweetExpansion.attachmentsMediaKeys],userFields: [UserField.profileImageUrl],query: 'place:$location');  
  return data;
}

Future<TwitterResponse<List<TweetData>, TweetMeta>> getTweetByLocation(LatLng location) async {
  var data = await client.tweets.searchRecent(maxResults: 30, expansions: [TweetExpansion.authorId, TweetExpansion.attachmentsMediaKeys],userFields: [UserField.profileImageUrl],query: 'point_radius:[${location.longitude} ${location.latitude} 25mi]');  
  return data;
}

Future<int> getTweetNumByLocation(String location) async {
  var data = await client.tweets.countRecent(query: 'place:$location place_country:US');
  return getTotalTweets(data.data);
}

getJson() async {
  final jsonString = await rootBundle.loadString('../../assets/cities.json');
  return json.decode(jsonString);
}

int getTotalTweets(List<TweetCountData> data) {
  int count = 0;
  for (var item in data) {
    count += item.count;
  }
  return count;
}