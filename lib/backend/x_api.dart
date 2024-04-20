import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'package:http/http.dart' as http;
import 'package:twitter_api_v2/twitter_api_v2.dart';

const baseUrl = 'https://api.twitter.com/2/tweets/search/recent';
const bearerToken = 'AAAAAAAAAAAAAAAAAAAAALGRtQEAAAAAaQubTUgfpHVDhmEwq2rh3YLdUKc%3D6teN3XZzrYsEqOkluWS7e5s8Zl10nCfDj8ZmM9Nb92js7M52Y0';  // Replace with your actual token

Future<http.Response> searchTweets(String query) async {
  // final url = Uri.parse('$baseUrl?query=$query&max_results=100');
  // print(url);
  final headers = {"Access-Control-Allow-Origin": "*"};

  return await http.get(Uri.parse('http://127.0.0.1:5000'), headers: headers);
}

final client = TwitterApi(
  bearerToken: 'AAAAAAAAAAAAAAAAAAAAALGRtQEAAAAAaQubTUgfpHVDhmEwq2rh3YLdUKc%3D6teN3XZzrYsEqOkluWS7e5s8Zl10nCfDj8ZmM9Nb92js7M52Y0', 
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


// Future<TwitterResponse<List<TweetData>, TweetMeta>>
Future<Null> getTweetByLocation(String location) async {
  // var data = await client.tweets.countRecent(query: 'has:geo (from:NWSNHC OR from:NHC_Atlantic OR from:NWSHouston OR from:NWSSanAntonio OR from:USGS_TexasRain OR from:USGS_TexasFlood OR from:JeffLindner1)');
  
  // print(data);
  // final sampleStream = await client.tweets.connectSampleStream();
  //   await for (final response in sampleStream.stream.handleError(print)) {
  //     print(response);
  //   }
  // try {
  // await client.tweets.createFilteringRules(
  //     rules: [
  //       FilteringRuleParam(
  //         //! => #Tesla has:media
  //         value: FilteringRule.of()
  //             .matchHashtag('Tesla')
  //             .build())
  //     ]
  //   );

  //   final filteredStream = await client.tweets.connectFilteredStream();
  //   await for (final response in filteredStream.stream.handleError(print)) {
  //     print(response.data);
  //     print(response.matchingRules);
  //   }
  // } on TimeoutException catch (e) {
  //   print(e);
  // } on UnauthorizedException catch (e) {
  //   print(e);
  // } on RateLimitExceededException catch (e) {
  //   print(e);
  // } on DataNotFoundException catch (e) {
  //   print(e);
  // } on TwitterUploadException catch (e) {
  //   print(e);
  // } on TwitterException catch (e) {
  //   print(e.response.headers);
  //   print(e.body);
  //   print(e);
  // }

    // return tweets;
  
  // print(client.users.lookupMe());
  // client.tweets.searchRecent(query: 'from:suhemparack -is:retweet', tweetFields: [TweetField.contextAnnotations, TweetField.createdAt], maxResults: 100).then((value) {
  //   for (var tweet in value.data) {
  //     print(tweet.text);
  //   }
  // }
  // );
  // print(client);
  // final tweets = await twitter.tweets.searchRecent(
  //     query: '#ElonMusk',
  //     maxResults: 20,
  //     // You can expand the search result.
  //     expansions: [
  //       TweetExpansion.authorId,
  //       TweetExpansion.inReplyToUserId,
  //     ],
  //     tweetFields: [
  //       TweetField.conversationId,
  //       TweetField.publicMetrics,
  //       TweetField.editControls,
  //     ],
  //     userFields: [
  //       UserField.location,
  //       UserField.verified,
  //       UserField.entities,
  //       UserField.publicMetrics,
  //     ],

  //     //! Safe paging is easy to implement.
  //     paging: (event) {
  //       print(event.response);

  //       if (event.count == 3) {
  //         return ForwardPaginationControl.stop();
  //       }

  //       return ForwardPaginationControl.next();
  //     },
  //   );
  // return tweets;
}