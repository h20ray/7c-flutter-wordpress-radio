import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Dialog for inputting username
class UsernameInputDialog extends StatefulWidget {
  const UsernameInputDialog({super.key});

  @override
  State<UsernameInputDialog> createState() => _UsernameInputDialogState();
}

class _UsernameInputDialogState extends State<UsernameInputDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /// Submit username
  void _submitUsername() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_usernameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      title: Text('shoutbox_username_prompt'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'shoutbox_username_set'.tr(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              autofocus: true,
              maxLength: 100,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'shoutbox_username_label'.tr(),
                hintText: 'shoutbox_username_hint'.tr(),
                border: const OutlineInputBorder(),
                counterText: '', // Hide character counter
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'shoutbox_username_required_short'.tr();
                }
                if (value.trim().length < 2) {
                  return 'shoutbox_username_too_short'.tr();
                }
                if (value.trim().length > 100) {
                  return 'shoutbox_username_too_long'.tr();
                }
                return null;
              },
              onFieldSubmitted: (_) => _submitUsername(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('shoutbox_cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _submitUsername,
          child: Text('shoutbox_set_username'.tr()),
        ),
      ],
    );
  }
}
