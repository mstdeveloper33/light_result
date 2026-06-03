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
