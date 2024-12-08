import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:librarymanage/MainScreen/pdf_screen.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase/supabase.dart';

class Detailbook extends StatefulWidget {
  final Books detailBook;
  final List<String> importImage;
  int currentIndex = 0;
  ImagePicker picker = ImagePicker();

  Detailbook({super.key, required this.detailBook, required this.importImage});
  

  @override
  State<Detailbook> createState() => _DetailbookState();
}

class _DetailbookState extends State<Detailbook> {
  @override
  void initState(){
    _fetchDetailImage();
    super.initState();
  }
  Future<void> _fetchDetailImage() async{
  final detailImage = await supabase.storage.from('images').list(searchOptions:  SearchOptions(search: widget.detailBook.book_id));
  if (detailImage.isNotEmpty){
  for (var singImage in detailImage){
    if(singImage.name!= '${widget.detailBook.book_id}.jpg'){
      String singleName = supabase.storage.from('images').getPublicUrl(singImage.name);
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      widget.importImage.add('$singleName?v=$timeStamp');
    }
  }
  }
  setState(() {
  });
}
 Future<void> _pickImage(String func) async {
    final XFile? pickedFile = await widget.picker.pickImage(
        source: ImageSource.gallery);
      if (pickedFile != null) {
        if(func == 'Add'){
        try {
          await supabase.storage.from('images').upload(
              '${widget.detailBook.book_id}.${widget.importImage.length}.jpg',
              File(pickedFile.path));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Images add to gallery')));
        } catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
    }
    else{
      try {
        if(widget.currentIndex!=0){
              await supabase.storage.from('images').update(
              '${widget.detailBook.book_id}.${widget.currentIndex}.jpg',
              File(pickedFile.path), fileOptions: const FileOptions(upsert: true));
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Images editted')));
        }
        else{
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cannot edit cover image, try edit the book instead')));
        }
        } catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.toString())));
        }
    }
  }
 }
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<Users>(context);
    String allcurGenres = '';
    for(String curGenre in widget.detailBook.genres){
      if (curGenre==widget.detailBook.genres[widget.detailBook.genres.length-1]){
        allcurGenres += curGenre;
      }
      else{
        allcurGenres += '$curGenre, ';
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Book Detail"),
            if(currentUser.auth)...[
            Expanded(
              child: IconButton(
                onPressed: () async{
                  await _pickImage('Add');
                  widget.importImage.removeWhere((singImage)=>singImage!=widget.importImage[0]);
                  await _fetchDetailImage();
              }, icon: const Icon(Icons.add),),
            ),
            Expanded(
              child: IconButton(
                onPressed: () async{
                  await _pickImage('Edit');
                  widget.importImage.removeWhere((singImage)=>singImage!=widget.importImage[0]);
                  await _fetchDetailImage();
              }, icon: const Icon(Icons.edit),),
            ),
            Expanded(
              child: IconButton(
                onPressed: () async{
                    if (widget.currentIndex == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Cannot delete the cover image, try edit the book or delete the book and add new'),duration:  Duration(seconds: 3) ,));
                    } else {
                      await supabase.storage.from('images').remove([
                        '${widget.detailBook.book_id}.${widget.currentIndex}.jpg'
                      ]);
                      widget.importImage.removeWhere(
                          (singImage) => singImage != widget.importImage[0]);
                      setState(() {
                        widget.currentIndex=0;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Deleted successfully'),duration:  Duration(seconds: 3) ,));
                      await _fetchDetailImage();
                    }          
              }, icon: const Icon(Icons.delete)),
            )
          ],
          ]
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Row(
                  children: [
                    IconButton(onPressed: (){
                      if(widget.currentIndex>0){
                        setState(() {
                        widget.currentIndex--;
                      });
                      }
                    }, icon: const Icon(Icons.arrow_back_ios_new_sharp)),
                    ClipRect(
                      child: Container(
                      height: 270,
                      width: 180,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(widget.importImage[widget.currentIndex]), 
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      )
                    ),
                    IconButton(onPressed: (){
                      if(widget.currentIndex<widget.importImage.length-1){
                        setState(() {
                          widget.currentIndex++;
                      });
                      }
                    }, icon: const Icon(Icons.arrow_forward_ios_sharp))
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              Text(
                "Book Name: ${widget.detailBook.book_name}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20.0),
              Text(
                "Author Name: ${widget.detailBook.author_name}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15.0),
              Text(
                "Genres: $allcurGenres",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15.0),
              if(widget.detailBook.status==0)
              const Text(
                "Status: Unread",
                style: TextStyle(fontSize: 16),
              ),
              if (widget.detailBook.status==widget.detailBook.total_pages)
              const Text(
                "Status: Completed",
                style: TextStyle(fontSize: 16),
              ),
              if (widget.detailBook.status>0&&widget.detailBook.status<widget.detailBook.total_pages)
              Text('Status: ${(((widget.detailBook.status/widget.detailBook.total_pages))*100).round()}% Read'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async{
                      if (widget.detailBook.status == 0) {
                        widget.detailBook.status = 1;
                        await supabase.rpc('append_to_booklist', 
                        params: {
                          'id': currentUser.user_id,
                          'new_book': [{'book_id': widget.detailBook.book_id, 'status': widget.detailBook.status}]
                        });
                      }
                        else{
                          // await supabase.from('user_accounts').select('book_list->status').eq('book_list->book_id', widget.detailBook.book_id);
                          // widget.detailBook.status = 
                        }
                      setState(() {
                      });
                      final result = await Navigator.push<int>(context, MaterialPageRoute(builder: (context)=> PdfViewScreen(readbook: widget.detailBook)));
                      if(result!=null){
                        widget.detailBook.status=result;
                        setState(() {
                        });
                      }
                    },
                    icon: const Icon(Icons.book),
                    label: const Text("Read Book"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}