import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/workflow_models.dart';

class MarketplaceException implements Exception {
  MarketplaceException(this.statusCode, this.message);
  final int statusCode;
  final String message;
  @override String toString() => message;
}

class MarketplaceApi {
  MarketplaceApi({http.Client? client, FlutterSecureStorage? storage})
      : client = client ?? http.Client(), storage = storage ?? const FlutterSecureStorage();

  final http.Client client;
  final FlutterSecureStorage storage;
  static const tokenKey = 'kwc_session_token_v1';
  String? token;

  Future<bool> restore() async {
    token = await storage.read(key: tokenKey);
    if (token == null) {
      final preferences = await SharedPreferences.getInstance();
      final legacyToken = preferences.getString(tokenKey);
      if (legacyToken != null) {
        await _saveToken(legacyToken);
        await preferences.remove(tokenKey);
      }
    }
    if (token == null) return false;
    try {
      await request('me');
      return true;
    } on MarketplaceException catch (error) {
      if (error.statusCode == 401) {
        await signOut();
        return false;
      }
      return true;
    } catch (_) {
      // Retain the session and cached profile while the device is offline.
      return true;
    }
  }

  Future<Map<String, dynamic>> request(String resource,
      {String method = 'GET', String? action, Map<String, dynamic>? body,
      Map<String, String>? query}) async {
    final uri = Uri.parse(ApiConfig.baseUrl).replace(path: '/marketplace',
        queryParameters: {'resource': resource, if (action != null) 'action': action, ...?query});
    final request = http.Request(method, uri)
      ..headers.addAll({'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'});
    if (method != 'GET') request.body = jsonEncode(body ?? {});
    late http.Response complete;
    try {
      final response = await client.send(request).timeout(const Duration(seconds: 20));
      complete = await http.Response.fromStream(response).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw MarketplaceException(0, 'Request timed out');
    } on SocketException {
      throw MarketplaceException(0, 'Unable to connect to the server');
    } on http.ClientException {
      throw MarketplaceException(0, 'Unable to connect to the server');
    }
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(complete.body) as Map<String, dynamic>;
    } on FormatException {
      throw MarketplaceException(complete.statusCode, 'Invalid server response');
    }
    if (complete.statusCode >= 400) {
      final message = (decoded['error'] ?? decoded['message'] ?? 'Request failed').toString();
      if (kDebugMode) debugPrint('Marketplace request failed (${complete.statusCode}): $message');
      throw MarketplaceException(complete.statusCode, message);
    }
    return decoded;
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final result = await request('auth',method: 'POST',action: 'login',
        body: {'email': email, 'password': password});
    final data = result['data'] as Map<String, dynamic>;
    await _saveToken(data['token'] as String);
    return data['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(String email, String password, String name,
      UserRole role, String language, String location) async {
    final result = await request('auth',method:'POST',action:'register',body:{
      'email': email.trim().toLowerCase(),'password': password,'name': name.trim(),
      'role': role.name.toUpperCase(),'language': language,'location': location,
    });
    final data = result['data'] as Map<String, dynamic>;
    await _saveToken(data['token'] as String);
    return data['user'] as Map<String, dynamic>;
  }

  Future<void> _saveToken(String value) async {
    await storage.write(key: tokenKey, value: value);
    token = value;
  }

  Future<void> signOut() async {
    if (token != null) {
      try { await request('auth',method:'POST',action:'logout'); } catch (_) { /* Remove local session even if offline. */ }
    }
    token = null;
    await storage.delete(key: tokenKey);
    await (await SharedPreferences.getInstance()).remove(tokenKey);
  }

  Future<void> uploadLot(DigitalLot lot) async {
    if (token == null) throw StateError('Sign in required');
    final material = lot.materials.first;
    await request('lots',method:'POST',body:{
      'clientRef':lot.lotId,'material':material.materialId,
      'category':material.materialId,'weightKg':lot.totalWeightKg,
      'condition':material.condition,'sourceType':material.sourceType,
      'location':lot.collectionLocation.label,'estimatedValue':lot.totalEstimatedValue,
      if(lot.imageBase64.isNotEmpty)'imageBase64':lot.imageBase64.first,
      if(material.detectedMaterialId!=null)'predictedMaterial':material.detectedMaterialId,
      if(material.detectedMaterialId!=null)'confidence':material.confidence,
    });
  }

  Future<List<Map<String,dynamic>>> list(String resource) async {
    final response = await request(resource);
    return (response['data'] as List).cast<Map<String,dynamic>>();
  }

  Future<Map<String,dynamic>> ledger() async =>
      (await request('ledger'))['data'] as Map<String,dynamic>;
}
