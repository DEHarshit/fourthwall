import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/pages/comp/loader.dart';
import 'package:socialwall/pages/comp/sign_in.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 249, 249, 249),
      body: isLoading
      ? const Loader()
      : SafeArea(
        child: Center(
          child: Column(
            children:  [
            //welcome
            const SizedBox(height:50 ),
            const Text(
              'Welcome',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5 
                ),
            ),
            const SizedBox(height:50 ),
            //logo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                Constants.logoPath,
                height:375),
            ),
            const SizedBox(height:50),
            //login
            const Text(
              "Sign in",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 25,
                letterSpacing: 0.7,
                ),
            ),

            const SizedBox(height:25 ),
            //google sign in 
            const SignIn(),
            const SizedBox(height:25 ),
            //login as a guest
            
          ]
          ),
        ),
      ),
    );
  }
}