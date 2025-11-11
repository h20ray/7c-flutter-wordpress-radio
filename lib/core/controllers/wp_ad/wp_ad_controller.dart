import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/wp_ad.dart';
import '../../repositories/wp_ad/wp_ad_repository.dart';
import '../config/config_controllers.dart';
import '../dio/dio_provider.dart';
import '../../logger/app_logger.dart';

final wpAdProvider =
    StateNotifierProvider<WPAdNotifier, AsyncData<List<WPAd>>>((ref) {
  final dio = ref.read(dioProvider);
  final repo = WPAdRepository(dio);
  final isCustomOn = ref.watch(configProvider).value?.isCustomAdOn ?? false;
  return WPAdNotifier(repo, isCustomOn);
});

class WPAdNotifier extends StateNotifier<AsyncData<List<WPAd>>> {
  WPAdNotifier(this.repo, this.isCustomAdOn) : super(const AsyncData([])) {
    {
      onInit();
    }
  }

  final WPAdRepository repo;
  final bool isCustomAdOn;

  onInit() async {
    if (isCustomAdOn) {
      final allAds = await repo.getAllAds();
      final now = DateTime.now();

      // Debug logging to verify ads are being fetched and parsed
      Log.debug('[WPAdController] Fetched ${allAds.length} ads from API');
      for (int i = 0; i < allAds.length; i++) {
        Log.debug('[WPAdController] Ad $i: ${allAds[i].toString()}');
      }

      final validAds = allAds.where((ad) {
        final isExpired = ad.expiryDate != null && ad.expiryDate!.isBefore(now);
        if (isExpired) {
          Log.debug('[WPAdController] Filtering out expired ad: ${ad.toString()}');
        }
        return ad.expiryDate == null || ad.expiryDate!.isAfter(now);
      }).toList();

      Log.debug('[WPAdController] Valid ads after filtering: ${validAds.length}');
      state = AsyncData(validAds);
    } else {
      Log.debug('[WPAdController] Custom ads disabled');
      state = const AsyncData([]);
    }
  }

  int getRandomAdNumber() {
    final totalAds = state.value.length;

    if (totalAds > 0) {
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return adNumber;
    } else {
      return -1;
    }
  }

  WPAd? getABannerAd() {
    final allBannerAds =
        state.value.where((element) => element.isBanner).toList();
    if (allBannerAds.isNotEmpty) {
      final totalAds = allBannerAds.length;
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return allBannerAds[adNumber];
    } else {
      return null;
    }
  }

  WPAd? getALargeBannerAd() {
    final allBannerAds =
        state.value.where((element) => !element.isBanner).toList();
    if (allBannerAds.isNotEmpty) {
      final totalAds = allBannerAds.length;
      final random = math.Random();
      final adNumber = random.nextInt(totalAds);
      return allBannerAds[adNumber];
    } else {
      return null;
    }
  }
}
