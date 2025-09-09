# Quan-Ly-Ghi-Chu

flutter create project_name

## API

| Method | Route                  | Description                         | Auth |
| ------ | ---------------------- | ----------------------------------- | :--: |
| POST   | /api/v1/auth/register  | Register a new user                 |  No  |
| POST   | /api/v1/auth/login     | Log in, get a token                 |  No  |
| DELETE | /api/v1/auth/me        | Delete your own account             | Yes |
| GET    | /api/v1/sync/          | Sync data                           | Yes |
| POST   | /api/v1/notes          | Create a new note                   | Yes |
| GET    | /api/v1/notes          | Get notes (filter: tag, words, etc) | Yes |
| GET    | /api/v1/notes/{noteId} | Get a note                          | Yes |
| PUT    | /api/v1/notes/{noteId} | Update a note                       | Yes |
| DELETE | /api/v1/notes/{noteId} | Delete a note                       | Yes |
| POST   | /api/v1/tags           | Create a new tag                    | Yes |
| GET    | /api/v1/tags           | Get all of the user's tags          | Yes |
| PUT    | /api/v1/tags/{tagId}   | Update a tag's name                 | Yes |
| DELETE | /api/v1/tags/{tagId}   | Delete a tag                        | Yes |

## Project Architecture



## Components

### Small Components

| Custom Widget           | Description                                                                   |
| ----------------------- | ----------------------------------------------------------------------------- |
| **Search & Filter Bar** | A text field for search and a button to open a tag filter panel.              |
| **Note Card**           | A card that displays a preview of a note's title, body, and tags.             |
| **Tag Chip**            | A small "pill" widget that displays a tag's name; can be selectable.          |
| **Custom TextField**    | Text input with consistent styling and validation logic for use in all forms. |

### Big Components

BottomNavigation to switch between Note List and Tag List.

| Component          |  API  | Standard Widgets | Reusable Widgets | Description |
| ------------------ | ----- | ---------------- | ---------------- | ----------- |
| **Login/Register** | POST /api/v1/auth/register<br>POST /api/v1/auth/login | Scaffold, TextField, TextButton, CircularProgressIndicator, ListView, Card | CustomTextField | Input validation.<br />Includes a list of locally saved user profiles below the form for quick login selection. |
| **Notes List**     | GET /api/v1/notes | Scaffold, AppBar, ListView / GridView, FloatingActionButton, RefreshIndicator, CircularProgressIndicator | Search & Filter Bar<br>Note Card | Search & Filter bar next to Account button (right) on top. <br> Displays notes in a list or grid.<br> Pull-to-refresh action to sync data. Floating Action Button to create a new note. |
| **Note Edit**      | POST /api/v1/notes<br>PUT /api/v1/notes/{noteId}<br>DELETE /api/v1/notes/{noteId} | Scaffold, AppBar, TextField, ListView, Wrap, IconButton, TextButton | Tag Chip | Dynamic list of body blocks, can turn the current line into a text or checklist. Tag selection interface, save/delete actions. |
| **Tag List**       | POST /api/v1/tags<br>GET /api/v1/tags<br>PUT /api/v1/tags/{tagId}<br>DELETE /api/v1/tags/{tagId} | Scaffold, AppBar, ListView, ListTile, IconButton, AlertDialog, TextField  | Tag Chip | A list of all user tags. Create, rename, deleting via dialogs. |


### Services
