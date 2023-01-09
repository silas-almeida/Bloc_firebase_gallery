import 'dart:io';

import 'package:bloc_firebase_gallery/auth/auth_error.dart';
import 'package:bloc_firebase_gallery/bloc/app_event.dart';
import 'package:bloc_firebase_gallery/bloc/app_state.dart';
import 'package:bloc_firebase_gallery/utils/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBLoc extends Bloc<AppEvent, AppState> {
  AppBLoc()
      : super(
          const AppStateLoggedOut(isLoading: false),
        ) {
    on<AppEventGoToRegistration>(
      (event, emit) {
        emit(
          const AppStateIsInRegistrationView(isLoading: false),
        );
      },
    );

    on<AppEventLogin>(
      ((event, emit) async {
        emit(const AppStateLoggedOut(isLoading: true));
        // log user in
        final email = event.email;
        final password = event.password;
        try {
          final userCredential =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final user = userCredential.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(user: user, images: images, isLoading: false),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedOut(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      }),
    );

    on<AppEventGoToLogin>(
      ((event, emit) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      }),
    );

    on<AppEventRegister>(
      (event, emit) async {
        emit(
          const AppStateIsInRegistrationView(isLoading: true),
        );
        final email = event.email;
        final password = event.password;
        try {
          //Create the user
          final credentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: credentials.user!,
              images: const [],
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateIsInRegistrationView(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );

    on<AppEventInitialize>(
      ((event, emit) async {
        //Get current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
        } else {
          emit(
            AppStateLoggedIn(
              isLoading: true,
              images: const [],
              user: user,
            ),
          );
          //grab users uploaded images
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              isLoading: false,
              images: images,
              user: user,
            ),
          );
        }
      }),
    );

    on<AppEventLogout>(
      ((event, emit) async {
        emit(
          const AppStateLoggedOut(isLoading: true),
        );
        await FirebaseAuth.instance.signOut();
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      }),
    );

    //Handle account deletion
    on<AppEventDeleteAccount>((event, emit) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
        return;
      }
      emit(
        AppStateLoggedIn(
          isLoading: true,
          user: user,
          images: state.images ?? [],
        ),
      );
      //deleting user folder
      try {
        //delete userFolder
        final folderContent =
            await FirebaseStorage.instance.ref(user.uid).listAll();
        for (final item in folderContent.items) {
          await item.delete().catchError((_) {});
        }
        await FirebaseStorage.instance.ref(user.uid).delete().catchError(
              (_) {},
            );
        await user.delete();
        await FirebaseAuth.instance.signOut();
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (firebaseAuthException) {
        emit(
          AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(firebaseAuthException)),
        );
      } on FirebaseException {
        emit(
          const AppStateLoggedOut(isLoading: false),
        );
      }
    });

    //handle uploading image
    on<AppEventUploadImage>(
      (event, emit) async {
        final user = state.user;
        //Log user out if we don't have an actual userId
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }
        //Start loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        //upload the file
        final file = File(event.filePathToUpload);
        await uploadImage(
          file: file,
          userId: user.uid,
        );
        // Grab the latest file references
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            isLoading: false,
            user: user,
            images: images,
          ),
        );
      },
    );
  }

  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
