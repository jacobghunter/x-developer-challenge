// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart';
// import 'package:url_launcher/url_launcher_string.dart';
import 'package:x_developer_competition/backend/x_api.dart';
// import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:twitter_oembed_api/twitter_oembed_api.dart';
import 'package:flutter_html/flutter_html.dart' as html;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:linked_text_splitter/linked_text_splitter.dart';
import 'package:location/location.dart';

// TODO: search tweets when clicking on map


void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoogleMapController mapController;

  // final LatLng _center = const LatLng(45.521563, -122.677433);

  final int redBound = 500;
  final int yellowBound = 300;
  final int greenBound = 100;

  final vegasCoords = [36.1716, -115.1391];
  final sfCoords = [37.77, -122.42];
  final laCoords = [34.052235, -118.243683];

  late LatLng _target;
  final Location location = Location();
  late LatLng currentLoc;

  late CameraPosition camera;

  List<dynamic> cityData = [];

  int circleNum = 0;

  bool tweetsView = false;

  Widget tweets = Text("Error");

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

  Widget makeTweetBox(TwitterResponse tweet, int index) {
    var data = tweet.data[index];
    var users = tweet.includes!.users;
    var image;
    try {
      image = users![index].profileImageUrl!;
    } catch (e) {
      image = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fillustrations%2Fmissing-file-icon&psig=AOvVaw1LmCy-kmlkiZTYf7AcYm4i&ust=1713806698382000&source=images&cd=vfe&opi=89978449&ved=0CBIQjRxqFwoTCMCX0c_p04UDFQAAAAAdAAAAABAE";
    }

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), 
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: Offset(0, 3), // changes position of shadow
                                )]),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        child: Image.network(users![index].profileImageUrl!))),
                  ),
                  Expanded(
                    flex: 9,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () {
                              launchUrl(Uri.parse("https://twitter.com/${users![index].username}"));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(users[index].name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.left)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: InkWell(
                            onTap: () {
                              launchUrl(Uri.parse("https://twitter.com/${users![index].username}"));
                            },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("@${users[index].username}", style: const TextStyle(fontSize: 14), textAlign: TextAlign.left,)),
                          ),
                        ),
                      ],
                      ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: RichText(text: TextSpan(
                            children: LinkedTextSplitter.normal(
                              linkStyle: const TextStyle(
                              color: Colors.blue,
                            ),
                            onAtSignTap: (value) {
                              launchUrl(Uri.parse("https://twitter.com/${value.substring(1)}"));
                            },
                            onLinkTap: (value) async {
                              launchUrl(Uri.parse(value));
                            },
                            onHashTagTap: (value) {
                              launchUrl(Uri.parse("https://twitter.com/hashtag/${value.substring(1)}"));
                            }
                            
                          ).create(data.text, const TextStyle(color: Colors.black
                    ))))
                          // Text(data.text)
                          ),
                        const SizedBox(height: 10),
                        TextButton(
                          style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.lightBlueAccent)),
                          onPressed: () {
                          launchUrl(Uri.parse("https://twitter.com/${data.authorId}/status/${data.id}"));
                        }, child: const Text("Launch Tweet", style: TextStyle(color: Colors.black))),
            ],
          ),
        ),
      ),
    );
}

  Circle constructCircle(LatLng location, double multiplier, Color color, double userNum, List<String> cityInfo) {
    var circ = Circle(
      center: location,
      fillColor: color, 
      radius: radius * multiplier,
      strokeWidth: 0,
      circleId: CircleId(circleNum.toString()),
      onTap: () {
        getCityTweets(cityInfo[0]).then((value) {
          List<Widget> tweetBoxes = [];
          for (int i = 0; i < value.data.length - 1; i++) {
            try {
              tweetBoxes.add(makeTweetBox(value, i));
            } catch (e) {}
          }
          // setState(() {
          //   tweetsView = true;
          // });
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => PostView(tweetBoxes: tweetBoxes, city: cityInfo, numPeople: userNum)),
          // );
          var vw = MediaQuery.of(context).size.width;
          var vh = MediaQuery.of(context).size.height;
          showDialog(
            context: context, builder: (_) => Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: vw * 0.4,
                child: PointerInterceptor(
                  child: AlertDialog(
                    surfaceTintColor: Colors.white,
                    alignment: Alignment.centerLeft,
                    // shape: RoundedRectangleBorder(borderRadius: ),
                    title: Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                            Align(
                        alignment: Alignment.center,
                        child: Text("${cityInfo[0]}, ${cityInfo[1]} \n$userNum active users", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), textAlign: TextAlign.center,)),
                        SizedBox(width: 40,)
                        ]
                        )), 
                        titlePadding: EdgeInsets.zero,
                        contentPadding: EdgeInsets.zero, 
                        content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: tweetBoxes),
                          ),
                        ),
                        )
                        ),
                          ),
                        ),
                      ),
            );    
        });
      }
      );
      circleNum += 1;
    return circ;
  }

  Set<Circle> makeHeatCircles(double num, LatLng location, List<String> cityInfo) {
    Set<Circle> newCircles = <Circle>{};
    double numCircles = 60; 
    Color color = Colors.red;

    if (num >= 1500 && num < 15000) {
      color = Colors.orange;
    } else if (num >= 300 && num < 1500) {
      color = Colors.yellow;
    } else if (num < 300) {
      color = Colors.green;
    }    

    for (double i = 0; i <= numCircles; i++) {
      if (num < 1000) {
        markers.add(Marker(markerId: MarkerId("$cityInfo[0]"), position: location, 
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
      newCircles.add(constructCircle(location, 0.6 * (i/(numCircles*2))*num, color.withOpacity(0.1 * (i/numCircles)), num, cityInfo));
    }   

    return newCircles;
  }

  Future<Set<Circle>> getCircles() async {
    // int sf = await getTweetNumByLocation("san francisco");
    // int la = await getTweetNumByLocation("Los Angeles");
    // int vegas = await getTweetNumByLocation("Los Angeles");

    Set<Circle> circles = {};

    int total = 0;

    for (var city in cityData) {
      if (total >=50) {
        break;
      }
      int tweetsInCity = await getTweetNumByLocation(city['city']);
      print("${city['city']}: $tweetsInCity");
      circles.addAll(makeHeatCircles(tweetsInCity.toDouble(), LatLng(city['latitude'], city['longitude']), [city['city'], city['state']]));
      total += 1;
    }

    return circles;
  }

  @override
  void initState() {
    _target = const LatLng(37.7766716, -122.4165386);
    camera = CameraPosition(target: _target, zoom: 7.0);
    location.getLocation().then((value) {
      currentLoc = LatLng(value.latitude!, value.longitude!);
      print(currentLoc);
      // markers.add(Marker(markerId: MarkerId("me"), position: currentLoc, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow)));
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
    var vw = MediaQuery.of(context).size.width;
    var vh = MediaQuery.of(context).size.height;

    Widget body =
      GoogleMap(
        myLocationEnabled: true,
        onCameraMove: (position) {
          // print(position.target);
          setState(() {
            _target = position.target;
            });
        },
              markers: markers,
              circles: heatCircles,
              onMapCreated: _onMapCreated,
              initialCameraPosition: camera,
              zoomControlsEnabled: false);

    // TODO: try doing map and tweets to the side? if not separate page

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
            mapToolbarEnabled: false,
            compassEnabled: false,
            zoomControlsEnabled: false,
            onCameraMove: (position) {
              // print(position.target);
              setState(() {
                _target = position.target;
                });
            },
            onTap: (location) {
              getTweetByLocation(location).then((value) {
              List<Widget> tweetBoxes = [];
              for (int i = 0; i < value.data.length - 1; i++) {
                try {
                  tweetBoxes.add(makeTweetBox(value, i));
                } catch (e) {}
              }
              var vw = MediaQuery.of(context).size.width;
              var vh = MediaQuery.of(context).size.height;
              showDialog(
                context: context, builder: (_) => Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: vw * 0.4,
                    child: PointerInterceptor(
                      child: AlertDialog(
                        surfaceTintColor: Colors.white,
                        alignment: Alignment.centerLeft,
                        // shape: RoundedRectangleBorder(borderRadius: ),
                        title: Row(
                          children: [
                            IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text("Tweets within 25 miles of your click", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,))),
                          ],
                        ), 
                        titlePadding: EdgeInsets.zero,
                        contentPadding: EdgeInsets.zero, 
                        content: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
                          child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: tweetBoxes),
                          ),
                        ),
                        )
                        ),
                    ),
                  ),
                ),
                );
                });
            },
                  markers: markers,
                  circles: heatCircles,
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: camera,),
      ),
    );
  }
}