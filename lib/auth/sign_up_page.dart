import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../api/auth_api.dart';
import '../model/user_model.dart';
import '../presentation/app_colors.dart';
import '../services/context_provider.dart';
import '../widgets/dialog/adaptive_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
                'You must Sign up to join',
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
                      const Text('Sign up with Google'),
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
                  'Name',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.account_box),
                  hintText: 'Name',
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
                  user = user.copyWith(name: value);
                },
              ),
              const SizedBox(
                height: 18,
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
                  //user = user.copyWith(email: value);
                },
              ),
              const SizedBox(
                height: 40,
              ),
              TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: AppColors.mariner),
                  onPressed: () async {
                    try {
                      await GetIt.I<AuthApi>().signUp(user);
                    } on Exception catch (error) {
                      await showAlert(title: error.toString());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: 200,
                    height: 32,
                    child: const Text(
                      'Sign Up',
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
                    'Have an account? ',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(navigatorKeyStart.currentContext!)
                          .pushNamed('sign_in');
                    },
                    child: const Text(
                      'Sign In',
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('РЕГИСТРАЦИЯ'),
            const SizedBox(
              height: 60,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: 'Имя', border: OutlineInputBorder()),
              onChanged: (value) {
                user = user.copyWith(name: value);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(
                  hintText: 'Почта', border: OutlineInputBorder()),
              onChanged: (value) {
                user = user.copyWith(email: value);
              },
            ),
            TextButton(
                onPressed: () async {
                  try {
                    await GetIt.I<AuthApi>().signUp(user);
                  } on Exception catch (error) {
                    await showAlert(title: error.toString());
                  }
                },
                child: const Text('Зарегистрироватся')),
            const SizedBox(
              height: 60,
            ),
          ],
        ),
      ),
    );
  }
}
