import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  // For Android emulator, use: http://10.0.2.2:3000/api
  // For iOS simulator, use: http://localhost:3000/api
  // For physical device, use your computer's IP: http://192.168.1.x:3000/api

  static Future<Map<String, dynamic>> requestOTP(String email,String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/request-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password':password
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to request OTP');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to verify OTP');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> verifyToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/verify-token/$token'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}