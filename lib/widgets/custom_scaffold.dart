import 'package:flutter/material.dart';
import 'package:tic_tac_toe_board_game/utils/app_assets.dart';
import 'package:tic_tac_toe_board_game/widgets/floating_particles.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.background),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            // Shared background drifting particles floating on the whole screen
            const Positioned.fill(
              child: FloatingParticlesBackground(),
            ),

            // Content layer
            Center(
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  constraints: const BoxConstraints(
                    maxWidth: 850,
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
