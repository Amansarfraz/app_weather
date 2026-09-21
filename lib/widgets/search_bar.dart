import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A rounded, glassy search field with an animated focus border and a
/// clear (x) button that fades in once there's text.
class CitySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool isLoading;
  final ValueChanged<String> onSubmitted;

  const CitySearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.hintText = 'Search city...',
    this.isLoading = false,
  });

  @override
  State<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends State<CitySearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
    widget.controller.addListener(() {
      final hasText = widget.controller.text.isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final value = widget.controller.text.trim();
    if (value.isEmpty) return;
    FocusScope.of(context).unfocus();
    widget.onSubmitted(value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _isFocused ? Colors.white : AppColors.glassBorder,
          width: _isFocused ? 1.6 : 1,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: widget.isLoading
                ? const Padding(
                    key: ValueKey('loading'),
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : _hasText
                    ? IconButton(
                        key: const ValueKey('clear'),
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () {
                          widget.controller.clear();
                          setState(() => _hasText = false);
                        },
                      )
                    : const SizedBox(key: ValueKey('empty'), width: 8),
          ),
        ],
      ),
    );
  }
}
