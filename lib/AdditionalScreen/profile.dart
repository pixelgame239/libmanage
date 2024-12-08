import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:librarymanage/Elements/userinformation.dart';
import 'package:librarymanage/main.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false;
  
  // Profile fields
  final TextEditingController firstNameController =
      TextEditingController();
  final TextEditingController lastNameController =
      TextEditingController();
        final TextEditingController emailController =
      TextEditingController();
  final TextEditingController roleController =
      TextEditingController();
  late StreamSubscription _userSubscription;
   @override
  void initState() {
    super.initState();
    _initializeUserProfile();
    _listenToUserChanges();
  }

  void _initializeUserProfile() {
    final currentUser = Provider.of<Users>(context, listen: false);
    firstNameController.text = currentUser.first_name;
    lastNameController.text = currentUser.last_name;
    emailController.text = currentUser.username;
    roleController.text = currentUser.auth ? 'Admin' : 'User';
  }

  void _listenToUserChanges() {
    final currentUser = Provider.of<Users>(context,listen: false);
    _userSubscription = supabase
        .from('user_accounts')
        .stream(primaryKey: ['user_id'])
        .eq('user_id', Provider.of<Users>(context, listen: false).user_id)
        .listen((List<Map<String, dynamic>> updates) {
      if (updates.isNotEmpty) {
        final updatedUser = updates.first;
        currentUser.changeUserInfor(currentUser.user_id, currentUser.username, currentUser.auth, updatedUser['first_name'], updatedUser['last_name']);
      }
    });

  }
  @override
  void dispose() {
    _userSubscription.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 40,
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
              child: Column(
                  children: [
                    const SizedBox(height: 30),
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/useravatar.png'), // Add the image path here
                    ),
                    const SizedBox(height: 10),
                    itemProfile('First Name', firstNameController, CupertinoIcons.person_3_fill,true),
                    const SizedBox(height: 5),
                    itemProfile('Last Name', lastNameController, Icons.person_pin_sharp,true),
                    const SizedBox(height: 5),
                    itemProfile('Email', emailController, CupertinoIcons.mail,false),
                    const SizedBox(height: 5),
                    itemProfile('Role', roleController, CupertinoIcons.briefcase_fill,false),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isEditing = !isEditing;
                          });
                          if (!isEditing) {
                            await _updateUserProfile(
                            firstNameController.text,
                            lastNameController.text,
                            Provider.of<Users>(context, listen: false).user_id,
                            );
                            }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(15),
                        ),
                        child: Text(isEditing ? 'Save' : 'Edit'),
                      ),
                    ),
                  ],
                ),
            ),
      ),
    );
  }

Widget itemProfile(String title, TextEditingController controller,
      IconData iconData, bool editable) {
    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(iconData),
        title: isEditing && editable
            ? TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        )
            : TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
          ),
          readOnly: true,
          enabled: false,
        ),
      ),
    );
  }
    Future<void> _updateUserProfile(
      String firstName, String lastName, String userId) async {
    final response = await supabase
        .from('user_accounts') 
        .update({
      'first_name': firstName,
      'last_name': lastName,
    })
        .eq('user_id', userId); 
    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile: ${response.error!.message}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Updated Profile')));
    }
  }
}
