// lib/APiServices/api_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Models/login_model.dart';
import '../Models/categery_model.dart';
import '../Models/page_data_Model.dart';
import '../Models/vendor_model.dart';
import 'common_repo.dart';

const String defaultBaseUrl = "http://192.168.1.101:3030";

class ApiService {
  final http.Client _client;
  final String baseUrl;

  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? defaultBaseUrl;

  // ---------- Auth ----------
  Future<CommonResponse<LoginModel>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');

    print('🔹 [API CALL] POST: $uri');
    print('🔹 Request Body: { "email": "$email", "password": "••••" }');

    try {
      final body = jsonEncode({'email': email, 'password': password});
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('✅ [API RESPONSE] Status Code: ${response.statusCode}');
      final rawBody = response.bodyBytes.isEmpty ? '' : utf8.decode(response.bodyBytes);
      print('✅ Raw Body: ${rawBody.isEmpty ? "<empty>" : rawBody}');

      if (rawBody.trim().isEmpty) {
        final msg = response.reasonPhrase ?? 'Empty response from server';
        return CommonResponse<LoginModel>(message: msg, success: false, data: null);
      }

      dynamic parsed;
      try {
        parsed = jsonDecode(rawBody);
      } catch (e) {
        print('❌ JSON decode error: $e');
        return CommonResponse<LoginModel>(message: 'Invalid JSON response', success: false, data: null);
      }

      if (parsed is! Map<String, dynamic>) {
        return CommonResponse<LoginModel>(message: 'Unexpected response structure', success: false, data: null);
      }

      final commonResp = CommonResponse<LoginModel>.fromJson(
        parsed,
            (data) => LoginModel.fromJson(data as Map<String, dynamic>),
      );

      return commonResp;
    } catch (e, st) {
      print('❌ [API ERROR] Exception during login: $e\n$st');
      return CommonResponse<LoginModel>(message: 'Login failed: $e', success: false, data: null);
    }
  }

  Future<CommonResponse<dynamic>> register({
    required String email,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/api/auth/register');
    print('🔹 [API CALL] POST: $uri');

    try {
      final payload = {'email': email, 'fullName': fullName, 'password': password, 'role': role.toUpperCase()};
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.body.trim().isEmpty) {
        return CommonResponse<dynamic>(message: response.reasonPhrase ?? 'Empty response', success: false, data: null);
      }

      dynamic parsed;
      try {
        parsed = jsonDecode(response.body);
      } catch (e) {
        return CommonResponse<dynamic>(message: 'Invalid JSON response', success: false, data: null);
      }

      if (parsed is! Map<String, dynamic>) {
        return CommonResponse<dynamic>(message: 'Unexpected response structure', success: false, data: null);
      }

      final commonResp = CommonResponse<dynamic>.fromJson(parsed, (d) => d);
      return commonResp;
    } catch (e, st) {
      print('❌ [API ERROR] Exception during register: $e\n$st');
      return CommonResponse<dynamic>(message: 'Register failed: $e', success: false, data: null);
    }
  }

  // ---------- Categories ----------
  Future<CommonResponse<PagedData<Category>>> getCategories({
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/api/categories').replace(queryParameters: {
      'page': page.toString(),
      'size': size.toString(),
    });
    print('GET $uri');

    try {
      final response = await _client.get(uri, headers: {'Accept': 'application/json'});
      final raw = response.body;
      if (raw.trim().isEmpty) {
        return CommonResponse<PagedData<Category>>(message: response.reasonPhrase ?? 'Empty response', success: false, data: null);
      }

      final parsed = jsonDecode(raw);
      if (parsed is! Map<String, dynamic>) {
        return CommonResponse<PagedData<Category>>(message: 'Unexpected structure', success: false, data: null);
      }

      final commonResp = CommonResponse<PagedData<Category>>.fromJson(
        parsed,
            (data) => PagedData<Category>.fromJson(data as Map<String, dynamic>, (item) => Category.fromJson(item as Map<String, dynamic>)),
      );

      return commonResp;
    } catch (e, st) {
      print('getCategories error: $e\n$st');
      return CommonResponse<PagedData<Category>>(message: 'Network error: $e', success: false, data: null);
    }
  }

  // ---------- Profile ----------
  Future<CommonResponse<dynamic>> getProfile() async {
    final uri = Uri.parse('$baseUrl/api/auth/me');
    final storage = const FlutterSecureStorage();

    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null || token.trim().isEmpty) {
        return CommonResponse<dynamic>(message: 'No auth token found', success: false, data: null);
      }

      final response = await _client.get(uri, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.body.trim().isEmpty) {
        return CommonResponse<dynamic>(message: response.reasonPhrase ?? 'Empty response', success: false, data: null);
      }

      final parsed = jsonDecode(response.body);
      if (parsed is! Map<String, dynamic>) {
        return CommonResponse<dynamic>(message: 'Unexpected response structure', success: false, data: null);
      }

      return CommonResponse<dynamic>.fromJson(parsed, (d) => d);
    } catch (e, st) {
      print('getProfile error: $e\n$st');
      return CommonResponse<dynamic>(message: 'Failed to fetch profile: $e', success: false, data: null);
    }
  }

  // ---------- Vendors ----------
  Future<CommonResponse<PagedData<Vendor>>> getVendors({
    int page = 0,
    int size = 20,
    int? categoryId,
  }) async {
    final params = {
      'page': page.toString(),
      'size': size.toString(),
      if (categoryId != null && categoryId > 0) 'categoryId': categoryId.toString(),
    };

    final uri = Uri.parse('$baseUrl/api/vendors?page=0&size=20&categoryId=1').replace(queryParameters: params);
    print('GET $uri');

    try {
      final resp = await _client.get(uri, headers: {'Accept': 'application/json'});
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return CommonResponse<PagedData<Vendor>>(success: false, message: 'Server returned ${resp.statusCode}', data: null);
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! Map<String, dynamic>) {
        return CommonResponse<PagedData<Vendor>>(success: false, message: 'Invalid JSON', data: null);
      }

      final data = PagedData<Vendor>.fromJson(decoded, (e) => Vendor.fromJson(e as Map<String, dynamic>));

      return CommonResponse<PagedData<Vendor>>(success: true, message: 'OK', data: data);
    } catch (e, st) {
      print('getVendors error: $e\n$st');
      return CommonResponse<PagedData<Vendor>>(success: false, message: 'Network error: $e', data: null);
    }
  }
}


