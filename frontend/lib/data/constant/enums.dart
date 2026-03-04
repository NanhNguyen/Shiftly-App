enum UserRole { INTERN, EMPLOYEE, MANAGER, HR }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.INTERN:
        return 'Thực tập sinh';
      case UserRole.EMPLOYEE:
        return 'Nhân viên';
      case UserRole.MANAGER:
        return 'Quản lý';
      case UserRole.HR:
        return 'Nhân sự';
    }
  }
}

enum BaseStatus { initial, loading, success, error }

enum ScheduleType { WORK, LEAVE }

extension ScheduleTypeExtension on ScheduleType {
  String get displayName {
    switch (this) {
      case ScheduleType.WORK:
        return 'Làm việc';
      case ScheduleType.LEAVE:
        return 'Nghỉ phép';
    }
  }
}

enum RequestStatus { PENDING, APPROVED, REJECTED }

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.PENDING:
        return 'Chờ duyệt';
      case RequestStatus.APPROVED:
        return 'Đã duyệt';
      case RequestStatus.REJECTED:
        return 'Từ chối';
    }
  }
}
