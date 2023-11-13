// ignore_for_file: prefer_final_fields, unused_field
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receiptcamp/logic/cubits/landing/landing_cubit.dart';
import 'package:receiptcamp/presentation/screens/file_explorer.dart';
import 'package:receiptcamp/presentation/screens/home.dart';
import 'package:receiptcamp/presentation/ui/landing/app_bar.dart';
import 'package:receiptcamp/presentation/ui/landing/drawer.dart';
import 'package:receiptcamp/presentation/ui/landing/nav_bar.dart';
import 'package:receiptcamp/presentation/ui/ui_constants.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: switchTabfadeDuration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: HomeAppBar(),
      body: FadeTransition(
        opacity: _controller,
        child: BlocBuilder<LandingCubit, int>(
          builder: (context, state) {
            _controller.forward(from: 0.0); // Trigger the animation
            return IndexedStack(
              index: state,
              children: const [
                Home(),
                FileExplorer(),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: BlocBuilder<LandingCubit, int>(
        builder: (context, state) {
          return bottomNavigationBar(state, context);
        },
      ),
    );
  }
}
