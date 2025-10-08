import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notes/features/notes/presentation/widgets/toolbar_search_field.dart';

class ToolBar extends StatelessWidget{
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
   return    Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.grid_view, color: Colors.white),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            );
  }
}

// Reusable toolbar for trash page with refresh functionality
class TrashToolBar extends StatefulWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final bool isGridView;
  final VoidCallback? onToggleView;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onSearchPressed;

  const TrashToolBar({
    super.key,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
    this.isGridView = false,
    this.onToggleView,
    this.onSearch,
    this.onSearchPressed,
  });

  @override
  State<TrashToolBar> createState() => _TrashToolBarState();
}

class _TrashToolBarState extends State<TrashToolBar> {
  bool _showSearch = false;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    widget.onSearchPressed?.call();
    setState(() => _showSearch = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      FocusScope.of(context).requestFocus(_focusNode);
      SystemChannels.textInput.invokeMethod('TextInput.show');
      Future.delayed(const Duration(milliseconds: 120), () {
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
          FocusScope.of(context).requestFocus(_focusNode);
          SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      });
    });
  }

  void _closeSearch() {
    _focusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _showSearch = false;
      _controller.clear();
    });
    widget.onSearch?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(widget.isGridView ? Icons.list : Icons.grid_view, color: Colors.white),
                onPressed: widget.onToggleView,
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.errorMessage != null)
                  Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent),
                      const SizedBox(width: 6),
                      Text(widget.errorMessage ?? 'Unknown error', style: const TextStyle(color: Colors.redAccent)),
                      const SizedBox(width: 12),
                    ],
                  ),
                IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: widget.isLoading ? null : widget.onRefresh),
                _showSearch
                    ? SearchField(controller: _controller, focusNode: _focusNode, onChanged: widget.onSearch, onClose: _closeSearch)
                    : IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: _openSearch),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
