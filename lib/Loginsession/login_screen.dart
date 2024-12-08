import 'dart:async';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:librarymanage/Elements/booknames.dart';
import 'package:librarymanage/Elements/themeData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:librarymanage/Elements/bookgenres.dart';
import 'package:librarymanage/Loginsession/forgot_password_screen.dart';
import 'package:librarymanage/main.dart';
import 'package:librarymanage/Loginsession/register_screen.dart';
import 'package:librarymanage/MainScreen/userScreen.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:provider/provider.dart';
import 'createUserFunc.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // ThemeData _currentTheme = ThemeData.light();
  // void _changeTheme(){
  //   setState(() {
  //     if(_currentTheme==ThemeData.dark()){
  //       _currentTheme = ThemeData.light();
  //     }
  //     else{
  //       _currentTheme = ThemeData.dark();
  //     }
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    final theme_mode = Provider.of<ThemeModel>(context).themeMode;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Users('user_id', 'username', false, [], 'first_name', 'last_name')),
        ChangeNotifierProvider(create: (context) => Genres([],'')),
        ChangeNotifierProvider(create: (context) => Books('book_id','book_name', 'author_name', 0, 0,[])),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const LoginPage(),
          themeMode: theme_mode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
        ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key?key}): super(key: key);
  // final VoidCallback changeTheme;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool pwstate = true;
  final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  TextEditingController _userController = TextEditingController();
  TextEditingController _passController = TextEditingController();
  var _userNameErr = "Invalid email";
  var _passErr = "Password must be 6 characters at least";
  var _userInvalid = false;
  var _passInvalid = false;
  bool is_loading = false;

@override
  void initState() {
    _setupAuthListener(false);
    super.initState();
  }
  void _setupAuthListener(bool loginMethod) async {
    String ggUserID = await genUserID();
    supabase.auth.onAuthStateChange.listen(
      (data) async {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn) {
          if (await supabase.auth.currentUser!.appMetadata['provider']=='google'){
            loginMethod=true;
          }
          if (loginMethod == true) {
            final ggUser = supabase.auth.currentUser!;
              final checkResponse = await supabase
                  .from('user_accounts')
                  .select()
                  .eq('username', '${ggUser.email}')
                  .count();
              if (checkResponse.count == 0) {
              // await supabase.auth.updateUser(UserAttributes(data: {'user_id': ggUserID}));
              // final updatedggUSer = supabase.auth.currentUser;
              // final finalggUser = supabase.auth.currentUser!;
              // print('user_id: ${updatedggUSer?.userMetadata!['user_id']}');
                if(mounted){
                await supabase.rpc('gen_new_user');
                await supabase.rpc(await supabase.rpc('handle_new_user', params: {
                  'id': ggUserID,
                  'email': ggUser.email,
                  'raw_user_meta_data': ggUser.userMetadata
                    }));
                loginMethod = false;
                    await _fetchUserInfor();
                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                }
              } else {
                if(mounted){
                    loginMethod=false;
                    await _fetchUserInfor();
                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                }
              }
          } else {
                if(mounted){
                    await _fetchUserInfor();
                      Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                }
          }
        }
      },
    );
  }
  Future<void> _fetchUserInfor() async{
      if(supabase.auth.currentUser == null){
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User is not signed in")));
        return;
      }
      final userName = supabase.auth.currentUser!.email;
      final user_response = await supabase.from('user_accounts').select().eq('username', '$userName').single();
      setState(() {
        is_loading = true;
      });
      if(is_loading){
        await Future.delayed(const Duration(seconds: 1));
      }
      try{
        if(mounted){
            context.read<Users>().changeUserInfor(user_response['user_id'], user_response['username'], user_response['is_admin'], user_response['first_name'], user_response['last_name']);
            setState(() {
              is_loading = false;
            });
        }
      } on PostgrestException catch (error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching: $error")));
      }
      catch (error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching: $error")));
      }
  }
  Future<void> _googleSignIn() async {
   await supabase.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo:'io.supabase.flutterquickstart://login-callback/',
    authScreenLaunchMode: LaunchMode.platformDefault
  );
}

//   Future<void> _googleSignIn() async {
//   final googleSignIn = GoogleSignIn();
//   try {
//     final googleUser = await googleSignIn.signIn();
//     if (googleUser == null) {
//       throw Exception('Google sign-in failed.');
//     }
//     final googleAuth = await googleUser.authentication;
//     final accessToken = googleAuth.accessToken;
//     final idToken = googleAuth.idToken;

//     if (accessToken == null) {
//       throw Exception('No access token found.');
//     }

//     if (idToken == null) {
//       throw Exception('No ID token found.');
//     }
//     if(idToken!= null){
//       setState(() {
//         is_loading = false;
//       });
//     }
//     await supabase.auth.signInWithIdToken(
//       provider: OAuthProvider.google,
//       idToken: idToken,
//       accessToken: accessToken,
//     );
//   } catch (error) {
//     print(error); // Log the error
//     throw error; // Rethrow for proper handling
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(219, 200, 252, 236),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 0, 15 , 0),
            color: const Color.fromARGB(219, 200, 252, 236),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 100)
                  ),
                   if(is_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(15),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/useravatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 30),
                  child: Text(
                    "\t\tHello!!!",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: TextField(
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: "EMAIL",
                      errorText: _userInvalid ? _userNameErr : null,
                      labelStyle: const TextStyle(color: Color(0xff888888), fontSize: 15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: <Widget>[
                      TextField(
                        style: const TextStyle(fontSize: 14, color: Colors.black),
                        controller: _passController,
                        obscureText: pwstate,
                        decoration: InputDecoration(
                          labelText: "PASSWORD",
                          errorText: _passInvalid ? _passErr : null,
                          labelStyle: const TextStyle(color: Color(0xff888888), fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          pwstate ? Icons.visibility_off : Icons.visibility,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            pwstate = !pwstate;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0,15),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onPressed: onSignInClicked,
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: ElevatedButton(
                    onPressed: () async{
                        // await _googleSignIn();
                        await _googleSignIn();
                      //await supabase.auth.signInWithOAuth(OAuthProvider.google);
                      // if (!kIsWeb&& Platform.isAndroid){
                      //   try{
                      //     final authResponse = await _googleSignIn();
                      //     if (authResponse.user !=null){
                      //       Navigator.pushReplacement(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (context) => HomeScreen(changeTheme: widget.changeTheme),
                      //         ),
                      //       );
                      //     }
                      //   } catch (error){
                      //     print("Error during Google sign-in: $error");
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text('Google Sign-In failed')),
                      //     );
                      //   }
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/google_logo.jpg', // Logo Google trong thư mục assets
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          "Continue with Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(children: [
                        const Text(
                          "NEW USER?",
                          style: TextStyle(fontSize: 12, color: Color(0xff888888)),
                        ),
                        TextButton(
                          child: const Text(
                            " REGISTER",
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                          },
                        ),
                      ]),
                      TextButton(
                        child: const Text(
                          " FORGOT PASSWORD",
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
Future<void> onSignInClicked() async {
  // Perform validation before calling setState
  _userInvalid = !emailRegEx.hasMatch(_userController.text);
  _passInvalid = _passController.text.length < 6;

  // Call setState only to update the UI based on validation
  setState(() {});

  if (!_userInvalid && !_passInvalid) {
    try {
      await supabase.auth.signInWithPassword(
        email: _userController.text,
        password: _passController.text
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logging in...'), duration: Duration(seconds: 1),));
        _userController.clear();
      }
    } on AuthException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected error occurred')));
      }
    }
    // try {
    //   // Perform the sign-in operation outside of setState
    //   final AuthResponse register_res = await supabase.auth.signInWithPassword(
    //     password: _passController.text,
    //     email: _userController.text,
    //   );

    //   // After the async operation completes, navigate to HomeScreen
    //   Navigator.push(
    //     context, 
    //     MaterialPageRoute(builder: (context) => HomeScreen(changeTheme: widget.changeTheme))
    //   );
    // } catch (e) {
    //   // Handle any potential errors here
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error during sign in: $e')));
    // }
  }
}
// Future<AuthResponse> _googleSignIn() async {
//   final googleSignIn = GoogleSignIn();
//   try {
//     final googleUser = await googleSignIn.signIn();
//     if (googleUser == null) {
//       throw Exception('Google sign-in failed.');
//     }

//     final googleAuth = await googleUser.authentication;
//     final accessToken = googleAuth.accessToken;
//     final idToken = googleAuth.idToken;

//     if (accessToken == null) {
//       throw Exception('No access token found.');
//     }

//     if (idToken == null) {
//       throw Exception('No ID token found.');
//     }

//     final response = await supabase.auth.signInWithIdToken(
//       provider: OAuthProvider.google,
//       idToken: idToken,
//       accessToken: accessToken,
//     );

//     return response;
//   } catch (error) {
//     print(error); // Log the error for debugging
//     throw error; // Rethrow the error for proper handling
//   }
// }
}