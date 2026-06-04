import 'package:light_result/light_result.dart';
import 'package:light_result/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    group('Success', () {
      test('creates a Success with value', () {
        final result = Success<String, int>(42);
        expect(result.value, 42);
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('const constructor', () {
        const result = Success<String, int>(42);
        expect(result.value, 42);
      });

      test('equality', () {
        expect(Success<String, int>(42), Success<String, int>(42));
        expect(Success<String, int>(42), isNot(Success<String, int>(43)));
        expect(Success<String, int>(42), isNot(Failure<String, int>('err')));
      });

      test('hashCode', () {
        expect(
          Success<String, int>(42).hashCode,
          Success<String, int>(42).hashCode,
        );
      });

      test('toString', () {
        expect(Success<String, int>(42).toString(), 'Success(42)');
      });

      test('map transforms value', () {
        final result = Success<String, int>(10).map((x) => x * 2);
        expect(result, Success<String, int>(20));
      });

      test('mapFailure does nothing', () {
        final result = Success<String, int>(10).mapFailure((e) => 'mapped: $e');
        expect(result, Success<String, int>(10));
      });

      test('flatMap chains computation', () {
        final result = Success<String, int>(10)
            .flatMap((x) => Success<String, int>(x + 5));
        expect(result, Success<String, int>(15));
      });

      test('flatMap can produce Failure', () {
        final result = Success<String, int>(10)
            .flatMap((x) => Failure<String, int>('failed'));
        expect(result, Failure<String, int>('failed'));
      });

      test('fold applies onSuccess', () {
        final value = Success<String, int>(42).fold(
          (l) => 'left: $l',
          (r) => 'right: $r',
        );
        expect(value, 'right: 42');
      });

      test('getOrElse returns value', () {
        final value = Success<String, int>(42).getOrElse((_) => 0);
        expect(value, 42);
      });

      test('getOrNull returns value', () {
        expect(Success<String, int>(42).getOrNull(), 42);
      });

      test('getFailureOrNull returns null', () {
        expect(Success<String, int>(42).getFailureOrNull(), isNull);
      });

      test('swap', () {
        final swapped = Success<String, int>(42).swap();
        expect(swapped, Failure<int, String>(42));
      });

      test('toOption returns Some', () {
        expect(Success<String, int>(42).toOption(), Some<int>(42));
      });

      test('tap executes action', () {
        int? captured;
        Success<String, int>(42).tap((v) => captured = v);
        expect(captured, 42);
      });

      test('tapFailure does nothing', () {
        String? captured;
        Success<String, int>(42).tapFailure((v) => captured = v);
        expect(captured, isNull);
      });
    });

    group('Failure', () {
      test('creates a Failure with value', () {
        final result = Failure<String, int>('error');
        expect(result.value, 'error');
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
      });

      test('const constructor', () {
        const result = Failure<String, int>('error');
        expect(result.value, 'error');
      });

      test('equality', () {
        expect(Failure<String, int>('err'), Failure<String, int>('err'));
        expect(Failure<String, int>('a'), isNot(Failure<String, int>('b')));
        expect(Failure<String, int>('err'), isNot(Success<String, int>(42)));
      });

      test('hashCode', () {
        expect(
          Failure<String, int>('err').hashCode,
          Failure<String, int>('err').hashCode,
        );
      });

      test('toString', () {
        expect(Failure<String, int>('error').toString(), 'Failure(error)');
      });

      test('map does nothing', () {
        final result = Failure<String, int>('err').map((x) => x * 2);
        expect(result, Failure<String, int>('err'));
      });

      test('mapFailure transforms value', () {
        final result = Failure<String, int>('err').mapFailure((e) => 'mapped: $e');
        expect(result, Failure<String, int>('mapped: err'));
      });

      test('flatMap does nothing', () {
        final result = Failure<String, int>('err')
            .flatMap((x) => Success<String, int>(x + 5));
        expect(result, Failure<String, int>('err'));
      });

      test('fold applies onFailure', () {
        final value = Failure<String, int>('err').fold(
          (l) => 'left: $l',
          (r) => 'right: $r',
        );
        expect(value, 'left: err');
      });

      test('getOrElse returns default', () {
        final value = Failure<String, int>('err').getOrElse((_) => 0);
        expect(value, 0);
      });

      test('getOrNull returns null', () {
        expect(Failure<String, int>('err').getOrNull(), isNull);
      });

      test('getFailureOrNull returns value', () {
        expect(Failure<String, int>('err').getFailureOrNull(), 'err');
      });

      test('swap', () {
        final swapped = Failure<String, int>('err').swap();
        expect(swapped, Success<int, String>('err'));
      });

      test('toOption returns None', () {
        expect(Failure<String, int>('err').toOption(), None<int>());
      });

      test('tap does nothing', () {
        int? captured;
        Failure<String, int>('err').tap((v) => captured = v);
        expect(captured, isNull);
      });

      test('tapFailure executes action', () {
        String? captured;
        Failure<String, int>('err').tapFailure((v) => captured = v);
        expect(captured, 'err');
      });
    });

    group('Factory constructors', () {
      test('Result.success', () {
        final result = Result<String, int>.success(42);
        expect(result, Success<String, int>(42));
      });

      test('Result.failure', () {
        final result = Result<String, int>.failure('err');
        expect(result, Failure<String, int>('err'));
      });

      test('Result.fromNullable with non-null', () {
        final result = Result<String, int>.fromNullable(42, () => 'null!');
        expect(result, Success<String, int>(42));
      });

      test('Result.fromNullable with null', () {
        final result = Result<String, int>.fromNullable(null, () => 'null!');
        expect(result, Failure<String, int>('null!'));
      });

      test('Result.fromPredicate true', () {
        final result = Result<String, int>.fromPredicate(
          18,
          (x) => x >= 18,
          (x) => 'Too young: $x',
        );
        expect(result, Success<String, int>(18));
      });

      test('Result.fromPredicate false', () {
        final result = Result<String, int>.fromPredicate(
          15,
          (x) => x >= 18,
          (x) => 'Too young: $x',
        );
        expect(result, Failure<String, int>('Too young: 15'));
      });
    });

    group('guard', () {
      test('returns Success on success', () {
        final result = Result.guard(
          () => int.parse('42'),
          (e, s) => 'Parse error: $e',
        );
        expect(result, Success<String, int>(42));
      });

      test('returns Failure on exception', () {
        final result = Result.guard(
          () => int.parse('abc'),
          (e, s) => 'Parse error',
        );
        expect(result, Failure<String, int>('Parse error'));
      });
    });

    group('guardAsync', () {
      test('returns Success on success', () async {
        final result = await Result.guardAsync(
          () async => 42,
          (e, s) => 'error',
        );
        expect(result, Success<String, int>(42));
      });

      test('returns Failure on exception', () async {
        final result = await Result.guardAsync<String, int>(
          () async => throw Exception('boom'),
          (e, s) => 'caught: $e',
        );
        expect(result.isFailure, isTrue);
      });
    });

    group('combine', () {
      test('all Successes produces Success<List>', () {
        final results = [
          Success<String, int>(1),
          Success<String, int>(2),
          Success<String, int>(3),
        ];
        final combined = Result.combine(results);
        expect(combined.isSuccess, isTrue);
        expect(combined.getOrElse((_) => []), [1, 2, 3]);
      });

      test('any Failure produces first Failure', () {
        final results = [
          Success<String, int>(1),
          Failure<String, int>('first error'),
          Failure<String, int>('second error'),
        ];
        final combined = Result.combine(results);
        expect(combined, Failure<String, List<int>>('first error'));
      });

      test('empty list produces Success<[]>', () {
        final combined = Result.combine<String, int>([]);
        expect(combined.isSuccess, isTrue);
        expect(combined.getOrElse((_) => [-1]), <int>[]);
      });
    });

    group('waitAll', () {
      test('all success', () async {
        final combined = await Result.waitAll([
          Future.value(Success<String, int>(1)),
          Future.value(Success<String, int>(2)),
        ]);
        expect(combined.isSuccess, isTrue);
        expect(combined.getOrElse((_) => []), [1, 2]);
      });

      test('any failure', () async {
        final combined = await Result.waitAll([
          Future.value(Success<String, int>(1)),
          Future.value(Failure<String, int>('fail')),
        ]);
        expect(combined, Failure<String, List<int>>('fail'));
      });
    });

    group('flatten', () {
      test('flattens nested Success', () {
        final nested = Success<String, Result<String, int>>(Success(42));
        expect(Result.flatten(nested), Success<String, int>(42));
      });

      test('flattens nested Failure', () {
        final nested = Success<String, Result<String, int>>(Failure('inner'));
        expect(Result.flatten(nested), Failure<String, int>('inner'));
      });

      test('outer Failure propagates', () {
        final nested = Failure<String, Result<String, int>>('outer');
        expect(Result.flatten(nested), Failure<String, int>('outer'));
      });
    });

    group('pattern matching', () {
      test('exhaustive switch', () {
        final Result<String, int> result = Success(42);
        final output = switch (result) {
          Failure(value: final e) => 'Error: $e',
          Success(value: final v) => 'Value: $v',
        };
        expect(output, 'Value: 42');
      });

      test('if-case pattern', () {
        final Result<String, int> result = Failure('error');
        if (result case Failure(value: final msg)) {
          expect(msg, 'error');
        } else {
          fail('Should be Failure');
        }
      });
    });
  });

  group('Option', () {
    group('Some', () {
      test('creates Some with value', () {
        final opt = Some(42);
        expect(opt.value, 42);
        expect(opt.isSome, isTrue);
        expect(opt.isNone, isFalse);
      });

      test('const constructor', () {
        const opt = Some(42);
        expect(opt.value, 42);
      });

      test('equality', () {
        expect(Some(42), Some(42));
        expect(Some(42), isNot(Some(43)));
        expect(Some(42), isNot(None<int>()));
      });

      test('toString', () {
        expect(Some(42).toString(), 'Some(42)');
      });

      test('map transforms value', () {
        expect(Some(10).map((x) => x * 2), Some(20));
      });

      test('flatMap chains', () {
        expect(Some(10).flatMap((x) => Some(x + 5)), Some(15));
        expect(Some(10).flatMap((_) => None<int>()), None<int>());
      });

      test('fold applies onSome', () {
        final v = Some(42).fold(() => 'none', (x) => 'some: $x');
        expect(v, 'some: 42');
      });

      test('getOrElse returns value', () {
        expect(Some(42).getOrElse(() => 0), 42);
      });

      test('toNullable returns value', () {
        expect(Some(42).toNullable(), 42);
      });

      test('toResult returns Success', () {
        expect(Some(42).toResult(() => 'err'), Success<String, int>(42));
      });

      test('filter keeps matching value', () {
        expect(Some(42).filter((x) => x > 10), Some(42));
      });

      test('filter removes non-matching value', () {
        expect(Some(5).filter((x) => x > 10), None<int>());
      });

      test('tap executes action', () {
        int? captured;
        Some(42).tap((v) => captured = v);
        expect(captured, 42);
      });
    });

    group('None', () {
      test('creates None', () {
        final opt = None<int>();
        expect(opt.isSome, isFalse);
        expect(opt.isNone, isTrue);
      });

      test('const constructor', () {
        const opt = None<int>();
        expect(opt.isNone, isTrue);
      });

      test('equality', () {
        expect(None<int>(), None<int>());
        expect(None<int>(), isNot(Some(42)));
      });

      test('toString', () {
        expect(None<int>().toString(), 'None()');
      });

      test('map does nothing', () {
        expect(None<int>().map((x) => x * 2), None<int>());
      });

      test('flatMap does nothing', () {
        expect(None<int>().flatMap((x) => Some(x + 5)), None<int>());
      });

      test('fold applies onNone', () {
        final v = None<int>().fold(() => 'none', (x) => 'some: $x');
        expect(v, 'none');
      });

      test('getOrElse returns default', () {
        expect(None<int>().getOrElse(() => 0), 0);
      });

      test('toNullable returns null', () {
        expect(None<int>().toNullable(), isNull);
      });

      test('toResult returns Failure', () {
        expect(None<int>().toResult(() => 'err'), Failure<String, int>('err'));
      });

      test('filter returns None', () {
        expect(None<int>().filter((x) => x > 10), None<int>());
      });

      test('tap does nothing', () {
        int? captured;
        None<int>().tap((v) => captured = v);
        expect(captured, isNull);
      });
    });

    group('Factory constructors', () {
      test('Option.some', () {
        expect(Option.some(42), Some(42));
      });

      test('Option.none', () {
        expect(Option<int>.none(), None<int>());
      });

      test('Option.fromNullable non-null', () {
        expect(Option.fromNullable(42), Some(42));
      });

      test('Option.fromNullable null', () {
        expect(Option.fromNullable(null as int?), None<int>());
      });

      test('Option.fromPredicate true', () {
        expect(Option.fromPredicate(42, (x) => x > 10), Some(42));
      });

      test('Option.fromPredicate false', () {
        expect(Option.fromPredicate(5, (x) => x > 10), None<int>());
      });

      test('Option.tryCatch success', () {
        expect(Option.tryCatch(() => int.parse('42')), Some(42));
      });

      test('Option.tryCatch failure', () {
        expect(Option.tryCatch(() => int.parse('abc')), None<int>());
      });
    });

    group('pattern matching', () {
      test('exhaustive switch', () {
        final Option<int> opt = Some(42);
        final output = switch (opt) {
          Some(value: final v) => 'Value: $v',
          None() => 'Empty',
        };
        expect(output, 'Value: 42');
      });
    });
  });

  group('TaskResult extensions', () {
    test('thenMap', () async {
      final result = await Future.value(Success<String, int>(10))
          .thenMap((x) => x * 2);
      expect(result, Success<String, int>(20));
    });

    test('thenMap on Failure', () async {
      final result = await Future.value(Failure<String, int>('err'))
          .thenMap((x) => x * 2);
      expect(result, Failure<String, int>('err'));
    });

    test('thenMapFailure', () async {
      final result = await Future.value(Failure<String, int>('err'))
          .thenMapFailure((e) => 'mapped: $e');
      expect(result, Failure<String, int>('mapped: err'));
    });

    test('thenFlatMap success chain', () async {
      final result = await Future.value(Success<String, int>(10))
          .thenFlatMap((x) async => Success<String, int>(x + 5));
      expect(result, Success<String, int>(15));
    });

    test('thenFlatMap Failure propagates', () async {
      final result = await Future.value(Failure<String, int>('err'))
          .thenFlatMap((x) async => Success<String, int>(x + 5));
      expect(result, Failure<String, int>('err'));
    });

    test('thenFold', () async {
      final msg = await Future.value(Success<String, int>(42))
          .thenFold((l) => 'left', (r) => 'right: $r');
      expect(msg, 'right: 42');
    });

    test('thenGetOrElse', () async {
      final val = await Future.value(Failure<String, int>('err'))
          .thenGetOrElse((_) => 0);
      expect(val, 0);
    });

    test('thenTap executes on Success', () async {
      int? captured;
      await Future.value(Success<String, int>(42))
          .thenTap((v) => captured = v);
      expect(captured, 42);
    });

    test('thenOrElse recovers from Failure', () async {
      final result = await Future.value(Failure<String, int>('err'))
          .thenOrElse((l) async => Success<String, int>(0));
      expect(result, Success<String, int>(0));
    });
  });

  group('TaskOption extensions', () {
    test('thenMap', () async {
      final result = await Future.value(Some(10) as Option<int>)
          .thenMap((x) => x * 2);
      expect(result, Some(20));
    });

    test('thenFlatMap', () async {
      final result = await Future.value(Some(10) as Option<int>)
          .thenFlatMap((x) async => Some(x + 5));
      expect(result, Some(15));
    });

    test('thenGetOrElse', () async {
      final val = await Future.value(None<int>() as Option<int>)
          .thenGetOrElse(() => 0);
      expect(val, 0);
    });

    test('thenToResult', () async {
      final result = await Future.value(Some(42) as Option<int>)
          .thenToResult(() => 'missing');
      expect(result, Success<String, int>(42));
    });
  });

  group('Typedefs', () {
    test('AppError equality', () {
      const f1 = AppError('error');
      const f2 = AppError('error');
      const f3 = AppError('other');
      expect(f1, f2);
      expect(f1, isNot(f3));
    });

    test('AppError toString', () {
      expect(const AppError('oops').toString(), 'AppError(oops)');
    });

    test('AppError hashCode', () {
      expect(
        const AppError('err').hashCode,
        const AppError('err').hashCode,
      );
    });

    test('ResultOf type alias works', () {
      ResultOf<int> parse(String s) {
        try {
          return Success(int.parse(s));
        } on FormatException catch (e) {
          return Failure(e);
        }
      }

      expect(parse('42'), isSuccess);
      expect(parse('abc'), isFailure);
    });

    test('Either type alias works', () {
      Either<String, int> divide(int a, int b) {
        if (b == 0) return Failure('Division by zero');
        return Success(a ~/ b);
      }

      expect(divide(10, 2), isSuccessWith(5));
      expect(divide(10, 0), isFailureWith('Division by zero'));
    });

    test('Unit type', () {
      Result<String, Unit> doSomething() => Success(unit);

      final result = doSomething();
      expect(result, isSuccess);
      expect(result.getOrNull(), unit);
    });

    test('Unit equality', () {
      expect(unit, unit);
      expect(unit.toString(), '()');
      expect(unit.hashCode, 0);
    });
  });

  group('Matchers', () {
    test('isSuccess', () {
      expect(Success<String, int>(42), isSuccess);
      expect(Failure<String, int>('err'), isNot(isSuccess));
    });

    test('isFailure', () {
      expect(Failure<String, int>('err'), isFailure);
      expect(Success<String, int>(42), isNot(isFailure));
    });

    test('isSuccessWith', () {
      expect(Success<String, int>(42), isSuccessWith(42));
      expect(Success<String, int>(42), isNot(isSuccessWith(43)));
    });

    test('isFailureWith', () {
      expect(Failure<String, int>('err'), isFailureWith('err'));
      expect(Failure<String, int>('err'), isNot(isFailureWith('other')));
    });

    test('isSome', () {
      expect(Some(42), isSome);
      expect(None<int>(), isNot(isSome));
    });

    test('isNone', () {
      expect(None<int>(), isNone);
      expect(Some(42), isNot(isNone));
    });

    test('isSomeWith', () {
      expect(Some(42), isSomeWith(42));
      expect(Some(42), isNot(isSomeWith(43)));
    });
  });
}
