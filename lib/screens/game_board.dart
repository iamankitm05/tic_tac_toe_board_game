import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe_board_game/utils/app_assets.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key});

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
        child: Container(
          margin: EdgeInsets.all(20),
          width: 400,
          height: double.infinity,
          child: Stack(
            children: [
              Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.pinkAccent.shade100,
                    child: Icon(Icons.person, color: Colors.pinkAccent),
                  ),
                  Text(
                    "Ankit kumar",
                    style: GoogleFonts.poppins(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Image.asset(AppAssets.cross, width: 24, height: 24),
                ],
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(AppAssets.circle, width: 24, height: 24),
                    Text(
                      "Ankit kumar",
                      style: GoogleFonts.poppins(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.blueAccent.shade100,
                      child: Icon(Icons.person, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
