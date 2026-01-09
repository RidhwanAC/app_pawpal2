import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_main.dart';
import 'package:app_pawpal2/widgets/auth_listtile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late double maxHeight;
  late double maxWidth;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isChecked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

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
          // Email Field
          Card(
            child: AuthListTile(
              controller: emailController,
              leadingIcon: Icons.person,
              title: 'Email',
              subtitle: 'Enter Email Address',
              maxChar: 50,
              deny: RegExp(r'[^a-zA-Z0-9@._-]'),
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

          // Remember Me
          Row(
            children: [
              const SizedBox(width: 5),
              const Text(
                "Remember Me",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Checkbox(
                activeColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.borderColor, width: 2),
                value: isChecked,
                onChanged: _rememberMe,
              ),
            ],
          ),

          const Expanded(child: SizedBox()),

          // Login Button
          SizedBox(
            width: maxWidth * 0.45,
            child: ElevatedButton(
              onPressed: _loginValidation,
              child: const Text(
                "Login",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _rememberMe(bool? value) {
    isChecked = value!;
    setState(() {});
    if (isChecked) {
      if (emailController.text.isNotEmpty &&
          passwordController.text.isNotEmpty) {
        updatePreferences(isChecked);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Preferences Stored"),
            backgroundColor: Colors.green,
            duration: Duration(milliseconds: 1500),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter your email and password"),
            backgroundColor: Colors.red,
            duration: Duration(milliseconds: 1500),
          ),
        );
        isChecked = false;
        setState(() {});
      }
    } else {
      updatePreferences(isChecked);
      if (emailController.text.isEmpty && passwordController.text.isEmpty) {
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Preferences Removed"),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1500),
        ),
      );
      setState(() {});
    }
  }

  void updatePreferences(bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString('email', emailController.text);
      prefs.setString('password', passwordController.text);
      prefs.setBool('rememberMe', isChecked);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.remove('rememberMe');
    }
  }

  void _loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool('rememberMe');
      if (rememberMe != null && rememberMe) {
        String? email = prefs.getString('email');
        String? password = prefs.getString('password');
        emailController.text = email ?? '';
        passwordController.text = password ?? '';
        isChecked = true;
        setState(() {});
      }
    });
  }

  void _loginValidation() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Empty Field Validation
    if (email.isEmpty || password.isEmpty) {
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
    updatePreferences(isChecked);
    _loginUser(email, password);
  }

  void _loginUser(String email, String password) async {
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
            content: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text(
                    'Logging in...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      barrierDismissible: false,
    );

    await http
        .post(
          Uri.parse('${Config.baseUrl}/app_pawpal/api/login.php'),
          body: {'email': email, 'password': password},
        )
        .then((response) async {
          var jsonResponse = response.body;
          var resarray = jsonDecode(jsonResponse);
          await Future.delayed(const Duration(milliseconds: 1000), () {});
          if (response.statusCode == 200) {
            if (resarray['status'] == 'success') {
              User user = User.fromJson(resarray['data'][0]);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_data', jsonEncode(user.toJson()));

              if (!mounted) return;
              Navigator.pop(context);
              setState(() {
                isLoading = false;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(user: user)),
              );
              if (!isChecked) {
                emailController.clear();
                passwordController.clear();
              }

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Login Successful'),
                  backgroundColor: Colors.green,
                  duration: Duration(milliseconds: 1500),
                ),
              );
            }
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
