// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';
//
// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   AuthBloc() : super(AuthInitial()) {
//     on<SignUpEvent>(_onSignUp);
//     on<LoginEvent>(_onLogin);
//     on<LogoutEvent>(_onLogout);
//   }
//
//   Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
//     emit(AuthLoading());
//     try {
//       UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
//         email: event.email,
//         password: event.password,
//       );
//       emit(AuthenticatedState(email: userCredential.user!.email!));
//     } catch (e) {
//       emit(AuthError(message: e.toString()));
//     }
//   }
//
//   Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
//     emit(AuthLoading());
//     try {
//       UserCredential userCredential = await _auth.signInWithEmailAndPassword(
//         email: event.email,
//         password: event.password,
//       );
//       emit(AuthenticatedState(email: userCredential.user!.email!));
//     } catch (e) {
//       emit(AuthError(message: e.toString()));
//     }
//   }
//
//   Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
//     emit(AuthLoading());
//     try {
//       await _auth.signOut();
//       emit(AuthUnauthenticated());
//     } catch (e) {
//       emit(AuthError(message: e.toString()));
//     }
//   }
// }





import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthBloc() : super(AuthInitial()) {
    // Check initial authentication state
    _checkAuthentication();
    on<SignUpEvent>(_onSignUp);
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
  }

  void _checkAuthentication() {
    // Check if the user is already authenticated
    final User? user = _auth.currentUser;
    if (user != null) {
      emit(AuthenticatedState(email: user.email!));
    }
  }

  Future<void> _onSignUp(SignUpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(email: userCredential.user!.email!));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      emit(AuthenticatedState(email: userCredential.user!.email!));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
