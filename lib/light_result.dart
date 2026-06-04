/// A lightweight functional error handling library for Dart 3.
///
/// The core library (`package:light_result/light_result.dart`) has **zero dependencies**.
/// Optional test matchers are available via `package:light_result/testing.dart`
/// (depends on `matcher`).
///
/// ## Core Types
///
/// - [Result] — Represents either a success ([Success]) or failure ([Failure]).
/// - [Option] — Represents an optional value ([Some]) or absence ([None]).
///
/// ## Quick Start
///
/// ```dart
/// import 'package:light_result/light_result.dart';
///
/// // Creating results
/// final success = Success<String, int>(42);
/// final failure = Failure<String, int>('Something went wrong');
///
/// // Pattern matching (exhaustive)
/// final message = switch (success) {
///   Failure(value: final error) => 'Error: $error',
///   Success(value: final data) => 'Data: $data',
/// };
///
/// // Functional chaining
/// final result = Success<String, int>(10)
///     .map((x) => x * 2)
///     .flatMap((x) => x > 0 ? Success(x) : Failure('negative'));
/// ```
library;

export 'src/result.dart';
export 'src/option.dart';
export 'src/task_result.dart';
export 'src/typedefs.dart';
