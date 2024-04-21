import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:x_developer_competition/backend/x_api.dart';

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

  int circleNum = 0;

  Set<Circle> heatCircles = <Circle>{};
  final radius = 20;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Circle constructCircle(LatLng location, double multiplier, Color color) {
    var circ = Circle(
      center: location,
      fillColor: color, 
      radius: radius * multiplier,
      strokeWidth: 0,
      circleId: CircleId(circleNum.toString())
      );
      circleNum += 1;
    return circ;
  }

  Set<Circle> makeHeatCircles(double num, LatLng location) {
    Set<Circle> newCircles = <Circle>{};
    double numCircles = 60; 
    
    for (double i = 0; i <= numCircles; i++) {
      newCircles.add(constructCircle(location, 0.5 * (i/(numCircles*2))*num, Colors.red.withOpacity(0.15 * (i/numCircles))));
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
    
    var first = makeHeatCircles(sf.toDouble(), LatLng(sfCoords[0], sfCoords[1]));
    first.addAll(makeHeatCircles(la.toDouble(), LatLng(laCoords[0], laCoords[1])));
    first.addAll(makeHeatCircles(vegas.toDouble(), LatLng(vegasCoords[0], vegasCoords[1])));
    return first;
  }

  @override
  void initState() {
    getCircles().then((value) {
      setState(() => heatCircles = value);
      
    },);
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
        appBar: AppBar(
          actions: [TextButton(child: Text("joe page :)"), onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            // WishList(listOfItemIds: data_store.user.wishlist)
            return Text("here");
          }
                      ));
        })],
          title: const Text('Maps Sample App'),
          elevation: 2,
        ),
        body: GoogleMap(
          circles: heatCircles,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}