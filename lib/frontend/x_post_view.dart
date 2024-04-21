import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class PostView extends StatefulWidget {
  final List<Widget> tweetBoxes;

  const PostView({super.key, required this.tweetBoxes});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          children: widget.tweetBoxes)
      );
  }
}