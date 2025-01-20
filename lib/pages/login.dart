import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/pages/quest_page.dart';
import '../bloc/quest_model_bloc.dart';
import '../ui_elements/abutton.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(googleSignInProvider: GoogleSignInProvider()),
      child: Builder(  // Add this Builder widget
        builder: (context) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.primary,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            title: const Text('Gamify'),
            centerTitle: true
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Welcome, It's time to Gamify your success!",
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => QuestModelBloc()..add(LoadQuestModel(state.userData['_id'])), // Assuming user.id exists
                            child: QuestPage(userId: state.userData['user']['_id']),
                          ),
                        ),
                      );
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return const CircularProgressIndicator();
                    }
                    if (state is AuthError) {
                      return Column(
                        children: [
                          Text(
                            state.message,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          newButton(  // Changed to PascalCase
                            text: 'Retry Login With Google',
                            ontap: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                          ),
                        ],
                      );
                    }
                    return newButton(  // Changed to PascalCase
                      text: 'Login With Google',
                      ontap: () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}