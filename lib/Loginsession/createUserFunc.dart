import 'package:librarymanage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<String> genUserID() async {
    try{
        final count_response = await supabase.from('count_user').select().single();
        if (count_response['gen_user'] <10){
          return 'u0000${count_response['gen_user']}';
        }
        else if (count_response['gen_user'] >=10 && count_response['gen_user'] <100){
          return 'u000${count_response['gen_user']}';
        }
        else if (count_response['gen_user']>=100 && count_response['gen_user'] <1000){
          return 'u00${count_response['gen_user']}';
        }
        else if (count_response['gen_user'] >=1000 && count_response['gen_user'] < 10000){
          return 'u0${count_response['gen_user']}';
        }
        else{
          return 'u${count_response['gen_user']}';
        }
    }
    on PostgrestException catch (error){
        return error.message;
      }
      catch (error){
        return error.toString();
      }
  }
