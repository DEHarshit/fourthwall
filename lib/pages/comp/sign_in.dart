import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:socialwall/controller/auth_controller.dart";
import "package:socialwall/core/constants/constants.dart";

class SignIn extends ConsumerWidget {
  const SignIn({super.key});

void signInWithGoogle(BuildContext context, WidgetRef ref){
  ref.read(authControllerProvider.notifier).signInWithGoogle(context);
}

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(Constants.google, width: 35),
        label: const Text(
          'Continue with Google', 
          style:TextStyle(fontSize:20)
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity,50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          ),
      ),
    );
  }
}