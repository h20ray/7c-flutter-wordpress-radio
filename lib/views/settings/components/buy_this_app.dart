import 'package:flutter/material.dart';
import '../../../core/constants/app_icons.dart';

import '../../../core/constants/constants.dart';
import '../../../core/utils/app_utils.dart';
import 'setting_list_tile.dart';

class BuyAppSettings extends StatelessWidget {
  const BuyAppSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(AppDefaults.margin),
        ),
        SettingTile(
          label: 'buy_this_app',
          icon: AppIcons.buy,
          iconColor: Colors.teal,
          trailing: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(AppIcons.arrowRight),
          ),
          onTap: () {
            const url =
                'https://saweria.co/widgets/qr?streamKey=090715ee70c3baecfb07af5aad8e87d5';
            AppUtils.launchUrl(url);
          },
        ),
      ],
    );
  }
}
