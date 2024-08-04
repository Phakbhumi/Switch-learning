import 'package:flutter_test/flutter_test.dart';
import 'package:switch_learning/src/data/validator.dart';

void main() {
  group('Validator Tests', () {
    late Validator validator;

    setUp(() {
      validator = Validator();
    });

    test('should return valid result for a unique topic', () async {
      final result = await validator.shouldModifyTopic('UniqueTopic', 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isTrue);
      expect(result.errorMessage, isEmpty);
    });

    test('should return error if topic is null', () async {
      final result = await validator.shouldModifyTopic(null, 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isFalse);
      expect(result.errorMessage, "Topic shouldn't be null");
    });

    test('should return error if topic is empty', () async {
      final result = await validator.shouldModifyTopic('', 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isFalse);
      expect(result.errorMessage, "Topic can't be empty!");
    });

    test('should return error if topic matches master key', () async {
      final result = await validator.shouldModifyTopic('Master123456', 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isFalse);
      expect(result.errorMessage, "Forbidden topic name (Equal to master key)");
    });

    test('should return error if topic contains underscore', () async {
      final result = await validator.shouldModifyTopic('Topic_With_Underscore', 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isFalse);
      expect(result.errorMessage, "Forbidden topic name (Contains underscore)");
    });

    test('should return error if topic already exists', () async {
      final result = await validator.shouldModifyTopic('ExistingTopic', 'Master123456', ['ExistingTopic']);
      expect(result.verdict, isFalse);
      expect(result.errorMessage, "Topic already exists!");
    });
  });
}
