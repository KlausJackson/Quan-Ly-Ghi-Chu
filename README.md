# Quan-Ly-Ghi-Chu

flutter create noteapp
See API requests and responses examples in [Task Manager](https://github.com/KlausJackson/Task-Manager)

## API

> **Person 1**

| No. | Method | Route                 | Description             |
| --- | :----: | --------------------- | ----------------------- |
| 1   |  POST  | /api/v1/auth/register | Register a new user     |
| 2   |  POST  | /api/v1/auth/login    | Log in, get a token     |
| 3   | DELETE | /api/v1/auth/me       | Delete your own account |
| 4   |  GET   | /api/v1/sync/         | Sync data               |

<hr>

> **Nguyen Anh Van**

| No. | Method | Route            | Description                         |
| --- | ------ | ---------------- | ----------------------------------- |
| 5   | POST   | /api/v1/notes    | Create a new note                   |
| 6   | GET    | /api/v1/notes    | Get notes (filter: tag, words, etc) |
| 7   | GET    | /api/v1/notes/id | Get a note                          |
| 8   | PUT    | /api/v1/notes/id | Update a note                       |

<hr>

> **Thai Tuan**

| No. | Method | Route                    | Description                 |
| --- | ------ | ------------------------ | --------------------------- |
| 9   | DELETE | /api/v1/notes/id         | Delete a note               |
| 10  | GET    | /api/v1/notes/trash      | Get all deleted notes       |
| 11  | PUT    | /api/v1/notes/id/restore | Restore a deleted note      |
| 12  | DELETE | /api/v1/notes/trash/id   | Permanently delete the note |

<hr>

> **Nguyen Truong**

| No. | Method | Route           | Description                |
| --- | ------ | --------------- | -------------------------- |
| 13  | POST   | /api/v1/tags    | Create a new tag           |
| 14  | GET    | /api/v1/tags    | Get all of the user's tags |
| 15  | PUT    | /api/v1/tags/id | Update a tag's name        |
| 16  | DELETE | /api/v1/tags/id | Delete a tag               |

## Project Architecture

```bash
lib/
├── core/
│   ├── constants.dart
│   └── date_formatter.dart
│
├── data/
│   ├── models/
│   │   ├── note.dart
│   │   ├── tag.dart
│   │   └── user.dart
│   │
│   ├── sources/
│   │   ├── local.dart   # local device database
│   │   └── remote.dart  # web API
│   │
│   └── services/
│       ├── auth.dart
│       ├── note.dart
│       ├── tag.dart
│       └── sync.dart
│
├── providers/              # State Management
│   ├── auth_provider.dart
│   ├── note_provider.dart
│   ├── tag_provider.dart
│   └── sync_provider.dart
│
└── presentation/
    ├── screens/
    │   ├── auth/
    │   │   └── auth.dart
    │   ├── notes/
    │   │   ├── note_list.dart
    │   │   ├── note_edit.dart
    │   │   └── trashed_list.dart
    │   └── tags/
    │       └── tag_list.dart
    │
    └── widgets/
        ├── note_card.dart
        ├── search_bar.dart
        ├── show_dialog.dart
        └── tag_chip.dart
```

### Luồng Dữ Liệu và Tính Năng

1.  **Fresh Start (Khởi đầu mới):** Người dùng mới có thể tạo ghi chú (notes) và thẻ (tags) mà không cần tài khoản. Dữ liệu được lưu trữ cục bộ trên thiết bị, liên kết với một hồ sơ mặc định chỉ có ở local. Để xóa một tài khoản, người dùng phải đăng nhập, nhập lại mật khẩu để xác nhận. Sau khi xóa thành công, người dùng sẽ cần đăng nhập vào một tài khoản khác hoặc có thể tiếp tục sử dụng ứng dụng ngoại tuyến (offline) mà không cần đăng nhập.
2.  **Optional Registration (Đăng ký tùy chọn):** Người dùng có thể chọn đăng ký tài khoản. Khi đăng ký, ứng dụng sẽ kích hoạt một quy trình đồng bộ hóa (sync), đẩy tất cả dữ liệu được tạo cục bộ lên máy chủ và liên kết nó với tài khoản mới.
3.  **Layered Communication (Kiến trúc phân lớp):**
    *   **Presentation (UI)** gửi các sự kiện của người dùng (user events) đến các **Providers**.
    *   **Providers** thực thi logic nghiệp vụ (business logic) và gọi các phương thức (methods) trên các **Services**.
    *   **Services** lấy dữ liệu từ **Local Storage** (bộ nhớ cục bộ) trước khi lấy từ **API**.

## Presentation (Lớp Giao Diện)

### Widgets (Các thành phần nhỏ)

| Custom Widget           | Description (Mô tả)                                                                         |
| ----------------------- | ------------------------------------------------------------------------------------------- |
| **Search & Filter Bar** | Một trường văn bản (text field) để tìm kiếm và một nút để mở bảng điều khiển lọc theo thẻ.     |
| **Note Card**           | Một thẻ (card) hiển thị bản xem trước của tiêu đề, nội dung và các thẻ của một ghi chú.    |
| **Tag Chip**            | Một widget nhỏ hình "viên thuốc" hiển thị tên của một thẻ; có thể chọn được. |
| **Custom ShowDialog**   | Các dialog tùy chỉnh cho mọi trường hợp sử dụng: hủy bỏ, tạo mới, xác nhận, v.v. |

### Screens (Các màn hình)

Sử dụng `BottomNavigation` để chuyển đổi giữa `Note List`, `Tag List`, và `Trashed List`. Hoặc dùng menu, sao cũng được.

| Component           | API                                                                                         | Standard Widgets                                                                                         | Reusable Widgets                 | Description (Mô tả)                                                                                                                                                                             |
| ------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Login; Register** | POST /api/v1/auth/register; POST /api/v1/auth/login                                         | TextField, TextButton, CircularProgressIndicator, ListView, Card                                         | CustomTextField                  | Input validation. Bao gồm một danh sách các hồ sơ người dùng đã lưu cục bộ bên dưới biểu mẫu để chọn đăng nhập nhanh.                                                            |
| **Notes List**      | GET /api/v1/notes                                                                           | ListView / GridView, FloatingActionButton, RefreshIndicator, CheckboxListTile, CircularProgressIndicator | Search & Filter Bar<br>Note Card | - Thanh `Search & Filter` bên cạnh nút `Account` (bên phải) ở trên cùng.<br>- Hiển thị ghi chú.<br>- Kéo để làm mới (Pull-to-refresh) để đồng bộ dữ liệu.<br>- `Floating Action Button` để tạo ghi chú mới. |
| **Note Edit**       | POST /api/v1/notes<br>PUT /api/v1/notes/id<br>DELETE /api/v1/notes/id                       | TextField, ListView, Wrap, IconButton, TextButton                                                        | Tag Chip                         | <ul><li>Danh sách động các khối nội dung (body blocks): có thể biến dòng hiện tại thành văn bản hoặc dạng văn bản + checkbox (checklist).</li><li>Giao diện chọn thẻ.</li><li>Các hành động lưu/hủy/xóa.</li></ul> |
| **Trashed List**    | GET /api/v1/notes/trash <br>PUT /api/v1/notes/id/restore <br> DELETE /api/v1/notes/trash/id | ListView, ListTile, CheckboxListTile, AlertDialog                                                        | Search & Filter Bar<br>Note Card | - Hiển thị các ghi chú đã xóa.<br>- Người dùng có thể khôi phục ghi chú trở lại danh sách chính hoặc xóa vĩnh viễn. |
| **Tag List**        | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/id<br>DELETE /api/v1/tags/id       | FloatingActionButton, CheckboxListTile, ListView, ListTile, IconButton, AlertDialog, TextField       | Tag Chip                         | <ul><li>Liệt kê tất cả các thẻ của người dùng</li><li>Tạo thẻ mới</li><li>Đổi tên thẻ</li><li>Xóa thẻ thông qua dialogs</li></ul> |

# Hướng Dẫn (Tutorial)

## 1. Model

Định nghĩa cấu trúc dữ liệu và tạo `Adapter` cho Hive.

```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;
  @HiveField(1)
  String? lastSynced; // timestamp, nullable

  User({required this.username, this.lastSynced});
}
```

Chạy lệnh sau trong terminal để tạo file `user.g.dart` (chứa `UserAdapter`):

```bash
flutter pub run build_runner build
```

## 2. Local (Lưu trữ cục bộ)

Bỏ comment dòng `Hive.registerAdapter(UserAdapter());` trong hàm `init()`.

```dart
  Future<Box<Note>> _getNotesTable(String currentUser) async {
    return await Hive.openBox<Note>('notes_$currentUser');
  }

  // --- Public Methods for NoteService ---
  Future<List<Note>> getNotes(String currentUser) async {
    final box = await _getNotesBox(currentUser);
    return box.values.toList();
  }
```

## 3. Remote (Tương tác với API)

...

## 4. Service (Tầng logic nghiệp vụ)

...

## 5. Provider (Tầng quản lý state)

...

## 6. ShowDialog (Sử dụng Dialog tái sử dụng)

### showInfoDialog

Dialog với `title`, `message`, và nút `OK`: dùng cho thông báo lỗi / thông tin.

```dart
AppDialogs.showInfoDialog(
  context: context,
  title: 'Lỗi',
  message: 'Không thể lưu ghi chú.',
  // onOkPressed: goi ham chuc nang
);

AppDialogs.showInfoDialog(
  context: context,
  title: 'Thành công',
  message: 'Đã lưu ghi chú.',
);
```

### showConfirmationDialog

Dialog với nút `Cancel` và một hành động xác nhận: dùng cho việc xóa.

```dart
AppDialogs.showConfirmationDialog(
  context: context,
  title: 'Xóa Ghi Chú?',
  message: 'Hành động này không thể hoàn tác.',
  confirmText: 'Xóa',
  onConfirm: () {
    // code xoa note ở đây
  },
);
```

### showInputDialog

Dialog với một trường nhập liệu (input field) và các nút `Cancel`/`Confirm`: dùng để xác nhận mật khẩu, đổi tên thẻ.
Hàm này trả về `String` đã nhập nếu xác nhận, hoặc `null` nếu hủy.

```dart
AppDialogs.showInputDialog(
    context: context,
    title: 'Xác Nhận Xóa Tài Khoản',
    message: 'Vui lòng nhập lại mật khẩu của bạn:',
    confirmText: 'Xóa',
).then((password) {
    if (password != null && password.isNotEmpty) {
        _authProvider.deleteAccount(password);
    } else if (password != null && password.isEmpty) {
        _snackbar('Mật khẩu không được để trống.');
    }
});
```




<!-- 
### Data Flow

1.  **Fresh Start:** new users can create notes and tags without needing an account. Data is stored locally on the device, linked to a default local-only profile. To delete an account, the user must log in, re-enter the account password. Once the deletion is successful, the user will need to log into an account again or can continue to use the app offline without being logged in.
2.  **Optional Registration:** user can choose to register an account. Upon registration, the app will trigger a sync process, pushing all locally created data to the server and linking it to the new account.
3.  **Layered Communication:**
    -   **Presentation (UI)** sends user events to the **Providers**.
    -   **Providers** execute business logic and call methods on the **Services**.
    -   **Services** fetch data from **Local Storage** before fetching from the **API**.

## Presentation

### Widgets

| Custom Widget           | Description                                                          |
| ----------------------- | -------------------------------------------------------------------- |
| **Search & Filter Bar** | A text field for search and a button to open a tag filter panel.     |
| **Note Card**           | A card that displays a preview of a note's title, body, and tags.    |
| **Tag Chip**            | A small "pill" widget that displays a tag's name; can be selectable. |
| **Custom ShowDialog**   | Custom dialogs for all use cases: destruction, create, confirm, etc. |

### Screens

BottomNavigation to switch between Note List, Tag List, Trashed List.

| Component           | API                                                                                         | Standard Widgets                                                                                         | Reusable Widgets                 | Description                                                                                                                                                                                     |
| ------------------- | ------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Login; Register** | POST /api/v1/auth/register; POST /api/v1/auth/login                                         | TextField, TextButton, CircularProgressIndicator, ListView, Card                                         | CustomTextField                  | Input validation. Includes a list of locally saved user profiles below the form for quick login selection.                                                                                      |
| **Notes List**      | GET /api/v1/notes                                                                           | ListView / GridView, FloatingActionButton, RefreshIndicator, CheckboxListTile, CircularProgressIndicator | Search & Filter Bar<br>Note Card | - Search & Filter bar next to Account button (right) on top.<br>- Displays notes.<br>- Pull-to-refresh action to sync data.<br>- Floating Action Button to create a new note. |
| **Note Edit**       | POST /api/v1/notes<br>PUT /api/v1/notes/id<br>DELETE /api/v1/notes/id                       | TextField, ListView, Wrap, IconButton, TextButton   | Tag Chip     | <ul><li>Dynamic list of body blocks: can turn the current line into a text or checklist.</li><li>Tag selection interface.</li><li>Save/delete actions.</li></ul>    |
| **Trashed List**    | GET /api/v1/notes/trash <br>PUT /api/v1/notes/id/restore <br> DELETE /api/v1/notes/trash/id | ListView, ListTile, CheckboxListTile, AlertDialog    | Search & Filter Bar<br>Note Card | - Displays deleted notes.<br>- Users can restore a note back to the main list or permanently delete notes.   |
| **Tag List**        | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/id<br>DELETE /api/v1/tags/id | FloatingActionButton, CheckboxListTile, ListView, ListTile, IconButton, AlertDialog, TextField | Tag Chip | <ul><li>List all user tags</li><li>Create new tags</li><li>Rename tags</li><li>Delete tags via dialogs</li></ul>  |

# Tutorial

## 1. Model

```dart
import 'package:hive/hive.dart';

part 'user.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  final String username;
  @HiveField(1)
  String? lastSynced; // timestamp, nullable

  User({required this.username, this.lastSynced});
}
```

Compile user.g.dart -> UserAdapter()

```bash
flutter pub run build_runner build
```

## Local

Uncomment `Hive.registerAdapter(UserAdapter());` in init().

```dart
  Future<Box<Note>> _getNotesTable(String currentUser) async {
    return await Hive.openBox<Note>('notes_$currentUser');
  }

  // --- Public Methods for NoteService ---
  Future<List<Note>> getNotes(String currentUser) async {
    final box = await _getNotesBox(currentUser);
    return box.values.toList();
  }
```

## Remote

...

## Service

...

## Provider

...

## ShowDialog

### showInfoDialog

Dialog with title, message, ok button: error / info

```dart
AppDialogs.showInfoDialog(
  context: context,
  title: 'Error',
  message: 'Could not save the note.',
  // onOkPressed: goi ham chuc nang
);

AppDialogs.showInfoDialog(
  context: context,
  title: 'Success',
  message: 'Saved the note.',
);
```

### showConfirmationDialog

Dialog with cancel and confirmation action: delete

```dart
AppDialogs.showConfirmationDialog(
  context: context,
  title: 'Delete Note?',
  message: 'This action cannot be undone.',
  confirmText: 'Delete',
  onConfirm: () {
    // code xoa note
  },
);
```

### showInputDialog

Dialog with input field and cancel/confirm actions: password confirmation, change tag name
Returnstheinputtextifconfirmed,nullifcancelled.

```dart
AppDialogs.showInputDialog(
    context: context,
    title: 'Confirm Account Deletion',
    message: 'Please re-enter your password:',
    confirmText: 'Delete',
    ).then((password) {
        if (password != null && password.isNotEmpty) {
            _authProvider.deleteAccount(password);
        } else if (password != null && password.isEmpty) {
            _snackbar('Password cannot be empty.');
        }
    }
);
``` -->
