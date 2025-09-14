import 'package:flutter/material.dart';
import 'package:quranicare/services/journal_service.dart';

class AddReflectionModal extends StatefulWidget {
  final int ayahId;
  final String ayahText;
  final String ayahTranslation;
  final Function(JournalData) onReflectionAdded;

  const AddReflectionModal({
    Key? key,
    required this.ayahId,
    required this.ayahText,
    required this.ayahTranslation,
    required this.onReflectionAdded,
  }) : super(key: key);

  @override
  State<AddReflectionModal> createState() => _AddReflectionModalState();
}

class _AddReflectionModalState extends State<AddReflectionModal> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final JournalService _journalService = JournalService();
  
  String? _selectedMood;
  // final List<String> _selectedTags = []; // Hapus tags
  // final List<String> _availableTags = []; // Hapus tags
  // bool _isLoading = false; // Hapus loading
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // _loadTagSuggestions(); // Hapus loading tags
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReflection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reflection = await _journalService.createAyahReflection(
        ayahId: widget.ayahId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        mood: _selectedMood,
        // tags: _selectedTags.isNotEmpty ? _selectedTags : null, // Hapus tags
      );

      widget.onReflectionAdded(reflection);
      Navigator.of(context).pop();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refleksi berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan refleksi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _addTag(String tag) {
    if (!_selectedTags.contains(tag)) {
      setState(() {
        _selectedTags.add(tag);
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  color: Colors.teal[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Refleksi Ayat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Ayah reference
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.ayahText,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.8,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.ayahTranslation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title field
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Judul Refleksi',
                          hintText: 'Masukkan judul refleksi Anda',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul tidak boleh kosong';
                          }
                          if (value.trim().length < 3) {
                            return 'Judul minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Content field
                      TextFormField(
                        controller: _contentController,
                        maxLines: 6,
                        decoration: InputDecoration(
                          labelText: 'Isi Refleksi',
                          hintText: 'Tulis refleksi, hikmah, atau pelajaran yang Anda ambil dari ayat ini...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Isi refleksi tidak boleh kosong';
                          }
                          if (value.trim().length < 10) {
                            return 'Isi refleksi minimal 10 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Mood selection
                      Text(
                        'Perasaan (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: JournalService.getMoodOptions().map((mood) {
                          final isSelected = _selectedMood == mood['value'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMood = isSelected ? null : mood['value'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.teal[100] : Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.teal[300]! : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                mood['label']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected ? Colors.teal[700] : Colors.grey[700],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Tags section
                      Text(
                        'Tag (Opsional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Selected tags
                      if (_selectedTags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              onDeleted: () => _removeTag(tag),
                              backgroundColor: Colors.teal[100],
                              deleteIconColor: Colors.teal[700],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Available tags
                      if (!_isLoading && _availableTags.isNotEmpty) ...[
                        Text(
                          'Tag yang tersedia:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _availableTags
                              .where((tag) => !_selectedTags.contains(tag))
                              .map((tag) {
                            return GestureDetector(
                              onTap: () => _addTag(tag),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReflection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}