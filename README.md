# Quan-Ly-Ghi-Chu

flutter create project_name

## API

> **Person 1**

| No. | Method | Route                    | Description                         |
| --- | :----: | ------------------------ | ----------------------------------- |
|  1  | POST   | /api/v1/auth/register    | Register a new user                 |
|  2  | POST   | /api/v1/auth/login       | Log in, get a token                 |
|  3  | DELETE | /api/v1/auth/me          | Delete your own account             |
|  4  | GET    | /api/v1/sync/            | Sync data                           |

<hr>

> **Person 2**

| No. | Method | Route                    | Description                         |
| --- | ------ | ------------------------ | ----------------------------------- |
|  5  | POST   | /api/v1/notes            | Create a new note                   |
|  6  | GET    | /api/v1/notes            | Get notes (filter: tag, words, etc) |
|  7  | GET    | /api/v1/notes/id         | Get a note                          |
|  8  | PUT    | /api/v1/notes/id         | Update a note                       |

<hr>

> **Person 3**

| No. | Method | Route                    | Description                         |
| --- | ------ | ------------------------ | ----------------------------------- |
|  9  | DELETE | /api/v1/notes/id         | Delete a note                       |
| 10  | GET    | /api/v1/notes/trash      | Get all deleted notes               |
| 11  | PUT    | /api/v1/notes/id/restore | Restore a deleted note              |
| 12  | DELETE | /api/v1/notes/trash/id   | Permanently delete the note         |

<hr>

> **Person 4**

| No. | Method | Route                    | Description                         |
| --- | ------ | ------------------------ | ----------------------------------- |
| 13  | POST   | /api/v1/tags             | Create a new tag                    |
| 14  | GET    | /api/v1/tags             | Get all of the user's tags          |
| 15  | PUT    | /api/v1/tags/id          | Update a tag's name                 |
| 16  | DELETE | /api/v1/tags/id          | Delete a tag                        |

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
├── logic/              # State Management
│   ├── auth.dart
│   ├── note.dart
│   └── tag.dart
│
└── presentation/ 
    ├── screens/ 
    │   ├── auth/
    │   │   └── auth.dart
    │   ├── notes/
    │   │   ├── note_list.dart
    │   │   └── note_edit.dart
    │   │   └── trashed_list.dart
    │   └── tags/
    │       └── tag_list.dart
    │
    └── widgets/
        ├── note_card.dart
        ├── search_bar.dart
        └── tag_chip.dart
```

### Data Flow

1.  **Fresh Start:** new user can create notes and tags without an account. Data is stored locally on the device, associated with a default local-only profile.
2.  **Optional Registration:** user can choose to register an account. Upon registration, the app will trigger a sync process, pushing all locally created data to the server and linking it to the new account.
3.  **Layered Communication:**
    *   **Presentation (UI)** sends user events to the **Logic**.
    *   **Logic** execute business logic and call methods on the **Services**.
    *   **Services** fetch data from **Local Storage** before fetching from the **API**.

## Presentation

### Widgets

| Custom Widget           | Description                                                                   |
| ----------------------- | ----------------------------------------------------------------------------- |
| **Search & Filter Bar** | A text field for search and a button to open a tag filter panel.              |
| **Note Card**           | A card that displays a preview of a note's title, body, and tags.             |
| **Tag Chip**            | A small "pill" widget that displays a tag's name; can be selectable.          |
| **Custom TextField**    | Text input with consistent styling and validation logic for use in all forms. |

### Screens

BottomNavigation to switch between Note List, Tag List, Trashed List.

| Component          |  API  | Standard Widgets | Reusable Widgets | Description |
| ------------------ | ----- | ---------------- | ---------------- | ----------- |
| **Login <br> Register** | POST /api/v1/auth/register<br>POST /api/v1/auth/login | TextField, TextButton, CircularProgressIndicator, ListView, Card | CustomTextField | Input validation.<br />Includes a list of locally saved user profiles below the form for quick login selection. |
| **Notes List**     | GET /api/v1/notes | ListView / GridView, FloatingActionButton, RefreshIndicator, CheckboxListTile, CircularProgressIndicator | Search & Filter Bar<br>Note Card | Search & Filter bar next to Account button (right) on top. <br> Displays notes in a list or grid.<br> Pull-to-refresh action to sync data. Floating Action Button to create a new note. |
| **Note Edit**      | POST /api/v1/notes<br>PUT /api/v1/notes/id<br>DELETE /api/v1/notes/id | TextField, ListView, Wrap, IconButton, TextButton | Tag Chip | Dynamic list of body blocks, can turn the current line into a text or checklist. Tag selection interface, save/delete actions. |
| **Trashed List**  | GET /api/v1/notes/trash <br>PUT /api/v1/notes/id/restore <br> DELETE /api/v1/notes/trash/id | ListView, ListTile, CheckboxListTile, AlertDialog | Search & Filter Bar<br>Note Card | Displays deleted notes. Users can either restore a note back to the main list or permanently delete it. |
| **Tag List**       | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/id<br>DELETE /api/v1/tags/id | FloatingActionButton, CheckboxListTile, ListView, ListTile, IconButton, AlertDialog, TextField | Tag Chip | A list of all user tags. Create, rename, deleting via dialogs. |





