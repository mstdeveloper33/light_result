import 'option.dart';

/// Core [Result] monad — the heart of functional error handling.
///
/// [Result] is a sealed class representing a value that is either:
/// - [Right] — a successful computation containing a value of type [R].
/// - [Left] — a failed computation containing an error of type [L].
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
///   if (b == 0) return Left('Division by zero');
///   return Right(a ~/ b);
/// }
///
/// final result = divide(10, 2);
///
/// // Exhaustive pattern matching — compiler ensures both cases are handled
/// final output = switch (result) {
///   Left(value: final error) => 'Error: $error',
///   Right(value: final data) => 'Result: $data',
/// };
/// ```
///
/// ## Functional Chaining
///
/// ```dart
/// final result = Right<String, int>(10)
///     .map((x) => x * 2)          // Right(20)
///     .flatMap((x) => divide(x, 4)) // Right(5)
///     .mapLeft((e) => 'Failed: $e'); // Only transforms if Left
/// ```
sealed class Result<L, R> {
  /// Creates a [Result] instance.
  ///
  /// Use [Right] or [Left] constructors directly, or the convenience
  /// factory constructors [Result.right], [Result.left], [Result.success],
  /// [Result.failure].
  const Result();

  // ─── Factory Constructors ───────────────────────────────────────────

  /// Creates a [Right] containing the success value [r].
  ///
  /// ```dart
  /// final result = Result<String, int>.right(42); // Right(42)
  /// ```
  factory Result.right(R r) = Right<L, R>;

  /// Creates a [Left] containing the failure value [l].
  ///
  /// ```dart
  /// final result = Result<String, int>.left('error'); // Left('error')
  /// ```
  factory Result.left(L l) = Left<L, R>;

  /// Alias for [Result.right] — creates a success [Result].
  ///
  /// ```dart
  /// final result = Result<String, int>.success(42); // Right(42)
  /// ```
  factory Result.success(R r) = Right<L, R>;

  /// Alias for [Result.left] — creates a failure [Result].
  ///
  /// ```dart
  /// final result = Result<String, int>.failure('oops'); // Left('oops')
  /// ```
  factory Result.failure(L l) = Left<L, R>;

  /// Creates a [Right] from a non-null value, or [Left] from [onNull] if null.
  ///
  /// Useful for bridging nullable APIs into the [Result] world.
  ///
  /// ```dart
  /// final result = Result<String, int>.fromNullable(
  ///   json['age'] as int?,
  ///   () => 'age field is missing',
  /// ); // Right(25) or Left('age field is missing')
  /// ```
  factory Result.fromNullable(R? value, L Function() onNull) =>
      value != null ? Right<L, R>(value) : Left<L, R>(onNull());

  /// Creates a [Right] if [predicate] returns true for [value],
  /// otherwise creates a [Left] using [onFalse].
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
      predicate(value) ? Right<L, R>(value) : Left<L, R>(onFalse(value));

  /// Executes [run] and wraps the result in a [Right].
  /// If [run] throws, catches the exception and wraps it in [Left] via [onError].
  ///
  /// ```dart
  /// final result = Result.guard(
  ///   () => int.parse('42'),
  ///   (error, stack) => 'Parse failed: $error',
  /// ); // Right(42)
  ///
  /// final failed = Result.guard(
  ///   () => int.parse('abc'),
  ///   (error, stack) => 'Parse failed: $error',
  /// ); // Left('Parse failed: FormatException...')
  /// ```
  static Result<L, R> guard<L, R>(
    R Function() run,
    L Function(Object error, StackTrace stack) onError,
  ) {
    try {
      return Right<L, R>(run());
    } catch (e, s) {
      return Left<L, R>(onError(e, s));
    }
  }

  /// Async version of [guard]. Executes [run] and wraps the result in [Right].
  /// If [run] throws, catches the exception and wraps it in [Left] via [onError].
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
      return Right<L, R>(await run());
    } catch (e, s) {
      return Left<L, R>(onError(e, s));
    }
  }

  /// Combines a list of [Result]s into a single [Result] containing
  /// a list of all success values.
  ///
  /// If **any** [Result] in the list is [Left], returns the **first** [Left] found.
  /// If **all** are [Right], returns a [Right] containing all values.
  ///
  /// ```dart
  /// final results = [Right<String, int>(1), Right<String, int>(2)];
  /// final combined = Result.combine(results); // Right([1, 2])
  ///
  /// final mixed = [Right<String, int>(1), Left<String, int>('fail')];
  /// final combined2 = Result.combine(mixed); // Left('fail')
  /// ```
  static Result<L, List<R>> combine<L, R>(List<Result<L, R>> results) {
    final values = <R>[];
    for (final result in results) {
      switch (result) {
        case Left<L, R>(value: final l):
          return Left<L, List<R>>(l);
        case Right<L, R>(value: final r):
          values.add(r);
      }
    }
    return Right<L, List<R>>(values);
  }

  /// Async version of [combine]. Awaits all futures and combines results.
  ///
  /// All futures are awaited concurrently using [Future.wait].
  /// If **any** result is [Left], returns the **first** [Left].
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
  /// final nested = Right<String, Result<String, int>>(Right(42));
  /// final flat = Result.flatten(nested); // Right(42)
  /// ```
  static Result<L, R> flatten<L, R>(Result<L, Result<L, R>> result) =>
      result.flatMap((r) => r);

  // ─── Getters ────────────────────────────────────────────────────────

  /// Returns `true` if this is a [Left] (failure).
  ///
  /// ```dart
  /// Left('error').isLeft;  // true
  /// Right(42).isLeft;      // false
  /// ```
  bool get isLeft => this is Left<L, R>;

  /// Returns `true` if this is a [Right] (success).
  ///
  /// ```dart
  /// Right(42).isRight;     // true
  /// Left('error').isRight; // false
  /// ```
  bool get isRight => this is Right<L, R>;

  // ─── Transformations ────────────────────────────────────────────────

  /// Applies [onLeft] if this is [Left], or [onRight] if this is [Right].
  ///
  /// This is the primary way to extract a value from a [Result] when you
  /// need to unify both cases into a single return type.
  ///
  /// ```dart
  /// final result = Right<String, int>(42);
  /// final message = result.fold(
  ///   (error) => 'Failed: $error',
  ///   (value) => 'Success: $value',
  /// ); // 'Success: 42'
  /// ```
  W fold<W>(W Function(L l) onLeft, W Function(R r) onRight);

  /// Transforms the [Right] value using [f], leaving [Left] unchanged.
  ///
  /// ```dart
  /// Right<String, int>(10).map((x) => x * 2);  // Right(20)
  /// Left<String, int>('err').map((x) => x * 2); // Left('err')
  /// ```
  Result<L, R2> map<R2>(R2 Function(R r) f);

  /// Transforms the [Left] value using [f], leaving [Right] unchanged.
  ///
  /// Useful for mapping error types between layers.
  ///
  /// ```dart
  /// Left<String, int>('not found').mapLeft((e) => HttpError(404, e));
  /// // Left(HttpError(404, 'not found'))
  /// ```
  Result<L2, R> mapLeft<L2>(L2 Function(L l) f);

  /// Chains a computation that returns a [Result], avoiding nested Results.
  ///
  /// If this is [Right], applies [f] to the value and returns the result.
  /// If this is [Left], returns this [Left] unchanged.
  ///
  /// This is the monadic **bind** operation, essential for composing
  /// sequential computations that may each independently fail.
  ///
  /// ```dart
  /// Result<String, int> parse(String s) =>
  ///     Result.guard(() => int.parse(s), (e, _) => 'Invalid: $s');
  ///
  /// Result<String, int> validate(int n) =>
  ///     n > 0 ? Right(n) : Left('Must be positive');
  ///
  /// final result = parse('42').flatMap(validate); // Right(42)
  /// final failed = parse('-1').flatMap(validate);  // Left('Must be positive')
  /// ```
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f);

  /// Returns the [Right] value, or [defaultValue] if this is [Left].
  ///
  /// ```dart
  /// Right<String, int>(42).getOrElse((_) => 0);   // 42
  /// Left<String, int>('err').getOrElse((_) => 0); // 0
  /// ```
  R getOrElse(R Function(L l) defaultValue);

  /// Returns the [Right] value or `null` if this is [Left].
  ///
  /// ```dart
  /// Right<String, int>(42).getOrNull(); // 42
  /// Left<String, int>('err').getOrNull(); // null
  /// ```
  R? getOrNull();

  /// Returns the [Left] value or `null` if this is [Right].
  ///
  /// ```dart
  /// Left<String, int>('err').getLeftOrNull(); // 'err'
  /// Right<String, int>(42).getLeftOrNull(); // null
  /// ```
  L? getLeftOrNull();

  /// Swaps [Left] and [Right] types.
  ///
  /// ```dart
  /// Right<String, int>(42).swap(); // Left<int, String>(42)
  /// Left<String, int>('err').swap(); // Right<int, String>('err')
  /// ```
  Result<R, L> swap();

  /// Converts this [Result] to an [Option], discarding the [Left] value.
  ///
  /// - [Right] becomes [Some]
  /// - [Left] becomes [None]
  ///
  /// ```dart
  /// Right<String, int>(42).toOption();    // Some(42)
  /// Left<String, int>('err').toOption(); // None()
  /// ```
  Option<R> toOption();

  /// Executes [action] if this is [Right], then returns this unchanged.
  ///
  /// Useful for side effects (logging, analytics) without breaking the chain.
  ///
  /// ```dart
  /// fetchUser()
  ///     .tap((user) => logger.info('Fetched: ${user.name}'))
  ///     .map((user) => user.email);
  /// ```
  Result<L, R> tap(void Function(R r) action);

  /// Executes [action] if this is [Left], then returns this unchanged.
  ///
  /// ```dart
  /// fetchUser()
  ///     .tapLeft((error) => logger.error('Failed: $error'))
  ///     .getOrElse((_) => defaultUser);
  /// ```
  Result<L, R> tapLeft(void Function(L l) action);
}

/// Represents a failed computation containing a value of type [L].
///
/// [Left] is the "failure" case of [Result]. By convention, the left side
/// carries the error information.
///
/// ```dart
/// final error = Left<String, int>('Something went wrong');
///
/// // Access via pattern matching
/// if (error case Left(value: final msg)) {
///   print(msg); // 'Something went wrong'
/// }
/// ```
final class Left<L, R> extends Result<L, R> {
  /// The failure value.
  final L value;

  /// Creates a [Left] containing the failure [value].
  const Left(this.value);

  @override
  W fold<W>(W Function(L l) onLeft, W Function(R r) onRight) => onLeft(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R r) f) => Left<L, R2>(value);

  @override
  Result<L2, R> mapLeft<L2>(L2 Function(L l) f) => Left<L2, R>(f(value));

  @override
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f) => Left<L, R2>(value);

  @override
  R getOrElse(R Function(L l) defaultValue) => defaultValue(value);

  @override
  R? getOrNull() => null;

  @override
  L? getLeftOrNull() => value;

  @override
  Result<R, L> swap() => Right<R, L>(value);

  @override
  Option<R> toOption() => None<R>();

  @override
  Result<L, R> tap(void Function(R r) action) => this;

  @override
  Result<L, R> tapLeft(void Function(L l) action) {
    action(value);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Left<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Represents a successful computation containing a value of type [R].
///
/// [Right] is the "success" case of [Result]. By convention, the right side
/// carries the success value (mnemonic: "right" = "correct").
///
/// ```dart
/// final success = Right<String, int>(42);
///
/// // Access via pattern matching
/// if (success case Right(value: final data)) {
///   print(data); // 42
/// }
/// ```
final class Right<L, R> extends Result<L, R> {
  /// The success value.
  final R value;

  /// Creates a [Right] containing the success [value].
  const Right(this.value);

  @override
  W fold<W>(W Function(L l) onLeft, W Function(R r) onRight) => onRight(value);

  @override
  Result<L, R2> map<R2>(R2 Function(R r) f) => Right<L, R2>(f(value));

  @override
  Result<L2, R> mapLeft<L2>(L2 Function(L l) f) => Right<L2, R>(value);

  @override
  Result<L, R2> flatMap<R2>(Result<L, R2> Function(R r) f) => f(value);

  @override
  R getOrElse(R Function(L l) defaultValue) => value;

  @override
  R? getOrNull() => value;

  @override
  L? getLeftOrNull() => null;

  @override
  Result<R, L> swap() => Left<R, L>(value);

  @override
  Option<R> toOption() => Some<R>(value);

  @override
  Result<L, R> tap(void Function(R r) action) {
    action(value);
    return this;
  }

  @override
  Result<L, R> tapLeft(void Function(L l) action) => this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Right<L, R> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}
