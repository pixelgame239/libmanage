import 'package:flutter/material.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> genres; // List of available options
  final List<String> selectedGenres; // Selected options
  final Function(List<String>) onSelectionChanged; // Callback when selection changes

  const MultiSelectChip({
    super.key,
    required this.genres,
    required this.selectedGenres,
    required this.onSelectionChanged,
  });

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> _selectedChoices = [];

  @override
  void initState() {
    super.initState();
    _selectedChoices = widget.selectedGenres; // Initialize with already selected genres
  }

  _buildChoiceList() {
    return widget.genres.map((genre) {
      final isSelected = _selectedChoices.contains(genre);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: FilterChip(
          label: Text(genre),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
          selected: isSelected,
          backgroundColor: Colors.grey[300],
          selectedColor: Colors.blue,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedChoices.add(genre);
              } else {
                _selectedChoices.remove(genre);
              }
              widget.onSelectionChanged(_selectedChoices); // Callback for parent widget
            });
          },
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
      spacing: 8.0,
      runSpacing: 4.0,
    );
  }
}
