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
    url: 'https://vcuvreljcgozbmtwvmyk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZjdXZyZWxqY2dvemJtdHd2bXlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzE3NzI0MzYsImV4cCI6MjA0NzM0ODQzNn0.xzIuopozExTOu-ZrY43DhlSTz3rsOCmSm8JrtKa8TjI',
  );
  runApp(ChangeNotifierProvider(create: (context)=>ThemeModel(),
  child: const MainApp(),) 
  );
}
final supabase = Supabase.instance.client;
