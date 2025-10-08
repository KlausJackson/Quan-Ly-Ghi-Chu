import 'package:flutter/material.dart';
import 'package:notes/features/notes/presentation/widgets/customers_toolbar.dart';

/// Top area widget for TrashPage: title, toolbar and selection controls.
class TrashTopArea extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final int notesCount;
  final bool selectMode;
  final int selectedCount;
  final bool isGridView;
  final VoidCallback? onRefresh;
  final VoidCallback? onToggleView;
  final VoidCallback? onEnterSelectMode;
  final VoidCallback? onSelectAllToggle;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onCancelSelection;
  final VoidCallback? onSearchPressed;
  final ValueChanged<String>? onSearch;

  const TrashTopArea({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.notesCount,
    required this.selectMode,
    required this.selectedCount,
    required this.isGridView,
    this.onRefresh,
    this.onToggleView,
    this.onEnterSelectMode,
    this.onSelectAllToggle,
    this.onDeleteSelected,
    this.onCancelSelection,
    this.onSearchPressed,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('My Account', style: TextStyle(color: Colors.white)),
            const SizedBox(width: 8),
            Switch(value: true, onChanged: (v) {}, activeColor: Colors.white, activeTrackColor: Colors.deepPurple),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              const Text('Thùng rác', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(isLoading ? 'Đang tải...' : '$notesCount ghi chú', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Use the full TrashToolBar (has search field + focus handling)
        TrashToolBar(
          isLoading: isLoading,
          errorMessage: errorMessage,
          onRefresh: onRefresh,
          isGridView: isGridView,
          onToggleView: onToggleView,
          onSearchPressed: onSearchPressed,
          onSearch: onSearch,
        ),
        // Selection controls
        if (!selectMode)
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: onEnterSelectMode,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[900], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('Chọn'),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  TextButton(
                    onPressed: onSelectAllToggle,
                    style: TextButton.styleFrom(backgroundColor: Colors.grey[800], padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Chọn tất cả', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                ]),
                Row(children: [
                  Padding(padding: const EdgeInsets.only(right: 12.0), child: Text('đã chọn $selectedCount', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                  ElevatedButton(onPressed: onDeleteSelected, style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[700], padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Xóa', style: TextStyle(color: Colors.white))),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: onCancelSelection, style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Hủy', style: TextStyle(color: Colors.white))),
                ]),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
