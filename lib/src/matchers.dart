import 'package:matcher/matcher.dart';

import 'option.dart';
import 'result.dart';

/// A matcher that verifies a [Result] is [Success].
///
/// ```dart
/// expect(Success(42), isSuccess);
/// expect(Failure('error'), isNot(isSuccess));
/// ```
const Matcher isSuccess = _IsSuccess();

/// A matcher that verifies a [Result] is [Failure].
///
/// ```dart
/// expect(Failure('error'), isFailure);
/// expect(Success(42), isNot(isFailure));
/// ```
const Matcher isFailure = _IsFailure();

/// A matcher that verifies a [Result] is [Success] containing [value].
///
/// ```dart
/// expect(Success(42), isSuccessWith(42));
/// expect(Success('hello'), isSuccessWith('hello'));
/// ```
Matcher isSuccessWith(Object? value) => _IsSuccessWith(value);

/// A matcher that verifies a [Result] is [Failure] containing [value].
///
/// ```dart
/// expect(Failure('error'), isFailureWith('error'));
/// ```
Matcher isFailureWith(Object? value) => _IsFailureWith(value);

/// A matcher that verifies an [Option] is [Some].
///
/// ```dart
/// expect(Some(42), isSome);
/// expect(None(), isNot(isSome));
/// ```
const Matcher isSome = _IsSome();

/// A matcher that verifies an [Option] is [None].
///
/// ```dart
/// expect(None(), isNone);
/// expect(Some(42), isNot(isNone));
/// ```
const Matcher isNone = _IsNone();

/// A matcher that verifies an [Option] is [Some] containing [value].
///
/// ```dart
/// expect(Some(42), isSomeWith(42));
/// ```
Matcher isSomeWith(Object? value) => _IsSomeWith(value);

// ─── Private Implementations ───────────────────────────────────────────

class _IsSuccess extends Matcher {
  const _IsSuccess();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Success;

  @override
  Description describe(Description description) =>
      description.add('a Success instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Failure) {
      return mismatchDescription
          .add('is a Failure with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsFailure extends Matcher {
  const _IsFailure();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) => item is Failure;

  @override
  Description describe(Description description) =>
      description.add('a Failure instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Success) {
      return mismatchDescription
          .add('is a Success with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsSuccessWith extends Matcher {
  final Object? _expected;
  const _IsSuccessWith(this._expected);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Success && item.value == _expected;

  @override
  Description describe(Description description) => description
      .add('a Success with value: ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Success) {
      return mismatchDescription
          .add('is a Success but with value: ')
          .addDescriptionOf(item.value);
    }
    if (item is Failure) {
      return mismatchDescription
          .add('is a Failure with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsFailureWith extends Matcher {
  final Object? _expected;
  const _IsFailureWith(this._expected);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Failure && item.value == _expected;

  @override
  Description describe(Description description) => description
      .add('a Failure with value: ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Failure) {
      return mismatchDescription
          .add('is a Failure but with value: ')
          .addDescriptionOf(item.value);
    }
    if (item is Success) {
      return mismatchDescription
          .add('is a Success with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsSome extends Matcher {
  const _IsSome();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Some;

  @override
  Description describe(Description description) =>
      description.add('a Some instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is None) {
      return mismatchDescription.add('is None');
    }
    return mismatchDescription.add('is not an Option instance');
  }
}

class _IsNone extends Matcher {
  const _IsNone();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) => item is None;

  @override
  Description describe(Description description) =>
      description.add('a None instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Some) {
      return mismatchDescription
          .add('is a Some with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not an Option instance');
  }
}

class _IsSomeWith extends Matcher {
  final Object? _expected;
  const _IsSomeWith(this._expected);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Some && item.value == _expected;

  @override
  Description describe(Description description) => description
      .add('a Some with value: ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Some) {
      return mismatchDescription
          .add('is a Some but with value: ')
          .addDescriptionOf(item.value);
    }
    if (item is None) {
      return mismatchDescription.add('is None');
    }
    return mismatchDescription.add('is not an Option instance');
  }
}
