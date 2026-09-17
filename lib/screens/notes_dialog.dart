import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/database/notes_database.dart';

class NoteDialog extends StatefulWidget {
  final int? noteId;
  final String? title;
  final String? content;
  final int colorIndex;
  final List<Color> noteColors;
  final Function onNoteSaved;

  const NoteDialog({
    super.key,
    this.noteId,
    this.title,
    this.content,
    required this.colorIndex,
    required this.noteColors,
    required this.onNoteSaved,
  });

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.content);
    _selectedColorIndex = widget.colorIndex;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final isEditing = widget.noteId != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: widget.noteColors[_selectedColorIndex],
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Note' : 'New Note',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF202124),
                    ),
                  ),
                  if (isEditing)
                    IconButton(
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      tooltip: 'Delete',
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currentDate,
                style: TextStyle(
                  color: const Color(0xFF202124).withOpacity(0.4),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              // Title Field
              TextField(
                controller: titleController,
                autofocus: !isEditing,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: const Color(0xFF202124).withOpacity(0.15)),
                ),
              ),
              const SizedBox(height: 12),

              // Description Field
              TextField(
                controller: descriptionController,
                maxLines: null,
                minLines: 5,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF202124),
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: const Color(0xFF202124).withOpacity(0.15)),
                ),
              ),
              const SizedBox(height: 32),

              // Color Selection Label
              const Text(
                "Background Color",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF202124),
                ),
              ),
              const SizedBox(height: 16),

              // Color Picker
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.noteColors.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedColorIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: widget.noteColors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black.withOpacity(0.05),
                            width: isSelected ? 2.5 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ] : [],
                        ),
                        child: isSelected 
                          ? const Icon(Icons.check_rounded, color: Colors.black, size: 20) 
                          : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Discard',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isEditing ? 'Update' : 'Save',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty && description.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final date = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    if (widget.noteId == null) {
      await NotesDatabase.instance.addNote(title, description, date, _selectedColorIndex);
    } else {
      await NotesDatabase.instance.updateNote(title, description, date, widget.noteId!, _selectedColorIndex);
    }
    widget.onNoteSaved();
    if (mounted) Navigator.pop(context);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete note?'),
        content: const Text('This will remove the note permanently.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await NotesDatabase.instance.deleteNote(widget.noteId!);
              widget.onNoteSaved();
              if (mounted) {
                Navigator.pop(context); // Close confirm dialog
                Navigator.pop(this.context); // Close note dialog
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
