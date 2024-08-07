import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:switch_learning/src/data/topic_provider.dart';

class Validator {
  Future<ValidationResult> shouldModifyTopic(BuildContext context, String? addedTopic, String masterKey) async {
    if (addedTopic == null) {
      return ValidationResult(false, "Topic shouldn't be null");
    }
    if (addedTopic == "") {
      return ValidationResult(false, "Topic can't be empty!");
    }
    if (addedTopic == masterKey) {
      return ValidationResult(false, "Forbidden topic name (Equal to master key)");
    }
    if (addedTopic.contains('_')) {
      return ValidationResult(false, "Forbidden topic name (Contains underscore)");
    }
    if (Provider.of<TopicProvider>(context, listen: false).isInTopicList(addedTopic)) {
      return ValidationResult(false, "Topic already exists!");
    }
    return ValidationResult(true, "");
  }
}

class ValidationResult {
  bool verdict;
  String errorMessage;

  ValidationResult(this.verdict, this.errorMessage);
}
