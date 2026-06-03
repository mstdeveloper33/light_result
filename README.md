# light_result

A lightweight, zero-dependency\* functional error handling package for Dart 3.

Built entirely on **sealed classes** and **pattern matching** — the compiler forces you to handle every case. No category theory. No boilerplate. Just safe, composable error handling.

> \*Core library has zero dependencies. The optional `testing.dart` utilities depend on `matcher`.

## The Problem

Every Dart/Flutter project has the same pain points:

```dart
// ❌ Problem 1: Functions lie about what can go wrong
Future<User> fetchUser(int id) async {
  // Can throw SocketException, TimeoutException, FormatException,
  // HttpException, JsonUnsupportedObjectError... but the signature says nothing.
  final response = await http.get('/users/$id');
  return User.fromJson(jsonDecode(response.body));
}

// ❌ Problem 2: Null means everything and nothing
User? getUser() => null; // Not found? Error? Not loaded yet? Who knows.

// ❌ Problem 3: try/catch spreads everywhere
try {
  final user = await fetchUser(1);
  final profile = await fetchProfile(user);
  final avatar = await downloadAvatar(profile);
  // What if the 2nd call fails? The 3rd? Different error types?
} catch (e) {
  // All errors land here. Good luck distinguishing them.
}
```

## The Solution

```dart
// ✅ Function signature tells the full story
Future<Result<AppFailure, User>> fetchUser(int id) async { ... }

// ✅ Compiler forces you to handle every case
final widget = switch (await fetchUser(1)) {
  Left(value: NetworkFailure(:final statusCode)) => ErrorView(code: statusCode),
  Left(value: ValidationFailure(:final field)) => FormError(field: field),
  Right(value: final user) => UserProfile(user: user),
};

// ✅ Clean async chains — no try/catch, no null checks
final avatar = await fetchUser(1)
    .thenFlatMap((user) => fetchProfile(user))
    .thenMap((profile) => profile.avatarUrl)
    .thenGetOrElse((_) => 'default_avatar.png');
```

## Why light_result?

| Feature | light_result | fpdart | dartz |
|---------|:---:|:---:|:---:|
| Dart 3 sealed classes | ✅ | ✅ | ❌ |
| Zero dependencies | ✅ | ❌ | ❌ |
| Exhaustive pattern matching | ✅ | ✅ | ❌ |
| Lightweight API | ✅ | ❌ | ❌ |
| Full documentation | ✅ | ✅ | ❌ |
| Async chaining extensions | ✅ | ✅ | ❌ |
| Guard/Combine utilities | ✅ | Partial | ❌ |
| Test matchers included | ✅ | ❌ | ❌ |

## Installation

```yaml
dependencies:
  light_result: ^0.1.0
```

## Quick Start

```dart
import 'package:light_result/light_result.dart';

// Define a function that can fail
Result<String, int> divide(int a, int b) {
  if (b == 0) return Left('Division by zero');
  return Right(a ~/ b);
}

// Exhaustive pattern matching — compiler ensures both cases are handled
final result = divide(10, 2);
final message = switch (result) {
  Left(value: final error) => 'Error: $error',
  Right(value: final data) => 'Result: $data',
};
```

## Core Types

### Result<L, R>

Represents either a **failure** (`Left<L>`) or **success** (`Right<R>`).

```dart
// Creating results
final success = Right<String, int>(42);
final failure = Left<String, int>('Something went wrong');

// Factory constructors
final fromNull = Result<String, int>.fromNullable(json['age'], () => 'missing');
final guarded = Result.guard(() => int.parse(input), (e, s) => 'Parse error: $e');
```

### Option<T>

Represents an **optional value** — eliminates null ambiguity.

```dart
final some = Some(42);
final none = None<int>();
final fromNullable = Option.fromNullable(possiblyNull);

final value = switch (some) {
  Some(value: final v) => 'Got: $v',
  None() => 'Empty',
};
```

## Functional Chaining

```dart
Result<String, int> parse(String s) =>
    Result.guard(() => int.parse(s), (e, _) => 'Invalid number');

Result<String, int> validate(int n) =>
    n > 0 ? Right(n) : Left('Must be positive');

// Chain operations — short-circuits on first Left
final result = parse('42')
    .flatMap(validate)
    .map((n) => n * 2)
    .tap((n) => print('Result: $n'));

// Extract value safely
final value = result.getOrElse((_) => 0);
```

## Async Chaining (TaskResult)

No more `await` chains! Compose async operations fluently:

```dart
Future<Result<AppError, User>> fetchUser(int id) async { ... }
Future<Result<AppError, Profile>> fetchProfile(User user) async { ... }

// Fluent async chain
final profile = await fetchUser(1)
    .thenFlatMap((user) => fetchProfile(user))
    .thenMap((profile) => profile.avatar)
    .thenTapLeft((err) => logger.error(err));
```

## Guard & Combine

```dart
// Safely wrap throwing code
final result = Result.guard(
  () => jsonDecode(input),
  (error, stack) => ParseFailure(error.toString()),
);

// Async guard
final data = await Result.guardAsync(
  () => httpClient.get('/api/users'),
  (error, stack) => NetworkFailure(error.toString()),
);

// Combine multiple results
final combined = Result.combine([
  validateName(name),
  validateEmail(email),
  validateAge(age),
]); // Right([name, email, age]) or first Left

// Parallel async
final users = await Result.waitAll([
  fetchUser(1),
  fetchUser(2),
  fetchUser(3),
]);
```

## Typed Failure Hierarchies

```dart
sealed class AppFailure extends Failure {
  const AppFailure(super.message, {super.stackTrace});
}

final class NetworkFailure extends AppFailure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode});
}

final class ValidationFailure extends AppFailure {
  final String field;
  const ValidationFailure(super.message, {required this.field});
}

// Exhaustive error handling with typed failures
final result = await fetchUser(1);
final widget = switch (result) {
  Left(value: NetworkFailure(:final statusCode)) => ErrorWidget('Network: $statusCode'),
  Left(value: ValidationFailure(:final field)) => ErrorWidget('Invalid: $field'),
  Right(value: final user) => UserWidget(user),
};
```

## Type Aliases

```dart
// Shorthand types for common patterns
typedef ResultOf<T> = Result<Exception, T>;
typedef StringResult<T> = Result<String, T>;
typedef AppResult<T> = Result<Failure, T>;
typedef AsyncResult<L, R> = Future<Result<L, R>>;
typedef AsyncResultOf<T> = Future<Result<Exception, T>>;
```

## Test Matchers

```dart
import 'package:light_result/testing.dart';

test('returns user on success', () async {
  final result = await repository.fetchUser(1);
  
  expect(result, isRight);
  expect(result, isRightWith(expectedUser));
});

test('returns failure on error', () async {
  final result = await repository.fetchUser(-1);
  
  expect(result, isLeft);
  expect(result, isLeftWith(NetworkFailure('Not found')));
});

test('option matchers', () {
  expect(Option.fromNullable(42), isSome);
  expect(Option.fromNullable(42), isSomeWith(42));
  expect(Option.fromNullable(null), isNone);
});
```

## Migration from fpdart/dartz

| fpdart/dartz | light_result |
|---|---|
| `Either<L, R>` | `Result<L, R>` |
| `Either.right(value)` | `Right(value)` |
| `Either.left(error)` | `Left(error)` |
| `Either.tryCatch(...)` | `Result.guard(...)` |
| `Option.of(value)` | `Some(value)` |
| `Option.none()` | `None()` |
| `TaskEither` | `Future<Result<L, R>>` + extensions |
| `.match(onLeft, onRight)` | `.fold(onLeft, onRight)` or `switch` |

## License

MIT
