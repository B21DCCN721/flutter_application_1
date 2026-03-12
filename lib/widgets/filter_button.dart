import 'package:flutter/material.dart';
import 'package:flutter_application_1/theme/colors.dart';

class FilterButton extends StatelessWidget {
  final String title;
  final String value;
  final String selectedValue;
  final Function(String) onSelected;
  const FilterButton({
    super.key,
    required this.title,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        onSelected(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grayBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
