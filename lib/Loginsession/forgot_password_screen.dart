// import 'package:flutter/material.dart';
// import 'package:librarymanage/Loginsession/login_screen.dart';

// class ForgotPasswordScreen extends StatefulWidget {
//   @override
//   _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
// }

// class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
//   final TextEditingController emailController = TextEditingController();
//   final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
//   final TextEditingController newPasswordController = TextEditingController();
//   final TextEditingController confirmPasswordController = TextEditingController();

//   String? emailError;
//   String? newPasswordError;
//   String? confirmPasswordError;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 200, 252, 236),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             TextField(
//               style: const TextStyle(color: Colors.black),
//               controller: emailController,
//               decoration: InputDecoration(
//                 labelText: 'Enter your email',
//                 labelStyle: const TextStyle(color: Colors.black38),
//                 errorText: emailError,
//               ),
//               onChanged: (value) {
//                 setState(() {
//                   emailError = null; // Clear error when typing
//                 });
//               },
//             ),
//             const SizedBox(height: 10),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
//               ),
//               onPressed: () {
//                 setState(() {
//                   if (emailController.text.isEmpty) {
//                     emailError = "Please enter your email";
//                   } else if (!emailController.text.contains('@')) {
//                     emailError = "Please enter a valid email";
//                   } else {
//                     emailError = null;
//                     showVerificationDialog(context);
//                   }
//                 });
//               },
//               child: const SizedBox(
//                 width: double.infinity,
//                 height: 56,
//                 child: Center(
//                   child: Text(
//                     "SEND CODE",
//                     style: TextStyle(color: Colors.white, fontSize: 12),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Cancel", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void showVerificationDialog(BuildContext context) {
//     showDialog(
//       traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text("Enter OTP Code"),
//           content: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: List.generate(6, (index) {
//               return _buildOtpTextField(index);
//             }),
//           ),
//           actions: [
//             Row(
//               children: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop(); // Close the dialog
//                   },
//                   child: const Text("Cancel", style: TextStyle(color: Colors.red)),
//                 ),
//                  ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//               onPressed: () {
//                 String code = '';
//                 for (int i = 0; i < 6; i++) {
//                   code += _otpControllers[i].text;
//                 }
//                 if (code.length == 6) {
//                   showNewPasswordDialog(context);
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text("Please enter a valid code")),
//                   );
//                 }
//               },
//               child: const Text("Verify Code", style: TextStyle(color: Colors.white)),
//             ),
//               ],
//             ),
//           ],
//         );
//       },
//     );
//   }


//   Widget _buildOtpTextField(int index) {
//     return SizedBox(
//       width: 40, // Độ rộng của mỗi ô OTP
//       height: 45, // Chiều cao của ô OTP
//       child: TextField(
//         controller: _otpControllers[index],
//         keyboardType: TextInputType.number,
//         maxLength: 1,
//         textAlign: TextAlign.center, // Căn giữa nội dung
//         decoration: InputDecoration(
//           counterText:  '',
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8), // Bo tròn góc
//             borderSide: const BorderSide(color: Colors.grey),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.blue),
//           ),
//           filled: true,
//           fillColor: Colors.white, // Màu nền của ô
//         ),
//         style: const TextStyle( // Tăng kích thước chữ để phù hợp với ô
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//           fontSize: 14 // Làm chữ đậm
//         ),
//         onChanged: (value) {
//           if (value.length == 1 && RegExp(r'^[0-9]$').hasMatch(value)) {
//             if (index < 3) {
//               FocusScope.of(context).nearestScope.nextFocus(); // Chuyển đến ô tiếp theo
//             }
//           } else if (value.isEmpty) {
//             if (index > 0) {
//               FocusScope.of(context).previousFocus(); // Quay lại ô trước
//             }
//           } else {
//             _otpControllers[index].clear(); // Xóa ký tự không hợp lệ
//           }
//         },
//       ),
//     );
//   }



//   void showNewPasswordDialog(BuildContext context) {
//     showDialog(
//       context: context, builder: (BuildContext context) {
//         bool isPasswordVisible = false;
//         bool isConfirmPasswordVisible = false;

//         return StatefulBuilder(
//           builder: (BuildContext context, StateSetter setState) {
//             return AlertDialog(
//               title: const Text("Enter New Password"),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     TextField(
//                       controller: newPasswordController,
//                       obscureText: !isPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'New Password',
//                         labelStyle: const TextStyle(color: Colors.black38),
//                         errorText: newPasswordError,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                             color: Colors.blueAccent,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               isPasswordVisible = !isPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           newPasswordError = null;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 10),
//                     TextField(
//                       controller: confirmPasswordController,
//                       obscureText: !isConfirmPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'Confirm New Password',
//                         labelStyle: const TextStyle(color: Colors.black38),
//                         errorText: confirmPasswordError,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                             color: Colors.blueAccent,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               isConfirmPasswordVisible = !isConfirmPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                       onChanged: (value) {
//                         setState(() {
//                           confirmPasswordError = null;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: const Text("Cancel", style: TextStyle(color: Colors.red)),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                   onPressed: () {
//                     setState(() {
//                       if (newPasswordController.text.isEmpty) {
//                         newPasswordError = "Please enter a new password";
//                       } else if (confirmPasswordController.text.isEmpty) {
//                         confirmPasswordError = "Please confirm your password";
//                       } else if (newPasswordController.text != confirmPasswordController.text) {
//                         confirmPasswordError = "Passwords do not match";
//                       } else if (newPasswordController.text.length < 6) {
//                         newPasswordError = 'Password must be at least 6 characters long';
//                       } else {
//                         newPasswordError = null;
//                         confirmPasswordError = null;
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Password has been changed successfully"),
//                             duration: Duration(seconds: 1),
//                           ),
//                         );
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (context) => const LoginPage()),
//                         );
//                       }
//                     });
//                   },
//                   child: const Text("Submit", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:librarymanage/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'otp_input_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key?key}): super(key: key);
  // final VoidCallback changeTheme;
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? emailError;
  String? newPasswordError;
  String? confirmPasswordError;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

    Future<void> _sendEmail(String email) async {
    try{
       await supabase.auth.resetPasswordForEmail(email);
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP code for reset password has been sent')),);
    } on AuthException catch (error){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),);
    }
    catch (error){
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unexpected Error')),);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 252, 236)
      ),
      backgroundColor: const Color.fromARGB(255, 200, 252, 236),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 200,
                width : 200,
                decoration: const BoxDecoration(
                  shape: BoxShape. circle,
                  image: DecorationImage(
                    image: AssetImage('assets/reset_pass.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 60)),
              TextField(
                style: const TextStyle(color: Colors.black),
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email',
                  labelStyle: const TextStyle(color: Colors.black38),
                  errorText: emailError,
                ),
                onChanged: (value) {
                  setState(() {
                    emailError = null; 
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                onPressed: () async{
                  if (!emailController.text.contains('@')) {
                    setState(() {
                      emailError = 'Enter a valid email address';
                    });
                    return;
                  }
                  else{
                    _sendEmail(emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP sent to your email!')),
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          OTPInputScreen(contextType: "forgotPassword", emailDes: emailController.text),
                    ),
                  );
                  }
                },
                child: const SizedBox(
                  width: 300,
                  height: 50,
                  child: Center(
                    child: Text(
                      "SEND CODE",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
        // AlertDialog(
        //   title: const Text("Enter OTP Code"),
        //   content: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: List.generate(6, (index) {
        //       return SizedBox(
        //         width: 35, // Độ rộng của mỗi ô OTP
        //         height: 50, // Chiều cao của ô OTP
        //         child: TextField(
        //           controller: _otpControllers[index],
        //           keyboardType: TextInputType.number,
        //           maxLength: 1,
        //           textAlign: TextAlign.center, // Căn giữa nội dung
        //           decoration: InputDecoration(
        //             counterText: '',
        //             border: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(8), // Bo tròn góc
        //               borderSide: const BorderSide(color: Colors.grey),
        //             ),
        //             focusedBorder: OutlineInputBorder(
        //               borderRadius: BorderRadius.circular(8),
        //               borderSide: const BorderSide(color: Colors.blue),
        //             ),
        //             filled: true,
        //             fillColor: Colors.white, // Màu nền của ô
        //           ),
        //           style: const TextStyle(
        //             fontSize: 15, // Tăng kích thước chữ để phù hợp với ô
        //             fontWeight: FontWeight.bold, // Làm chữ đậm
        //             color: Colors.black
        //           ),
        //           onChanged: (value) {
        //             if (value.length == 1 && RegExp(r'^[0-9]$').hasMatch(value)) {
        //               if (value.length == 1 && index < 5) {
        //                 FocusScope.of(context).nextFocus(); // Chuyển đến ô tiếp theo
        //               }}
        //               else if (value.isEmpty && index > 0) {
        //                 FocusScope.of(context).previousFocus(); // Quay lại ô trước
        //             }
        //             else{
        //               _otpControllers[index].clear();
        //             }
        //           },
        //         ),
        //       );
        //     }),
        //   ),
        //   actions: [
        //     Row(
        //       children: [
        //         TextButton(
        //           onPressed: () {
        //             Navigator.of(context).pop(); // Đóng hộp thoại
        //           },
        //           child: const Text("Cancel", style: TextStyle(color: Colors.red)),
        //         ),
        //         ElevatedButton(
        //       style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        //       onPressed: validateOtpCode,
        //       child: const Text("Verify Code", style: TextStyle(color: Colors.white)),
        //     ),
        //       ],
        //     ),
        //   ],
        // );