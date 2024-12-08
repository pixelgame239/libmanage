import 'package:flutter/material.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:librarymanage/MainScreen/pdf_screen.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';

class Detailbook extends StatefulWidget {
  final Books detailBook;
  final String importImage;

  const Detailbook({super.key, required this.detailBook, required this.importImage});
  

  @override
  State<Detailbook> createState() => _DetailbookState();
}

class _DetailbookState extends State<Detailbook> {
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
        title: const Text("Book Detail"),
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