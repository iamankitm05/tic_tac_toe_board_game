import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';
import 'package:tic_tac_toe_board_game/blocs/game_manager/game_manager_bloc.dart';
import 'package:tic_tac_toe_board_game/firebase_options.dart';
import 'package:tic_tac_toe_board_game/screens/menu_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameManagerBloc(),
      child: MaterialApp(
        title: 'Tic Tac Toe Board Game',
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: ThemeMode.dark,
        builder: (context, child) {
          return ToastificationWrapper(child: child!);
        },
        home: const MenuScreen(),
      ),
    );
  }
}
