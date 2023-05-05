import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../api/auth_api.dart';
import '../model/user_model.dart';
import '../presentation/app_colors.dart';
import '../services/context_provider.dart';
import '../widgets/dialog/adaptive_dialog.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  UserModel user = UserModel(name: '', email: '', uid: '', imageUrl: '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 70,
              ),
              const Text(
                'You must Sign in to join',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 22,
              ),
              OutlinedButton(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user),
                      const SizedBox(
                        width: 12,
                      ),
                      const Text('Sign in with Google'),
                    ],
                  ),
                ),
                onPressed: () {},
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Or'),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Email',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_balance),
                  hintText: 'Uname@email.com',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                onChanged: (value) {
                  user = user.copyWith(email: value);
                },
              ),
              const SizedBox(
                height: 18,
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  hintText: 'Password',
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF1F0F5)),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                onChanged: (value) {
                  // user = user.copyWith(email: value);
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text(
                    'Forgot password?',
                    style: TextStyle(color: AppColors.mariner),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.mariner),
                  onPressed: () async {
                    try {
                      await GetIt.I<AuthApi>().login(user);
                    } on Exception catch (error) {
                      await showAlert(title: error.toString());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 32,
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  )),
              const SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don’t have account? ',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(navigatorKeyStart.currentContext!)
                          .pushNamed('sign_up');
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: AppColors.mariner, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 60,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
