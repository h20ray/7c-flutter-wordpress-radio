import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../config/wp_config.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/logger/app_logger.dart';
import '../models/shoutbox_message_model.dart';

/// Remote data source for shoutbox operations
abstract class ShoutboxRemoteDataSource {
  Future<List<ShoutboxMessageModel>> getMessages({
    int afterId = 0,
    int limit = 50,
  });

  Future<ShoutboxMessageModel> sendMessage({
    required String username,
    required String message,
  });

  Future<String> deleteMessage(int messageId);

  Future<int> getLatestMessageId();
}

/// Implementation of shoutbox remote data source
class ShoutboxRemoteDataSourceImpl implements ShoutboxRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  ShoutboxRemoteDataSourceImpl({
    required this.dio,
    String? baseUrl,
  }) : baseUrl = baseUrl ?? 'https://${WPConfig.url}';

  @override
  Future<List<ShoutboxMessageModel>> getMessages({
    int afterId = 0,
    int limit = 50,
  }) async {
    final url = '$baseUrl/wp-json/tujuhcahaya/shoutbox/messages';
    if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
      Log.debug('[ShoutboxDataSource] Fetching messages from: $url');
    }
    if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
      Log.debug('[ShoutboxDataSource] Query params: afterId=$afterId, limit=$limit');
    }

    try {
      final response = await dio.get(
        url,
        queryParameters: {
          'after_id': afterId,
          'limit': limit,
        },
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Response status: ${response.statusCode}');
      }
      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Response data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        
        // Handle WordPress plugin response format: {messages: [], total: 0, status: ok}
        if (jsonData.containsKey('messages') && jsonData['status'] == 'ok') {
          final messagesData = jsonData['messages'] as List<dynamic>;
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully fetched ${messagesData.length} messages');
          }
          return messagesData
              .map((json) => ShoutboxMessageModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        // Handle alternative format: {success: true, data: [], last_id: 0}
        else if (jsonData['success'] == true) {
          final messagesData = jsonData['data'] as List<dynamic>;
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully fetched ${messagesData.length} messages (alternative format)');
          }
          return messagesData
              .map((json) => ShoutboxMessageModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          Log.error('[ShoutboxDataSource] API returned error: ${jsonData['message'] ?? jsonData['status']}');
          throw ServerException(jsonData['message'] ?? 'shoutbox_failed_fetch'.tr());
        }
      } else if (response.statusCode == 429) {
        final jsonData = response.data as Map<String, dynamic>;
        Log.error('[ShoutboxDataSource] Rate limit exceeded: ${jsonData['message']}');
        throw RateLimitException(jsonData['message'] ?? 'shoutbox_rate_limit'.tr());
      } else {
        Log.error('[ShoutboxDataSource] HTTP error ${response.statusCode}: ${response.data}');
        throw ServerException('${'shoutbox_failed_fetch'.tr()}: ${response.statusCode}');
      }
    } catch (e) {
      Log.error('[ShoutboxDataSource] Exception in getMessages: $e');
      
      // Handle DioException types
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            Log.warning('[ShoutboxDataSource] Request timeout - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_timeout'.tr());
          case DioExceptionType.connectionError:
            Log.warning('[ShoutboxDataSource] Connection error - throwing NetworkException');
            throw NetworkException('shoutbox_connection_error'.tr());
          case DioExceptionType.unknown:
            // Handle unknown DioException (often contains HttpException)
            if (e.error != null && e.error.toString().contains('Connection closed before full header was received')) {
              Log.warning('[ShoutboxDataSource] Connection closed before headers received - throwing NetworkException');
              throw NetworkException('shoutbox_connection_lost'.tr());
            } else if (e.error != null && e.error.toString().contains('HttpException')) {
              Log.warning('[ShoutboxDataSource] HttpException in unknown DioException - throwing NetworkException');
              throw NetworkException('shoutbox_network_error'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Unknown DioException - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            }
          case DioExceptionType.badResponse:
            // Handle bad response (4xx, 5xx)
            if (e.response?.statusCode == 404) {
              Log.warning('[ShoutboxDataSource] API endpoint not available (404) - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Bad response ${e.response?.statusCode} - throwing ServerException');
              throw ServerException('shoutbox_server_error'.tr());
            }
          case DioExceptionType.cancel:
            Log.warning('[ShoutboxDataSource] Request cancelled - throwing NetworkException');
            throw NetworkException('shoutbox_request_cancelled'.tr());
          default:
            Log.warning('[ShoutboxDataSource] Unhandled DioException type: ${e.type} - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
        }
      }
      
      // Handle HttpException directly
      if (e.toString().contains('HttpException')) {
        if (e.toString().contains('Connection closed before full header was received')) {
          Log.warning('[ShoutboxDataSource] Connection closed before headers received - throwing NetworkException');
          throw NetworkException('shoutbox_connection_lost'.tr());
        } else {
          Log.warning('[ShoutboxDataSource] HttpException - throwing NetworkException');
          throw NetworkException('shoutbox_network_error'.tr());
        }
      }
      
      // Handle 404 specifically - API endpoint not available
      if (e.toString().contains('404')) {
        Log.warning('[ShoutboxDataSource] Shoutbox API endpoint not available (404) - throwing ApiUnavailableException');
        throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
      }
      
      rethrow;
    }
  }

  @override
  Future<ShoutboxMessageModel> sendMessage({
    required String username,
    required String message,
  }) async {
    final url = '$baseUrl/wp-json/tujuhcahaya/shoutbox/messages';
    final data = {
      'username': username,
      'message': message,
    };
    
    if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
      Log.debug('[ShoutboxDataSource] Sending message to: $url');
    }
    if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
      Log.debug('[ShoutboxDataSource] Message data: $data');
    }

    try {
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Cache-Control': 'no-cache',
            'Pragma': 'no-cache',
          },
        ),
      );

      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Send response status: ${response.statusCode}');
      }
      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Send response data: ${response.data}');
      }

      if (response.statusCode == 201) {
        final jsonData = response.data as Map<String, dynamic>;
        
        // Handle WordPress plugin response format: {status: 'success', data: {...}}
        if (jsonData['status'] == 'success' && jsonData.containsKey('data')) {
          final messageData = jsonData['data'] as Map<String, dynamic>;
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully sent message (WordPress format)');
          }
          // Create a complete message object with required fields
          final completeMessageData = {
            'id': DateTime.now().millisecondsSinceEpoch, // Generate temporary ID
            'user_id': 0,
            'username': messageData['username'] ?? username,
            'message': messageData['message'] ?? message,
            'created_at': messageData['timestamp'] ?? DateTime.now().toIso8601String(),
            'is_admin': false,
          };
          return ShoutboxMessageModel.fromJson(completeMessageData);
        }
        // Handle alternative format: {success: true, data: {...}}
        else if (jsonData['success'] == true) {
          final messageData = jsonData['data'] as Map<String, dynamic>;
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully sent message (alternative format)');
          }
          return ShoutboxMessageModel.fromJson(messageData);
        } else {
          Log.error('[ShoutboxDataSource] Send failed - API returned error: ${jsonData['message']}');
          throw ServerException(jsonData['message'] ?? 'shoutbox_failed_send'.tr());
        }
      } else if (response.statusCode == 400) {
        final jsonData = response.data as Map<String, dynamic>;
        Log.error('[ShoutboxDataSource] Validation error: ${jsonData['message']}');
        throw ValidationException(jsonData['message'] ?? 'shoutbox_invalid_data'.tr());
      } else if (response.statusCode == 429) {
        final jsonData = response.data as Map<String, dynamic>;
        Log.error('[ShoutboxDataSource] Rate limit exceeded on send: ${jsonData['message']}');
        throw RateLimitException(jsonData['message'] ?? 'shoutbox_rate_limit'.tr());
      } else if (response.statusCode == 403) {
        final jsonData = response.data as Map<String, dynamic>;
        Log.error('[ShoutboxDataSource] Shoutbox disabled: ${jsonData['message']}');
        throw ServerException(jsonData['message'] ?? 'shoutbox_disabled'.tr());
      } else {
        Log.error('[ShoutboxDataSource] Send HTTP error ${response.statusCode}: ${response.data}');
        throw ServerException('${'shoutbox_failed_send'.tr()}: ${response.statusCode}');
      }
    } catch (e) {
      Log.error('[ShoutboxDataSource] Exception in sendMessage: $e');
      
      // Handle DioException types
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            Log.warning('[ShoutboxDataSource] Send request timeout - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_timeout'.tr());
          case DioExceptionType.connectionError:
            Log.warning('[ShoutboxDataSource] Send connection error - throwing NetworkException');
            throw NetworkException('shoutbox_connection_error'.tr());
          case DioExceptionType.unknown:
            // Handle unknown DioException (often contains HttpException)
            if (e.error != null && e.error.toString().contains('Connection closed before full header was received')) {
              Log.warning('[ShoutboxDataSource] Send connection closed before headers received - throwing NetworkException');
              throw NetworkException('shoutbox_connection_lost'.tr());
            } else if (e.error != null && e.error.toString().contains('HttpException')) {
              Log.warning('[ShoutboxDataSource] Send HttpException in unknown DioException - throwing NetworkException');
              throw NetworkException('shoutbox_network_error'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Send unknown DioException - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            }
          case DioExceptionType.badResponse:
            // Handle bad response (4xx, 5xx)
            if (e.response?.statusCode == 404) {
              Log.warning('[ShoutboxDataSource] Send API endpoint not available (404) - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Send bad response ${e.response?.statusCode} - throwing ServerException');
              throw ServerException('shoutbox_server_error'.tr());
            }
          case DioExceptionType.cancel:
            Log.warning('[ShoutboxDataSource] Send request cancelled - throwing NetworkException');
            throw NetworkException('shoutbox_request_cancelled'.tr());
          default:
            Log.warning('[ShoutboxDataSource] Send unhandled DioException type: ${e.type} - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
        }
      }
      
      // Handle HttpException directly
      if (e.toString().contains('HttpException')) {
        if (e.toString().contains('Connection closed before full header was received')) {
          Log.warning('[ShoutboxDataSource] Send connection closed before headers received - throwing NetworkException');
          throw NetworkException('shoutbox_connection_lost'.tr());
        } else {
          Log.warning('[ShoutboxDataSource] Send HttpException - throwing NetworkException');
          throw NetworkException('shoutbox_network_error'.tr());
        }
      }
      
      // Handle 404 specifically - API endpoint not available
      if (e.toString().contains('404')) {
        Log.warning('[ShoutboxDataSource] Shoutbox API endpoint not available (404) - throwing ApiUnavailableException');
        throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
      }
      
      rethrow;
    }
  }

  @override
  Future<String> deleteMessage(int messageId) async {
    final url = '$baseUrl/wp-json/tujuhcahaya/shoutbox/messages/$messageId';
    if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
      Log.debug('[ShoutboxDataSource] Deleting message at: $url');
    }

    try {
      final response = await dio.delete(url);

      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Delete response status: ${response.statusCode}');
      }
      if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
        Log.debug('[ShoutboxDataSource] Delete response data: ${response.data}');
      }

      if (response.statusCode == 200) {
        final jsonData = response.data as Map<String, dynamic>;
        
        // Handle WordPress plugin response format: {status: 'success', message: '...'}
        if (jsonData['status'] == 'success') {
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully deleted message (WordPress format)');
          }
          return jsonData['message'] ?? 'shoutbox_delete_success'.tr();
        }
        // Handle alternative format: {success: true, message: '...'}
        else if (jsonData['success'] == true) {
          if (RadioTujuhCahayaConfig.enableShoutboxDebugLogging) {
            Log.debug('[ShoutboxDataSource] Successfully deleted message (alternative format)');
          }
          return jsonData['message'] ?? 'shoutbox_delete_success'.tr();
        } else {
          Log.error('[ShoutboxDataSource] Delete failed - API returned error: ${jsonData['message']}');
          throw ServerException(jsonData['message'] ?? 'shoutbox_failed_delete'.tr());
        }
      } else if (response.statusCode == 404) {
        Log.error('[ShoutboxDataSource] Message not found for deletion');
        throw ServerException('shoutbox_not_found'.tr());
      } else if (response.statusCode == 403) {
        Log.error('[ShoutboxDataSource] Insufficient permissions to delete message');
        throw ServerException('shoutbox_insufficient_permissions'.tr());
      } else {
        Log.error('[ShoutboxDataSource] Delete HTTP error ${response.statusCode}: ${response.data}');
        throw ServerException('${'shoutbox_failed_delete'.tr()}: ${response.statusCode}');
      }
    } catch (e) {
      Log.error('[ShoutboxDataSource] Exception in deleteMessage: $e');
      
      // Handle DioException types
      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            Log.warning('[ShoutboxDataSource] Delete request timeout - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_timeout'.tr());
          case DioExceptionType.connectionError:
            Log.warning('[ShoutboxDataSource] Delete connection error - throwing NetworkException');
            throw NetworkException('shoutbox_connection_error'.tr());
          case DioExceptionType.unknown:
            // Handle unknown DioException (often contains HttpException)
            if (e.error != null && e.error.toString().contains('Connection closed before full header was received')) {
              Log.warning('[ShoutboxDataSource] Delete connection closed before headers received - throwing NetworkException');
              throw NetworkException('shoutbox_connection_lost'.tr());
            } else if (e.error != null && e.error.toString().contains('HttpException')) {
              Log.warning('[ShoutboxDataSource] Delete HttpException in unknown DioException - throwing NetworkException');
              throw NetworkException('shoutbox_network_error'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Delete unknown DioException - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            }
          case DioExceptionType.badResponse:
            // Handle bad response (4xx, 5xx)
            if (e.response?.statusCode == 404) {
              Log.warning('[ShoutboxDataSource] Delete API endpoint not available (404) - throwing ApiUnavailableException');
              throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
            } else {
              Log.warning('[ShoutboxDataSource] Delete bad response ${e.response?.statusCode} - throwing ServerException');
              throw ServerException('shoutbox_server_error'.tr());
            }
          case DioExceptionType.cancel:
            Log.warning('[ShoutboxDataSource] Delete request cancelled - throwing NetworkException');
            throw NetworkException('shoutbox_request_cancelled'.tr());
          default:
            Log.warning('[ShoutboxDataSource] Delete unhandled DioException type: ${e.type} - throwing ApiUnavailableException');
            throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
        }
      }
      
      // Handle HttpException directly
      if (e.toString().contains('HttpException')) {
        if (e.toString().contains('Connection closed before full header was received')) {
          Log.warning('[ShoutboxDataSource] Delete connection closed before headers received - throwing NetworkException');
          throw NetworkException('shoutbox_connection_lost'.tr());
        } else {
          Log.warning('[ShoutboxDataSource] Delete HttpException - throwing NetworkException');
          throw NetworkException('shoutbox_network_error'.tr());
        }
      }
      
      // Handle 404 specifically - API endpoint not available
      if (e.toString().contains('404')) {
        Log.warning('[ShoutboxDataSource] Shoutbox API endpoint not available (404) - throwing ApiUnavailableException');
        throw ApiUnavailableException('shoutbox_unavailable_message'.tr());
      }
      
      rethrow;
    }
  }

  @override
  Future<int> getLatestMessageId() async {
    // Get the latest message to determine the latest ID
    final messages = await getMessages(limit: 1);
    if (messages.isNotEmpty) {
      return messages.last.id;
    }
    return 0;
  }
}
