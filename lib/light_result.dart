/// A lightweight, zero-dependency functional error handling library for Dart 3.
///
/// Built entirely on modern Dart 3 features: sealed classes, pattern matching,
/// records, and exhaustive checking. Provides production-grade functional
/// error handling without the complexity of category theory.
///
/// ## Core Types
///
/// - [Result] — Represents either a success ([Right]) or failure ([Left]).
/// - [Option] — Represents an optional value ([Some]) or absence ([None]).
///
/// ## Quick Start
///
/// ```dart
/// import 'package:light_result/light_result.dart';
///
/// // Creating results
/// final success = Right<String, int>(42);
/// final failure = Left<String, int>('Something went wrong');
///
/// // Pattern matching (exhaustive)
/// final message = switch (success) {
///   Left(value: final error) => 'Error: $error',
///   Right(value: final data) => 'Data: $data',
/// };
///
/// // Functional chaining
/// final result = Right<String, int>(10)
///     .map((x) => x * 2)
///     .flatMap((x) => x > 0 ? Right(x) : Left('negative'));
/// ```
library;

export 'src/result.dart';
export 'src/option.dart';
export 'src/task_result.dart';
export 'src/typedefs.dart';
