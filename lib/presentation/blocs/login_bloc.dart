import 'package:rxdart/rxdart.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../utils/validator.dart';

enum AuthMode { login, register }

class LoginBloc {
  final AuthUseCases authUseCases;

  LoginBloc(this.authUseCases);

  final _nameSubject = BehaviorSubject<String>.seeded('');
  final _emailSubject = BehaviorSubject<String>.seeded('');
  final _passwordSubject = BehaviorSubject<String>.seeded('');
  final _modeSubject = BehaviorSubject<AuthMode>.seeded(AuthMode.login);
  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);
  final _loginSuccessSubject = PublishSubject<UserEntity>();
  final _errorSubject = PublishSubject<String>();

  // ── Inputs ───────────────────────────────────────────────────────────────
  Function(String) get changeName => _nameSubject.sink.add;
  Function(String) get changeEmail => _emailSubject.sink.add;
  Function(String) get changePassword => _passwordSubject.sink.add;

  void toggleMode() {
    final current = _modeSubject.value;
    _modeSubject.add(
        current == AuthMode.login ? AuthMode.register : AuthMode.login);
    // Clear error on mode switch
    _errorSubject.add('');
  }

  // ── Outputs ──────────────────────────────────────────────────────────────
  Stream<bool> get isLoading => _isLoadingSubject.stream;
  Stream<UserEntity> get loginSuccess => _loginSuccessSubject.stream;
  Stream<String> get error => _errorSubject.stream;
  Stream<AuthMode> get mode => _modeSubject.stream;
  AuthMode get currentMode => _modeSubject.value;

  // ── Submit ────────────────────────────────────────────────────────────────
  void submit() async {
    final email = _emailSubject.value.trim();
    final password = _passwordSubject.value.trim();
    final name = _nameSubject.value.trim();
    final mode = _modeSubject.value;

    // Delegate all validation to the Validator utility (SRP)
    final nameError = mode == AuthMode.register ? Validator.name(name) : null;
    final emailError = Validator.email(email);
    final passwordError = Validator.password(password);

    final firstError = nameError ?? emailError ?? passwordError;
    if (firstError != null) {
      _errorSubject.add(firstError);
      return;
    }

    _isLoadingSubject.add(true);

    try {
      UserEntity user;
      if (mode == AuthMode.register) {
        user = await authUseCases.register(name, email, password);
      } else {
        user = await authUseCases.login(email, password);
      }
      _loginSuccessSubject.add(user);
    } catch (e) {
      _errorSubject.add(Validator.firebaseAuthError(e.toString()));
    } finally {
      if (!_isLoadingSubject.isClosed) {
        _isLoadingSubject.add(false);
      }
    }
  }

  void dispose() {
    _nameSubject.close();
    _emailSubject.close();
    _passwordSubject.close();
    _modeSubject.close();
    _isLoadingSubject.close();
    _loginSuccessSubject.close();
    _errorSubject.close();
  }
}
