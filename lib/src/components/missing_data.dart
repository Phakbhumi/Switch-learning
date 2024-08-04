import 'package:flutter/material.dart';

class MissingData extends StatelessWidget {
  const MissingData(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.sentiment_neutral,
          size: 60,
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 30),
          ],
        ),
      ],
    );
  }
}
