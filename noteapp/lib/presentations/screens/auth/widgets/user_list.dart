import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:noteapp/features/auth/auth_provider.dart';
import 'package:noteapp/features/auth/user_model.dart';
import 'package:noteapp/presentations/shared_widgets/show_dialogs.dart';

class UserList extends StatelessWidget {
  final Function(UserModel) onUserSelected;

  const UserList({super.key, required this.onUserSelected});

  String _formatDateTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Use select/watch to rebuild only when list changes
    final profiles = context.select<AuthProvider, List<UserModel>>(
      (p) => p.savedUsers,
    );

    if (profiles.isEmpty) {
      return const Center(
        child: Text(
          'No saved users found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final user = profiles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user.username),
            subtitle: Text(
              user.lastSynced != null
                  ? _formatDateTime(user.lastSynced!)
                  : 'Not synced',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            onTap: () => onUserSelected(user),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () {
                ShowDialogs.showConfirmationDialog(
                  context: context,
                  title: 'Delete User',
                  message:
                      'Are you sure you want to delete the user "${user.username}" and all associated data on this device?',
                  confirmText: 'Delete',
                  onConfirm: () {
                    context.read<AuthProvider>().deleteLocalUser(user.username);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
