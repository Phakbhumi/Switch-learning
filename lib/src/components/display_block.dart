import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/theme/theme_provider.dart';

class DisplayBlock extends StatelessWidget {
  const DisplayBlock({
    super.key,
    required this.title,
    required this.index,
    required this.editData,
    required this.deleteData,
  });

  final String title;
  final int index;
  final ValueSetter<int> editData;
  final ValueSetter<int> deleteData;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Visibility(
        visible: Provider.of<ThemeProvider>(context).showMisc,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => editData(index),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => deleteData(index),
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
