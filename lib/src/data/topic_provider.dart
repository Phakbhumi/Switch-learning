import 'package:flutter/material.dart';

class TopicProvider extends ChangeNotifier {
  late Set<String> topicList;

  TopicProvider() {
    topicList = {};
  }

  void addTopic(String newTopic) {
    topicList.add(newTopic);
  }

  void removeTopic(String topic) {
    topicList.remove(topic);
  }

  bool isInTopicList(String newTopic) {
    return topicList.contains(newTopic);
  }
}
