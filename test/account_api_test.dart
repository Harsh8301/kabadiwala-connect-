import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kabadiwala_connect/models/workflow_models.dart';
import 'package:kabadiwala_connect/services/marketplace_api.dart';

class MemoryStorage extends FlutterSecureStorage {
  String? value;

  @override
  Future<void> write({required String key, required String? value,
      IOSOptions? iOptions, AndroidOptions? aOptions, LinuxOptions? lOptions,
      WindowsOptions? wOptions, WebOptions? webOptions, MacOsOptions? mOptions}) async {
    this.value = value;
  }

  @override
  Future<String?> read({required String key, IOSOptions? iOptions,
      AndroidOptions? aOptions, LinuxOptions? lOptions,
      WindowsOptions? wOptions, WebOptions? webOptions, MacOsOptions? mOptions}) async => value;
}

void main() {
  test('registration sends backend fields and stores its session', () async {
    final storage = MemoryStorage();
    final api = MarketplaceApi(storage: storage, client: MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/marketplace');
      expect(request.url.queryParameters, {'resource':'auth','action':'register'});
      expect(request.headers['content-type'], 'application/json');
      final payload = jsonDecode(request.body) as Map<String, dynamic>;
      expect(payload, {'email':'anuj@example.com','password':'longpassword123',
        'name':'Anuj','role':'RECYCLER','language':'hi','location':'Nashik'});
      return http.Response(jsonEncode({'data':{'token':'session-value','user':{
        'id':'user-1','email':'anuj@example.com','name':'Anuj',
        'role':'RECYCLER','language':'hi','location':'Nashik'}}}), 201);
    }));
    final user = await api.register('  ANUJ@example.com ', 'longpassword123',
        ' Anuj ', UserRole.recycler, 'hi', 'Nashik');
    expect(user['role'], 'RECYCLER');
    expect(api.token, 'session-value');
    expect(storage.value, 'session-value');
  });

  test('server validation and duplicate responses retain status and message', () async {
    for (final status in [400, 409, 422, 500, 503]) {
      final api = MarketplaceApi(storage: MemoryStorage(), client: MockClient((_) async =>
          http.Response(jsonEncode({'error':'Backend response'}), status)));
      await expectLater(api.register('a@example.com', 'longpassword123', 'A',
          UserRole.collector, 'en', 'Pune'), throwsA(isA<MarketplaceException>()
          .having((error) => error.statusCode, 'status', status)
          .having((error) => error.message, 'message', 'Backend response')));
    }
  });
}
