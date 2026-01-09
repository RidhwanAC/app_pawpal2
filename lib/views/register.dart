import 'dart:convert';
import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_home.dart';
import 'package:app_pawpal2/widgets/auth_listtile.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late double maxHeight;
  late double maxWidth;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    maxHeight = MediaQuery.of(context).size.height;
    maxWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        maxWidth * 0.05,
        0,
        maxWidth * 0.05,
        maxHeight * 0.02,
      ),
      child: Column(
        children: [
          // Name Field
          Card(
            child: AuthListTile(
              controller: nameController,
              leadingIcon: Icons.person,
              title: 'User Name',
              subtitle: 'Enter User Name',
              deny: RegExp(r'[^a-zA-Z\s]'),
            ),
          ),

          const SizedBox(height: 10),

          // Email Field
          Card(
            child: AuthListTile(
              controller: emailController,
              leadingIcon: Icons.email,
              title: 'Email Address',
              subtitle: 'Enter Email Address',
              deny: RegExp(r'[^a-zA-Z0-9@._-]'),
            ),
          ),

          const SizedBox(height: 10),

          // Phone Number Field
          Card(
            child: AuthListTile(
              controller: phoneNumberController,
              leadingIcon: Icons.phone,
              title: 'Phone Number',
              subtitle: 'Enter Phone Number',
              maxChar: 15,
              deny: RegExp(r'[^0-9]'),
            ),
          ),

          const SizedBox(height: 10),

          // Password Field
          Card(
            child: AuthListTile(
              controller: passwordController,
              leadingIcon: Icons.lock,
              title: 'Password',
              subtitle: 'Enter Password',
              maxChar: 20,
              deny: RegExp(r'[^a-zA-Z0-9!@#$%^&*._-]'),
              obscureText: true,
            ),
          ),

          const SizedBox(height: 10),

          // Confirm Password Field
          Card(
            child: AuthListTile(
              controller: confirmPasswordController,
              leadingIcon: Icons.lock,
              title: 'Confirm Password',
              subtitle: 'Re-enter Password',
              maxChar: 20,
              deny: RegExp(r'[^a-zA-Z0-9!@#$%^&*._-]'),
              obscureText: true,
            ),
          ),

          const Expanded(child: SizedBox()),

          // Register Button
          SizedBox(
            width: maxWidth * 0.45,
            child: ElevatedButton(
              onPressed: _registerDialog,
              child: const Text(
                "Register",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _registerDialog() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneNumberController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Empty Field Validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 2000),
        ),
      );
      return;
    }

    // Email Validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,10}$',
    );
    if (emailRegex.hasMatch(email) == false) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 2000),
        ),
      );
      return;
    }

    // Password Validation
    if (password.length < 6 || password.length > 20) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be between 6 and 20 characters'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 2000),
        ),
      );
      return;
    }

    // Passwords Match Validation
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 2000),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register this account?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _registerUser(email, password, name, phone);
            },
            child: const Text('Register'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
        content: const Text('Are you sure you want to register this account?'),
      ),
    );
  }

  void _registerUser(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    setState(() {
      isLoading = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text(
                  'Registering...',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
    await http
        .post(
          Uri.parse('${Config.baseUrl}/app_pawpal/api/register.php'),
          body: {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
          },
        )
        .then((response) async {
          if (response.statusCode == 200) {
            var jsonResponse = response.body;
            var resarray = jsonDecode(jsonResponse);
            await Future.delayed(const Duration(milliseconds: 1000), () {});
            if (resarray['status'] == 'success') {
              User user = User.fromJson(resarray['data'][0]);
              if (!mounted) return;
              Navigator.pop(context);
              setState(() {
                isLoading = false;
              });

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(user: user)),
              );
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registration successful'),
                  backgroundColor: Colors.green,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            }
            if (isLoading) {
              if (!mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(resarray['message']),
                  backgroundColor: Colors.red,
                  duration: const Duration(milliseconds: 1500),
                ),
              );
              setState(() {
                isLoading = false;
              });
            }
          }
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            if (!mounted) return;
            Navigator.pop(context);
            setState(() {
              isLoading = false;
            });
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Request timed out. Please try again.'),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 1500),
              ),
            );
          },
        );

    if (isLoading) {
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    }
  }
}
