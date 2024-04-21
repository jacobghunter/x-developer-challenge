import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:csv/csv.dart';

const String baseUrl = 'https://api.twitter.com/2/tweets/sample/stream';
const bearerToken = 'AAAAAAAAAAAAAAAAAAAAALGRtQEAAAAAaQubTUgfpHVDhmEwq2rh3YLdUKc%3D6teN3XZzrYsEqOkluWS7e5s8Zl10nCfDj8ZmM9Nb92js7M52Y0';  // Replace with your actual token
const joeToken = 'AAAAAAAAAAAAAAAAAAAAAKuQtQEAAAAAY5W1SmHNhxXbzE8ELDpQUrAN2vI%3DH8uqDBss0h5nJELS2ydJgs80ONpuSqdp0xbEbuKlDNYYLuQaUG';

Future<http.Response> searchTweets(String query) async {
  final headers = {"Access-Control-Allow-Origin": "*"};

  return await http.get(Uri.parse('http://127.0.0.1:5000'), headers: headers);
}

final client = TwitterApi(
  bearerToken: bearerToken, 
  // oauthTokens: const OAuthTokens(
  //     consumerKey: '1781133441830125568-82s3Jw0vijYnzgNQU94Q4JuBVjahhR',
  //     consumerSecret: 'U1kNUjvalTu9I83uonP85YFkqX1co9NuBJcHGmjrJMNWr',
  //     accessToken: 'VTNnTkM2WDNsdzE5MGVjLWQzVmM6MTpjaQ',
  //     accessTokenSecret: 'TX0FwcajMXsGy4v7RXKDyybiTZGBO0XcItypfEjzfUjb8P7Nun',
  //   ),
  // retryConfig: RetryConfig(
  //     maxAttempts: 5,
  //     onExecute: (event) => print(
  //       'Retry after ${event.intervalInSeconds} seconds... '
  //       '[${event.retryCount} times]',
  //     ),
  //   ),

  //   //! The default timeout is 10 seconds.
  //   timeout: const Duration(seconds: 20)
    );

Future<List<TweetData>> getCityTweet(String location) async {
  var data = await client.tweets.searchRecent(maxResults: 10, expansions: [TweetExpansion.authorId],query: 'place:$location');
  // print(data.data);
  return data.data;
}

// Future<TwitterResponse<List<TweetData>, TweetMeta>>
Future<int> getTweetByLocation(String location) async {

  // var location = "San Francisco";
  var data = await client.tweets.countRecent(query: 'place:$location place_country:US');
  
  // print(data.data);
  // final sampleStream = await client.tweets.connectSampleStream();
  // await for (final response in sampleStream.stream.handleError(print)) {
  //   print(response);
  // }

  // getFilterStream();

  return getTotalTweets(data.data);
}

getJson() async {
  final jsonString = await rootBundle.loadString('../../assets/cities.json');
  return json.decode(jsonString);
}

void getFilterStream() async {
  try {
  await client.tweets.createFilteringRules(
    dryRun: true,
      rules: [
        //         {"value": "dog has:images", "tag": "dog pictures"},
        // {"value": "cat has:images -grumpy", "tag": "cat pictures"},
        FilteringRuleParam(
          value: FilteringRule.ofSample(percent: 50)
          .matchKeyword('dog')
                    .and()
                    .matchCountry(Country.unitedStates)
              .build(),
        ),
      ],
    );

    final filteredStream = await client.tweets.connectFilteredStream();
    await for (final response in filteredStream.stream.handleError(print)) {
      print(response.data);
      print(response.matchingRules);
    }
  } on TimeoutException catch (e) {
    print(e);
  } on UnauthorizedException catch (e) {
    print(e);
  } on RateLimitExceededException catch (e) {
    print(e);
  } on DataNotFoundException catch (e) {
    print(e);
  } on TwitterUploadException catch (e) {
    print(e);
  } on TwitterException catch (e) {
    print(e.response.headers);
    print(e.body);
    print(e);
  }
}

int getTotalTweets(List<TweetCountData> data) {
  int count = 0;
  for (var item in data) {
    count += item.count;
  }
  return count;
}