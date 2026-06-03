/// Test matchers for [Result] and [Option] types.
///
/// Import this library in your test files to use fluent matchers:
///
/// ```dart
/// import 'package:light_result/light_result.dart';
/// import 'package:light_result/testing.dart';
/// import 'package:test/test.dart';
///
/// void main() {
///   test('returns Right', () {
///     expect(fetchUser(1), isRight);
///     expect(fetchUser(1), isRightWith(expectedUser));
///   });
/// }
/// ```
library;

export 'src/matchers.dart';
