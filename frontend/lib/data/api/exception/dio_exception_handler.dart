import 'package:dio/dio.dart';
import 'dart:developer' as dev;

class DioExceptionHandler {
  static String handleException(dynamic err) {
    dev.log('Handling exception: $err');
    if (err is DioException) {
      dev.log('DioException type: ${err.type}');
      dev.log('DioException response: ${err.response?.data}');

      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
        case DioExceptionType.badResponse:
          final data = err.response?.data;
          if (data is Map) {
            final message = data['message'] ?? data['error'];
            if (message is List) return message.join('\n');
            if (message is String) return message;
          }
          return 'Lỗi hệ thống: ${err.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';
        case DioExceptionType.connectionError:
          return 'Lỗi kết nối mạng. Vui lòng thử lại sau.';
        default:
          return 'Đã xảy ra lỗi kết nối (${err.type}). Vui lòng thử lại sau.';
      }
    }
    return err?.toString() ?? 'Đã xảy ra lỗi ngoài ý muốn.';
  }
}
