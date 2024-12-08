import 'package:flutter/material.dart';
import 'package:librarymanage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ScreenWidget {
  TextStyle titlestyle = const TextStyle(
      fontSize: 29,
      fontWeight: FontWeight.w900,
    );
  TextStyle genre_style = const TextStyle(color: Color.fromARGB(255, 188, 217, 0));
  static void close_drawer(GlobalKey<ScaffoldState> _mainscreenkey){
      _mainscreenkey.currentState?.closeDrawer();
  }
}
Future<String> genBookID() async {
    try{
        final count_response = await supabase.from('count_user').select().single();
        if (count_response['gen_book'] <10){
          return 'b00${count_response['gen_book']}';
        }
        else if (count_response['gen_book'] >=10 && count_response['gen_book'] <100){
          return 'b0${count_response['gen_book']}';
        }
        else {
          return 'b${count_response['gen_book']}';
        }
    }
    on PostgrestException catch (error){
        return error.message;
      }
      catch (error){
        return error.toString();
      }
  }

