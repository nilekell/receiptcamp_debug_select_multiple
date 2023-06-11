import 'package:bloc/bloc.dart';

class LandingCubit extends Cubit<int> {
  LandingCubit() : super(0);

  updateIndex(int value) {
    switch (value) {
      case 0:
        emit(state + 1);
      case 1:
        emit(state - 1);
      default:
        emit(-1);
    }
  }
  }
