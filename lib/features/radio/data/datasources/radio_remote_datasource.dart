import 'package:dio/dio.dart';
import 'dart:convert';
import '../../../../config/wp_config.dart';
import '../models/radio_model.dart';

abstract class RadioRemoteDataSource {
  Future<RadioModel> getRadioConfig();
}

class RadioRemoteDataSourceImpl implements RadioRemoteDataSource {
  final Dio dio;

  RadioRemoteDataSourceImpl({required this.dio});

  @override
  Future<RadioModel> getRadioConfig() async {
    final url = 'https://${WPConfig.url}/wp-json/tujuhcahaya/v2/radio-config';
    final response = await dio.get(url);

    if (response.statusCode == 200) {
      // Ensure we have a Map<String, dynamic>
      final responseData = response.data;
      Map<String, dynamic> jsonData;

      if (responseData is Map<String, dynamic>) {
        jsonData = responseData;
      } else if (responseData is Map) {
        jsonData = Map<String, dynamic>.from(responseData);
      } else if (responseData is String) {
        // If response is a JSON string, parse it
        try {
          jsonData = json.decode(responseData) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Failed to parse JSON response: $e');
        }
      } else {
        throw Exception(
            'Invalid response data type: ${responseData.runtimeType}');
      }

      return RadioModel.fromJson(jsonData);
    } else {
      throw Exception('Failed to load radio config');
    }
  }
}
