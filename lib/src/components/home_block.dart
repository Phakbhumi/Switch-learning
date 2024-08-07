import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/theme/theme_provider.dart';

class HomeBlock extends StatelessWidget {
  const HomeBlock({
    super.key,
    required this.index,
    required this.currentTopic,
    required this.editData,
    required this.deleteData,
  });

  final int index;
  final String currentTopic;
  final ValueSetter<TopicData> editData;
  final ValueSetter<TopicData> deleteData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info_outline),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  currentTopic,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              Visibility(
                visible: Provider.of<ThemeProvider>(context).showMisc,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => editData(
                        TopicData(index: index, currentTopic: currentTopic),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteData(
                        TopicData(index: index, currentTopic: currentTopic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicData {
  final int index;
  final String currentTopic;

  const TopicData({
    required this.index,
    required this.currentTopic,
  });
}
