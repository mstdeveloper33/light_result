import '../light_result.dart';

/// A [Result] where the failure type is [Exception].
///
/// Convenient shorthand for the most common use case where errors are [Exception]s.
///
/// ```dart
/// ResultOf<int> parseInt(String s) {
///   try {
///     return Success(int.parse(s));
///   } on FormatException catch (e) {
///     return Failure(e);
///   }
/// }
/// ```
typedef ResultOf<T> = Result<Exception, T>;

/// A [Result] where the failure type is [String].
///
/// Useful for simple scenarios where error messages are sufficient.
///
/// ```dart
/// StringResult<int> divide(int a, int b) {
///   if (b == 0) return Failure('Cannot divide by zero');
///   return Success(a ~/ b);
/// }
/// ```
typedef StringResult<T> = Result<String, T>;

/// A [Result] where the failure type is a custom [AppError] class.
///
/// For production applications using a typed failure hierarchy:
///
/// ```dart
/// sealed class AppFailure {
///   const AppFailure();
/// }
/// class NetworkFailure extends AppFailure { ... }
/// class CacheFailure extends AppFailure { ... }
///
/// AppResult<User> fetchUser(int id) async { ... }
/// ```
typedef AppResult<T> = Result<AppError, T>;

/// A [Future] returning a [Result].
///
/// Common return type for async operations.
///
/// ```dart
/// AsyncResult<String, User> fetchUser(int id) async {
///   // ...
///   return Success(user);
/// }
/// ```
typedef AsyncResult<L, R> = Future<Result<L, R>>;

/// A [Future] returning a [ResultOf] (failure type = [Exception]).
///
/// ```dart
/// AsyncResultOf<User> fetchUser(int id) async {
///   // ...
/// }
/// ```
typedef AsyncResultOf<T> = Future<Result<Exception, T>>;

/// Type alias for [Result] — for developers migrating from fpdart/dartz.
///
/// ```dart
/// Either<String, int> divide(int a, int b) {
///   if (b == 0) return Failure('Division by zero');
///   return Success(a ~/ b);
/// }
/// ```
typedef Either<L, R> = Result<L, R>;

/// Represents the absence of a meaningful return value in a [Result].
///
/// Use [Unit] instead of `void` when you need a [Result] that signals
/// success without carrying data. Since `void` cannot be used as a type
/// argument, `Result<AppError, void>` is invalid — use `Result<AppError, Unit>`.
///
/// ```dart
/// Result<AppError, Unit> deleteUser(int id) {
///   if (id <= 0) return Failure(ValidationFailure('Invalid id'));
///   database.delete(id);
///   return Success(unit);
/// }
///
/// // Pattern matching still works
/// switch (deleteUser(1)) {
///   case Failure(value: final err) => print('Failed: ${err.message}'),
///   case Success() => print('Deleted successfully'),
/// }
/// ```
final class Unit {
  const Unit._();

  @override
  bool operator ==(Object other) => other is Unit;

  @override
  int get hashCode => 0;

  @override
  String toString() => '()';
}

/// The singleton instance of [Unit].
///
/// ```dart
/// Result<String, Unit> save(Data data) {
///   repository.save(data);
///   return Success(unit);
/// }
/// ```
const unit = Unit._();

/// Base failure class for structured error handling.
///
/// Extend this class to create a typed failure hierarchy for your application.
/// Using sealed subclasses enables exhaustive pattern matching on error types.
///
/// ```dart
/// sealed class AppFailure extends AppError {
///   const AppFailure(super.message, {super.stackTrace});
/// }
///
/// final class NetworkFailure extends AppFailure {
///   final int? statusCode;
///   const NetworkFailure(super.message, {this.statusCode, super.stackTrace});
/// }
///
/// final class ValidationFailure extends AppFailure {
///   final String field;
///   const ValidationFailure(super.message, {required this.field, super.stackTrace});
/// }
///
/// // Exhaustive error handling
/// final result = await fetchUser(1);
/// final message = switch (result) {
///   Failure(value: NetworkFailure(:final statusCode)) => 'Network: $statusCode',
///   Failure(value: ValidationFailure(:final field)) => 'Invalid: $field',
///   Success(value: final user) => 'Hello, ${user.name}!',
/// };
/// ```
class AppError {
  /// Human-readable description of the failure.
  final String message;

  /// Optional stack trace captured at the point of failure.
  final StackTrace? stackTrace;

  /// Creates an [AppError] with a [message] and optional [stackTrace].
  const AppError(this.message, {this.stackTrace});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppError &&
          other.runtimeType == runtimeType &&
          other.message == message);

  @override
  int get hashCode => Object.hash(runtimeType, message);

  @override
  String toString() => '$runtimeType($message)';
}

// ─── Deprecated Aliases (Migration) ──────────────────────────────────────────

/// Deprecated: Use [Failure] instead.
@Deprecated('Use Failure instead. Will be removed in v1.0.0')
typedef Left<L, R> = Failure<L, R>;

/// Deprecated: Use [Success] instead.
@Deprecated('Use Success instead. Will be removed in v1.0.0')
typedef Right<L, R> = Success<L, R>;
