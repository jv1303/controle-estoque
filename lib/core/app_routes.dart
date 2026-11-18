import 'package:material_ui/material_ui.dart';

import '../models/product.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_form_screen.dart';
import '../screens/register_screen.dart';
import '../services/auth_service.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const productForm = '/product-form';

  static const _privateRoutes = {home, productForm};

  static Route<dynamic> generate(RouteSettings settings) {
    var name = settings.name;

    // rota privada sem ninguem logado -> manda pro login
    if (_privateRoutes.contains(name) && !AuthService.instance.isLoggedIn) {
      name = login;
    }

    final Widget page = switch (name) {
      AppRoutes.register => const RegisterScreen(),
      AppRoutes.home => const HomeScreen(),
      AppRoutes.productForm => ProductFormScreen(
        product: settings.arguments as Product?,
      ),
      _ => const LoginScreen(),
    };

    return MaterialPageRoute(
      builder: (_) => page,
      settings: RouteSettings(name: name, arguments: settings.arguments),
    );
  }
}
