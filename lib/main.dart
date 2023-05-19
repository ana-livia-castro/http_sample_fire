import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http_sample_fire/pages/input_list_form.dart';
import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AppFirebase());
}

class AppFirebase extends StatelessWidget {
  const AppFirebase({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Person - App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const InputListForm(title: 'Cadastro de Pessoas'),
    );
  }
}
