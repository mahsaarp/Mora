import 'dart:io';
import 'dart:convert';

class SocketService {
  static const String _serverIp = '172.20.10.7';
  static const int _serverPort = 8888;

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

      // ✅ تغییر کلید از 'route' به 'action' برای هماهنگی با بک‌اند جاوا
      final Map<String, dynamic> requestMap = {
        'action': action,
        'payload': payload ?? {},
      };

      String jsonPayload = jsonEncode(requestMap);
      socket.add(utf8.encode('$jsonPayload\n'));
      await socket.flush();

      String responseString = await socket
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .first;

      Map<String, dynamic> responseJson = jsonDecode(responseString);
      return responseJson;
    } catch (e) {
      print('Socket Error: $e');
      return {
        'statusCode': 500,
        'message': 'Error $e',
      };
    } finally {
      await socket?.close();
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    return await sendRequest(
      action: 'login',
      payload: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> signUp(String username, String password) async {
    return await sendRequest(
      action: 'signup',
      payload: {
        'username': username,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> uploadPhoto({
    required int userId,
    required String name,
    required String fileData,
    String? caption,
    bool commentAllowed = true,
  }) async {
    return await sendRequest(
      action: 'uploadPhoto',
      payload: {
        'userId': userId,
        'name': name,
        'fileData': fileData,
        'caption': caption ?? '',
        'commentAllowed': commentAllowed,
      },
    );
  }

  static Future<Map<String, dynamic>> getHomePhotos() async {
    return await sendRequest(action: 'getHomePhotos');
  }

  static Future<Map<String, dynamic>> getUserProfile(String username) async {
    return await sendRequest(
      action: 'getUserProfile',
      payload: {'username': username},
    );
  }

  static Future<Map<String, dynamic>> search(String query) async {
    return await sendRequest(
      action: 'search',
      payload: {'query': query},
    );
  }

  static Future<Map<String, dynamic>> downloadPhoto(int photoId) async {
    return await sendRequest(
      action: 'downloadPhoto',
      payload: {'photoId': photoId},
    );
  }

  static Future<Map<String, dynamic>> likePhoto(int userId, int photoId) async {
    return await sendRequest(
      action: 'likePhoto',
      payload: {'userId': userId, 'photoId': photoId},
    );
  }

  static Future<Map<String, dynamic>> addComment(int userId, int photoId, String text) async {
    return await sendRequest(
      action: 'addComment',
      payload: {'userId': userId, 'photoId': photoId, 'text': text},
    );
  }

  static Future<Map<String, dynamic>> createAlbum({
    required int userId,
    required String name,
    required List<int> photoIds,
  }) async {
    return await sendRequest(
      action: 'createAlbum',
      payload: {
        'userId': userId,
        'name': name,
        'photoIds': photoIds,
      },
    );
  }

  static Future<Map<String, dynamic>> getAlbumDetails(int albumId) async {
    return await sendRequest(
      action: 'getAlbumDetails',
      payload: {'albumId': albumId},
    );
  }
}