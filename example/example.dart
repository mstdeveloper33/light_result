// ignore_for_file: avoid_print
import 'package:light_result/light_result.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REAL-WORLD EXAMPLE: Complete Flutter App Architecture with light_result
//
// This example demonstrates how light_result fits into a real production app
// with proper layering: Domain → Data → Presentation
// ═══════════════════════════════════════════════════════════════════════════════

// ─── STEP 1: Define Your Failure Types ────────────────────────────────────────
// Create a sealed failure hierarchy — the compiler will force exhaustive handling

sealed class AppFailure extends AppError {
  const AppFailure(super.message, {super.stackTrace});
}

/// Network errors (API down, timeout, no internet)
final class NetworkFailure extends AppFailure {
  final int? statusCode;
  const NetworkFailure(super.message, {this.statusCode, super.stackTrace});
}

/// Server returned data but it's invalid
final class ParseFailure extends AppFailure {
  const ParseFailure(super.message, {super.stackTrace});
}

/// Business logic validation errors
final class ValidationFailure extends AppFailure {
  final String field;
  const ValidationFailure(super.message,
      {required this.field, super.stackTrace});
}

/// User is not authenticated
final class AuthFailure extends AppFailure {
  const AuthFailure(super.message, {super.stackTrace});
}

// ─── STEP 2: Define Your Models ──────────────────────────────────────────────

class User {
  final int id;
  final String name;
  final String email;
  final int age;
  const User(
      {required this.id,
      required this.name,
      required this.email,
      required this.age});

  @override
  String toString() => 'User($name, $email)';
}

class Session {
  final String token;
  final User user;
  const Session({required this.token, required this.user});
}

// ─── STEP 3: Repository Layer (Data Sources) ─────────────────────────────────
// Every function explicitly declares what can go wrong via return type

/// Simulates an API login call
Future<Result<AppFailure, Session>> login(
    String email, String password) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));

  // Simulate different outcomes
  if (email.isEmpty || password.isEmpty) {
    return Failure(
        const ValidationFailure('Credentials required', field: 'email'));
  }
  if (password.length < 6) {
    return Failure(
        const ValidationFailure('Password too short', field: 'password'));
  }
  if (email == 'blocked@test.com') {
    return Failure(const AuthFailure('Account is blocked'));
  }

  // Simulate network failure
  if (email == 'timeout@test.com') {
    return Failure(const NetworkFailure('Connection timed out', statusCode: 408));
  }

  // Success!
  return Success(Session(
    token: 'jwt_token_123',
    user: User(id: 1, name: 'John Doe', email: email, age: 28),
  ));
}

/// Simulates fetching user profile from API
Future<Result<AppFailure, User>> fetchUserProfile(String token) async {
  await Future<void>.delayed(const Duration(milliseconds: 50));

  if (token.isEmpty) {
    return Failure(const AuthFailure('Token expired'));
  }

  return Success(
      const User(id: 1, name: 'John Doe', email: 'john@test.com', age: 28));
}

// ─── STEP 4: Form Validation ─────────────────────────────────────────────────
// Each validator returns Result — compose them with Result.combine

Result<AppFailure, String> validateEmail(String email) {
  if (email.isEmpty) {
    return Failure(
        const ValidationFailure('Email is required', field: 'email'));
  }
  if (!email.contains('@')) {
    return Failure(
        const ValidationFailure('Invalid email format', field: 'email'));
  }
  return Success(email);
}

Result<AppFailure, String> validatePassword(String password) {
  if (password.isEmpty) {
    return Failure(const ValidationFailure('Password is required',
        field: 'password'));
  }
  if (password.length < 6) {
    return Failure(const ValidationFailure('Min 6 characters',
        field: 'password'));
  }
  return Success(password);
}

Result<AppFailure, int> validateAge(String ageStr) {
  return Result.guard<AppFailure, int>(
    () => int.parse(ageStr),
    (_, __) => const ParseFailure('Invalid age format'),
  ).flatMap((age) => age >= 18
      ? Success(age)
      : Failure(const ValidationFailure('Must be 18+', field: 'age')));
}

// ─── STEP 5: Use Case / Business Logic Layer ─────────────────────────────────

/// Complete login flow: validate → authenticate → return session
Future<Result<AppFailure, Session>> loginUseCase(
    String email, String password) async {
  // First validate inputs
  final validation = Result.combine<AppFailure, String>([
    validateEmail(email),
    validatePassword(password),
  ]);

  // If validation fails, return the first error immediately
  return validation.fold(
    (failure) async => Failure(failure),
    (values) => login(values[0], values[1]),
  );
}

// ─── STEP 6: Handling Nullable/Optional Data ─────────────────────────────────

/// Simulates reading from local cache — value might not exist
Option<User> getCachedUser() {
  // Simulate cache miss
  const Map<String, dynamic>? cached = null;
  return Option.fromNullable(cached).flatMap((json) => Option.tryCatch(
        () => User(
          id: json['id'] as int,
          name: json['name'] as String,
          email: json['email'] as String,
          age: json['age'] as int,
        ),
      ));
}

/// Parse optional fields from API response safely
Option<int> parseOptionalAge(Map<String, dynamic> json) {
  return Option.fromNullable(json['age'] as int?);
}

// ─── STEP 7: Main — Putting It All Together ──────────────────────────────────

void main() async {
  print('═══ SCENARIO 1: Login Flow ═══\n');

  // Successful login
  final loginResult = await loginUseCase('john@test.com', 'secret123');
  switch (loginResult) {
    case Failure(value: ValidationFailure(:final field, :final message)):
      print('❌ Validation Error on "$field": $message');
    case Failure(value: AuthFailure(:final message)):
      print('🔒 Auth Error: $message');
    case Failure(value: NetworkFailure(:final statusCode, :final message)):
      print('🌐 Network Error ($statusCode): $message');
    case Failure(value: final other):
      print('⚠️ Unexpected: ${other.message}');
    case Success(value: final session):
      print('✅ Logged in as: ${session.user.name}');
      print('   Token: ${session.token}');
  }

  // Failed login — bad password
  print('');
  final failedLogin = await loginUseCase('john@test.com', '123');
  print('Short password: ${failedLogin.fold(
    (f) => '❌ ${f.message}',
    (s) => '✅ ${s.user.name}',
  )}');

  print('\n═══ SCENARIO 2: Async Chaining ═══\n');

  // Chain: login → fetch profile → extract name
  final userName = await login('john@test.com', 'secret123')
      .thenMap((session) => session.token)
      .thenFlatMap((token) => fetchUserProfile(token))
      .thenMap((user) => user.name)
      .thenTapFailure((err) => print('   [LOG] Error: ${err.message}'))
      .thenGetOrElse((_) => 'Anonymous');

  print('User name: $userName');

  print('\n═══ SCENARIO 3: Form Validation ═══\n');

  // Validate multiple fields at once
  final formResult = Result.combine<AppFailure, Object>([
    validateEmail('john@test.com'),
    validatePassword('secret123'),
    validateAge('25'),
  ]);

  print('Valid form: ${formResult.fold(
    (f) => '❌ ${f.message}',
    (values) => '✅ All ${values.length} fields valid',
  )}');

  // Invalid form
  final badForm = Result.combine<AppFailure, Object>([
    validateEmail('not-an-email'),
    validatePassword('123'),
    validateAge('17'),
  ]);

  print('Bad form: ${badForm.fold(
    (f) => '❌ First error: ${f.message}',
    (values) => '✅ $values',
  )}');

  print('\n═══ SCENARIO 4: Option for Cache/Nullable ═══\n');

  // Try to get cached user, fallback to API
  final cachedUser = getCachedUser();
  print('Cache: ${cachedUser.fold(
    () => 'MISS — will fetch from API',
    (user) => 'HIT — ${user.name}',
  )}');

  // Parse optional JSON fields
  final json = <String, dynamic>{'name': 'Alice', 'age': null};
  final age = parseOptionalAge(json);
  final ageDisplay = age.fold(
    () => 'Not provided',
    (a) => '$a years old',
  );
  print('Age field: $ageDisplay');

  // Convert Option → Result (when absence is an error)
  final ageRequired = age.toResult(
    () => const ValidationFailure('Age is required', field: 'age'),
  );
  print('Age required: ${ageRequired.fold(
    (f) => '❌ ${f.message}',
    (a) => '✅ $a',
  )}');

  print('\n═══ SCENARIO 5: Guard — Wrapping Unsafe Code ═══\n');

  // Safely parse JSON without try/catch
  final parsed = Result.guard(
    () => int.parse('not_a_number'),
    (error, stack) => ParseFailure('$error'),
  );
  print('Parse "not_a_number": ${parsed.fold(
    (f) => '❌ ${f.message}',
    (v) => '✅ $v',
  )}');

  // Async guard — wrap any Future that might throw
  final apiResult = await Result.guardAsync(
    () async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return {'users': 42}; // Simulating API response
    },
    (error, stack) => NetworkFailure('Request failed: $error'),
  );
  print('API call: ${apiResult.fold(
    (f) => '❌ ${f.message}',
    (data) => '✅ Got ${data['users']} users',
  )}');

  print('\n═══ SCENARIO 6: Unit Type — Side Effects ═══\n');

  // Functions that "do something" but don't return data
  Result<AppFailure, Unit> saveToDatabase(User user) {
    // Simulate save
    print('   [DB] Saving ${user.name}...');
    return Success(unit); // Success, no meaningful return value
  }

  final saveResult = saveToDatabase(
    const User(id: 1, name: 'John', email: 'john@test.com', age: 28),
  );
  print('Save: ${saveResult.fold(
    (f) => '❌ ${f.message}',
    (_) => '✅ Saved successfully',
  )}');
}

