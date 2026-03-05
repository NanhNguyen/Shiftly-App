import 'package:dio/dio.dart';

class DioExceptionHandler {
  static String handleException(dynamic err) {
    if (err is DioException) {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
        case DioExceptionType.badResponse:
          final data = err.response?.data;
          if (data is Map) {
            final message = data['message'];
            if (message is List) return message.join('\n');
            if (message is String) return message;
          }
          return 'Lỗi hệ thống: ${err.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy.';
        case DioExceptionType.connectionError:
          return 'Lỗi kết nối mạng. Vui lòng thử lại sau.';
        default:
          return 'Đã xảy ra lỗi ngoài ý muốn. Vui lòng thử lại sau.';
      }
    }
    return err?.toString() ?? 'Đã xảy ra lỗi.';
  }
}
