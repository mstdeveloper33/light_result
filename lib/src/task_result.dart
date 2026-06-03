import 'dart:async';

import '../light_result.dart';

/// Extensions on `Future<Result<L, R>>` to enable fluent async chaining.
///
/// These extensions eliminate the need to `await` intermediate results
/// when composing async operations that return [Result].
///
/// ## Without TaskResult Extensions
///
/// ```dart
/// Future<Result<String, User>> fetchUser() async { ... }
/// Future<Result<String, Profile>> fetchProfile(User user) async { ... }
///
/// // Verbose — must await each step
/// final userResult = await fetchUser();
/// final profileResult = await userResult.fold(
///   (err) async => Left(err),
///   (user) => fetchProfile(user),
/// );
/// ```
///
/// ## With TaskResult Extensions
///
/// ```dart
/// final profile = await fetchUser()
///     .thenMap((user) => user.name)
///     .thenFlatMap((name) => fetchProfile(name));
/// ```
extension TaskResult<L, R> on Future<Result<L, R>> {
  /// Transforms the [Right] value inside the [Future] using [f].
  ///
  /// ```dart
  /// Future<Result<String, int>> fetchAge() async => Right(25);
  ///
  /// final doubled = await fetchAge().thenMap((age) => age * 2);
  /// // Right(50)
  /// ```
  Future<Result<L, R2>> thenMap<R2>(R2 Function(R r) f) async {
    final result = await this;
    return result.map(f);
  }

  /// Transforms the [Left] value inside the [Future] using [f].
  ///
  /// ```dart
  /// final mapped = await fetchData()
  ///     .thenMapLeft((err) => 'Wrapped: $err');
  /// ```
  Future<Result<L2, R>> thenMapLeft<L2>(L2 Function(L l) f) async {
    final result = await this;
    return result.mapLeft(f);
  }

  /// Chains an async computation that returns a [Result],
  /// avoiding nested `Future<Result<Result<...>>>`.
  ///
  /// ```dart
  /// final profile = await fetchUser()
  ///     .thenFlatMap((user) => fetchProfile(user.id));
  /// ```
  Future<Result<L, R2>> thenFlatMap<R2>(
    FutureOr<Result<L, R2>> Function(R r) f,
  ) async {
    final result = await this;
    return switch (result) {
      Left<L, R>(value: final l) => Left<L, R2>(l),
      Right<L, R>(value: final r) => await f(r),
    };
  }

  /// Applies [onLeft] or [onRight] to produce a single value.
  ///
  /// ```dart
  /// final message = await fetchUser().thenFold(
  ///   (err) => 'Error: $err',
  ///   (user) => 'Hello, ${user.name}!',
  /// );
  /// ```
  Future<W> thenFold<W>(
    W Function(L l) onLeft,
    W Function(R r) onRight,
  ) async {
    final result = await this;
    return result.fold(onLeft, onRight);
  }

  /// Returns the [Right] value or [defaultValue] if [Left].
  ///
  /// ```dart
  /// final name = await fetchUser()
  ///     .thenGetOrElse((_) => defaultUser);
  /// ```
  Future<R> thenGetOrElse(R Function(L l) defaultValue) async {
    final result = await this;
    return result.getOrElse(defaultValue);
  }

  /// Executes [action] on the [Right] value without transforming it.
  ///
  /// ```dart
  /// final user = await fetchUser()
  ///     .thenTap((user) => analytics.logFetch(user.id))
  ///     .thenMap((user) => user.name);
  /// ```
  Future<Result<L, R>> thenTap(void Function(R r) action) async {
    final result = await this;
    return result.tap(action);
  }

  /// Executes [action] on the [Left] value without transforming it.
  ///
  /// ```dart
  /// final user = await fetchUser()
  ///     .thenTapLeft((err) => logger.error(err));
  /// ```
  Future<Result<L, R>> thenTapLeft(void Function(L l) action) async {
    final result = await this;
    return result.tapLeft(action);
  }

  /// Recovers from a [Left] by trying an alternative computation.
  ///
  /// ```dart
  /// final data = await fetchFromNetwork()
  ///     .thenOrElse((err) async => fetchFromCache());
  /// ```
  Future<Result<L2, R>> thenOrElse<L2>(
    FutureOr<Result<L2, R>> Function(L l) onLeft,
  ) async {
    final result = await this;
    return switch (result) {
      Left<L, R>(value: final l) => await onLeft(l),
      Right<L, R>(value: final r) => Right<L2, R>(r),
    };
  }
}

/// Extensions on `Future<Option<T>>` for fluent async option chaining.
///
/// ```dart
/// Future<Option<User>> findCachedUser(int id) async { ... }
///
/// final name = await findCachedUser(1)
///     .thenMap((user) => user.name)
///     .thenGetOrElse(() => 'Unknown');
/// ```
extension TaskOption<T> on Future<Option<T>> {
  /// Transforms the [Some] value inside the [Future] using [f].
  Future<Option<R>> thenMap<R>(R Function(T t) f) async {
    final option = await this;
    return option.map(f);
  }

  /// Chains a computation that returns an [Option].
  Future<Option<R>> thenFlatMap<R>(
    FutureOr<Option<R>> Function(T t) f,
  ) async {
    final option = await this;
    return switch (option) {
      Some<T>(value: final v) => await f(v),
      None<T>() => None<R>(),
    };
  }

  /// Returns the [Some] value or [defaultValue] if [None].
  Future<T> thenGetOrElse(T Function() defaultValue) async {
    final option = await this;
    return option.getOrElse(defaultValue);
  }

  /// Applies [onNone] or [onSome] to produce a single value.
  Future<W> thenFold<W>(
    W Function() onNone,
    W Function(T t) onSome,
  ) async {
    final option = await this;
    return option.fold(onNone, onSome);
  }

  /// Converts the [Option] inside the [Future] to a [Result].
  Future<Result<L, T>> thenToResult<L>(L Function() onNone) async {
    final option = await this;
    return option.toResult(onNone);
  }
}
