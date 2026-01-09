/// Purpose: The initial authentication screen that toggles between Login and Register views.
/// It serves as the entry point for unauthenticated users.

import 'package:app_pawpal2/views/login.dart';
import 'package:app_pawpal2/views/register.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageViewController = PageController();
  late double scHeight;
  late double scWidth;

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    scHeight = MediaQuery.of(context).size.height;
    scWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              child: Center(
                child: Column(
                  children: [
                    // Title
                    SizedBox(
                      height: scHeight * 0.1,
                      width: scWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            children: [
                              // Stroked text as border.
                              Text(
                                'PawPal',
                                style: TextStyle(
                                  fontSize: scHeight * 0.05,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 5
                                    ..color = const Color(0xFF8B5E3B),
                                ),
                              ),
                              // Solid text as fill.
                              Text(
                                'PawPal',
                                style: TextStyle(
                                  fontSize: scHeight * 0.05,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: scHeight * 0.1,
                            width: scHeight * 0.1,
                            child: Image.asset(
                              'assets/paw.png',
                              scale: 14,
                              fit: BoxFit.none,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Images
                    SizedBox(
                      height: scHeight * 0.15,
                      width: scWidth * 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: scHeight * 0.3,
                            width: scWidth * 0.3,
                            child: Image.asset(
                              'assets/cat.png',
                              scale: 6,
                              fit: BoxFit.none,
                              alignment: const Alignment(-0.1, -1.8),
                            ),
                          ),
                          SizedBox(
                            height: scHeight * 0.3,
                            width: scWidth * 0.3,
                            child: Image.asset(
                              'assets/rabbit.png',
                              scale: 6,
                              fit: BoxFit.none,
                              alignment: const Alignment(-0.1, -1.4),
                            ),
                          ),
                          SizedBox(
                            height: scHeight * 0.3,
                            width: scWidth * 0.3,
                            child: Image.asset(
                              'assets/dog.png',
                              scale: 5,
                              fit: BoxFit.none,
                              alignment: const Alignment(-0.1, -1.5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Container
                    Container(
                      width: scWidth * 0.78,
                      height: scHeight * 0.55,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF8B5E3B),
                          width: 3,
                        ),
                        borderRadius: BorderRadius.zero,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(scHeight * 0.01),
                                child: TextButton(
                                  onPressed: navigatePage(0),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontWeight: _currentIndex == 0
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(scHeight * 0.01),
                                child: TextButton(
                                  onPressed: navigatePage(1),
                                  child: Text(
                                    "Register",
                                    style: TextStyle(
                                      fontWeight: _currentIndex == 1
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: PageView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: _pageViewController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              children: const <Widget>[
                                LoginView(),
                                RegisterView(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Cat House
            Positioned(
              bottom: 0,
              left: 0,
              height: scHeight * 0.4,
              width: scWidth * 0.3,
              // ignore: sized_box_for_whitespace
              child: Image.asset(
                'assets/cathouse.png',
                scale: 4,
                fit: BoxFit.none,
                alignment: const Alignment(0.2, -1),
              ),
            ),

            // Ball
            Positioned(
              bottom: scHeight * 0.1,
              right: 0,
              height: scHeight * 0.15,
              width: scWidth * 0.3,
              child: Image.asset(
                'assets/ball.png',
                scale: 12,
                fit: BoxFit.none,
                alignment: const Alignment(1, 1.5),
              ),
            ),

            // Door Mat
            Positioned(
              bottom: 0,
              height: scHeight * 0.1,
              width: scWidth * 0.6,
              child: Image.asset(
                'assets/doormat.png',
                scale: 5,
                fit: BoxFit.none,
                alignment: const Alignment(0, 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 0 - Login, 1 - Register
  navigatePage(int index) => () {
    setState(() {
      _currentIndex = index;
    });
    _pageViewController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  };
}
