import 'dart:convert';
import 'package:crypto/crypto.dart';

class SecurityService {
  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*()]'))) return false;
    return true;
  }

  static String sanitizeInput(String input) {
    return input.replaceAll(RegExp(r'''[<>"']'''), '').trim();
  }
}
