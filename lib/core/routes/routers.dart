import 'package:ginilog_customer_app/core/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/logins.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/onboarding_.dart';
import 'package:ginilog_customer_app/features/auth/presentation/screen/user_register.dart';

import '../../features/home_screen.dart';
import '../helpers/globals.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RootRoutes.onboard:
      return MaterialPageRoute(builder: (context) => const OnboardingScreen());
    case RootRoutes.login:
      return MaterialPageRoute(builder: (context) => const LoginScreens());
    case RootRoutes.createAccount:
      return MaterialPageRoute(builder: (context) => const RegisterScreen());
    case RootRoutes.tab:
      return MaterialPageRoute(
        builder: (context) => const HomeScreenPage(imdex: 0),
      );

    default:
      {
        return _errorRoute();
      }
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text('ERROR'), centerTitle: true),
        body: const Center(child: Text('Page not found!')),
      );
    },
  );
}

Future<String> initialRoute() async {
  final hasViewedOnboarding = globals.isViewed == 0;
  final isLoggedIn = globals.userId.isNotEmpty;

  if (!hasViewedOnboarding) {
    return RootRoutes.onboard;
  }

  if (!isLoggedIn) {
    return RootRoutes.login;
  }

  return RootRoutes.tab;
}
