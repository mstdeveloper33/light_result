import 'option.dart';

/// Core [Result] monad — the heart of functional error handling.
///
/// [Result] is a sealed class representing a value that is either:
/// - [Success] — a successful computation containing a value of type [R].
/// - [Failure] — a failed computation containing an error of type [L].
///
/// Using sealed classes ensures **exhaustive pattern matching** at compile time,
/// forcing developers to handle both success and failure cases.
///
/// ## Why Result over Exceptions?
///
/// Exceptions break the type system — a function signature like `int parse(String s)`
/// tells you nothing about what can go wrong. With [Result], the return type
/// `Result<FormatError, int>` explicitly communicates all possible outcomes.
///
/// ## Basic Usage
///
/// ```dart
/// Result<String, int> divide(int a, int b) {
///   if (b == 0) return Failure('Division by zero');
///   return Success(a ~/ b);
/// }
///
/// final result = divide(10, 2);
///
/// // Exhaustive pattern matching — compiler ensures both cases are handled
/// final output = switch (result) {
///   Failure(value: final error) => 'Error: $error',
///   Success(value: final data) => 'Result: $data',
/// };
/// ```
///
/// ## Functional Chaining
///
/// ```dart
/// final result = Success<String, int>(10)
///     .map((x) => x * 2)          // Success(20)
///     .flatMap((x) => divide(x, 4)) // Success(5)
///     .mapFailure((e) => 'Failed: $e'); // Only transforms if Failure
/// ```
sealed class Result<L, R> {
  /// Creates a [Result] instance.
  ///
  /// Use [Success] or [Failure] constructors directly, or the convenience
  /// factory constructors [Result.success], [Result.failure], [Result.success],
  /// [Result.failure].
  const Result();

  // ─── Factory Constructors ───────────────────────────────────────────

  /// Creates a [Success] containing the success value [r].
  ///
  /// ```dart
  /// final result = Result<String, int>.success(42); // Success(42)
  /// ```
  factory Result.success(R r) = Success<L, R>;

  /// Creates a [Failure] containing the failure value [l].
  ///
  /// ```dart
  /// final result = Result<String, int>.failure('oops'); // Failure('oops')
  /// ```
  factory Result.failure(L l) = Failure<L, R>;

  /// Creates a [Success] from a non-null value, or [Failure] from [onNull] if null.
  ///
  /// Useful for bridging nullable APIs into the [Result] world.
  ///
  /// ```dart
  /// final result = Result<String, int>.fromNullable(
  ///   json['age'] as int?,
  ///   () => 'age field is missing',
  /// ); // Success(25) or Failure('age field is missing')
  /// ```
  factory Result.fromNullable(R? value, L Function() onNull) =>
      value != null ? Success<L, R>(value) : Failure<L, R>(onNull());

  /// Creates a [Success] if [predicate] returns true for [value],
  /// otherwise creates a [Failure] using [onFalse].
  ///
  /// ```dart
  /// final result = Result<String, int>.fromPredicate(
  ///   age,
  ///   (a) => a >= 18,
  ///   (a) => 'Must be 18+, got $a',
  /// );
  /// ```
  factory Result.fromPredicate(
    R value,
    bool Function(R r) predicate,
    L Function(R r) onFalse,
  ) =>
      predicate(value) ? Success<L, R>(value) : Failure<L, R>(onFalse(value));

  /// Executes [run] and wraps the result in a [Success].
  /// If [run] throws, catches the exception and wraps it in [Failure] via [onError].
  ///
  /// ```dart
  /// final result = Result.guard(
  ///   () => int.parse('42'),
  ///   (error, stack) => 'Parse failed: $error',
  /// ); // Success(42)
  ///
  /// final failed = Result.guard(
  ///   () => int.parse('abc'),
  ///   (error, stack) => 'Parse failed: $error',
  /// ); // Failure('Parse failed: FormatException...')
  /// ```
  static Result<L, R> guard<L, R>(
    R Function() run,
    L Function(Object error, StackTrace stack) onError,
  ) {
    try {
      return Success<L, R>(run());
    } catch (e, s) {
      return Failure<L, R>(onError(e, s));
    }
  }

  /// Async version of [guard]. Executes [run] and wraps the result in [Success].
  /// If [run] throws, catches the exception and wraps it in [Failure] via [onError].
  ///
  /// ```dart
  /// final result = await Result.guardAsync(
  ///   () => httpClient.get('/users/1'),
  ///   (error, stack) => NetworkFailure(error.toString()),
  /// );
  /// ```
  static Future<Result<L, R>> guardAsync<L, R>(
    Future<R> Function() run,
    L Function(Object error, StackTrace stack) onError,
  ) async {
    try {
      return Success<L, R>(await run());
    } catch (e, s) {
      return Failure<L, R>(onError(e, s));
    }
  }

  /// Combines a list of [Result]s into a single [Result] containing
  /// a list of all success values.
  ///
  /// If **any** [Result] in the list is [Failure], returns the **first** [Failure] found.
  /// If **all** are [Success], returns a [Success] containing all values.
  ///
  /// ```dart
  /// final results = [Success<String, int>(1), Success<String, int>(2)];
  /// final combined = Result.combine(results); // Success([1, 2])
  ///
  /// final mixed = [Success<String, int>(1), Failure<String, int>('fail')];
  /// final combined2 = Result.combine(mixed); // Failure('fail')
  /// ```
  static Result<L, List<R>> combine<L, R>(List<Result<L, R>> results) {
    final values = <R>[];
    for (final result in results) {
      switch (result) {
        case Failure<L, R>(value: final l):
          return Failure<L, List<R>>(l);
        case Success<L, R>(value: final r):
          values.add(r);
      }
    }
    return Success<L, List<R>>(values);
  }

  /// Async version of [combine]. Awaits all futures and combines results.
  ///
  /// All futures are awaited concurrently using [Future.wait].
  /// If **any** result is [Failure], returns the **first** [Failure].
  ///
  /// ```dart
  /// final results = await Result.waitAll([
  ///   fetchUser(1),
  ///   fetchUser(2),
  /// ]);
  /// ```
  static Future<Result<L, List<R>>> waitAll<L, R>(
    List<Future<Result<L, R>>> futures,
  ) async {
    final results = await Future.wait(futures);
    return combine(results);
  }

  /// Flattens a nested [Result] into a single [Result].
  ///
  /// ```dart
  /// final nested = Success<String, Result<String, int>>(Success(42));
  /// final flat = Result.flatten(nested); // Success(42)
  /// ```
  static Result<L, R> flatten<L, R>(Result<L, Result<L, R>> result) =>
      result.flatMap((r) => r);

  // ─── Getters ────────────────────────────────────────────────────────

  /// Returns `true` if this is a [Failure] (failure).
  ///
  /// ```dart
  /// Failure('error').isFailure;  // true
  /// Success(42).isFailure;      // false
  /// ```
  bool get isFailure => this is Failure<L, R>;

  /// Returns `true` if this is a [Success] (success).
  ///
  /// ```dart
  /// Success(42).isSuccess;     // true
  /// Failure('error').isSuccess; // false
  /// ```
  bool get isSuccess => this is Success<L, R>;

  // ─── Transformations ────────────────────────────────────────────────

  /// Applies [onFailure] if this is [Failure], or [onSuccess] if this is [Success].
  ///
  /// This is the primary way to extract a value from a [Result] when you
  /// need to unify both cases into a single return type.
  ///
  /// ```dart
  /// final result = Success<String, int>(42);
  /// final message = result.fold(
  ///   (error) => 'Failed: $error',
  ///   (value) => 'Success: $value',
  /// ); // 'Success: 42'
  /// ```
  W fold<W>(W Function(L l) onFailure, W Function(R r) onSuccess);

  /// Transforms the [Success] value using [f], leaving [Failure] unchanged.
  ///
  /// ```dart
  /// Success<String, int>(10).map((x) => x * 2);  // Success(20)
  /// Failure<String, int>('err').map((x) => x * 2); // Failure('err')
  /// ```
  Result<L, R2> map<R2>(R2 Function(R r) f);

  /// Transforms the [Failure] value using [f], leaving [Success] unchanged.
  ///
  /// Useful for mapping error types between layers.
  ///
  /// ```dart
  /// Failure<String, int>('not found').mapFailure((e) => HttpError(404, e));
  /// // Failure(HttpError(404, 'not found'))
  /// ```
  Result<L2, R> mapFailure<L2>(L2 Function(L l) f);

  /// Chains a computation that returns a [Result], avoiding nested Results.
  ///
  /// If this is [Success], applies [f] to the value and returns the result.
  /// If this is [Failure], returns this [Failure] unchanged.
  ///
  /// This is the monadic **bind** operation, essential for composing
  /// sequential computations that may each independently fail.
  ///
  /// ```dart
  /// Result<String, int> parse(String s) =>
  ///     Result.guard(() => int.parse(s), (e, _) => 'Invalid: $s');
  ///
  /// Result<String, int> validate(int n) =>
  ///     n > 0 ? Success(n) : Failure('Must be positive');
  ///
  /// final result = parse('42').flatMap(validate); // Success(42)
  /// final failed = parse('-1').flatMap(validate);  // Failure('Must be positive')
  /// ```
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f);

  /// Returns the [Success] value, or [defaultValue] if this is [Failure].
  ///
  /// ```dart
  /// Success<String, int>(42).getOrElse((_) => 0);   // 42
  /// Failure<String, int>('err').getOrElse((_) => 0); // 0
  /// ```
  R getOrElse(R Function(L l) defaultValue);

  /// Returns the [Success] value or `null` if this is [Failure].
  ///
  /// ```dart
  /// Success<String, int>(42).getOrNull(); // 42
  /// Failure<String, int>('err').getOrNull(); // null
  /// ```
  R? getOrNull();

  /// Returns the [Failure] value or `null` if this is [Success].
  ///
  /// ```dart
  /// Failure<String, int>('err').getFailureOrNull(); // 'err'
  /// Success<String, int>(42).getFailureOrNull(); // null
  /// ```
  L? getFailureOrNull();

  /// Swaps [Failure] and [Success] types.
  ///
  /// ```dart
  /// Success<String, int>(42).swap(); // Failure<int, String>(42)
  /// Failure<String, int>('err').swap(); // Success<int, String>('err')
  /// ```
  Result<R, L> swap();

  /// Converts this [Result] to an [Option], discarding the [Failure] value.
  ///
  /// - [Success] becomes [Some]
  /// - [Failure] becomes [None]
  ///
  /// ```dart
  /// Success<String, int>(42).toOption();    // Some(42)
  /// Failure<String, int>('err').toOption(); // None()
  /// ```
  Option<R> toOption();

  /// Executes [action] if this is [Success], then returns this unchanged.
  ///
  /// Useful for side effects (logging, analytics) without breaking the chain.
  ///
  /// ```dart
  /// fetchUser()
  ///     .tap((user) => logger.info('Fetched: ${user.name}'))
  ///     .map((user) => user.email);
  /// ```
  Result<L, R> tap(void Function(R r) action);

  /// Executes [action] if this is [Failure], then returns this unchanged.
  ///
  /// ```dart
  /// fetchUser()
  ///     .tapFailure((error) => logger.error('Failed: $error'))
  ///     .getOrElse((_) => defaultUser);
  /// ```
  Result<L, R> tapFailure(void Function(L l) action);
}

/// Represents a failed computation containing a value of type [L].
///
/// [Failure] is the "failure" case of [Result], carrying the error
/// information of type [L].
///
/// ```dart
/// final error = Failure<String, int>('Something went wrong');
///
/// // Access via pattern matching
/// if (error case Failure(value: final msg)) {
///   print(msg); // 'Something went wrong'
/// }
/// ```
final class Failure<L, R> extends Result<L, R> {
  /// The failure value.
  final L value;

  /// Creates a [Failure] containing the failure [value].
  const Failure(this.value);

  @override
  W fold<W>(W Function(L l) onFailure, W Function(R r) onSuccess) => onFailure(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R r) f) => Failure<L, R2>(value);

  @override
  Result<L2, R> mapFailure<L2>(L2 Function(L l) f) => Failure<L2, R>(f(value));

  @override
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f) => Failure<L, R2>(value);

  @override
  R getOrElse(R Function(L l) defaultValue) => defaultValue(value);

  @override
  R? getOrNull() => null;

  @override
  L? getFailureOrNull() => value;

  @override
  Result<R, L> swap() => Success<R, L>(value);

  @override
  Option<R> toOption() => None<R>();

  @override
  Result<L, R> tap(void Function(R r) action) => this;

  @override
  Result<L, R> tapFailure(void Function(L l) action) {
    action(value);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Failure<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Failure($value)';
}

/// Represents a successful computation containing a value of type [R].
///
/// [Success] is the "success" case of [Result], carrying the
/// success value of type [R].
///
/// ```dart
/// final success = Success<String, int>(42);
///
/// // Access via pattern matching
/// if (success case Success(value: final data)) {
///   print(data); // 42
/// }
/// ```
final class Success<L, R> extends Result<L, R> {
  /// The success value.
  final R value;

  /// Creates a [Success] containing the success [value].
  const Success(this.value);

  @override
  W fold<W>(W Function(L l) onFailure, W Function(R r) onSuccess) => onSuccess(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R r) f) => Success<L, R2>(f(value));

  @override
  Result<L2, R> mapFailure<L2>(L2 Function(L l) f) => Success<L2, R>(value);

  @override
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f) => f(value);

  @override
  R getOrElse(R Function(L l) defaultValue) => value;

  @override
  R? getOrNull() => value;

  @override
  L? getFailureOrNull() => null;

  @override
  Result<R, L> swap() => Failure<R, L>(value);

  @override
  Option<R> toOption() => Some<R>(value);

  @override
  Result<L, R> tap(void Function(R r) action) {
    action(value);
    return this;
  }

  @override
  Result<L, R> tapFailure(void Function(L l) action) => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}
