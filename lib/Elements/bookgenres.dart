import 'package:flutter/material.dart';

class Genres extends ChangeNotifier{
  List<String> all_genres;
  String genre_name;
  Genres(this.all_genres, this.genre_name);
  void deleteGenres(String deleteGenres){
    all_genres.remove(deleteGenres);
    notifyListeners();
  }
  void showAllGenres(String newgenrename){
    all_genres.add(newgenrename);
    notifyListeners();
  }
  void resetGenres(){
    all_genres.clear();
    notifyListeners();
  }
void updateGenre(String oldGenre, String newGgenre){
  all_genres[all_genres.indexOf(oldGenre)]=newGgenre;
  notifyListeners();
}
}
