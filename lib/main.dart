import 'package:flutter/material.dart';
import 'package:librarymanage/Elements/themeData.dart';
import 'package:librarymanage/Loginsession/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// void main() {
//   runApp(const MainApp());
// }


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'SUPABASE-URL',
    anonKey: 'SUPABASE-ANON-KEY',
  );
  runApp(ChangeNotifierProvider(create: (context)=>ThemeModel(),
  child: const MainApp(),) 
  );
}
final supabase = Supabase.instance.client;
