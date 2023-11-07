import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppBlocObserver extends BlocObserver {
  /*
  commenting onChange method out as it outputs what onTransition does, except without the event.
  Using both methods makes terminal output when running unnecessarily verbose
  @override
  void onChange(BlocBase bloc, Change change) {
    if (kDebugMode || kProfileMode) {
      super.onChange(bloc, change);
      print('${bloc.runtimeType} $change');
    }
  }
  */

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode || kProfileMode) {
      print('${bloc.runtimeType} $error $stackTrace');
      super.onError(bloc, error, stackTrace);
    }
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    if (kDebugMode || kProfileMode) {
      super.onTransition(bloc, transition);
      print('${bloc.runtimeType} $transition');
    }
  }
}
