import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/constant/enums.dart';
import '../../data/api/exception/dio_exception_handler.dart';

abstract class BaseCubit<T> extends Cubit<T> {
  BaseCubit(super.initialState);

  // Helper methods to reduce boilerplate in child cubits
  void setLoading() {
    try {
      print('BaseCubit: Setting loading state');
      emit((state as dynamic).copyWith(status: BaseStatus.loading));
    } catch (e) {
      print('BaseCubit: Error setting loading state: $e');
    }
  }

  void setSuccess() {
    try {
      print('BaseCubit: Setting success state');
      emit((state as dynamic).copyWith(status: BaseStatus.success));
    } catch (e) {
      print('BaseCubit: Error setting success state: $e');
    }
  }

  void setError(String message) {
    try {
      print('BaseCubit: Setting error state with message: $message');
      emit(
        (state as dynamic).copyWith(
          status: BaseStatus.error,
          errorMessage: message,
        ),
      );
    } catch (e) {
      print('BaseCubit: Error setting error state: $e');
    }
  }

  /// Professional wrapper for API calls
  Future<void> safeCall(Future<void> Function() call) async {
    setLoading();
    try {
      await call();
    } catch (e) {
      print('BaseCubit: safeCall caught error: $e');
      setError(DioExceptionHandler.handleException(e));
    }
  }
}
