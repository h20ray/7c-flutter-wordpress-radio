import '../logger/app_logger.dart';

class WPAd {
  int id;
  String imageURL;
  String adTarget;
  bool isBanner;
  String size;
  DateTime? expiryDate;
  WPAd({
    required this.id,
    required this.imageURL,
    required this.adTarget,
    required this.isBanner,
    required this.size,
    this.expiryDate,
  });

  factory WPAd.fromMap(Map<String, dynamic> map) {
    // Convert string ID to int using hashCode for consistency
    int adId = 0;
    if (map['id'] != null) {
      final idValue = map['id'];
      if (idValue is int) {
        adId = idValue;
      } else if (idValue is String) {
        // Use hashCode for string IDs like "banner" or "square"
        adId = idValue.hashCode.abs();
      }
    }

    // Parse expiry date if it exists (support both snake_case and camelCase for compatibility)
    DateTime? parsedExpiryDate;
    final expiryField = map['expiry_date'] ?? map['expiryDate'];
    if (expiryField != null && expiryField.toString().isNotEmpty) {
      try {
        // Split the date string and rearrange to standard format
        List<String> dateParts = expiryField.split('/');
        if (dateParts.length == 3) {
          String standardDate =
              '${dateParts[2]}-${dateParts[0]}-${dateParts[1]}';
          parsedExpiryDate = DateTime.parse(standardDate);
        }
      } catch (e) {
        Log.error('Error parsing expiry date: ${e.toString()}');
      }
    }

    return WPAd(
      id: adId,
      imageURL: map['thumbnail'] ?? map['imageUrl'] ?? '',
      adTarget: map['ad_target'] ?? map['targetUrl'] ?? '',
      isBanner: (map['ad_size'] ?? map['adSize']) == 'Banner' ? true : false,
      size: map['ad_size'] ?? map['adSize'] ?? '',
      expiryDate: parsedExpiryDate,
    );
  }

  @override
  String toString() {
    return 'WPAd(id: $id, imageURL: $imageURL, adTarget: $adTarget, isBanner: $isBanner, size: $size, expiryDate: $expiryDate)';
  }
}
