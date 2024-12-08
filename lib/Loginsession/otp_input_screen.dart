import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:librarymanage/main.dart';
import 'package:librarymanage/Loginsession/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPInputScreen extends StatefulWidget {
  final String contextType;
  final String emailDes; // "register" or "forgotPassword"

  const OTPInputScreen({super.key, required this.contextType, required this.emailDes});
  // final VoidCallback changeTheme;

  @override
  _OTPInputScreenState createState() => _OTPInputScreenState();
}

class _OTPInputScreenState extends State<OTPInputScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? newPasswordError;
  String? confirmPasswordError;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String getOTPString() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  Future<void> _otpSignup() async {
    try {
      final res = await supabase.auth.verifyOTP(
          type: OtpType.signup, email: widget.emailDes, token: getOTPString());
      if (res.user != null){
        try{
          await supabase.rpc('gen_new_user');
          // await supabase.rpc('handle_new_user', params: {'id':'', 'email': res.user!.email, 'raw_user_meta_data': res.user!.userMetadata});
        } catch (error){
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected Error: $error')),
          );
        }
      }
    } on AuthException catch (error) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected Error: $error')),
      );
    }
  }
  Future<void> _otpForgot() async{
    try{
      final res = await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: widget.emailDes,
        token: getOTPString()
        );
        if (res.user==null){
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP verification failed')),);
           Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
          return;
        }
        else{
          _showChangePasswordDialog(context);
        }
    } on AuthException catch (error){
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected Error')),
      );
    }
  }
  Future<void> _updatePass() async{
    try{
    final update_res = await supabase.auth.updateUser(UserAttributes(password: confirmPasswordController.text));
        if (update_res.user != null){
          ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password Reset Successfully')),);
          Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()));
        }
    }
    on AuthException catch (error){
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginPage()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.contextType == "register" ? "Verify Your Account" : "Enter OTP";
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 252, 236),
      ),
      backgroundColor: const Color.fromARGB(255, 200, 252, 236),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 250,
                width: 250,
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/otp_logo.png'),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 35,
                    height: 50,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      onChanged: (value) {
                        if (value.length == 1 &&
                            RegExp(r'^[0-9]$').hasMatch(value)) {
                          if (index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
                onPressed: () async {
                  if (getOTPString().length == 6) {
                    if (widget.contextType == "register") {
                      _otpSignup();
                    } else if (widget.contextType == "forgotPassword") {
                      _otpForgot();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text("Please enter a valid 6-digit OTP code.")),
                    );
                  }
                },
                child: const SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Center(
                    child: Text(
                      "VERIFY OTP",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Enter New Password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "New Password",
                        errorText: newPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          newPasswordError =
                              null; 
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: !isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        errorText: confirmPasswordError,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                      onChanged: (_) {
                        setState(() {
                          confirmPasswordError =
                              null; 
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child:
                      const Text("Cancel", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () async{
                    validateNewPassword(setState);
                  },
                  child: const Text("Submit",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void validateNewPassword(void Function(VoidCallback) setState) {
    setState(() {
      newPasswordError = null;
      confirmPasswordError = null;

      final newPassword = newPasswordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

      // Kiểm tra mật khẩu mới
      if (newPassword.isEmpty) {
        newPasswordError = 'Please enter your new password';
      } else if (newPassword.length < 6) {
        newPasswordError = 'Password must be at least 6 characters long';
      }

      // Kiểm tra mật khẩu xác nhận
      if (confirmPassword.isEmpty) {
        confirmPasswordError = 'Please confirm your password';
      } else if (newPassword != confirmPassword) {
        confirmPasswordError = 'Passwords do not match';
      }

      // Nếu không có lỗi
      if (newPasswordError == null && confirmPasswordError == null) {
        _updatePass();
      }
    });
  }
}
