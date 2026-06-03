import 'package:matcher/matcher.dart';

import 'option.dart';
import 'result.dart';

/// A matcher that verifies a [Result] is [Right].
///
/// ```dart
/// expect(Right(42), isRight);
/// expect(Left('error'), isNot(isRight));
/// ```
const Matcher isRight = _IsRight();

/// A matcher that verifies a [Result] is [Left].
///
/// ```dart
/// expect(Left('error'), isLeft);
/// expect(Right(42), isNot(isLeft));
/// ```
const Matcher isLeft = _IsLeft();

/// A matcher that verifies a [Result] is [Right] containing [value].
///
/// ```dart
/// expect(Right(42), isRightWith(42));
/// expect(Right('hello'), isRightWith('hello'));
/// ```
Matcher isRightWith(Object? value) => _IsRightWith(value);

/// A matcher that verifies a [Result] is [Left] containing [value].
///
/// ```dart
/// expect(Left('error'), isLeftWith('error'));
/// ```
Matcher isLeftWith(Object? value) => _IsLeftWith(value);

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

class _IsRight extends Matcher {
  const _IsRight();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Right;

  @override
  Description describe(Description description) =>
      description.add('a Right instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Left) {
      return mismatchDescription
          .add('is a Left with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsLeft extends Matcher {
  const _IsLeft();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) => item is Left;

  @override
  Description describe(Description description) =>
      description.add('a Left instance');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Right) {
      return mismatchDescription
          .add('is a Right with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsRightWith extends Matcher {
  final Object? _expected;
  const _IsRightWith(this._expected);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Right && item.value == _expected;

  @override
  Description describe(Description description) => description
      .add('a Right with value: ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Right) {
      return mismatchDescription
          .add('is a Right but with value: ')
          .addDescriptionOf(item.value);
    }
    if (item is Left) {
      return mismatchDescription
          .add('is a Left with value: ')
          .addDescriptionOf(item.value);
    }
    return mismatchDescription.add('is not a Result instance');
  }
}

class _IsLeftWith extends Matcher {
  final Object? _expected;
  const _IsLeftWith(this._expected);

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) =>
      item is Left && item.value == _expected;

  @override
  Description describe(Description description) => description
      .add('a Left with value: ')
      .addDescriptionOf(_expected);

  @override
  Description describeMismatch(
    Object? item,
    Description mismatchDescription,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is Left) {
      return mismatchDescription
          .add('is a Left but with value: ')
          .addDescriptionOf(item.value);
    }
    if (item is Right) {
      return mismatchDescription
          .add('is a Right with value: ')
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
