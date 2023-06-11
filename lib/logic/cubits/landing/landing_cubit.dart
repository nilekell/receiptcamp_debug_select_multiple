import 'package:bloc/bloc.dart';

class LandingCubit extends Cubit<int> {
  LandingCubit() : super(0);

  updateIndex(int value) {
    emit(value);
  }
}
