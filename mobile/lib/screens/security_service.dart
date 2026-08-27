class SecurityService {
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
