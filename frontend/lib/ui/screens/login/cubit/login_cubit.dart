import 'package:injectable/injectable.dart';
import '../../../cubit/base_cubit.dart';
import '../../../../data/service/auth_service.dart';
import '../../../../data/constant/enums.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState> {
  final AuthService _authService;

  LoginCubit(this._authService) : super(const LoginState());

  void togglePasswordVisibility() {
    emit(
      state.copyWith(
        obscurePassword: !state.obscurePassword,
        status: BaseStatus.initial,
      ),
    );
  }

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      setError('Vui lòng nhập đầy đủ email và mật khẩu');
      return;
    }

    safeCall(() async {
      await _authService.login(email, password);
      setSuccess();
    });
  }
}
