import 'dart:html';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:x_developer_competition/backend/x_api.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:twitter_oembed_api/twitter_oembed_api.dart';
import 'package:flutter_html/flutter_html.dart' as html;


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(45.521563, -122.677433);

  final int redBound = 500;
  final int yellowBound = 300;
  final int greenBound = 100;

  final vegasCoords = [36.1716, -115.1391];
  final sfCoords = [37.77, -122.42];
  final laCoords = [34.052235, -118.243683];

  CameraPosition camera = CameraPosition(target: LatLng(0, 0));

  List<dynamic> cityData = [];

  int circleNum = 0;

  Set<Circle> heatCircles = <Circle>{};
  Set<Marker> markers = <Marker>{};

  final radius = 20;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<Widget> getTweetEmbed(TweetData tweet) async {
    final twitterApi = TwitterOEmbedApi();

    try {
      // You can get the embedded tweet by specifying the tweet ID.
      final embeddedTweet = await twitterApi.publishEmbeddedTweet(
        screenName: tweet.authorId!,
        tweetId: tweet.id,
        maxWidth: 550,
        align: ContentAlign.center,
      );

      print(embeddedTweet.html);
      return html.Html(data: embeddedTweet.html);
    } on TwitterOEmbedException catch (e) {
      print(e);
      return Text("not founc");
    }
  }

  Widget makeTweetBox(TweetData tweet, double tweetNum) {
    // getTweetEmbed(tweet);
    // WebViewController controller = WebViewController.fromPlatformCreationParams(PlatformWebViewControllerCreationParams());
    return Container(
      child: Column(
        children: [
          Text("Total users in that area: ${tweetNum.toString()}"),
          Text(tweet.text),
          TextButton(onPressed: () {
            launchUrl(Uri.parse("https://twitter.com/${tweet.authorId}/status/${tweet.id}"));
          }, child: const Text("Launch Tweet")),
          // WebViewWidget(controller: controller)
        ],
        ),
    );
}

  Circle constructCircle(LatLng location, double multiplier, Color color, double userNum, String cityName) {
    var circ = Circle(
      center: location,
      fillColor: color, 
      radius: radius * multiplier,
      strokeWidth: 0,
      circleId: CircleId(circleNum.toString()),
      onTap: () {
        getCityTweet(cityName).then((value) {
          showDialog(context: context, builder: (_) => CupertinoAlertDialog(title: Text(cityName), content: makeTweetBox(value[Random().nextInt(10)], userNum)));    
        });
        
        
      }
      );
      circleNum += 1;
    return circ;
  }

  Set<Circle> makeHeatCircles(double num, LatLng location, String name) {
    Set<Circle> newCircles = <Circle>{};
    double numCircles = 60; 
    Color color = Colors.red;

    if (num > 300 && num < 500) {
      color = Colors.yellow;
    } else if (num < 300) {
      color = Colors.green;
    }    

    for (double i = 0; i <= numCircles; i++) {
      if (num < 1000) {
        markers.add(Marker(markerId: MarkerId("$name"), position: location, 
        onTap: () {
          setState(() {
            double zoom = 10;
            if (num < 200) {
              zoom = 15;
            } else if (num < 300) {
              zoom = 14;
            } else if (num < 400) {
              zoom = 13;
            }
            mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: location, zoom: zoom)));
          });
        }));
      }
      newCircles.add(constructCircle(location, 0.6 * (i/(numCircles*2))*num, color.withOpacity(0.1 * (i/numCircles)), num, name));
    }   

    // if (num > redBound) {
    //   for (double i = 0; i < 100; i++) {
    //     // newCircles.add(constructCircle(location, 2 * (i * 0.1), Colors.green.withOpacity(opacity)));
    //     // newCircles.add(constructCircle(location, 1 * (i * 0.05), Colors.yellow.withOpacity(opacity)));
    //     newCircles.add(constructCircle(location, 0.5 * (i * 0.05), Colors.red.withOpacity(opacity)));
    //   }
      
      
    // } else if (num > yellowBound && num < redBound) {
    //   for (double i = 0; i < 10; i++) {
    //     newCircles.add(constructCircle(location, i * 0.5, Colors.yellow.withOpacity(opacity)));
    //     newCircles.add(constructCircle(location, i * 0.5, Colors.green.withOpacity(opacity)));
    //   }
    // } else {
    //   for (double i = 0; i < 10; i++) {
    //     newCircles.add(constructCircle(location, i * 0.5, Colors.green.withOpacity(opacity)));
    //   }
    // }

    return newCircles;
  }

  Future<Set<Circle>> getCircles() async {
    int sf = await getTweetByLocation("san francisco");
    int la = await getTweetByLocation("Los Angeles");
    int vegas = await getTweetByLocation("Los Angeles");

    Set<Circle> circles = {};

    int total = 0;

    for (var city in cityData) {
      if (total >= 10) {
        break;
      }
      int tweetsInCity = await getTweetByLocation(city['city']);
      print("${city['city']}: $tweetsInCity");
      circles.addAll(makeHeatCircles(tweetsInCity.toDouble(), LatLng(city['latitude'], city['longitude']), city['city']));
      total += 1;
    }

    return circles;
  }

  @override
  void initState() {
    setState(() {
      camera = CameraPosition(target: _center, zoom: 11.0);
    });
    getJson().then((value) {
        setState(() {
          cityData = value;
        }); 
        getCircles().then((value) {
          setState(() => heatCircles = value);
        });
    });
    
    super.initState();
  }

  _updateCircles(Set<Circle> circles) {
    setState(() {
      heatCircles.addAll(circles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.5),
          centerTitle: false,
          leading: InkWell(child: const Image(height: 75,image: AssetImage("../../assets/xlogo.png")), onTap: () {
            launchUrl(Uri.parse("https://twitter.com/"));
          },),
          title: const Text('Twitter Heat Map', style: TextStyle(color: Colors.white),),
          elevation: 2,
          ),
        body: GoogleMap(
          markers: markers,
          circles: heatCircles,
          onMapCreated: _onMapCreated,
          initialCameraPosition: camera,
        ),
      ),
    );
  }
}