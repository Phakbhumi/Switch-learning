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
          Icons.add,
          size: 60,
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
