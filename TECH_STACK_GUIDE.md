# 🚀 Hướng Dẫn Kỹ Thuật Chi Tiết - Dự Án ShiftFlow

Tài liệu này được tổng hợp từ các bản devdocs của bạn, giải thích cặn kẽ về **từng công nghệ được sử dụng**, **cách thức hoạt động**, và **cách chúng được áp dụng trong project ShiftFlow** để bạn có thể vừa đọc vừa mapping trực tiếp vào code và dễ dàng học theo.

---


## 🖥️ PHẦN 1: BACKEND (NestJS + MongoDB)

Hệ thống Backend của ShiftFlow đóng vai trò là "bộ não" xử lý dữ liệu, phục vụ REST API cho Mobile App.

### 1. Kiến Trúc NestJS (Modules, Controllers, Services)
NestJS tổ chức code thành các tệp tin theo tính chất công việc thay vì gộp chung.
- **Module (`*.module.ts`)**: Giống như một cái hộp chứa một tính năng độc lập (ví dụ: `auth.module.ts`, `schedules.module.ts`). Nó khai báo cho ứng dụng biết tính năng này bao gồm những file nào, xài những database nào.
- **Controller (`*.controller.ts`)**: Đóng vai trò là "Lễ tân". Nó làm nhiệm vụ mở các endpoint (như `GET /schedules/my`), nhận yêu cầu và dữ liệu đầu vào từ người dùng (HTTP Request), sau đó đẩy việc vào trong cho Service. **Tuyệt đối không viết logic tính toán ở trong Controller.**
- **Service (`*.service.ts`)**: "Nông dân" làm việc thực sự. Mọi thuật toán tính toán, gọi database, v.v... đều nằm ở đây.

**💡 Trong ứng dụng này:** 
Mỗi khi bạn truy cập `POST /schedules` để tạo lịch nghỉ, `SchedulesController` sẽ nhận Request Body chứa ngày giờ, chuyển hóa thành tham số và gọi `this.schedulesService.create(data)`. `SchedulesService` sau đó lưu vào DB và tương tác với `NotificationsService` để gửi thông báo.
Sự liên kết giữa chúng được thiết lập bởi cơ chế **Dependency Injection (DI)** (thông qua `constructor`).

### 2. Database - MongoDB với Mongoose
MongoDB là cơ sở dữ liệu phi cấu trúc (NoSQL). Bạn không cần định nghĩa bảng cứng nhắc bằng SQL, thay vào đó dùng thư viện **Mongoose** (cầu nối).
- **Schema (`*.schema.ts`)**: Được viết bằng Class của TypeScript. Đây là bản vẽ định nghĩa một document có những trường gì.
  ```typescript
  @Schema({ timestamps: true }) 
  export class User { ... }
  ```
- **Thao tác dữ liệu**: Ở Service, Mongoose model được tiêm vào (inject) thông qua constructor, giúp truy vấn dữ liệu như `this.userModel.findOne()`, `.findByIdAndUpdate()`.
- **Populate (Join dữ liệu)**: Giả sử lịch (`ScheduleRequest`) chỉ lưu `employee_id`. Tại service, ta dùng `.populate('employee_id', 'name role')` thì Mongoose sẽ tự động móc nối sang bảng User để lấy Tên và Vai trò của người đó để trả về thẳng cho FE.

### 3. JWT Auth (Xác thực với JSON Web Token)
Thay vì bắt đăng nhập liên tục, khi Login, backend phản hồi lại một chuỗi mã hóa gọi là `access_token` chứa Id và Quyền của họ.
- **Áp dụng**: Token này sau đó được Client (Flutter) gửi kèm vào mọi request tiếp theo trên "Header".
- **JwtAuthGuard**: Đóng vai trò như ổ khóa bảo mật. Nếu gắn `@UseGuards(JwtAuthGuard)` trên một API trong Controller, ai không có Token (chưa login) sẽ bị HTTP 401 Unauthorized ngay lập tức. Token hợp lệ sẽ được giải mã và trả về thông tin user vào `req.user`.

### 4. RBAC - Role Based Access Control (Phân Quyền Vượt Trội)
Trong ShiftFlow, tài khoản được chia làm `INTERN`, `MANAGER`, và `HR`. Sẽ rất nguy hiểm nếu Intern lại chọc vào được API Duyệt lịch nghỉ của Manager.
- **Roles Decorator (`@Roles`)**: Ta tự tạo một cái nhãn dán cho các API, ví dụ `@Roles(UserRole.MANAGER)`.
- **RolesGuard**: Ổ khóa số hai đi sau JwtGuard. Guard này sẽ đọc cái "nhãn" bạn đã dán, chạy đối chiếu với cái `req.user.role` nằm trong JWT gửi lên. Trùng thì đi tiếp, xó Role thấp hơn thì ăn lỗi `403 Forbidden`.

---

## 📱 PHẦN 2: FRONTEND (Flutter)

Trên Flutter, UI mạnh nhất nhờ tính linh hoạt. Giao tiếp với API và quản lý giao diện phức tạp được quyết định bởi 5 yếu tố công nghệ sau:

### 1. State Management - Bloc/Cubit
Flutter là UI mô phỏng theo Trạng thái (State). ShiftFlow không dùng `setState()` cục bộ quá nhiều mà dùng `Cubit` (Một biến thể đơn giản gọn nhẹ của BLoC pattern).
- **Nguyên lý**: UI chỉ có nhiệm vụ nghe ngóng (Listen) và Cập nhật giao diện (Builder) chứ không chứa logic kiểm tra Dữ liệu. Logic đẩy lấy dữ liệu, lưu dữ liệu sẽ do `Cubit` hoàn thành rồi phát Loa (`emit()`). Khi Loa réo lên một loại State mới (`loading`, `success`,.v.v), `BlocBuilder` của Flutter sẽ tự vẽ lại hình.
- **Trong bài này**: Nhờ Cubit, tính năng Badge đếm số thông báo trên nút chuông rất tuyệt vời. `HomeCubit` lấy số Pending Request và lưu vào state. Trong UI, cái chuông trên top chỉ việc bọc qua `BlocBuilder<HomeCubit>`, mỗi khi trạng thái pending đổi là số lại tự động nhẩy.

### 2. Mô Hình Repository (Gọi API với Dio)
Để tách bạch và chuẩn hóa, code được chia theo tầng. Thay vì Widget tự đẻ ra `Dio` gửi Fetch, Data được qua Repository.
- **Dio**: Là một thư viện HTTP call xịn xò. Trong ShiftFlow, ta dùng Interceptor - Cài ở Base, hễ bất cứ request nào gửi ra internet từ máy cũng sẽ MÓC một cái Token trong máy để nhét vào cái Header. Gọn, khỏe!
- **Repository**: Đại lý kết nối Dio lại với các hàm trả về Model cụ thể (`ScheduleRequestRepo`). Các Cubit sẽ có nhiệm vụ liên hệ với các Repository này để xin dữ liệu. Cấu trúc Clean Code cực mạnh.

### 3. Dependency Injection (GetIt & Injectable)
Vấn đề nảy sinh: Lấy biến Cubit và biến Repository ra ở mọi nơi kiểu gì cho không bị trùng hoặc không bị quá tải bộ nhớ?
- **Giải pháp**: Xài cái Thùng rỗng tên là `getIt`. Các class (dù là Repo hay Cubit) chỉ việc dán nhãn `@injectable` hoặc `@lazySingleton` (dùng chung 1 cái suốt năm tháng tạo app) lên đầu file. Khởi chạy tool build, máy sẽ TỰ ĐỘNG dọn dẹp nhét hết tụi nó vào cấu hình hộp `getIt`.
- **Thay vì phải viết code**: `HomeCubit homeCubit = new HomeCubit(new HomeRepo(new Dio()))`. Thì giờ, nhờ có bộ tiêm Injection, ở bất kỳ màn nào, ta chỉ gọi hàm gọi đò `getIt<HomeCubit>()` là chiếc Cubit tương ứng nhảy ra xài!

### 4. Định Tuyến (AutoRoute)
Chuyển trang (Navigator) ở màn Flutter gốc thì phải nhớ chuỗi tên '/home' hay '/detail'. Với `auto_route`:
- Khởi tạo màn hình, thêm nhãn `@RoutePage()`.
- Chỉnh file list Config. Cài package generation. Nó tạo ra các biến hằng.
- Gọi chuyển trang siêu dễ và truyền được cả biến qua rất an toàn: `context.pushRoute(NotificationRoute())`. Có lỗi là nó bắt ngay ở IDE chứ không đợi chạy app.

### 5. Dữ Liệu Bất Biến (Freezed)
Thay vì code chay class dữ liệu (mệt mỏi với `.fromJson` và `.toJson`), ta xài `Freezed` - công nghệ tạo ra những class dữ liệu BẤT BIẾN (không cho phép sửa bằng tay, mà phải tạo bản copy nếu cần cập nhật). Đảm bảo giao thức JSON từ Server về App luôn an toàn 100%.

### 6. TableCalendar + Intl (Trái tim của bài toán)
Vì là một app về ngày nghỉ, Lịch là thứ phức tạp nhất:
- **`intl`**: Thư viện không thể thiếu để format ngày giờ và convert ngày theo mọi form như chuỗi sang date.
- **`table_calendar`**: Chứa rất nhiều cơ chế "Duyệt". Ví dụ hàm `eventLoader` (Sẽ lặp trong tất cả các mảng lịch để tìm xem cái ngày x trên Lịch có thuộc vào cái mảng Schedule List tải dưới API hay không để chấm Dot). Ngoài ra việc can thiệp bằng `defaultBuilder` giúp chỉnh UI theo ca Sáng/Chiều ngay trên các ô Lịch khi cần thiết cực kỳ tiện lợi!

---
*Hy vọng tài liệu này sẽ giúp bạn dễ dàng nắm bắt bức tranh toàn cảnh của hệ thống.*
