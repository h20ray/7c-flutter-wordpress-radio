import 'package:dio/dio.dart';
import 'dart:developer' as developer;
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
    developer.log('[RadioDataSource] Fetching radio config from: $url',
        name: 'RadioConfig');

    final response = await dio.get(url);

    developer.log('[RadioDataSource] Response status: ${response.statusCode}',
        name: 'RadioConfig');
    developer.log('[RadioDataSource] Response data: ${response.data}',
        name: 'RadioConfig');

    if (response.statusCode == 200) {
      final radioModel = RadioModel.fromJson(response.data);
      developer.log(
          '[RadioDataSource] Parsed radio model - albumArtSource: ${radioModel.albumArtSource}',
          name: 'RadioConfig');
      return radioModel;
    } else {
      developer.log(
          '[RadioDataSource] ERROR: Failed to load radio config - status: ${response.statusCode}',
          name: 'RadioConfig');
      throw Exception('Failed to load radio config');
    }
  }
}
