import 'package:flutter/material.dart';
import 'package:mailer/smtp_server/gmail.dart';

import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SupportPage extends StatefulWidget {
  @override
  _SupportPageState createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final _messageController = TextEditingController();

  void _sendEmail() async {
    final email = 'hermankats16@gmail.com';
    final subject = 'User Feedback';
    final body = _messageController.text;

    final smtpServer = gmail('cjbapp2024@gmail.com',
        'zbsu pkgj ghep msyn'); // Update with your SMTP server details

    final message = Message()
      ..from = Address('cjbapp2024@gmail.com')
      ..recipients.add(email)
      ..subject = subject
      ..text = body;

    try {
      final sendReport = await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sent: ${sendReport.toString()}')),
      );
      _messageController.clear();
    } on MailerException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message not sent. $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _messageController,
              decoration: InputDecoration(labelText: 'Enter your question'),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _sendEmail,
              child: Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
