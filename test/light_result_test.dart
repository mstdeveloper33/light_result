import 'package:light_result/light_result.dart';
import 'package:light_result/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    group('Right', () {
      test('creates a Right with value', () {
        final result = Right<String, int>(42);
        expect(result.value, 42);
        expect(result.isRight, isTrue);
        expect(result.isLeft, isFalse);
      });

      test('const constructor', () {
        const result = Right<String, int>(42);
        expect(result.value, 42);
      });

      test('equality', () {
        expect(Right<String, int>(42), Right<String, int>(42));
        expect(Right<String, int>(42), isNot(Right<String, int>(43)));
        expect(Right<String, int>(42), isNot(Left<String, int>('err')));
      });

      test('hashCode', () {
        expect(
          Right<String, int>(42).hashCode,
          Right<String, int>(42).hashCode,
        );
      });

      test('toString', () {
        expect(Right<String, int>(42).toString(), 'Right(42)');
      });

      test('map transforms value', () {
        final result = Right<String, int>(10).map((x) => x * 2);
        expect(result, Right<String, int>(20));
      });

      test('mapLeft does nothing', () {
        final result = Right<String, int>(10).mapLeft((e) => 'mapped: $e');
        expect(result, Right<String, int>(10));
      });

      test('flatMap chains computation', () {
        final result = Right<String, int>(10)
            .flatMap((x) => Right<String, int>(x + 5));
        expect(result, Right<String, int>(15));
      });

      test('flatMap can produce Left', () {
        final result = Right<String, int>(10)
            .flatMap((x) => Left<String, int>('failed'));
        expect(result, Left<String, int>('failed'));
      });

      test('fold applies onRight', () {
        final value = Right<String, int>(42).fold(
          (l) => 'left: $l',
          (r) => 'right: $r',
        );
        expect(value, 'right: 42');
      });

      test('getOrElse returns value', () {
        final value = Right<String, int>(42).getOrElse((_) => 0);
        expect(value, 42);
      });

      test('getOrNull returns value', () {
        expect(Right<String, int>(42).getOrNull(), 42);
      });

      test('getLeftOrNull returns null', () {
        expect(Right<String, int>(42).getLeftOrNull(), isNull);
      });

      test('swap', () {
        final swapped = Right<String, int>(42).swap();
        expect(swapped, Left<int, String>(42));
      });

      test('toOption returns Some', () {
        expect(Right<String, int>(42).toOption(), Some<int>(42));
      });

      test('tap executes action', () {
        int? captured;
        Right<String, int>(42).tap((v) => captured = v);
        expect(captured, 42);
      });

      test('tapLeft does nothing', () {
        String? captured;
        Right<String, int>(42).tapLeft((v) => captured = v);
        expect(captured, isNull);
      });
    });

    group('Left', () {
      test('creates a Left with value', () {
        final result = Left<String, int>('error');
        expect(result.value, 'error');
        expect(result.isLeft, isTrue);
        expect(result.isRight, isFalse);
      });

      test('const constructor', () {
        const result = Left<String, int>('error');
        expect(result.value, 'error');
      });

      test('equality', () {
        expect(Left<String, int>('err'), Left<String, int>('err'));
        expect(Left<String, int>('a'), isNot(Left<String, int>('b')));
        expect(Left<String, int>('err'), isNot(Right<String, int>(42)));
      });

      test('hashCode', () {
        expect(
          Left<String, int>('err').hashCode,
          Left<String, int>('err').hashCode,
        );
      });

      test('toString', () {
        expect(Left<String, int>('error').toString(), 'Left(error)');
      });

      test('map does nothing', () {
        final result = Left<String, int>('err').map((x) => x * 2);
        expect(result, Left<String, int>('err'));
      });

      test('mapLeft transforms value', () {
        final result = Left<String, int>('err').mapLeft((e) => 'mapped: $e');
        expect(result, Left<String, int>('mapped: err'));
      });

      test('flatMap does nothing', () {
        final result = Left<String, int>('err')
            .flatMap((x) => Right<String, int>(x + 5));
        expect(result, Left<String, int>('err'));
      });

      test('fold applies onLeft', () {
        final value = Left<String, int>('err').fold(
          (l) => 'left: $l',
          (r) => 'right: $r',
        );
        expect(value, 'left: err');
      });

      test('getOrElse returns default', () {
        final value = Left<String, int>('err').getOrElse((_) => 0);
        expect(value, 0);
      });

      test('getOrNull returns null', () {
        expect(Left<String, int>('err').getOrNull(), isNull);
      });

      test('getLeftOrNull returns value', () {
        expect(Left<String, int>('err').getLeftOrNull(), 'err');
      });

      test('swap', () {
        final swapped = Left<String, int>('err').swap();
        expect(swapped, Right<int, String>('err'));
      });

      test('toOption returns None', () {
        expect(Left<String, int>('err').toOption(), None<int>());
      });

      test('tap does nothing', () {
        int? captured;
        Left<String, int>('err').tap((v) => captured = v);
        expect(captured, isNull);
      });

      test('tapLeft executes action', () {
        String? captured;
        Left<String, int>('err').tapLeft((v) => captured = v);
        expect(captured, 'err');
      });
    });

    group('Factory constructors', () {
      test('Result.right', () {
        final result = Result<String, int>.right(42);
        expect(result, Right<String, int>(42));
      });

      test('Result.left', () {
        final result = Result<String, int>.left('err');
        expect(result, Left<String, int>('err'));
      });

      test('Result.success', () {
        final result = Result<String, int>.success(42);
        expect(result, Right<String, int>(42));
      });

      test('Result.failure', () {
        final result = Result<String, int>.failure('err');
        expect(result, Left<String, int>('err'));
      });

      test('Result.fromNullable with non-null', () {
        final result = Result<String, int>.fromNullable(42, () => 'null!');
        expect(result, Right<String, int>(42));
      });

      test('Result.fromNullable with null', () {
        final result = Result<String, int>.fromNullable(null, () => 'null!');
        expect(result, Left<String, int>('null!'));
      });

      test('Result.fromPredicate true', () {
        final result = Result<String, int>.fromPredicate(
          18,
          (x) => x >= 18,
          (x) => 'Too young: $x',
        );
        expect(result, Right<String, int>(18));
      });

      test('Result.fromPredicate false', () {
        final result = Result<String, int>.fromPredicate(
          15,
          (x) => x >= 18,
          (x) => 'Too young: $x',
        );
        expect(result, Left<String, int>('Too young: 15'));
      });
    });

    group('guard', () {
      test('returns Right on success', () {
        final result = Result.guard(
          () => int.parse('42'),
          (e, s) => 'Parse error: $e',
        );
        expect(result, Right<String, int>(42));
      });

      test('returns Left on exception', () {
        final result = Result.guard(
          () => int.parse('abc'),
          (e, s) => 'Parse error',
        );
        expect(result, Left<String, int>('Parse error'));
      });
    });

    group('guardAsync', () {
      test('returns Right on success', () async {
        final result = await Result.guardAsync(
          () async => 42,
          (e, s) => 'error',
        );
        expect(result, Right<String, int>(42));
      });

      test('returns Left on exception', () async {
        final result = await Result.guardAsync<String, int>(
          () async => throw Exception('boom'),
          (e, s) => 'caught: $e',
        );
        expect(result.isLeft, isTrue);
      });
    });

    group('combine', () {
      test('all Rights produces Right<List>', () {
        final results = [
          Right<String, int>(1),
          Right<String, int>(2),
          Right<String, int>(3),
        ];
        final combined = Result.combine(results);
        expect(combined.isRight, isTrue);
        expect(combined.getOrElse((_) => []), [1, 2, 3]);
      });

      test('any Left produces first Left', () {
        final results = [
          Right<String, int>(1),
          Left<String, int>('first error'),
          Left<String, int>('second error'),
        ];
        final combined = Result.combine(results);
        expect(combined, Left<String, List<int>>('first error'));
      });

      test('empty list produces Right<[]>', () {
        final combined = Result.combine<String, int>([]);
        expect(combined.isRight, isTrue);
        expect(combined.getOrElse((_) => [-1]), <int>[]);
      });
    });

    group('waitAll', () {
      test('all success', () async {
        final combined = await Result.waitAll([
          Future.value(Right<String, int>(1)),
          Future.value(Right<String, int>(2)),
        ]);
        expect(combined.isRight, isTrue);
        expect(combined.getOrElse((_) => []), [1, 2]);
      });

      test('any failure', () async {
        final combined = await Result.waitAll([
          Future.value(Right<String, int>(1)),
          Future.value(Left<String, int>('fail')),
        ]);
        expect(combined, Left<String, List<int>>('fail'));
      });
    });

    group('flatten', () {
      test('flattens nested Right', () {
        final nested = Right<String, Result<String, int>>(Right(42));
        expect(Result.flatten(nested), Right<String, int>(42));
      });

      test('flattens nested Left', () {
        final nested = Right<String, Result<String, int>>(Left('inner'));
        expect(Result.flatten(nested), Left<String, int>('inner'));
      });

      test('outer Left propagates', () {
        final nested = Left<String, Result<String, int>>('outer');
        expect(Result.flatten(nested), Left<String, int>('outer'));
      });
    });

    group('pattern matching', () {
      test('exhaustive switch', () {
        final Result<String, int> result = Right(42);
        final output = switch (result) {
          Left(value: final e) => 'Error: $e',
          Right(value: final v) => 'Value: $v',
        };
        expect(output, 'Value: 42');
      });

      test('if-case pattern', () {
        final Result<String, int> result = Left('error');
        if (result case Left(value: final msg)) {
          expect(msg, 'error');
        } else {
          fail('Should be Left');
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

      test('toResult returns Right', () {
        expect(Some(42).toResult(() => 'err'), Right<String, int>(42));
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

      test('toResult returns Left', () {
        expect(None<int>().toResult(() => 'err'), Left<String, int>('err'));
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
      final result = await Future.value(Right<String, int>(10))
          .thenMap((x) => x * 2);
      expect(result, Right<String, int>(20));
    });

    test('thenMap on Left', () async {
      final result = await Future.value(Left<String, int>('err'))
          .thenMap((x) => x * 2);
      expect(result, Left<String, int>('err'));
    });

    test('thenMapLeft', () async {
      final result = await Future.value(Left<String, int>('err'))
          .thenMapLeft((e) => 'mapped: $e');
      expect(result, Left<String, int>('mapped: err'));
    });

    test('thenFlatMap success chain', () async {
      final result = await Future.value(Right<String, int>(10))
          .thenFlatMap((x) async => Right<String, int>(x + 5));
      expect(result, Right<String, int>(15));
    });

    test('thenFlatMap Left propagates', () async {
      final result = await Future.value(Left<String, int>('err'))
          .thenFlatMap((x) async => Right<String, int>(x + 5));
      expect(result, Left<String, int>('err'));
    });

    test('thenFold', () async {
      final msg = await Future.value(Right<String, int>(42))
          .thenFold((l) => 'left', (r) => 'right: $r');
      expect(msg, 'right: 42');
    });

    test('thenGetOrElse', () async {
      final val = await Future.value(Left<String, int>('err'))
          .thenGetOrElse((_) => 0);
      expect(val, 0);
    });

    test('thenTap executes on Right', () async {
      int? captured;
      await Future.value(Right<String, int>(42))
          .thenTap((v) => captured = v);
      expect(captured, 42);
    });

    test('thenOrElse recovers from Left', () async {
      final result = await Future.value(Left<String, int>('err'))
          .thenOrElse((l) async => Right<String, int>(0));
      expect(result, Right<String, int>(0));
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
      expect(result, Right<String, int>(42));
    });
  });

  group('Typedefs', () {
    test('Failure equality', () {
      const f1 = Failure('error');
      const f2 = Failure('error');
      const f3 = Failure('other');
      expect(f1, f2);
      expect(f1, isNot(f3));
    });

    test('Failure toString', () {
      expect(const Failure('oops').toString(), 'Failure(oops)');
    });

    test('Failure hashCode', () {
      expect(
        const Failure('err').hashCode,
        const Failure('err').hashCode,
      );
    });

    test('ResultOf type alias works', () {
      ResultOf<int> parse(String s) {
        try {
          return Right(int.parse(s));
        } on FormatException catch (e) {
          return Left(e);
        }
      }

      expect(parse('42'), isRight);
      expect(parse('abc'), isLeft);
    });

    test('Either type alias works', () {
      Either<String, int> divide(int a, int b) {
        if (b == 0) return Left('Division by zero');
        return Right(a ~/ b);
      }

      expect(divide(10, 2), isRightWith(5));
      expect(divide(10, 0), isLeftWith('Division by zero'));
    });

    test('Unit type', () {
      Result<String, Unit> doSomething() => Right(unit);

      final result = doSomething();
      expect(result, isRight);
      expect(result.getOrNull(), unit);
    });

    test('Unit equality', () {
      expect(unit, unit);
      expect(unit.toString(), '()');
      expect(unit.hashCode, 0);
    });
  });

  group('Matchers', () {
    test('isRight', () {
      expect(Right<String, int>(42), isRight);
      expect(Left<String, int>('err'), isNot(isRight));
    });

    test('isLeft', () {
      expect(Left<String, int>('err'), isLeft);
      expect(Right<String, int>(42), isNot(isLeft));
    });

    test('isRightWith', () {
      expect(Right<String, int>(42), isRightWith(42));
      expect(Right<String, int>(42), isNot(isRightWith(43)));
    });

    test('isLeftWith', () {
      expect(Left<String, int>('err'), isLeftWith('err'));
      expect(Left<String, int>('err'), isNot(isLeftWith('other')));
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
