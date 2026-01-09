/// Purpose: The main container screen after login.
/// It handles navigation via a Drawer and switches between different main sections (My Submissions, Explore, etc.).

import 'package:app_pawpal2/config/config.dart';
import 'package:app_pawpal2/config/app_theme.dart';
import 'package:app_pawpal2/models/user.dart';
import 'package:app_pawpal2/views/sc_auth.dart';
import 'package:app_pawpal2/views/sc_explore.dart';
import 'package:app_pawpal2/views/sc_myadoptions.dart';
import 'package:app_pawpal2/views/sc_mysubmission.dart';
import 'package:app_pawpal2/views/sc_profile.dart';
import 'package:app_pawpal2/views/sc_user_donations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late User _user;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      MySubmissionScreen(user: _user),
      ExploreScreen(user: _user),
      MyAdoptionsScreen(user: _user),
      UserDonationsScreen(user: _user),
      ProfileScreen(
        user: _user,
        onUserUpdated: (updatedUser) {
          setState(() {
            _user = updatedUser;
          });
        },
      ),
    ];

    final List<String> titles = [
      "My Submissions",
      "Explore Submissions",
      "My Adoptions",
      "My Donations",
      "My Profile",
    ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            titles[_currentIndex],
            style: const TextStyle(
              color: AppTheme.textColorDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.scaffoldColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppTheme.textColorDark),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: AppTheme.primaryColor),
                accountName: Text(
                  _user.name ?? "User",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(_user.email ?? ""),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage:
                      (_user.profileImage != null &&
                          _user.profileImage!.isNotEmpty)
                      ? NetworkImage(
                          "${Config.baseUrl}/app_pawpal/assets/profile/${_user.profileImage}",
                        )
                      : null,
                  child:
                      (_user.profileImage != null &&
                          _user.profileImage!.isNotEmpty)
                      ? null
                      : Text(
                          (_user.name ?? "U")[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 40.0,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('My Submissions'),
                selected: _currentIndex == 0,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  _onItemTapped(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Explore Submissions'),
                selected: _currentIndex == 1,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  _onItemTapped(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volunteer_activism),
                title: const Text('My Adoptions'),
                selected: _currentIndex == 2,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  _onItemTapped(2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on),
                title: const Text('My Donations'),
                selected: _currentIndex == 3,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  _onItemTapped(3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('My Profile'),
                selected: _currentIndex == 4,
                selectedColor: AppTheme.primaryColor,
                onTap: () {
                  _onItemTapped(4);
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _logoutDialog();
                },
              ),
            ],
          ),
        ),
        body: screens[_currentIndex],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_data');
                if (!context.mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
