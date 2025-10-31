import 'package:flutter/widgets.dart';
import 'package:shokti/Onboardpage.dart';
import 'package:shokti/views/Login.dart';
import 'package:shokti/views/SignUp.dart';
import 'package:shokti/landingpage.dart';
import 'package:shokti/Tracker.dart';
import 'package:shokti/EnergyPage.dart';
import 'package:shokti/ChatPage.dart';
import 'package:shokti/SetUpPage.dart';

/// Centralized route names for the app
class Routes {
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String landing = '/landing';
  static const String tracker = '/tracker';
  static const String energy = '/energy';
  static const String chat = '/chat';
  static const String setup = '/setup';
}

/// Map of routes to plug into `MaterialApp.routes`
///
/// Note: `SetupPage` expects a `userId` — pass it via `Navigator.pushNamed(context, Routes.setup, arguments: 'userIdValue')`
final Map<String, WidgetBuilder> appRoutes = {
  Routes.onboarding: (context) => const OnboardingPage(title: 'Home Page'),
  Routes.login: (context) => const Login(),
  Routes.signup: (context) => const Signup(),
  Routes.landing: (context) => const Landingpage(),
  Routes.tracker: (context) => const Tracker(),
  Routes.energy: (context) => const EnergyPage(),
  Routes.chat: (context) => const ChatPage(),

  // Setup route expects either a String (userId) or a Map with {'userId': id}
  Routes.setup: (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String userId = '';
    if (args is String) {
      userId = args;
    } else if (args is Map && args['userId'] is String) {
      userId = args['userId'] as String;
    }

    return SetupPage(userId: userId);
  },
};
