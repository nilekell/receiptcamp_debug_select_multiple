import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/data/repositories/database_repository.dart';
import 'package:receiptcamp/logic/blocs/explorer/explorer_bloc.dart';
import 'package:receiptcamp/logic/blocs/home/home_bloc.dart';
import 'package:receiptcamp/bloc_observer.dart';
import 'package:receiptcamp/logic/blocs/upload/upload_bloc.dart';
import 'package:receiptcamp/presentation/router/app_router.dart';
import 'package:receiptcamp/presentation/screens/home.dart';

void main() async {
  Bloc.observer = AppBlocObserver();
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseRepository.instance.init();
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<HomeBloc>(
        create: (BuildContext context) => HomeBloc(databaseRepository: DatabaseRepository.instance)..add(HomeInitialEvent()),
      ),
      BlocProvider<UploadBloc>(
        create: (context) => UploadBloc()..add(UploadInitialEvent()),
      ),
      BlocProvider<ExplorerBloc>(
        create: (BuildContext context) => ExplorerBloc()..add(ExplorerInitialEvent()),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: (context) => DatabaseRepository.instance,
      child: MaterialApp(
        title: 'ReceiptCamp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: AppRouter().onGenerateRoute,
        home: const Home(),
      ),
    );
  }
}
