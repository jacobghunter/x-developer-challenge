import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PostView extends StatefulWidget {
  final List<Widget> tweetBoxes;
  final List<String> city;
  final double numPeople;

  const PostView({super.key, required this.tweetBoxes, required this.city, required this.numPeople});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.city[0]}, ${widget.city[1]}. Total people posting here: ${widget.numPeople}"),
      ),
      body: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: widget.tweetBoxes)
      );
  }
}