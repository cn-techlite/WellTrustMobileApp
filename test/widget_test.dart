import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:well_trust_mobile_app/features/auth/data/dto/login_request.dart';
import 'package:well_trust_mobile_app/features/auth/data/model/login_response_model.dart';
import 'package:well_trust_mobile_app/features/auth/data/model/auth_result_model.dart';
import 'package:well_trust_mobile_app/features/auth/domain/usercases/auth_repository.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/state_model/auth_state.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.loginError});

  final Object? loginError;

  @override
  Future<AuthResultModel> login({
    required String username,
    required String pin,
  }) async {
    if (loginError != null) throw loginError!;
    return AuthResultModel.failure('Login failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('login state', () {
    test('requires a username and a 5 digit PIN', () {
      expect(const AuthState().canLogin, isFalse);
      expect(
        const AuthState(username: 'jane.carer', pin: '12345').canLogin,
        isTrue,
      );
      expect(
        const AuthState(username: 'jane.carer', pin: '1234').canLogin,
        isFalse,
      );
      expect(const AuthState(username: '', pin: '12345').canLogin, isFalse);
    });

    test('resetLoginForm clears credentials from another auth flow', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final controller = container.read(authControllerProvider.notifier);
      controller.onUsernameChanged('jane.carer');
      controller.onPinChanged('12345');

      controller.resetLoginForm();

      final state = container.read(authControllerProvider).requireValue;
      expect(state.username, isEmpty);
      expect(state.pin, isEmpty);
      expect(state.canLogin, isFalse);
    });

    test('surfaces repository errors to the login screen', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepository(loginError: 'No Internet connection.'),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.future);
      final result = await container
          .read(authControllerProvider.notifier)
          .login(username: 'jane.carer', pin: '12345');

      expect(result.isSuccess, isFalse);
      expect(result.message, 'No Internet connection.');
    });
  });

  group('kiosk device login contract', () {
    test('sends username and passcode', () {
      expect(const LoginRequest(username: 'janed', pin: '12345').toJson(), {
        'username': 'janed',
        'passcode': '12345',
      });
    });

    test('maps the kiosk response onto the session model', () {
      final model = LoginResponseModel.fromJson({
        'token': 'jwt',
        'refreshToken': 'refresh',
        'staffId': '7c1e2b3a',
        'staffName': 'Jane Doe',
        'username': 'janed',
        'deviceId': '9f8e7d6c',
        'deviceName': 'Reception Tablet 1',
        'deviceReferenceNumber': 'KD-A1B2C3D4',
      });

      expect(model.token, 'jwt');
      expect(model.refreshToken, 'refresh');
      expect(model.userId, '7c1e2b3a');
      expect(model.fullName, 'Jane Doe');
      expect(model.username, 'janed');
      expect(model.deviceName, 'Reception Tablet 1');
      expect(model.deviceReferenceNumber, 'KD-A1B2C3D4');
      expect(model.roles, isEmpty);
    });
  });
}
