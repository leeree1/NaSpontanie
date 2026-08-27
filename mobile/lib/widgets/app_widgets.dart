import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      automaticallyImplyLeading: false,
      actions: actions,
    );
  }
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final onPressedOrNull = isLoading ? null : onPressed;
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary),
          )
        : Text(label);

    if (outlined) {
      if (icon != null && !isLoading) {
        return OutlinedButton.icon(
          onPressed: onPressedOrNull,
          icon: Icon(icon),
          label: Text(label),
        );
      }
      return OutlinedButton(onPressed: onPressedOrNull, child: child);
    }

    final style = color == null
        ? null
        : ElevatedButton.styleFrom(backgroundColor: color);

    if (icon != null && !isLoading) {
      return ElevatedButton.icon(
        onPressed: onPressedOrNull,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }
    return ElevatedButton(onPressed: onPressedOrNull, style: style, child: child);
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.focusColor,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Color? focusColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    final focused = focusColor;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon,
        focusedBorder: focused == null
            ? null
            : OutlineInputBorder(
                borderRadius: radius,
                borderSide: BorderSide(color: focused, width: 2),
              ),
      ),
    );
  }
}

class ChoiceChipRow<T> extends StatelessWidget {
  const ChoiceChipRow({
    super.key,
    required this.values,
    required this.selected,
    required this.onSelected,
    this.labelBuilder,
  });

  final List<T> values;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final value = values[index];
          final isSelected = selected == value;
          return ChoiceChip(
            label: Text(labelBuilder?.call(value) ?? value.toString()),
            selected: isSelected,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            onSelected: (chipSelected) {
              if (chipSelected) onSelected(value);
            },
          );
        },
      ),
    );
  }
}

class XpBadge extends StatelessWidget {
  const XpBadge({super.key, required this.xp, this.chip = false});

  final int xp;
  final bool chip;

  @override
  Widget build(BuildContext context) {
    if (chip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt, color: AppColors.primary, size: 18),
            const SizedBox(width: 4),
            Text(
              '$xp XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$xp XP',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
