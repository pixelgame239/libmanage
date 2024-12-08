import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librarymanage/Elements/bookgenres.dart';
import 'package:librarymanage/MainScreen/MultiSelectChip.dart';
import 'package:librarymanage/MainScreen/screenElements.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:file_picker/file_picker.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> _selectedGenres = [];
  String? _imagePath;
  String? _filePath;
  TextEditingController titleController = TextEditingController();
  TextEditingController authorController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

    Future<void> _pickFile() async {
    // Use FilePicker to select a PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allows custom file types
      allowedExtensions: ['pdf'], // Only allow PDF files
    );

    if (result != null) {
      // Get the file path of the selected PDF
      setState(() {
        _filePath = result.files.single.path; // Store the path
      });
    }
  }

  void _addBook(String title, String author_name) async{
  if (_formKey.currentState!.validate()) {
      // Kiểm tra xem các mục có được chọn đủ không
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one genre.")),
        );
        return;
      }
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please pick an image.")),
        );
        return;
      }
      if (_filePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please pick a PDF file.")),
        );
        return;
      }

      // Đọc số trang từ file PDF
      final pdfBytes = File(_filePath!).readAsBytesSync();
      final PdfDocument pdfDocument = PdfDocument(inputBytes: pdfBytes);
      final pageCount = pdfDocument.pages.count;
      pdfDocument.dispose(); // Giải phóng bộ nhớ
      final book_id = await genBookID();
          // Nếu tất cả các điều kiện đều thỏa mãn, tiến hành lưu sách
      await supabase.from('books').insert({'book_id': book_id, 'book_names': title, 'author_name': author_name, 'total_pages': pageCount});
      for(String genre in _selectedGenres){
              await supabase.from('book_genres').insert({'genre_name':genre, 'book_id': book_id});
      }
      await supabase.storage.from('pdf').upload('$book_id.pdf', File(_filePath!));
      await supabase.storage.from('images').upload('$book_id.jpg', File(_imagePath!));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Book added successfully!")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please fill in all required fields.")),
          );

        }
      }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Book"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Enter Book Details",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: "Author",
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Enter an author' : null,
              ),
              const SizedBox(height: 16),
              MultiSelectChip(
                genres: Provider.of<Genres>(context).all_genres,
                selectedGenres: _selectedGenres,
                onSelectionChanged: (selectedList) {
                  setState(() {
                    _selectedGenres = selectedList;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Pick Image (jpg file only)"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_imagePath!),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: (){
                  _pickFile();
                },
                icon: const Icon(Icons.insert_drive_file),
                label: const Text("Pick File (Pdf file only)"),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_filePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Selected file: ${_filePath!.split('/').last}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (){
                  _addBook(titleController.text, authorController.text);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Add Book"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

