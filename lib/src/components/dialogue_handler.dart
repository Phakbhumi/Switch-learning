import 'package:flutter/material.dart';

class DialogueHandler {
  Future<void> errorDialog(BuildContext context, String errorMessage) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Ok"),
            ),
          ],
        ),
      );

  Future<bool?> deleteDialog(BuildContext context, String currentTopic) => showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Are you sure you want to delete $currentTopic?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Yes, delete it"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("No, do not delete"),
            ),
          ],
        ),
      );
}
