import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/home_screen.dart';
import 'screens/voice_capture_screen.dart';
import "screens/active_exercise_screen.dart";
import "screens/exercises_list_screen.dart";

void main() {
  sqfliteFfiInit();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App para Ansiedad',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/registro': (context) => RegistroScreen(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return HomeScreen(userId: args);
        },
        '/voice-capture': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return VoiceCaptureScreen(userId: args);
        },
        '/exercises': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as int;
          return ExercisesListScreen(userId: args);
        },
        '/active-exercise': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ActiveExerciseScreen(
            userId: args['userId'],
            exerciseType: args['exerciseType'],
          );
        },
      },
    );
  }
}
