// ignore_for_file: avoid_print
import 'package:light_result/light_result.dart';

// ─── Domain Layer ─────────────────────────────────────────────────────────

sealed class AppFailure extends Failure {
  const AppFailure(super.message, {super.stackTrace});
}

final class NetworkFailure extends AppFailure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode, super.stackTrace});
}

final class ValidationFailure extends AppFailure {
  final String field;
  const ValidationFailure(super.message,
      {required this.field, super.stackTrace});
}

class User {
  final int id;
  final String name;
  final int age;
  const User({required this.id, required this.name, required this.age});
}

// ─── Repository Layer ─────────────────────────────────────────────────────

Future<Result<AppFailure, User>> fetchUser(int id) async {
  // Simulate network call
  await Future<void>.delayed(const Duration(milliseconds: 100));

  if (id <= 0) {
    return Left(const NetworkFailure('User not found', statusCode: 404));
  }
  return Right(User(id: id, name: 'John Doe', age: 30));
}

Result<AppFailure, String> validateName(String name) {
  if (name.isEmpty) {
    return Left(
        const ValidationFailure('Name is required', field: 'name'));
  }
  if (name.length < 2) {
    return Left(const ValidationFailure('Name too short', field: 'name'));
  }
  return Right(name);
}

// ─── Usage Examples ───────────────────────────────────────────────────────

void main() async {
  // Example 1: Basic pattern matching
  print('--- Example 1: Pattern Matching ---');
  final result = await fetchUser(1);
  final message = switch (result) {
    Left(value: NetworkFailure(:final statusCode)) =>
      'Network error (status: $statusCode)',
    Left(value: ValidationFailure(:final field)) =>
      'Validation error on: $field',
    Right(value: final user) => 'Hello, ${user.name}!',
  };
  print(message);

  // Example 2: Functional chaining
  print('\n--- Example 2: Functional Chaining ---');
  final greeting = await fetchUser(1)
      .thenMap((user) => user.name)
      .thenMap((name) => 'Welcome back, $name!')
      .thenGetOrElse((_) => 'Welcome, guest!');
  print(greeting);

  // Example 3: Guard - safely wrapping exceptions
  print('\n--- Example 3: Guard ---');
  final parsed = Result.guard(
    () => int.parse('not_a_number'),
    (error, stack) => 'Parse failed: $error',
  );
  print(parsed); // Left(Parse failed: ...)

  // Example 4: Combine multiple validations
  print('\n--- Example 4: Combine ---');
  final validations = Result.combine<AppFailure, String>([
    validateName('John'),
    validateName('Doe'),
  ]);
  print(validations.fold(
    (err) => 'Validation failed: ${err.message}',
    (names) => 'All valid: $names',
  ));

  // Example 5: Option
  print('\n--- Example 5: Option ---');
  final Map<String, dynamic> json = {'name': 'Alice', 'age': null};
  final name = Option.fromNullable(json['name'] as String?);
  final age = Option.fromNullable(json['age'] as int?);

  print(name.fold(() => 'No name', (n) => 'Name: $n'));
  print(age.fold(() => 'No age provided', (a) => 'Age: $a'));

  // Example 6: Option to Result conversion
  print('\n--- Example 6: Option → Result ---');
  final ageResult = age.toResult(
    () => const ValidationFailure('Age is required', field: 'age'),
  );
  print(ageResult); // Left(ValidationFailure(Age is required))
}
