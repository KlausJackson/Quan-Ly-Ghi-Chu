import 'package:flutter/material.dart';

/// Small reusable search field used inside the toolbar.
/// Keeps the toolbar file focused on layout/behavior.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClose;
  final double width;

  const SearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onClose,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          hintText: 'Tìm kiếm...',
          hintStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: onClose,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
