import 'package:flutter/material.dart';

/// Contextless global snackbar controller.
class CustomSnack {
  final snackbarKey = GlobalKey<ScaffoldMessengerState>();

  void success({required String text}) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void error({required String text}) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void info({required String text}) {
    snackbarKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
