import 'dart:convert';
_extractRoleFromJwt(String token) {
  /// Attempts to decode a JWT token payload and extract a role string.
  /// Returns null if unable to decode or role not found.
  String? _extractRoleFromJwt(String token) {
    try {
      // JWT expected: header.payload.signature
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];

      // Base64Url decode with proper padding
      String normalized = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final decoded = utf8.decode(
          base64Url.decode(payload)); // use base64Url.decode directly
      final Map<String, dynamic> map = jsonDecode(decoded) as Map<
          String,
          dynamic>;

      // common claim names to check
      final possible = <String>[
        'role',
        'roles',
        'authority',
        'authorities',
        'scope'
      ];
      for (final key in possible) {
        if (map.containsKey(key) && map[key] != null) {
          final val = map[key];
          if (val is String) return val;
          if (val is List && val.isNotEmpty) return val.first.toString();
          if (val is Map) return val.values.join(',');
          return val.toString();
        }
      }

      // maybe role is inside 'user' or 'data'
      if (map.containsKey('user') && map['user'] is Map) {
        final u = map['user'] as Map<String, dynamic>;
        if (u.containsKey('role')) return u['role']?.toString();
      }

      return null;
    } catch (e) {
      print('JWT decode failed: $e');
      return null;
    }
  }
}