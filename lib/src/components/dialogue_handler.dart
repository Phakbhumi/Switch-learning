import 'package:flutter/material.dart';
import 'selector.dart';

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

  Future<String?> singleOpenDialog(
    BuildContext context,
    String title,
    String hint,
    String prefix,
  ) {
    TextEditingController controller = TextEditingController();
    controller.text = prefix;
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: TextField(
          decoration: InputDecoration(hintText: hint),
          controller: controller,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(controller.text);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  Future<List<String>?> doubleOpenDialog(
    BuildContext context,
    String title,
    String firstHint,
    String firstPrefix,
    String secondHint,
    String secondPrefix,
    bool isPopUp,
    List<String> keyWordList,
  ) {
    TextEditingController firstController = TextEditingController();
    TextEditingController secondController = TextEditingController();
    firstController.text = firstPrefix;
    secondController.text = secondPrefix;
    return showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close),
            ),
          ],
        ),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPopUp)
              Selector(
                itemList: keyWordList,
                onPressed: (String select) {
                  firstController.text = select;
                },
              ),
            if (isPopUp) const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(hintText: firstHint),
              controller: firstController,
            ),
            const SizedBox(height: 40),
            if (isPopUp)
              Selector(
                itemList: keyWordList,
                onPressed: (String select) {
                  secondController.text = select;
                },
              ),
            if (isPopUp) const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(hintText: secondHint),
              controller: secondController,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop([
                firstController.text,
                secondController.text,
              ]);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
