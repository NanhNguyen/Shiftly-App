import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/constant/enums.dart';
import '../../data/api/exception/dio_exception_handler.dart';

abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);

  // Helper methods to reduce boilerplate in child cubits
  void setLoading() {
    try {
      emit((state as dynamic).copy(status: BaseStatus.loading));
    } catch (_) {
      try {
        emit((state as dynamic).copyWith(status: BaseStatus.loading));
      } catch (_) {}
    }
  }

  void setSuccess() {
    try {
      emit((state as dynamic).copy(status: BaseStatus.success));
    } catch (_) {
      try {
        emit((state as dynamic).copyWith(status: BaseStatus.success));
      } catch (_) {}
    }
  }

  void setError(String message) {
    try {
      emit(
        (state as dynamic).copyWith(
          status: BaseStatus.error,
          errorMessage: message,
        ),
      );
    } catch (_) {}
  }

  /// Professional wrapper for API calls
  Future<void> safeCall(Future<void> Function() call) async {
    setLoading();
    try {
      await call();
    } catch (e) {
      setError(DioExceptionHandler.handleException(e));
    }
  }
}
