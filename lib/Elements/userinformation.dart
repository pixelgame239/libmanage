import 'package:flutter/material.dart';

import 'booknames.dart';

class Users extends ChangeNotifier{
  String user_id;
  String username;
  bool auth;
  String first_name;
  String last_name;
  List<Books> user_books;
  Users(this.user_id, this.username, this.auth, this.user_books, this.first_name, this.last_name);
  void changeAll(Users newUsers){
    newUsers;
    notifyListeners();
  }
  void changeUserInfor(String new_user_id, String newusername, bool newauth, String newfirst_name, String newlast_name){
  user_id = new_user_id;
  username = newusername;
  auth = newauth;
  first_name = newfirst_name;
  last_name = newlast_name;
  notifyListeners();
}
}
