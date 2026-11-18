import 'package:material_ui/material_ui.dart';

import 'core/app_routes.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.instance.restoreSession();
  runApp(const MeuEstoqueApp());
}

class MeuEstoqueApp extends StatelessWidget {
  const MeuEstoqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu Estoque',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: AuthService.instance.isLoggedIn
          ? AppRoutes.home
          : AppRoutes.login,
      onGenerateRoute: AppRoutes.generate,
      // sem isso o flutter empilha o login embaixo da home
      onGenerateInitialRoutes: (name) => [
        AppRoutes.generate(RouteSettings(name: name)),
      ],
    );
  }
}
