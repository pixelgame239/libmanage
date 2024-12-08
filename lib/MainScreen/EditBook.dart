import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librarymanage/Elements/bookgenres.dart';
import 'package:librarymanage/Elements/booknames.dart';
// import 'package:librarymanage/MainScreen/pdf_screen.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'MultiSelectChip.dart';

class EditBook extends StatefulWidget {
  final Books detailBook;
  final String importImage;

  const EditBook({super.key, required this.detailBook, required this.importImage});

  @override
  State<EditBook> createState() => _EditBookState();
}

class _EditBookState extends State<EditBook> {
  late TextEditingController _bookNameController;
  late TextEditingController _authorNameController;
  List<String> _selectedGenres =[];
  String? _imagePath;
  String? _filePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bookNameController = TextEditingController(text: widget.detailBook.book_name);
    _authorNameController = TextEditingController(text: widget.detailBook.author_name);
    _fetchcurrentGenres();
    // _selectedGenres = List.from(widget.detailBook.genres);
  }
   Future<void> _fetchcurrentGenres() async {
    try {
      final response = await supabase
          .from('book_genres')
          .select('genre_name')
          .eq('book_id', widget.detailBook.book_id);
      setState(() {
        for(var singleGenre in response){
          _selectedGenres.add(singleGenre['genre_name']);
        }
        // _selectedGenres = List<String>.from(
        //   response.map((e) => e['genre_name']),
        // );
      });
        } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching genres: $e")));
    }
  }
   Future<void> _updateBook() async {
    final bookId = widget.detailBook.book_id;
    final bookName = _bookNameController.text;
    final authorName = _authorNameController.text;

    // Kiểm tra thông tin đầu vào
    if (bookName.isEmpty || authorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      // Bắt đầu transaction để cập nhật sách
      await supabase.from('books').update({
        'book_names': bookName,
        'author_name': authorName,
          // Save file URL
      }).eq('book_id', bookId);


      // Xóa thể loại cũ trong bảng liên kết
      await supabase.from('book_genres').delete().eq('book_id', bookId);

      // Thêm thể loại mới
      for (final genreName in _selectedGenres) {
        await supabase.from('book_genres').insert({
            'book_id': bookId,
            'genre_name': genreName,
          });
      }
      if(_filePath!=null){
        final pdfRead = File(_filePath!).readAsBytesSync();
        final PdfDocument pdfDoc = PdfDocument(inputBytes: pdfRead);
        int total_pages = pdfDoc.pages.count;
        pdfDoc.dispose();
        await supabase.from('books').update({'total_pages':total_pages}).eq('book_id', bookId);
        await supabase.storage.from('pdf').update('$bookId.pdf', File(_filePath!), fileOptions: const FileOptions(upsert: true));
      }
      if(_imagePath!=null){
        await supabase.storage.from('images').update('$bookId.jpg', File(_imagePath!), fileOptions: const FileOptions(upsert: true));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Book updated successfully!")),
      );
      Navigator.maybePop(context,_imagePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }

  // Hàm xử lý khi chọn thể loại
  void _onGenresSelected(List<String> selectedGenres) {
    setState(() {
      _selectedGenres = selectedGenres;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result)async {
        if(didPop){
          return;
        }
        result = _imagePath;
        Navigator.pop(context,result);
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text("Edit Book"),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 300,
                  width: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.importImage),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      // Chức năng thay đổi tệp

                      icon: const Icon(Icons.image),
                      label: const Text(
                        "Change Image (jpg file only)",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),),
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


                  Center(
                    child: ElevatedButton.icon(
                      onPressed: (){
                        _pickFile();
                      },
                      icon: const Icon(Icons.insert_drive_file),
                      label: const Text(
                        "Change File (pdf file only)",
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                ],
              ),

              const SizedBox(height: 20.0),
              TextFormField(
                controller: _bookNameController,
                decoration: const InputDecoration(
                  labelText: "Book Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _authorNameController,
                decoration: const InputDecoration(
                  labelText: "Author Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              const Text(
                "Genres: ",
                style: TextStyle(fontSize: 16),
              ),
              // Phần chọn thể loại (MultiSelectChip)
              MultiSelectChip(
                genres: Provider
                    .of<Genres>(context)
                    .all_genres,
                selectedGenres: _selectedGenres,
                onSelectionChanged: _onGenresSelected,
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _updateBook,
                child: const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
    Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
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
}
