import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

import '../screens/admin_screen.dart';
import '../screens/employee_screen.dart';
import '../screens/hr_screen.dart';
import '../screens/login_screen.dart';

class LoginProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Email/Password Login
  Future<void> loginUser(
      String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setLoading(true);

    try {
      final UserCredential userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;

      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final role = userData?['role'];
          if (role == 'Manager') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminScreen(userData: userData!)),
            );
          } else if (role == 'HR') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HrScreen(userData: userData!)),
            );
          } else if (role == 'Employee') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EmployeeScreen(userData: userData!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown user role')),
            );
            await _auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No role assigned')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log in')),
      );
      print('Email/Password login error: $error');
    } finally {
      setLoading(false);
    }
  }

  // Google Sign-In
  Future<void> signInWithGoogle(BuildContext context) async {
    setLoading(true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setLoading(false);
        return; // User canceled the sign-in.
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          final role = userData?['role'];
          if (role == 'Manager') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminScreen(userData: userData!)),
            );
          } else if (role == 'HR') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HrScreen(userData: userData!)),
            );
          } else if (role == 'Employee') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => EmployeeScreen(userData: userData!)),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Unknown user role')),
            );
            await _auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No role assigned')),
          );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign in failed')),
      );
      print('Google sign in error: $error');
    } finally {
      setLoading(false);
    }
  }
}
