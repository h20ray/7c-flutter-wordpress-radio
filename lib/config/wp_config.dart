import 'package:flutter/material.dart';

class WPConfig {
  /// The Name of your app
  static const String appName = 'UpRadio';

  /// The url of your app, should not included any '/' slash or any 'https://' or 'http://'
  /// Otherwise it may break the compatibility, And your website must be
  /// a wordpress website.
  static const String url = 'upradio.id';

  /// Your onesignal id
  static const String oneSignalId = 'c06f166f-da4f-4040-a1ac-180400a9be3e';

  /// Primary Color of the App, must be a valid hex code after '0xFF'
  static const Color primaryColor = Color(0xFF38B7FF);

  /// Deeplinks config
  /// If you are using something like this:
  /// https://newspro.uixxy.com/sample-post/
  /// make this true or else false
  static const bool usingPlainFormatLink = true;

  /// IF we should keep the caching of home categories tab caching or not
  /// if this is false, then we will fetch new data and refresh the
  /// list if user changes tab or click on one
  static bool enableHomeTabCache = true;
}
