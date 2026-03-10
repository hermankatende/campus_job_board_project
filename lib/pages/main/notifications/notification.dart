import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Notification_Page extends StatefulWidget {
  const Notification_Page({super.key});

  @override
  State<Notification_Page> createState() => _Notification_PageState();
}

class _Notification_PageState extends State<Notification_Page> {
  Box? notificationsBox;

  @override
  void initState() {
    super.initState();
    notificationsBox = Hive.box('notifications');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ValueListenableBuilder(
        valueListenable: notificationsBox!.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return Center(
              child: Text('No notifications'),
            );
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              var notification = box.getAt(index);
              return ListTile(
                title: Text(notification['title']),
                subtitle: Text(notification['body']),
              );
            },
          );
        },
      ),
    );
  }
}
