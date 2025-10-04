import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

Future<void> sendOtpEmail(String email, String otp) async {
  final smtpServer = gmail(email, 'your_app_password');

  final message = Message()
    ..from = Address('your_gmail@gmail.com', 'Password Manager Demo')
    ..recipients.add(email)
    ..subject = 'Your OTP Code'
    ..text = 'Your OTP is: $otp';

  try {
    await send(message, smtpServer);
    print("OTP sent successfully");
  } catch (e) {
    print("Failed to send OTP: $e");
  }
}
