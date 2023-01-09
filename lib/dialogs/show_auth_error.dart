import 'package:bloc_firebase_gallery/auth/auth_error.dart';
import 'package:bloc_firebase_gallery/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showAuthError({
  required BuildContext context,
  required AuthError error,
}) {
  return showGenericDialog<void>(
    context: context,
    title: error.dialogTitle,
    content: error.dialogText,
    optionsBuilder: () => {
      'Ok': true,
    },
  );
}
