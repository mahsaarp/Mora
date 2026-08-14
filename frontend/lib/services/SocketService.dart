import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'session_manager.dart';

class SocketService {
  static const String _serverIp = '172.20.10.7';
  static const int _serverPort = 8888;
  static const String baseUrl = 'http://$_serverIp:$_serverPort';
  static String? loggedInUsername;

  static Future<Map<String, dynamic>> sendRequest({
    required String action,
    Map<String, dynamic>? payload,
  }) async {
    Socket? socket;
    try {
      socket = await Socket.connect(
        _serverIp,
        _serverPort,
        timeout: const Duration(seconds: 5),
      );

      final Map<String, dynamic> requestMap = {
        'action': action,
        'payload': payload ?? {},
      };

      String jsonPayload = jsonEncode(requestMap);
      socket.add(utf8.encode('$jsonPayload\n'));
      await socket.flush();

      String? responseString;
      await for (var line in socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        responseString = line;
        break;
      }

      if (responseString == null || responseString.isEmpty) {
        return {'statusCode': 500, 'message': 'Empty response from server'};
      }

      return jsonDecode(responseString);
    } catch (e) {
      print('Socket Error: $e');
      return {'statusCode': 500, 'message': 'Error $e'};
    } finally {
      await socket?.close();
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    final resp = await sendRequest(action: 'login', payload: {'username': username, 'password': password});
    if (resp['statusCode'] == 200 || resp['success'] == true) {
      loggedInUsername = username;
      final data = resp['data'] ?? {};

      var rawId = data['userId'] ?? data['id'] ?? resp['userId'] ?? resp['id'] ?? data['user']?['id'];
      int? id;
      if (rawId != null) {
        id = int.tryParse(rawId.toString());
      }

      if (id != null && id > 0) {
        await SessionManager().setUser(id, username);
      }
    }
    return resp;
  }

  static Future<Map<String, dynamic>> signUp(String username, String password) async {
    final resp = await sendRequest(action: 'signup', payload: {'username': username, 'password': password});
    if (resp['statusCode'] == 200 || resp['success'] == true) {
      loggedInUsername = username;
      final data = resp['data'] ?? {};

      var rawId = data['userId'] ?? data['id'] ?? resp['userId'] ?? resp['id'] ?? data['user']?['id'];
      int? id;
      if (rawId != null) {
        id = int.tryParse(rawId.toString());
      }

      if (id != null && id > 0) {
        await SessionManager().setUser(id, username);
      }
    }
    return resp;
  }

  static Future<Map<String, dynamic>> logout(String username) async => sendRequest(action: 'logout', payload: {'username': username});
  static Future<Map<String, dynamic>> deleteAccount(String username) async => sendRequest(action: 'deleteAccount', payload: {'username': username});

  static Future<Map<String, dynamic>> updateSettings({String? themeMode, String? themeColor}) async {
    return await sendRequest(action: 'updateSettings', payload: {
      'userId': SessionManager().userId,
      'username': loggedInUsername,
      if (themeMode != null) 'themeMode': themeMode,
      if (themeColor != null) 'themeColor': themeColor,
    });
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String oldUsername,
    String? newUsername,
    String? newPassword,
    String? avatarData,
  }) async {
    return await sendRequest(action: 'updateProfile', payload: {
      'oldUsername': oldUsername,
      if (newUsername != null) 'newUsername': newUsername,
      if (newPassword != null) 'newPassword': newPassword,
      if (avatarData != null) 'avatarData': avatarData,
    });
  }

  static Future<Map<String, dynamic>> getHomePhotos() async => sendRequest(action: 'getHomePhotos');
  static Future<Map<String, dynamic>> downloadPhoto(int photoId) async => sendRequest(action: 'downloadPhoto', payload: {'photoId': photoId});
  static Future<Map<String, dynamic>> uploadPhoto({required String username, required String name, required String fileData, String? caption, List<String>? tags, List<int>? albumIds, bool commentAllowed = true}) async {
    return await sendRequest(action: 'uploadPhoto', payload: {
      'username': username,
      'name': name,
      'fileData': fileData,
      'caption': caption ?? '',
      'tags': tags ?? [],
      'albumIds': albumIds ?? [],
      'commentAllowed': commentAllowed,
    });
  }
  static Future<Map<String, dynamic>> updatePhoto({required int photoId, required String name, required String caption, required List<String> tags, required bool commentAllowed}) async {
    return await sendRequest(action: 'updatePhoto', payload: {'photoId': photoId, 'name': name, 'caption': caption, 'tags': tags, 'commentAllowed': commentAllowed});
  }
  static Future<Map<String, dynamic>> deletePhoto(int photoId) async => sendRequest(action: 'deletePhoto', payload: {'photoId': photoId});
  static Future<Map<String, dynamic>> likePhoto(dynamic userIdOrUsername, int photoId) async => sendRequest(action: 'likePhoto', payload: {'userId': userIdOrUsername, 'photoId': photoId});
  static Future<Map<String, dynamic>> addComment(dynamic userIdOrUsername, int photoId, String text) async => sendRequest(action: 'addComment', payload: {'userId': userIdOrUsername, 'photoId': photoId, 'text': text});

  static Future<Map<String, dynamic>> getAlbums() async => sendRequest(action: 'getAlbums');
  static Future<Map<String, dynamic>> createAlbum({required dynamic userId, required String name, required List<int> photoIds}) async {
    return await sendRequest(action: 'createAlbum', payload: {'userId': userId, 'albumName': name, 'photoIds': photoIds});
  }
  static Future<Map<String, dynamic>> addPhotoToAlbum({required int albumId, required int photoId}) async => sendRequest(action: 'addPhotoToAlbum', payload: {'albumId': albumId, 'photoId': photoId});
  static Future<Map<String, dynamic>> getAlbumDetails(int albumId) async => sendRequest(action: 'getAlbumDetails', payload: {'albumId': albumId});
  static Future<Map<String, dynamic>> removePhotoFromAlbum({required int albumId, required int photoId}) async => sendRequest(action: 'removePhotoFromAlbum', payload: {'albumId': albumId, 'photoId': photoId});
  static Future<Map<String, dynamic>> deleteAlbum(int albumId) async => sendRequest(action: 'deleteAlbum', payload: {'albumId': albumId});

  static Future<Map<String, dynamic>> getUserProfile(String username) async => sendRequest(action: 'getUserProfile', payload: {'username': username});
  static Future<Map<String, dynamic>> getAllUsers() async => sendRequest(action: 'getAllUsers');
  static Future<Map<String, dynamic>> banUser(int userId) async => sendRequest(action: 'banUser', payload: {'userId': userId});
  static Future<Map<String, dynamic>> unbanUser(int userId) async => sendRequest(action: 'unbanUser', payload: {'userId': userId});
  static Future<Map<String, dynamic>> search(String query) async => sendRequest(action: 'search', payload: {'query': query});
}
