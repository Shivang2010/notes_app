import 'package:flutter/material.dart';
import 'package:notes_app/database/notes_database.dart';
import 'package:notes_app/screens/notes_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> notes = [];

  final List<Color> noteColors = [
    const Color(0xFFFFFFFF), // White
    const Color(0xFFF28B82), // Pastel Red
    const Color(0xFFFBBC04), // Pastel Orange
    const Color(0xFFFFF475), // Pastel Yellow
    const Color(0xFFCCFF90), // Pastel Green
    const Color(0xFFA7FFEB), // Pastel Teal
    const Color(0xFFCBF0F8), // Pastel Light Blue
    const Color(0xFFAECBFA), // Pastel Blue
    const Color(0xFFD7AEFB), // Pastel Purple
    const Color(0xFFFDCFE8), // Pastel Pink
    const Color(0xFFE6C9A8), // Pastel Brown
    const Color(0xFFE8EAED), // Pastel Gray
  ];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final fetchedNotes = await NotesDatabase.instance.getNotes();
    setState(() {
      notes = fetchedNotes;
    });
  }

  void _showNoteDialog({int? noteId, String? title, String? content, int colorIndex = 0}) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) => NoteDialog(
        noteId: noteId,
        title: title,
        content: content,
        colorIndex: colorIndex,
        noteColors: noteColors,
        onNoteSaved: fetchNotes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                title: const Text(
                  'Notes',
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
              ),
            ),
            if (notes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notes_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No notes yet',
                        style: TextStyle(color: Colors.grey[500], fontSize: 18),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      final colorIdx = note['color'] ?? 0;
                      final safeColorIdx = (colorIdx >= 0 && colorIdx < noteColors.length) ? colorIdx : 0;

                      return GestureDetector(
                        onTap: () => _showNoteDialog(
                          noteId: note['id'],
                          title: note['title'],
                          content: note['description'],
                          colorIndex: safeColorIdx,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: noteColors[safeColorIdx],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.black.withOpacity(0.05), width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                note['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF202124),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Text(
                                  note['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF202124).withOpacity(0.7),
                                    height: 1.4,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                note['date'].toString().split(' ')[0],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF202124).withOpacity(0.4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add_rounded, size: 28),
        label: const Text('New Note', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
