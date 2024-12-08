import 'package:flutter/material.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:librarymanage/MainScreen/AddBookScreen.dart';
import 'package:librarymanage/MainScreen/EditBook.dart';
import 'package:librarymanage/MainScreen/detailbook_screen.dart';
// import 'package:librarymanage/MainScreen/pdf_screen.dart';
import 'package:librarymanage/MainScreen/screenElements.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart';


class Bookscreen extends StatefulWidget {
  final String screenType; 
  int numbBooks;
  final List<Books> listBooks;

  Bookscreen({Key? key, required this.screenType, required this.numbBooks, required this.listBooks}) : super(key: key);

  @override
  State<Bookscreen> createState() => _BookscreenState();
}

class _BookscreenState extends State<Bookscreen> {
  //   @override
  // void initState() {
  //   super.initState();
  // }
   Future<void> _fetchAllbooks() async {
    try{
      final PostgrestResponse<PostgrestList> allbooks;
      List<String> userbooks = [];
      Books temp_book;
      var userBookResponse;
        userBookResponse = await supabase.from('user_accounts').select('book_list').eq('user_id', Provider.of<Users>(context,listen: false).user_id).single();
        if(userBookResponse['book_list'] !=null){
          for(var book in userBookResponse['book_list']){
          userbooks.add(book['book_id']);
        }
        }
        allbooks = await supabase.from('books').select().count();
        widget.listBooks.clear();
    for (var book in allbooks.data){
      var bookGenres=await supabase.from('book_genres').select('genre_name').eq('book_id', book['book_id']);
      List<String> addGenrescase1=[];
      for(var availableGenres in bookGenres){
        addGenrescase1.add(availableGenres['genre_name']);
      }
        if(userbooks.contains(book['book_id'])){
          for(var status in userBookResponse['book_list']){
            if(book['book_id']==status['book_id']){
              temp_book = Books(book['book_id'],book['book_names'], book['author_name'], status['status'], book['total_pages'], addGenrescase1);
              widget.listBooks.add(temp_book);
               break;
            }
          }
        }
        else{
         temp_book = Books(book['book_id'],book['book_names'], book['author_name'], 0, book['total_pages'], addGenrescase1);
        widget.listBooks.add(temp_book);
        }
      }
      widget.numbBooks = widget.listBooks.length;
       if (mounted){
      setState(() {
      });
    }
    } catch (error) {
        if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
    }

  String _importImage(String book_id) {
    try{
      final imgResponse = supabase.storage.from('images').getPublicUrl('$book_id.jpg');
      String timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      return '$imgResponse?v=$timeStamp';
    } catch(error){
      return error.toString();
    }
    // final imgLoad = await http.get(Uri.parse(img_url));
    // if (imgLoad.statusCode==200){
    //   return imgLoad.bodyBytes;
    // }
    // else{
    //   throw Exception('Unexpected Error');
    // }
  }

  @override
  Widget build(BuildContext context) {
    var displayBooks = widget.listBooks;
    return Scaffold(
      body: Column(
        children: [
          // Trường hợp màn hình Home
          if (widget.screenType == "Home") ...[
            Container(
              padding: const EdgeInsets.all(0),
              child: const Text(
                'Home',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                clipBehavior: Clip.hardEdge,
                child: AspectRatio(
                  aspectRatio: 23 / 9,
                  child: Container(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Dòng chấm tròn
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Row(
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 3),
                  ],
                );
              }),
            ),
            if(widget.numbBooks==0)
              const Center(child: Text('No book found! Try adding new book'),)
          ],

          // Trường hợp màn hình Manage Library
          if (widget.screenType == "Manage") ...[
            Text('Manage', style: ScreenWidget().titlestyle),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                  color: Color.fromARGB(255, 3, 122, 218),
                ),
                width: double.infinity,
                height: 40,
                child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController genrecontroller =TextEditingController();
                          return AlertDialog(
                            title: const Text('Add new genre'),
                            content: TextField(
                              controller: genrecontroller,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () async{
                                  String newgenre  = genrecontroller.text;
                                  if (newgenre.isNotEmpty) {
                                    // Cập nhật thể loại trong Supabase
                                    await supabase.from('genres')
                                        .insert({'genre_name': newgenre});
                                  }
                                  // Perform the deletion logic here
                                  // For example, remove the book from the list or database

                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: const Text(
                                  'Add',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Close the dialog without deleting
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                        style: TextStyle(color: Colors.white),
                        '+ Add new genre')),
              ),
            ),
            // Using GridView.builder to display books in cards
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns in the grid
                  crossAxisSpacing: 5, // Space between columns
                  mainAxisSpacing: 0, // Space between rows
                  childAspectRatio: 0.45, // Aspect ratio of each item (Card)
                ),
                itemCount: widget.numbBooks + 1, // Number of books to display
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildAddBookCard();
                  } else {
                    Books temp_book = displayBooks[index-1]; // Fetch current book
                    return _buildBookCard(temp_book, widget.screenType);
                  } // Use the card builder for each book
                },
              ),
            ),
          ],

          // Trường hợp màn Discover và Genre
          if (widget.screenType != "Home" && widget.screenType != "Manage") ...[
            Text(widget.screenType, style: ScreenWidget().titlestyle),
            if(widget.numbBooks==0)...[
              const Center(child: Text('No book found!'),)
            ],
            Expanded(
              child: GridView.builder (
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.45,
                ),
                itemCount: widget.numbBooks,
                itemBuilder: (context, index) {
                  Books temp_book = displayBooks[index];
                  return _buildBookCard(temp_book, widget.screenType);
                },
              ),
            ),
          ],

          // GridView of books cho màn Home
          if (widget.screenType == "Home")
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: widget.numbBooks,
                itemBuilder: (context, index) {
                  Books temp_book = displayBooks[index];
                  return _buildBookCard(temp_book, widget.screenType);
                },
              ),
            ),
        ],
      ),
    );
  }
   Widget _buildAddBookCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async {
          final newBook = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookScreen()),
          );

          if (newBook != null) {
            // Handle the newly added book here
          }
        },
        child: Card(
          elevation: 3, // Add shadow effect to the card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: const Color.fromARGB(255, 3, 122, 218),
                  // Placeholder color for the "Add New Book" card
                  child: const Center(
                    child: Icon(
                      Icons.add, // Add icon
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget card sách
  Widget _buildBookCard(Books curBook, String screenType) {
    String allcurGenres ='';
    for (String curGenre in curBook.genres){
      allcurGenres +=  ' $curGenre';
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () async{
          String image_url = _importImage(curBook.book_id);
          Navigator.push(context, MaterialPageRoute(builder: (context)=> Detailbook(detailBook: curBook, importImage: image_url,)));
        },
        child: Card(
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  color: Colors.grey[300],
                  child:  Center(child: 
                  Image.network(_importImage(curBook.book_id), errorBuilder: (context, error, stackTrace) => const Text('Error fetching image'),)
                  // FutureBuilder(future: _importImage(curBook.book_id), 
                  // builder: (context, snapshot){
                  //       if (snapshot.connectionState == ConnectionState.waiting) {
                  //         return const CircularProgressIndicator();
                  //       } else if (snapshot.hasError) {
                  //         return Text('Error: ${snapshot.error}');
                  //       } else if (snapshot.hasData) {
                  //         return Image.network(snapshot.data!);  
                  //       } else {
                  //         return const Text('No image found');
                  //       }
                  // }) 
                  ),
                ),
              ),
               Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  curBook.book_name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text(
                  'Genres: $allcurGenres',
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Text('Author:  ${curBook.author_name}'),
              ),
              if (screenType == 'Manage') ...[
                // Row for Edit and Delete buttons
                Padding(
                  padding: const EdgeInsets.all(0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          String image_url = await _importImage(curBook.book_id);
                           final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditBook(
                                        detailBook: curBook,
                                        importImage: image_url,
                                      )));
                            if(result!=null){
                              setState(() {
                              });
                            }
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Delete Book Dialog'),
                                content: const Text(
                                    'Are you sure you want to delete this book?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () async{
                                      await supabase.rpc('remove_from_all_users_booklist', params: {'book_id':curBook.book_id});
                                      await supabase.from('books').delete().eq('book_id', curBook.book_id);
                                      await supabase.storage.from('pdf').remove(['${curBook.book_id}.pdf']);
                                      await supabase.storage.from('images').remove(['${curBook.book_id}.jpg']);
                                      await _fetchAllbooks();
                                      // Perform the deletion logic here
                                      // For example, remove the book from the list or database

                                      Navigator.of(context).pop(); // Close the dialog
                                    },
                                    child: const Text(
                                      'Yes, delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog without deleting
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}