import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_models.dart';

/// Who is signed in: null = signed out. While loading (app start), the router shows a splash.
///
/// signIn/register throw [ApiException] on failure so the screen can show the message; the
/// state only changes on success, so a wrong password never signs anyone out.
class AuthController extends AsyncNotifier<AuthSession?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthSession?> build() async {
    try {
      return await _repository.restore();
    } catch (_) {
      return null; // never fail here: Riverpod would retry and the app would stay on the splash
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    final session = await _repository.signIn(email: email, password: password);
    state = AsyncData(session);
  }

  Future<void> register({
    required String organizationName,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final session = await _repository.register(
      organizationName: organizationName,
      fullName: fullName,
      email: email,
      password: password,
    );
    state = AsyncData(session);
  }

  /// Reload the user and memberships (e.g. after joining an organization).
  Future<void> refreshSession() async {
    state = AsyncData(await _repository.me());
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = const AsyncData(null);
  }

  /// Called by the network layer when the refresh token stops working.
  void sessionExpired() => state = const AsyncData(null);
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);
