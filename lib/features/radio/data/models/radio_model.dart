import '../../domain/entities/radio_entity.dart';
import 'dart:developer' as developer;

class RadioModel extends RadioEntity {
  const RadioModel({
    required super.enabled,
    required super.streamUrl,
    required super.autoplay,
    required super.showAlbumCover,
    required super.textScrolling,
    required super.metadataUrl,
    required super.logoNetworkUrl,
    required super.albumArtSource,
    required super.lastUpdated,
    super.backupStreamUrls,
    super.radioCoreV2Enabled,
    super.banners,
  });

  factory RadioModel.fromJson(Map<String, dynamic> json) {
    final albumArtSource = json['albumArtSource'] ?? 1;

    developer.log('[RadioModel] Parsing radio configuration from JSON',
        name: 'RadioConfig');
    developer.log('[RadioModel] Raw JSON data: $json', name: 'RadioConfig');
    developer.log('[RadioModel] Parsed albumArtSource: $albumArtSource',
        name: 'RadioConfig');
    developer.log('[RadioModel] Stream URL: ${json['streamUrl']}',
        name: 'RadioConfig');
    developer.log('[RadioModel] Show album cover: ${json['showAlbumCover']}',
        name: 'RadioConfig');

    return RadioModel(
      enabled: json['enabled'] ?? false,
      streamUrl: json['streamUrl'] ?? '',
      autoplay: json['autoplay'] ?? false,
      showAlbumCover: json['showAlbumCover'] ?? true,
      textScrolling: json['textScrolling'] ?? true,
      metadataUrl: json['metadataUrl'] ?? '',
      logoNetworkUrl: _extractLogoNetworkUrl(json['logoNetworkUrl']),
      albumArtSource: albumArtSource,
      lastUpdated: DateTime.parse(
          json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      backupStreamUrls: _extractBackupStreamUrls(json['backupStreamUrls']),
      radioCoreV2Enabled: json['radioCoreV2Enabled'] ?? false,
      banners: _extractBanners(json['banners']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'streamUrl': streamUrl,
      'autoplay': autoplay,
      'showAlbumCover': showAlbumCover,
      'textScrolling': textScrolling,
      'metadataUrl': metadataUrl,
      'logoNetworkUrl': logoNetworkUrl,
      'albumArtSource': albumArtSource,
      'lastUpdated': lastUpdated.toIso8601String(),
      'backupStreamUrls': backupStreamUrls,
      'radioCoreV2Enabled': radioCoreV2Enabled,
      'banners': banners.map((banner) => {
        'imageUrl': banner.imageUrl,
        'targetUrl': banner.targetUrl,
      }).toList(),
    };
  }

  RadioEntity toEntity() {
    return RadioEntity(
      enabled: enabled,
      streamUrl: streamUrl,
      autoplay: autoplay,
      showAlbumCover: showAlbumCover,
      textScrolling: textScrolling,
      metadataUrl: metadataUrl,
      logoNetworkUrl: logoNetworkUrl,
      albumArtSource: albumArtSource,
      lastUpdated: lastUpdated,
      backupStreamUrls: backupStreamUrls,
      radioCoreV2Enabled: radioCoreV2Enabled,
      banners: banners,
    );
  }

  /// Extract logo network URL from various formats (string, object, etc.)
  static String _extractLogoNetworkUrl(dynamic logoData) {
    if (logoData == null) return '';

    if (logoData is String) {
      return logoData;
    }

    if (logoData is Map<String, dynamic>) {
      // Handle WordPress attachment object
      if (logoData.containsKey('guid')) {
        return logoData['guid'] ?? '';
      }
      if (logoData.containsKey('ID')) {
        // If we have an ID but no guid, we can't resolve it on the client side
        // The server should have already resolved this
        return '';
      }
    }

    return '';
  }

  /// Extract backup stream URLs from JSON
  static List<String> _extractBackupStreamUrls(dynamic backupUrlsData) {
    if (backupUrlsData == null) return [];

    if (backupUrlsData is List) {
      return backupUrlsData
          .where((url) => url is String && url.isNotEmpty)
          .cast<String>()
          .toList();
    }

    return [];
  }

  /// Extract banners from JSON
  static List<RadioBanner> _extractBanners(dynamic bannersData) {
    if (bannersData == null) return [];

    if (bannersData is List) {
      return bannersData
          .whereType<Map<String, dynamic>>()
          .map((banner) {
            final imageUrl = banner['imageUrl'] as String? ?? '';
            final targetUrl = banner['targetUrl'] as String? ?? '';
            return RadioBanner(
              imageUrl: imageUrl,
              targetUrl: targetUrl,
            );
          })
          .where((banner) => banner.imageUrl.isNotEmpty && banner.targetUrl.isNotEmpty)
          .toList();
    }

    return [];
  }
}
