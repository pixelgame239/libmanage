import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:librarymanage/AdditionalScreen/profile.dart';
import 'package:librarymanage/Elements/bookgenres.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Loginsession/login_screen.dart';
import 'package:librarymanage/MainScreen/bookscreen.dart';
import 'package:librarymanage/MainScreen/screenElements.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:librarymanage/main.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:diacritic/diacritic.dart';

import '../Elements/themeData.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key?key}): super(key: key);
  // final VoidCallback changeTheme;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String content = '';
  int numbBooks=0;
  String screentype = 'Home';
  bool is_searching = false;
  bool show_genres = false;
  bool show_user = false;
  List<Books> listBooks = [];
  String filterGenre='Home';
  TextEditingController searchcontroller =TextEditingController();
  final GlobalKey<ScaffoldState> _mainscreenkey = GlobalKey<ScaffoldState>();
  @override
  void initState(){
    _fetchGenre();
    _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
    _initializeRealTime();
    super.initState();
  }
  Future<void> _signOut() async{
    try {
      await supabase.removeAllChannels();
      await supabase.auth.signOut();
      context.read<Genres>().resetGenres();
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected error')));
      }
    } finally {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }
  Future<void> _fetchGenre() async {
    final allGenres = await supabase.from('genres').select();
    for(var genre in allGenres){
      String single_genre = genre['genre_name'];
      context.read<Genres>().showAllGenres(single_genre);
    }
  }
//   Future<int> _fetchNumbBooks() async {
//     try{
//       final books_number = await supabase.from('books').select('book_id').count(CountOption.exact);
//       return books_number.count;
//     }
//   catch (error){
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
//     return 0;
//   }
// }
  Future<void> _fetchAllbooks(int numBooks, List<Books> displayBooks, String content, String fetchGenre) async {
    try{
      final PostgrestResponse<PostgrestList> allbooks;
      List<String> userbooks = [];
      Books temp_book;
      var userBookResponse;
      if (fetchGenre==''){
        userBookResponse = await supabase.from('user_accounts').select('book_list').eq('user_id', Provider.of<Users>(context,listen: false).user_id).single();
        if(userBookResponse['book_list'] !=null){
          for(var book in userBookResponse['book_list']){
          userbooks.add(book['book_id']);
        }
        }
        allbooks = await supabase.from('books').select().count();
      }
      else if(fetchGenre == 'Home'){
        userBookResponse = await supabase.from('user_accounts').select('book_list').eq('user_id', Provider.of<Users>(context,listen: false).user_id).single();
        if(userBookResponse['book_list'] !=null){
          for(var book in userBookResponse['book_list']){
          userbooks.add(book['book_id']);
        }
        }
        allbooks = await supabase.from('books').select().inFilter('book_id',userbooks).count();
      }
      else{
        userBookResponse = await supabase.from('user_accounts').select('book_list').eq('user_id', Provider.of<Users>(context,listen: false).user_id).single();
        if(userBookResponse['book_list'] !=null){
          for(var book in userBookResponse['book_list']){
          userbooks.add(book['book_id']);
        }
        }
        allbooks = await supabase.from('books').select('''book_id,book_names, author_name, total_pages, book_genres!inner(book_id, genre_name)''').eq('book_genres.genre_name)', fetchGenre).count();
      }
    listBooks.clear();
    for (var book in allbooks.data){
      if(removeDiacritics(book['book_names'].toString().toLowerCase()).contains(content.toLowerCase())||removeDiacritics(book['author_name'].toString().toLowerCase()).contains(content.toLowerCase())){
      var bookGenres=await supabase.from('book_genres').select('genre_name').eq('book_id', book['book_id']);
      List<String> addGenrescase1=[];
      for(var availableGenres in bookGenres){
        addGenrescase1.add(availableGenres['genre_name']);
      }
        if(userbooks.contains(book['book_id'])){
          for(var status in userBookResponse['book_list']){
            if(book['book_id']==status['book_id']){
              temp_book = Books(book['book_id'],book['book_names'], book['author_name'], status['status'], book['total_pages'], addGenrescase1);
              listBooks.add(temp_book);
               break;
            }
          }
        }
        else{
         temp_book = Books(book['book_id'],book['book_names'], book['author_name'], 0, book['total_pages'], addGenrescase1);
        listBooks.add(temp_book);
        }
      }
      else if(book['book_names'].toString().toLowerCase().contains(content.toLowerCase())||book['author_name'].toString().toLowerCase().contains(content.toLowerCase())){
        var bookGenres=await supabase.from('book_genres').select('genre_name').eq('book_id', book['book_id']);
        List<String> addGenrescase2=[];
        for(var availableGenres in bookGenres){
          addGenrescase2.add(availableGenres['genre_name']);
        }
          if(userbooks.contains(book['book_id'])){
             for(var status in userBookResponse['book_list']){
            if(book['book_id']==status['book_id']){
              temp_book = Books(book['book_id'],book['book_names'], book['author_name'], status['status'], book['total_pages'], addGenrescase2);
              listBooks.add(temp_book);
               break;
            }
          }
        }
        else{
          temp_book = Books(book['book_id'],book['book_names'], book['author_name'], 0, book['total_pages'], addGenrescase2);
          listBooks.add(temp_book);
        }
      }
  }
    numbBooks=listBooks.length;
    if (mounted){
      setState(() {
      });
    }
    }catch (error){
      if(mounted){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
}
  @override
  Widget build(BuildContext context) {
    final controlTheme = Provider.of<ThemeModel>(context);
    final currentUser = Provider.of<Users>(context);
    ThemeData currentTheme =Theme.of(context);
    return  Scaffold(
        key: _mainscreenkey,
        appBar: AppBar(
          leading: Builder(
            builder: (context){
              return  IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: (){
              _mainscreenkey.currentState?.openDrawer();
            },
            );
            }
            ),
          title: is_searching 
          ?TextField(
            controller: searchcontroller,
            autofocus: true,
            decoration: const InputDecoration(
              icon:  Icon(
                Icons.search
              ),
              hintText: 'Search by author or book name...',
              hintStyle: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)
            ),
            onChanged: (value) async{
              content= value;
              await _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
              // setState(() {
              // });
            },
            onEditingComplete: (){
               setState(() {
                is_searching = false;
              });
            },
            onTapOutside: (event) => setState(() {
              is_searching =false;
            })
          )
          : Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
              onPressed: (){
                setState(() {
                  is_searching = true;
                });
                },
                 icon: const Icon(Icons.search),
              ),
            ],
          )
        ),
        body: Bookscreen(screenType: screentype, numbBooks: numbBooks, listBooks: listBooks),
        drawer: Drawer(
          width: 250,
          backgroundColor: const Color.fromARGB(255, 21, 133, 238),
          child: ListView(
            children: [
              SizedBox(
                width: 300,
                height: 100,
                child: DrawerHeader(
                  margin: const EdgeInsets.fromLTRB(0,8,0,0),
                child: TextButton(
                  style: ButtonStyle(
                    fixedSize: WidgetStateProperty.all(const Size(300, 70))
                  ),
                  onPressed: (){
                    setState(() {
                      show_user = !show_user;
                    });
                  },
                  child: Row(
                  children: [
                     CircleAvatar(
                    child: Text(currentUser.auth ? 'Ad' : 'User'
                    )
                  ),
                  const Padding(padding: EdgeInsets.only(left: 5)),
                  Expanded(child: Text('\tHello ${currentUser.first_name} ${currentUser.last_name}', style: const TextStyle(color: Colors.black54),)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black54,)
                  ]
                    ),
                )
                )
                  ),
                   if (show_user)
                   Column(
                    children: [
                        Row(
                            children: [
                              const Padding(padding: EdgeInsets.only(left: 20)),
                              TextButton(
                                child: const Row(
                                  children: [
                                      Icon(Icons.person, color: Colors.black54,),
                                      Text('My Profile', style: TextStyle(color: Colors.black54),),
                                  ],
                                ),
                                onPressed:(){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>const ProfileScreen()));
                                } ,
                              ),
                              TextButton(onPressed: () async{
                                if (currentTheme.brightness == Brightness.dark) {
                                  controlTheme.toggleTheme();
                                }
                                await _signOut();
                              }, child: const Row(
                                  children: [
                                      Icon(Icons.logout, color: Colors.black54,),
                                      Text('Logout', style: TextStyle(color: Colors.black54),),
                                  ],
                                ),
                                )
                            ],
                          ),
                    ],
                   ),
                      
              ListTile(
                title: const Text('Home'),
                trailing: const Icon(Icons.home),
                shape: const Border(bottom: BorderSide(width: 1, color: Colors.black54),
                top:BorderSide(width: 1, color: Colors.black54) ),
                onTap: () async{
                  ScreenWidget.close_drawer(_mainscreenkey);
                  screentype = 'Home';
                  filterGenre = 'Home';
                  await _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
                  setState(() {
                    listBooks;
                    numbBooks;
                    filterGenre;
                    screentype;
                  });
                },
              ),
              ListTile(
                title: const Text('Discover'),
                shape: const Border(bottom: BorderSide(width: 1, color: Colors.black54)),
                trailing: const Icon(Icons.explore),
                onTap: () async {
                  ScreenWidget.close_drawer(_mainscreenkey);
                  await _fetchAllbooks(numbBooks, listBooks,content, '');
                  setState(() {
                    filterGenre='';
                    screentype = 'Discover';
                    numbBooks;
                    listBooks;
                  });
                },
              ),
              ListTile(
                title: show_genres
                ? Text('Genre',
                style: ScreenWidget().genre_style)
                :const Text('Genre'),
                shape: const Border(bottom: BorderSide(width: 1, color: Colors.black54)),
                trailing: const Icon(Icons.label),
                onTap: () {
                  setState(() {
                    show_genres = !show_genres;
                  });
                },
              ),
              if (show_genres)
              Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Consumer<Genres>(
                      builder: (context, genres, child) {
                        return ListBody(
                          children: [
                            for (var genre in genres.all_genres)
                              ListTile(
                                title: Text(genre),
                                shape: const Border(
                                    bottom: BorderSide(
                                        width: 1, color: Colors.black54)),
                                trailing: OverflowBox(
                                  maxWidth: 30,
                                  maxHeight: 50,
                                  fit: OverflowBoxFit.deferToChild,
                                  alignment: Alignment.centerRight,
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'Edit') {
                                        _showEditGenreDialog(
                                            context, genre);
                                      } else if (value == 'Delete') {
                                        _showDeleteConfirmation(
                                            context, genre);
                                      }
                                    },
                                    icon: const Icon(Icons.more_vert),
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem(
                                          value: 'Edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit),
                                              Text('Edit')
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'Delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete),
                                              Text('Delete')
                                            ],
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                                onTap: () async {
                                  ScreenWidget.close_drawer(_mainscreenkey);
                                  await _fetchAllbooks(
                                      numbBooks, listBooks, content, genre);
                                  setState(() {
                                    screentype = genre;
                                    filterGenre = genre;
                                    numbBooks;
                                    listBooks;
                                  });
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                if (currentUser.auth)
                ListTile(
                  title: const Text('Manage Library'),
                  trailing: const Icon(Icons.settings),
                  onTap: () async{
                    filterGenre='';
                    ScreenWidget.close_drawer(_mainscreenkey);
                    await _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
                    setState(() {
                      screentype='Manage';
                    });
                  },
                ),
            ],
          )
        ),
        floatingActionButton: SizedBox(
          width: 40,
          height: 40,
          child: FloatingActionButton(
          onPressed: (){
            controlTheme.toggleTheme();
          },
          child: const Icon(Icons.brightness_medium)
          ),
        )
      );
  }
    void _showEditGenreDialog(BuildContext context, String genre) {
    TextEditingController _editController = TextEditingController(text: genre);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Genre'),
          content: TextField(
            controller: _editController,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String updatedGenre = _editController.text;

                if (updatedGenre.isNotEmpty) {
                  // Cập nhật thể loại trong Supabase
                  await supabase
                      .from('genres')
                      .update({'genre_name': updatedGenre})
                      .eq('genre_name', genre);

                  // Cập nhật danh sách thể loại trong Provider (nếu cần)
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, String genre) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Genre'),
          content: const Text('Are you sure you want to delete this genre?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await supabase
                    .from('genres')
                    .delete()
                    .eq('genre_name', genre);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _initializeRealTime() {
    var genreProvider = Provider.of<Genres>(context,listen: false);
    supabase.channel('homescreen').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'genres',
      callback: (payload) {
        if (payload.eventType==PostgresChangeEvent.update) {
          genreProvider.updateGenre(payload.oldRecord['genre_name'], payload.newRecord['genre_name']);
        }
        else if(payload.eventType==PostgresChangeEvent.delete){
          genreProvider.deleteGenres(payload.oldRecord['genre_name']);
        }
        else{
          genreProvider.showAllGenres(payload.newRecord['genre_name']);
        }
        context.read<Genres>().resetGenres();
        _fetchGenre();
        _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
      }
    ).onPostgresChanges(
      event: PostgresChangeEvent.all, 
      schema: 'public',
      table: 'books',
      callback: (payload){
        if(payload.eventType!=PostgresChangeEvent.delete){
          _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
        }
      }
      ).onPostgresChanges(
        event: PostgresChangeEvent.all, 
        schema: 'public',
        table: 'user_accounts',
        callback: (payload){
          if(payload.newRecord['book_list']!=payload.oldRecord['book_list']){
            _fetchAllbooks(numbBooks, listBooks, content, filterGenre);
          }
        }
      ).subscribe();
  }
}
