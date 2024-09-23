import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dev_test/pages/home_page.dart';
import 'package:flutter_dev_test/pages/login_page.dart';
import 'package:flutter_dev_test/pages/recovery_secret_page.dart';

import 'bloc/auth_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/recovery': (context) => RecoverySecretPage(),
          '/home': (context) => HomePage(),
        },
      ),
    ),
  );
}
