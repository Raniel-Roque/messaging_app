import 'package:flutter/material.dart';
import 'package:messaging_app/components/my_button.dart';
import 'package:messaging_app/components/my_text_field.dart';
import 'package:messaging_app/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  //Text Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //Sign In user
  void signIn(BuildContext context) async {
    //Auth Service
    final authService = AuthService();

    //Try Login
    try {
      await authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
    }

    //Catch
    catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Logo
                Icon(
                  Icons.message,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 20),

                //Welcome Back Message
                Text(
                  "Welcome back you've been missed!",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                //Email Textfield
                MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false),

                const SizedBox(height: 10),

                //Password Textfield
                MyTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true),

                const SizedBox(height: 25),

                //Sign in Button
                MyButton(onTap: () => signIn(context), text: 'Sign In'),

                const SizedBox(height: 15),

                //Not a member? Register Now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: const Text(
                        'Register now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
