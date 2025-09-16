import 'package:flutter/material.dart';
import 'package:onebank/app_locator.dart';
import 'package:onebank/routes/route.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: const Text('Splash View')),
          ElevatedButton(
            onPressed: () {
              appRouter.pushNamed(AppRoute.loginView);
            },
            child: const Text('Go to Login View'),
          ),
        ],
      ),
    );
  }
}
