import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe_board_game/blocs/game_manager/game_manager_bloc.dart';
import 'package:tic_tac_toe_board_game/screens/game_board.dart';
import 'package:tic_tac_toe_board_game/utils/app_assets.dart';
import 'package:tic_tac_toe_board_game/utils/url_helper.dart';
import 'package:tic_tac_toe_board_game/utils/my_toast.dart';
import 'package:tic_tac_toe_board_game/utils/app_colors.dart';
import 'package:tic_tac_toe_board_game/widgets/custom_scaffold.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  bool _isCreatingRoom = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCodeController = TextEditingController();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _nameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      MyToast.warning(context, 'Please enter your name!');
      return;
    }

    if (!_isCreatingRoom) {
      final code = _roomCodeController.text.trim();
      if (code.isEmpty || code.length < 4) {
        MyToast.warning(
          context,
          'Please enter a valid room code (at least 4 characters)!',
        );
        return;
      }
    }

    final bloc = context.read<GameManagerBloc>();
    if (_isCreatingRoom) {
      bloc.add(CreateRoomEvent(name));
    } else {
      bloc.add(
        JoinRoomEvent(
          guestName: name,
          roomId: _roomCodeController.text.trim().toUpperCase(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _isCreatingRoom
        ? AppColors.creatorColor
        : AppColors.guestColor;

    return CustomScaffold(
      child: BlocListener<GameManagerBloc, GameManagerState>(
        listenWhen: (previous, current) =>
            previous.success != current.success ||
            previous.error != current.error,
        listener: (context, state) {
          if (state.error != null) {
            MyToast.error(context, state.error!);
            context.read<GameManagerBloc>().add(const ClearStatusEvent());
          }
          if (state.success == 'room_created' ||
              state.success == 'room_joined') {
            MyToast.success(
              context,
              state.success == 'room_created'
                  ? "Lobby created successfully!"
                  : "Joined lobby successfully!",
            );
            context.read<GameManagerBloc>().add(const ClearStatusEvent());
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => const GameBoard()));
          }
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Gap(20),
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Column(
                        children: [
                          Image.asset(
                            AppAssets.decorative,
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                          const Gap(10),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "TIC ",
                                  style: GoogleFonts.uncialAntiqua(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.creatorColor,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.creatorColor
                                            .withValues(alpha: 0.6),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                TextSpan(
                                  text: "TAC ",
                                  style: GoogleFonts.uncialAntiqua(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.indigoAccent,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.indigoAccent
                                            .withValues(alpha: 0.6),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                TextSpan(
                                  text: "TOE ",
                                  style: GoogleFonts.uncialAntiqua(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.greenAccent,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.greenAccent.withValues(
                                          alpha: 0.6,
                                        ),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(40),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.1),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SlidingToggle(
                            isCreatingRoom: _isCreatingRoom,
                            onToggle: (value) {
                              setState(() {
                                _isCreatingRoom = value;
                              });
                            },
                            themeColor: themeColor,
                          ),
                          const Gap(30),

                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              key: ValueKey<bool>(_isCreatingRoom),
                              children: [
                                MenuTextField(
                                  controller: _nameController,
                                  hintText: "Enter your name",
                                  icon: Icons.person_outline,
                                  activeColor: themeColor,
                                ),
                                if (!_isCreatingRoom) ...[
                                  const Gap(16),
                                  MenuTextField(
                                    controller: _roomCodeController,
                                    hintText: "Enter room code",
                                    icon: Icons.vpn_key_outlined,
                                    activeColor: themeColor,
                                    isCode: true,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const Gap(30),

                          BlocBuilder<GameManagerBloc, GameManagerState>(
                            builder: (context, state) {
                              return PlayButton(
                                onTap: _handleSubmit,
                                themeColor: themeColor,
                                isCreatingRoom: _isCreatingRoom,
                                isLoading: state.isLoading,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Gap(40),

                    if (kIsWeb) ...[
                      const WebApkDownloadButton(),
                      const Gap(20),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Reusable Widgets for Menu Screen
// ----------------------------------------------------

class SlidingToggle extends StatelessWidget {
  const SlidingToggle({
    super.key,
    required this.isCreatingRoom,
    required this.onToggle,
    required this.themeColor,
  });

  final bool isCreatingRoom;
  final ValueChanged<bool> onToggle;
  final Color themeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment: isCreatingRoom
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: LinearGradient(
                    colors: isCreatingRoom
                        ? [AppColors.creatorColor, AppColors.redAccent]
                        : [AppColors.guestColor, AppColors.indigoAccent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(true),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Create Room",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isCreatingRoom
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onToggle(false),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Text(
                      "Join Room",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: !isCreatingRoom
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MenuTextField extends StatelessWidget {
  const MenuTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.activeColor,
    this.isCode = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final Color activeColor;
  final bool isCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: activeColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.06),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        textCapitalization: isCode
            ? TextCapitalization.characters
            : TextCapitalization.words,
        maxLength: isCode ? 8 : 20,
        decoration: InputDecoration(
          counterText: "",
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14),
          prefixIcon: Icon(icon, color: activeColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.onTap,
    required this.themeColor,
    required this.isCreatingRoom,
    required this.isLoading,
  });

  final VoidCallback? onTap;
  final Color themeColor;
  final bool isCreatingRoom;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isCreatingRoom
                ? [AppColors.creatorColor, AppColors.redAccent]
                : [AppColors.guestColor, AppColors.indigoAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: themeColor.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isCreatingRoom
                          ? Icons.add_box_rounded
                          : Icons.login_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isCreatingRoom ? "CREATE LOBBY" : "JOIN LOBBY",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class WebApkDownloadButton extends StatefulWidget {
  const WebApkDownloadButton({super.key});

  @override
  State<WebApkDownloadButton> createState() => _WebApkDownloadButtonState();
}

class _WebApkDownloadButtonState extends State<WebApkDownloadButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          launchUrlString(
            "https://github.com/iamankitm05/tic_tac_toe_board_game/releases/download/tic-tac-toe-v1.0.0/Tic-Tac-Toe-V1.0.0",
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? Matrix4.diagonal3Values(1.04, 1.04, 1.0)
              : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? AppColors.greenAccent
                  : AppColors.greenAccent.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.greenAccent.withValues(
                  alpha: _isHovered ? 0.3 : 0.08,
                ),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.greenAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.android,
                  color: AppColors.greenAccent,
                  size: 24,
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Download Android App",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    "Get the APK for mobile play",
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const Gap(16),
              const Icon(
                Icons.file_download_outlined,
                color: AppColors.greenAccent,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
