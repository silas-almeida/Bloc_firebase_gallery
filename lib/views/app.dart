import 'package:bloc_firebase_gallery/bloc/app_bloc.dart';
import 'package:bloc_firebase_gallery/bloc/app_event.dart';
import 'package:bloc_firebase_gallery/bloc/app_state.dart';
import 'package:bloc_firebase_gallery/dialogs/show_auth_error.dart';
import 'package:bloc_firebase_gallery/loading/loading_screen.dart';
import 'package:bloc_firebase_gallery/views/login_view.dart';
import 'package:bloc_firebase_gallery/views/photo_gallery_view.dart';
import 'package:bloc_firebase_gallery/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (context) => AppBloc()
        ..add(
          const AppEventInitialize(),
        ),
      child: MaterialApp(
        title: 'Photo Gallery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            if (appState.isLoading) {
              LoadingScreen.instance()
                  .show(context: context, text: 'Loading...');
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = appState.authError;
            if (authError != null) {
              showAuthError(context: context, error: authError);
            }
          },
          builder: (context, appState) {
            if (appState is AppStateLoggedOut) {
              return const LoginView();
            } else if (appState is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (appState is AppStateIsInRegistrationView) {
              return const RegisterView();
            } else {
              //Should never happen
              return Container();
            }
          },
        ),
      ),
    );
  }
}
