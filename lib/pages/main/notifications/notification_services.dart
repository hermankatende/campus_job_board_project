import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  final String apiUrl =
      'https://cjb-backend-c13f38f16c2e.herokuapp.com/sendNotification'; // Ensure this is correct

  Future<void> sendNotification(String token, String title, String body) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<void> sendNotificationsToSubscribers(
      String jobCategory, List<String> tokens) async {
    for (String token in tokens) {
      await sendNotification(
          token, 'A new job posted', 'A new $jobCategory job has been posted');
    }
  }
}
