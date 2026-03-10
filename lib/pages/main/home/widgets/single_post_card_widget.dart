// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cjb/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:cjb/data/post_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SinglePostCardWidget extends StatefulWidget {
  final PostEntity post;
  const SinglePostCardWidget({super.key, required this.post});

  @override
  State<SinglePostCardWidget> createState() => _SinglePostCardWidgetState();
}

class _SinglePostCardWidgetState extends State<SinglePostCardWidget> {
  Future<List<String>> _fetchPostImages() async {
    List<String> imageUrls = [];
    try {
      if (widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty) {
        imageUrls = [widget.post.imageUrl!];
      }
    } catch (e) {
      print('Error fetching post images: $e');
    }
    return imageUrls;
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                      width: 70,
                      height: 70,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: CircleAvatar(
                            backgroundImage: AssetImage('assets/holder.jpeg'),
                            radius: 20,
                          ))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.post.username ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _openBottomModalSheet();
                              },
                              child: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                        Text(
                          widget.post.email ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _launchURL('https://samuelms46.github.io/');
                              },
                              child: Text(
                                '# campus Job board',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.blue),
                              ),
                            ),
                            const Icon(
                              Icons.public,
                              size: 15,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.post.description ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
        FutureBuilder<List<String>>(
          future: _fetchPostImages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(); // Removed CircularProgressIndicator
            } else if (snapshot.hasError) {
              print('Snapshot Error: ${snapshot.error}');
              return const Center(child: Text('Error fetching images'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                width: double.infinity,
                color: Colors.grey,
                child: const Center(child: Text('No images available')),
              );
            } else {
              List<String> imageUrls = snapshot.data!;
              return SizedBox(
                height: 350,
                child: PageView.builder(
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      height: 350,
                      color: Colors.grey,
                      child: CachedNetworkImage(
                        imageUrl: imageUrls[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Center(child: Icon(Icons.error)),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                child: _singleReactItemWidget(
                    bgColor: Colors.blue.shade200, image: "thumbs_up.png"),
              ),
              Positioned(
                left: 16,
                child: _singleReactItemWidget(
                    bgColor: Colors.red.shade200, image: "love.png"),
              ),
              Positioned(
                left: 34,
                child: _singleReactItemWidget(
                    bgColor: Colors.amber.shade200, image: "insightful.png"),
              ),
              Positioned(
                left: 70,
                child: Text("${0}"),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "${0} comments - ",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                  Text(
                    "${0} shared",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _singleActionItemWidget(
                icon: Icons.thumb_up_alt_outlined, title: "Like"),
            _singleActionItemWidget(icon: Icons.comment, title: "Comment"),
            _singleActionItemWidget(icon: Icons.share, title: "share"),
            // _singleActionItemWidget(icon: Icons.send, title: "Send"),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 8,
          color: Colors.grey.shade300,
        ),
      ],
    );
  }

  _singleActionItemWidget({IconData? icon, String? title}) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.grey,
        ),
        Text(
          "$title",
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  _singleReactItemWidget({String? image, Color? bgColor}) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: Colors.white),
      ),
      child: Image.asset(
        "assets/$image",
        width: 10,
        height: 10,
      ),
    );
  }

  void _openBottomModalSheet() {
    showModalBottomSheet(
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            color: cjbWhiteFFFFFF,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: cjbMediumGrey86888A),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                _bottomNavigationItem(
                    title: "Save", iconData: Icons.bookmark_border),
                const SizedBox(
                  height: 30,
                ),
                _bottomNavigationItem(
                    title: "Share via", iconData: Icons.share),
                const SizedBox(
                  height: 30,
                ),
                _bottomNavigationItem(
                    title: "Chat with: ${widget.post.username}",
                    iconData: Icons.chat_bubble),
                const SizedBox(
                  height: 30,
                ),
                _bottomNavigationItem(
                    title: "Remove connection with ${widget.post.username}",
                    iconData: Icons.person_remove),
                const SizedBox(
                  height: 30,
                ),
                _bottomNavigationItem(
                    title: "Mute ${widget.post.username}",
                    iconData: FontAwesomeIcons.volumeXmark),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _bottomNavigationItem({IconData? iconData, String? title}) {
    return Row(
      children: [
        Icon(
          iconData,
          size: 25,
          color: cjbMediumGrey86888A,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            "$title",
            style: const TextStyle(
                fontSize: 16,
                color: cjbMediumGrey86888A,
                fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
