import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:masar_pro/config/app_colors.dart';

class CustomDropdownField<T> extends StatefulWidget {
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>>? items;
  final Function(T?)? onChanged;
  final String? suffixAsset;
  final String? Function(T?)? validator;
  final bool disableWithOverlay;
  final VoidCallback? onOverlayTap;
  final bool disableAutoSelect;

  const CustomDropdownField({
    super.key,
    this.hintText,
    this.value,
    this.items,
    this.onChanged,
    this.suffixAsset,
    this.validator,
    this.disableWithOverlay = false,
    this.onOverlayTap,
    this.disableAutoSelect = false,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  T? _selectedValue;

  @override
  void initState() {
    super.initState();
    _handleAutoSelection();
  }

  @override
  void didUpdateWidget(CustomDropdownField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items || widget.value != oldWidget.value) {
      _handleAutoSelection();
    }
  }

  void _handleAutoSelection() {
    _selectedValue = widget.value;
    final items = widget.items;

    if (items != null && items.isNotEmpty) {
      bool valueExists = _selectedValue != null &&
          items.any((item) => item.value == _selectedValue);

      if (!valueExists && !widget.disableAutoSelect && items.length == 1) {
        _selectedValue = items.first.value;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onChanged?.call(_selectedValue);
        });
      }
    } else {
      _selectedValue = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasMatchingValue = _selectedValue == null ||
        (widget.items?.any((item) => item.value == _selectedValue) ?? false);

    Widget dropdown = DropdownButtonFormField<T>(
      isExpanded: true,
      // ignore: deprecated_member_use
      value: hasMatchingValue ? _selectedValue : null,
      selectedItemBuilder: widget.items != null
          ? (BuildContext context) {
              return widget.items!.map<Widget>((DropdownMenuItem<T> item) {
                return Row(
                  children: [
                    Flexible(
                      child: item.child,
                    ),
                  ],
                );
              }).toList();
            }
          : null,
      items: widget.items?.map((item) {
        return DropdownMenuItem<T>(
          value: item.value,
          enabled: item.enabled,
          alignment: item.alignment,
          onTap: item.onTap,
          child: Row(
            children: [
              Flexible(
                child: item.child,
              ),
            ],
          ),
        );
      }).toList(),
      focusColor: AppColors.grayLight,
      onChanged: widget.onChanged == null
          ? null
          : (value) {
              setState(() {
                _selectedValue = value;
              });
              widget.onChanged!(value);
            },
      validator: widget.validator,
      icon: Icon(Icons.arrow_drop_down, color: AppColors.black, size: 30),
      style: TextStyle(color: AppColors.black, fontSize: 14),
      decoration: InputDecoration(
        fillColor: AppColors.white,
        hintText: widget.hintText?.tr(),
        prefixIcon: widget.suffixAsset != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(widget.suffixAsset!, height: 20, width: 20),
              )
            : null,
        constraints: const BoxConstraints(maxHeight: 38),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        focusedBorder: _buildBorder(width: 1),
        enabledBorder: _buildBorder(width: 1),
        border: _buildBorder(width: 1),
      ),
    );

    if (widget.disableWithOverlay) {
      return Stack(
        children: [
          dropdown,
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onOverlayTap,
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    }
    
    return dropdown;  }

  OutlineInputBorder _buildBorder({double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.gray, width: width),
    );
  }
}
