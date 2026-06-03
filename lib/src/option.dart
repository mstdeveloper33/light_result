import 'result.dart';

/// Functional [Option] type — a safe alternative to nullable types.
///
/// [Option] is a sealed class representing a value that may or may not exist:
/// - [Some] — contains a non-null value of type [T].
/// - [None] — represents the absence of a value.
///
/// ## Why Option over null?
///
/// While Dart has null safety, `null` still has ambiguity:
/// - Is `null` a valid domain value or an error state?
/// - Chaining operations on nullable types requires verbose null checks.
/// - Pattern matching on nullable types isn't exhaustive.
///
/// [Option] makes the "absence" explicit and forces handling via exhaustive matching.
///
/// ## Basic Usage
///
/// ```dart
/// Option<int> findUser(int id) {
///   final user = database.get(id);
///   return Option.fromNullable(user?.age);
/// }
///
/// // Exhaustive pattern matching
/// final message = switch (findUser(1)) {
///   Some(value: final age) => 'Age: $age',
///   None() => 'User not found',
/// };
/// ```
///
/// ## Converting between Option and Nullable
///
/// ```dart
/// // Nullable → Option
/// final opt = Option.fromNullable(possiblyNullValue);
///
/// // Option → Nullable
/// final nullable = opt.toNullable();
/// ```
sealed class Option<T> {
  /// Creates an [Option] instance.
  const Option();

  // ─── Factory Constructors ───────────────────────────────────────────

  /// Creates a [Some] containing [value].
  ///
  /// ```dart
  /// final opt = Option.some(42); // Some(42)
  /// ```
  factory Option.some(T value) = Some<T>;

  /// Creates a [None] representing absence.
  ///
  /// ```dart
  /// final opt = Option<int>.none(); // None()
  /// ```
  factory Option.none() = None<T>;

  /// Creates an [Option] from a nullable value.
  ///
  /// - If [value] is non-null, returns [Some] containing the value.
  /// - If [value] is null, returns [None].
  ///
  /// ```dart
  /// Option.fromNullable(42);   // Some(42)
  /// Option.fromNullable(null); // None()
  ///
  /// // Perfect for bridging nullable APIs
  /// final name = Option.fromNullable(json['name'] as String?);
  /// ```
  factory Option.fromNullable(T? value) =>
      value != null ? Some<T>(value) : None<T>();

  /// Creates an [Option] by evaluating [predicate] on [value].
  ///
  /// - If [predicate] returns true, returns [Some] containing [value].
  /// - Otherwise returns [None].
  ///
  /// ```dart
  /// Option.fromPredicate(18, (age) => age >= 18); // Some(18)
  /// Option.fromPredicate(15, (age) => age >= 18); // None()
  /// ```
  factory Option.fromPredicate(T value, bool Function(T t) predicate) =>
      predicate(value) ? Some<T>(value) : None<T>();

  /// Executes [run] and wraps the result in [Some].
  /// If [run] throws, returns [None].
  ///
  /// ```dart
  /// Option.tryCatch(() => int.parse('42'));    // Some(42)
  /// Option.tryCatch(() => int.parse('abc'));  // None()
  /// ```
  static Option<T> tryCatch<T>(T Function() run) {
    try {
      return Some<T>(run());
    } catch (_) {
      return None<T>();
    }
  }

  // ─── Getters ────────────────────────────────────────────────────────

  /// Returns `true` if this is [Some].
  ///
  /// ```dart
  /// Some(42).isSome; // true
  /// None().isSome;   // false
  /// ```
  bool get isSome => this is Some<T>;

  /// Returns `true` if this is [None].
  ///
  /// ```dart
  /// None().isNone;   // true
  /// Some(42).isNone; // false
  /// ```
  bool get isNone => this is None<T>;

  // ─── Transformations ────────────────────────────────────────────────

  /// Applies [onNone] if this is [None], or [onSome] if this is [Some].
  ///
  /// ```dart
  /// final opt = Some(42);
  /// final msg = opt.fold(
  ///   () => 'empty',
  ///   (value) => 'value: $value',
  /// ); // 'value: 42'
  /// ```
  W fold<W>(W Function() onNone, W Function(T t) onSome);

  /// Transforms the contained value using [f] if this is [Some].
  ///
  /// ```dart
  /// Some(10).map((x) => x * 2); // Some(20)
  /// None<int>().map((x) => x * 2); // None()
  /// ```
  Option<R> map<R>(R Function(T t) f);

  /// Chains a computation that returns an [Option], avoiding nesting.
  ///
  /// ```dart
  /// Option<int> parseAge(String s) => Option.tryCatch(() => int.parse(s));
  /// Option<String> validateAge(int age) =>
  ///     age >= 18 ? Some('Valid') : None();
  ///
  /// final result = parseAge('25').flatMap(validateAge); // Some('Valid')
  /// ```
  Option<R> flatMap<R>(Option<R> Function(T t) f);

  /// Returns the contained value if [Some], otherwise returns [defaultValue].
  ///
  /// ```dart
  /// Some(42).getOrElse(() => 0); // 42
  /// None<int>().getOrElse(() => 0); // 0
  /// ```
  T getOrElse(T Function() defaultValue);

  /// Returns the contained value if [Some], otherwise returns `null`.
  ///
  /// ```dart
  /// Some(42).toNullable(); // 42
  /// None<int>().toNullable(); // null
  /// ```
  T? toNullable();

  /// Converts this [Option] to a [Result].
  ///
  /// - [Some] becomes [Right] containing the value.
  /// - [None] becomes [Left] containing the result of [onNone].
  ///
  /// ```dart
  /// Some(42).toResult(() => 'missing');    // Right(42)
  /// None<int>().toResult(() => 'missing'); // Left('missing')
  /// ```
  Result<L, T> toResult<L>(L Function() onNone);

  /// Returns this [Option] if it is [Some] and [predicate] returns true.
  /// Otherwise returns [None].
  ///
  /// ```dart
  /// Some(42).filter((x) => x > 10); // Some(42)
  /// Some(5).filter((x) => x > 10);  // None()
  /// None<int>().filter((x) => x > 10); // None()
  /// ```
  Option<T> filter(bool Function(T t) predicate);

  /// Executes [action] if this is [Some], then returns this unchanged.
  ///
  /// ```dart
  /// Some(42).tap((x) => print(x)); // prints 42, returns Some(42)
  /// ```
  Option<T> tap(void Function(T t) action);
}

/// Represents the presence of a value.
///
/// ```dart
/// final some = Some(42);
/// print(some.value); // 42
/// ```
final class Some<T> extends Option<T> {
  /// The contained value.
  final T value;

  /// Creates a [Some] containing [value].
  const Some(this.value);

  @override
  W fold<W>(W Function() onNone, W Function(T t) onSome) => onSome(value);

  @override
  Option<R> map<R>(R Function(T t) f) => Some<R>(f(value));

  @override
  Option<R> flatMap<R>(Option<R> Function(T t) f) => f(value);

  @override
  T getOrElse(T Function() defaultValue) => value;

  @override
  T? toNullable() => value;

  @override
  Result<L, T> toResult<L>(L Function() onNone) => Right<L, T>(value);

  @override
  Option<T> filter(bool Function(T t) predicate) =>
      predicate(value) ? this : None<T>();

  @override
  Option<T> tap(void Function(T t) action) {
    action(value);
    return this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Some<T> && other.value == value);

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Some($value)';
}

/// Represents the absence of a value.
///
/// ```dart
/// final none = None<int>();
/// print(none.isNone); // true
/// ```
final class None<T> extends Option<T> {
  /// Creates a [None] instance.
  const None();

  @override
  W fold<W>(W Function() onNone, W Function(T t) onSome) => onNone();

  @override
  Option<R> map<R>(R Function(T t) f) => None<R>();

  @override
  Option<R> flatMap<R>(Option<R> Function(T t) f) => None<R>();

  @override
  T getOrElse(T Function() defaultValue) => defaultValue();

  @override
  T? toNullable() => null;

  @override
  Result<L, T> toResult<L>(L Function() onNone) => Left<L, T>(onNone());

  @override
  Option<T> filter(bool Function(T t) predicate) => this;

  @override
  Option<T> tap(void Function(T t) action) => this;

  @override
  bool operator ==(Object other) => identical(this, other) || other is None<T>;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'None()';
}
