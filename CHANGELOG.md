## 0.2.1

* Expanded Dart SDK support to `>=3.0.0 <4.0.0`.
* Relaxed the `lints` development dependency to support the wider SDK range.
* Excluded local progress notes and generated files from published archives.

## 0.2.0 — Breaking: Success/Failure Rename

### Breaking Changes

* **Renamed core types**: `Left` → `Failure`, `Right` → `Success`.
* **Renamed getters**: `isLeft` → `isFailure`, `isRight` → `isSuccess`.
* **Renamed methods**: `mapLeft` → `mapFailure`, `getLeftOrNull` → `getFailureOrNull`, `tapLeft` → `tapFailure`.
* **Renamed async extensions**: `thenMapLeft` → `thenMapFailure`, `thenTapLeft` → `thenTapFailure`.
* **Renamed matchers**: `isLeft` → `isFailure`, `isRight` → `isSuccess`, `isLeftWith` → `isFailureWith`, `isRightWith` → `isSuccessWith`.
* **Renamed utility class**: `Failure` → `AppError` (to avoid conflict with the new `Failure` sealed subclass).
* **Removed** `Result.left()` and `Result.right()` factory constructors (use `Result.failure()` / `Result.success()`).

### Migration

Deprecated `Left<L, R>` and `Right<L, R>` type aliases are provided for gradual migration. See README for full migration table.

### Why?

Dart developers coming from Rust/Kotlin expect `Ok`/`Err` or `Success`/`Failure` terminology. The old `Left`/`Right` naming (Haskell/Scala Either convention) was a barrier to adoption. The new names are self-documenting — no mnemonic needed.

## 0.1.2

* Docs: Rewrote README with motivation section and real-world comparisons.
* Docs: Rewrote example with 6 practical scenarios (login, API, validation, cache, Option, async chaining).

## 0.1.1

* Fix: LICENSE file now uses standard MIT format recognized by pub.dev.
* Fix: Resolved `unintended_html_in_doc_comment` warning in TaskResult docs.
* Added `Unit` type for void-returning Result operations.
* Added `Either<L, R>` type alias for fpdart/dartz migration.

## 0.1.0

* Initial release.
* `Result<L, R>` sealed class with `Left` and `Right` subclasses.
* `Option<T>` sealed class with `Some` and `None` subclasses.
* Full pattern matching support with exhaustive checking.
* Functional chaining: `map`, `mapLeft`, `flatMap`, `fold`, `getOrElse`, `tap`, `tapLeft`, `swap`, `filter`.
* `Result.guard()` and `Result.guardAsync()` for safe exception wrapping.
* `Result.combine()` and `Result.waitAll()` for combining multiple results.
* `TaskResult` and `TaskOption` extensions for async chaining without intermediate `await`.
* Type aliases: `ResultOf`, `StringResult`, `AppResult`, `AsyncResult`, `AsyncResultOf`.
* `Failure` base class for typed error hierarchies.
* Test matchers: `isRight`, `isLeft`, `isRightWith`, `isLeftWith`, `isSome`, `isNone`, `isSomeWith`.
