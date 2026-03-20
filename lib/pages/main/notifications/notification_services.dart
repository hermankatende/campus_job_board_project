import 'package:cjb/services/api_client.dart';

class NotificationService {
  final _api = ApiClient.instance;

  Future<void> sendNotification(String token, String title, String body) async {
    try {
      await _api.post('/api/common/send-notification/', {
        'token': token,
        'title': title,
        'body': body,
      });
    } on ApiException catch (e) {
      // ignore_for_file: avoid_print
      print('Failed to send notification: ${e.message}');
    }
  }

  Future<void> sendNotificationsToSubscribers(
      String jobCategory, List<String> tokens) async {
    for (final token in tokens) {
      await sendNotification(
          token, 'New job posted', 'A new $jobCategory job has been posted');
    }
  }
}
