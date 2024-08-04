class Validator {
  Future<ValidationResult> shouldModifyTopic(String? addedTopic, String masterKey, List<String> topic) async {
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
    if (topic.contains(addedTopic)) {
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
