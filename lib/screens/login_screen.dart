import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/login_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final loginProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('W E L C O M E', style: TextStyle(fontSize: 20.0)),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              controller: _emailController,
              prefixIcon: Icons.email,
              labelText: 'Email',
            ),
            const SizedBox(height: 16.0),
            _buildTextFormField(
              controller: _passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              labelText: 'Password',
              suffixIcon: Icons.visibility_off_outlined,
              obscureText: true,
            ),
            const SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: loginProvider.isLoading
                  ? null
                  : () => loginProvider.loginUser(
                _emailController.text.trim(),
                _passwordController.text.trim(),
                context,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orangeAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: loginProvider.isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.0,
                ),
              )
                  : const Text('Login'),
            ),
            const SizedBox(height: 20.0),
            // Google Sign-In Button
            SizedBox(
              height: 65,
              width: 200,
              child: ElevatedButton.icon(
                onPressed: loginProvider.isLoading
                    ? null
                    : () => loginProvider.signInWithGoogle(context),
                // icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String labelText,
    IconData? suffixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      obscureText: obscureText,
    );
  }
}
