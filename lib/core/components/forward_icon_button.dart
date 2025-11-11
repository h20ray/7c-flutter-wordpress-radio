import 'package:flutter/material.dart';
import '../constants/app_icons.dart';

import '../constants/app_defaults.dart';

class ForwardIconButton extends StatelessWidget {
  const ForwardIconButton({
    super.key,
    required this.onTap,
  });

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(AppDefaults.padding),
        ),
        child: const Icon(
          AppIcons.arrowRight2,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
