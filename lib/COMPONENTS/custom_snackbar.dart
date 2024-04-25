import 'package:flutter/material.dart';
class CustomSnackbar {
  showSnackbar(BuildContext context, String content,String type) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        backgroundColor:Color.fromARGB(255, 71, 71, 56),
        duration: const Duration(seconds: 2),
        content: Text(content),
        action: SnackBarAction(
          label: '',
          textColor: Colors.black,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
