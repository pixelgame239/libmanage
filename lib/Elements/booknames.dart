import 'package:flutter/material.dart';

class Books extends ChangeNotifier{
  String book_id;
  String book_name;
  String author_name;
  int total_pages;
  int status; 
  List<String> genres;
  Books(this.book_id,this.book_name, this.author_name, this.status, this.total_pages, this.genres);
  void changeStatus(int currentStatus){
    status = currentStatus;
    notifyListeners();
  }
}