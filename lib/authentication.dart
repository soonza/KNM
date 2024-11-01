import 'package:flutter/material.dart';
import 'package:project/item_list_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // Apple Sign-In 패키지 import
import 'dart:io';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  void _navigateToItemListPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ItemListPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 131),
              const SizedBox(height: 41),
              if (Platform.isIOS) ...[
                // Apple 로그인 버튼
                Container(
                  width: 331,
                  height: 58,
                  child: SignInWithAppleButton(
                    onPressed: () async {
                      User? user = await authService.signInWithApple();
                      if (user != null) {
                        // 로그인 성공, ItemListPage로 이동
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ItemListPage()),
                        );
                      } else {
                        // 로그인 실패 처리
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Apple 로그인 실패")),
                        );
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 15),
              InkWell(
                onTap: () async {
                  User? user = await authService.signInWithGoogle();
                  if (user != null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ItemListPage()),
                    );
                  } else {
                    print("로그인 실패");
                  }
                },
                child: Container(
                  width: 331,
                  height: 58,
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: const Text(
                    "Sign in with Google",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AuthService 클래스는 동일
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Apple 로그인 메서드 추가
  Future<User?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print("Apple Sign In completed. User: ${appleCredential.email}");

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      print("Created Firebase AuthCredential for Apple");

      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      print("Firebase sign in completed. User: ${userCredential.user?.uid}");

      // Apple doesn't always return user's name, so we need to handle it
      if (appleCredential.givenName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(
            "${appleCredential.givenName} ${appleCredential.familyName}");
      }

      return userCredential.user;
    } catch (e) {
      print("Apple 로그인 실패: $e");
      if (e is FirebaseAuthException) {
        print("Firebase Auth Error Code: ${e.code}");
        print("Firebase Auth Error Message: ${e.message}");
      }
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      print("Starting Google Sign In process");
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print("Google Sign In completed. User: ${googleUser?.email}");

      if (googleUser == null) {
        print("Google Sign In was aborted by the user");
        return null;
      }

      print("Retrieving Google Auth tokens");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print(
          "Got Google Auth tokens. Access token: ${googleAuth.accessToken != null}, ID token: ${googleAuth.idToken != null}");

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print("Created Firebase AuthCredential");

      print("Attempting to sign in to Firebase");
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      print("Firebase sign in completed. User: ${userCredential.user?.uid}");

      return userCredential.user;
    } catch (e) {
      print("Detailed Google 로그인 실패: $e");
      if (e is FirebaseAuthException) {
        print("Firebase Auth Error Code: ${e.code}");
        print("Firebase Auth Error Message: ${e.message}");
      }
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
