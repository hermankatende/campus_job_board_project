// ignore_for_file: prefer_const_constructors

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cjb/data/post_entity.dart';
import 'package:cjb/pages/main/create/posts/post_service.dart';
import 'package:cjb/pages/main/home/widgets/single_post_card_widget.dart';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cjb/theme/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _controller = ScrollController();
  bool _isShow = true;
  late Future<List<PostEntity>> _postsFuture;
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    _postsFuture = _postService.fetchPosts();

    _controller.addListener(() {
      // Using a variable to track if _isShow is already in the desired state
      if (_controller.position.pixels > 3 && _isShow) {
        setState(() {
          _isShow = false;
        });
      } else if (_controller.position.pixels <= 3 && !_isShow) {
        setState(() {
          _isShow = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 5),
          _isShow
              ? Container(
                  width: double.infinity,
                  height: 8,
                  color: cjbLightGreyCACCCE,
                )
              : Container(),
          Expanded(
            child: FutureBuilder<List<PostEntity>>(
              future: _postsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: SpinKitWanderingCubes(
                    color: Colors.blue[900],
                    size: 50.0,
                  ));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No posts available'));
                }

                List<PostEntity> posts = snapshot.data!;

                return ListView.builder(
                  controller: _controller,
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return SinglePostCardWidget(post: post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
