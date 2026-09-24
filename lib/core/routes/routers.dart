import 'package:well_trust_mobile_app/core/routes/route.dart';
import 'package:flutter/material.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/get_started.dart';

import '../../features/home_screen.dart';
import '../helpers/globals.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RootRoutes.onboard:
      return MaterialPageRoute(builder: (context) => const GetStartedScreen());
    case RootRoutes.login:
      return MaterialPageRoute(builder: (context) => const LoginScreens());
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
  final hasValidSession =
      globals.userId.trim().isNotEmpty && globals.token.trim().isNotEmpty;

  if (!hasViewedOnboarding) {
    return RootRoutes.onboard;
  }

  if (!hasValidSession) {
    return RootRoutes.login;
  }

  return RootRoutes.tab;
}
