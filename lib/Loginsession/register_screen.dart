import 'package:flutter/material.dart';
import 'package:librarymanage/Loginsession/createUserFunc.dart';
import 'package:librarymanage/main.dart';
import 'login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'otp_input_screen.dart';

class RegisterScreen extends StatefulWidget {
    const RegisterScreen({Key?key}): super(key: key);
    // final VoidCallback changeTheme;
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController confirmPasswordController =TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signUp() async{
    try{
        final res = await supabase.auth.signUp(
          email: emailController.text,
          password: confirmPasswordController.text,
          data: {
            'user_id': await genUserID(),
            'email': emailController.text,
            'first_name': firstnameController.text,
            'last_name': lastnameController.text,
            'password': confirmPasswordController.text,
          }
          );
          if(res.user != null && res.session == null){
            setState(() {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP code has been sent to your email')));
            });
            Navigator.push(context, 
            MaterialPageRoute(builder: (context)=> OTPInputScreen(contextType: 'register', emailDes: emailController.text)));
          }
    } on AuthException catch (error){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
    catch (error){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unexpected error!')));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(219, 200, 252, 236),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Ảnh đại diện
                Container(
                  height: 150,
                  width: 150,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/useravatar.png'),
                      // Đường dẫn ảnh
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegEx = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegEx.hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.black38),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // First Name
                TextFormField(
                  controller: firstnameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'First Name',
                    labelStyle: TextStyle(color: Colors.black38),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Last Name
                TextFormField(
                  controller: lastnameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    labelStyle: TextStyle(color: Colors.black38),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.black38),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Confirm Password
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: const TextStyle(color: Colors.black38),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueAccent),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Nút đăng ký
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                  child: const SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Center(
                      child: Text(
                        "REGISTER",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _signUp();
                    }
                  },
                ),
                // Đã có tài khoản? Chuyển sang Login
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ALREADY HAVE AN ACCOUNT?",
                      style: TextStyle(fontSize: 12, color: Color(0xff888888)),
                    ),
                    TextButton(
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
