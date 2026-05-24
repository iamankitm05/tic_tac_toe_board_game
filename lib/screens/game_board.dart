import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tic_tac_toe_board_game/blocs/game_manager/game_manager_bloc.dart';
import 'package:tic_tac_toe_board_game/modals/room.dart';
import 'package:tic_tac_toe_board_game/utils/app_assets.dart';
import 'package:tic_tac_toe_board_game/utils/my_toast.dart';
import 'package:tic_tac_toe_board_game/utils/app_colors.dart';
import 'package:tic_tac_toe_board_game/widgets/custom_scaffold.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  String? _lastShownRequester;
  bool _isDialogShowing = false;

  // Local helper to calculate the winning combo indices for highlights
  List<int>? _getWinningCombo(List<String> board) {
    final List<List<int>> winLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6],             // Diagonals
    ];

    for (var line in winLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];

      if (a.isNotEmpty && a == b && a == c) {
        return line;
      }
    }
    return null;
  }

  void _copyRoomCode(BuildContext context, String roomId) {
    Clipboard.setData(ClipboardData(text: roomId));
    MyToast.success(context, 'Lobby code $roomId copied!');
  }

  void _showPlayRequestDialog(BuildContext context, String requesterName) {
    _isDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            "Play Lobby Request",
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "$requesterName wants to join as Player 2. If accepted, current scores will reset to 0.",
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                context.read<GameManagerBloc>().add(const AcceptPlayRequestEvent(false));
                Navigator.of(dialogContext).pop();
              },
              child: Text("DECLINE", style: GoogleFonts.poppins(color: AppColors.redAccent)),
            ),
            TextButton(
              onPressed: () {
                _isDialogShowing = false;
                context.read<GameManagerBloc>().add(const AcceptPlayRequestEvent(true));
                Navigator.of(dialogContext).pop();
              },
              child: Text("ACCEPT", style: GoogleFonts.poppins(color: AppColors.greenAccent)),
            ),
          ],
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }

  void _showGuestListBottomSheet(BuildContext context, Room room, GameManagerState state) {
    final myName = state.currentPlayName;
    final isAlreadyPlayer = room.creatorName == myName || room.guestName == myName;
    final isPendingRequest = room.requestingPlayer == myName;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground.withValues(alpha: 0.95),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "LOBBY VIEWERS (${room.guests.length})",
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                const Gap(12),
                if (room.guests.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        "No other viewers in the lobby.",
                        style: GoogleFonts.poppins(color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: room.guests.length,
                      itemBuilder: (context, index) {
                        final guest = room.guests[index];
                        final isMe = guest == myName;
                        final isCurrentPlayer2 = guest == room.guestName;

                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.white10,
                            child: Icon(Icons.visibility, color: Colors.white60, size: 20),
                          ),
                          title: Text(
                            guest + (isMe ? " (You)" : ""),
                            style: GoogleFonts.poppins(
                              color: isMe ? AppColors.creatorColor : AppColors.textPrimary,
                              fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isCurrentPlayer2
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.guestColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.guestColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    "PLAYER 2",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.guestColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                const Gap(20),
                if (!isAlreadyPlayer)
                  ElevatedButton(
                    onPressed: isPendingRequest
                        ? null
                        : () {
                            context.read<GameManagerBloc>().add(const RequestToPlayEvent());
                            Navigator.pop(sheetContext);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.creatorColor,
                      disabledBackgroundColor: Colors.white12,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isPendingRequest ? "REQUEST PENDING..." : "REQUEST TO PLAY",
                      style: GoogleFonts.poppins(
                        color: isPendingRequest ? AppColors.textMuted : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameManagerBloc, GameManagerState>(
      listenWhen: (previous, current) =>
          (previous.room != null && current.room == null) ||
          previous.error != current.error ||
          previous.warning != current.warning ||
          previous.info != current.info ||
          previous.room?.requestingPlayer != current.room?.requestingPlayer,
      listener: (context, state) {
        if (state.room == null) {
          _isDialogShowing = false;
          Navigator.of(context).popUntil((route) => route.isFirst);
          MyToast.error(context, 'The lobby was closed or host disconnected.');
          return;
        }

        if (state.error != null) {
          MyToast.error(context, state.error!);
        }

        if (state.warning != null) {
          MyToast.warning(context, state.warning!);
        }

        if (state.info != null) {
          MyToast.info(context, state.info!);
        }

        // Show dialog to Host when someone requests to play (safeguarded against duplicate overlays)
        if (state.isCreator && state.room?.requestingPlayer != null) {
          if (_lastShownRequester != state.room!.requestingPlayer) {
            if (_isDialogShowing) {
              _isDialogShowing = false;
              Navigator.of(context).pop(); // Dismiss previous request dialog
            }
            _lastShownRequester = state.room!.requestingPlayer;
            _showPlayRequestDialog(context, state.room!.requestingPlayer!);
          }
        } else if (state.room?.requestingPlayer == null) {
          if (_isDialogShowing) {
            _isDialogShowing = false;
            Navigator.of(context).pop(); // Dismiss request dialog since it was resolved/canceled
          }
          _lastShownRequester = null;
        }
      },
      child: CustomScaffold(
        child: BlocBuilder<GameManagerBloc, GameManagerState>(
          builder: (context, state) {
            final room = state.room;
            if (room == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.creatorColor),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 650;
                return Column(
                  children: [
                    BoardHeader(
                      room: room,
                      state: state,
                      onBack: () {
                        context.read<GameManagerBloc>().add(const LeaveRoomEvent());
                        Navigator.of(context).pop();
                      },
                      onCopy: () => _copyRoomCode(context, room.id),
                      onOpenGuestList: () => _showGuestListBottomSheet(context, room, state),
                    ),
                    const Gap(20),
                    Expanded(
                      child: isWide
                          ? _buildWideLayout(context, room, state)
                          : _buildMobileLayout(context, room, state),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // Responsive layout: Desktop (Side cards)
  Widget _buildWideLayout(BuildContext context, Room room, GameManagerState state) {
    final winningCombo = _getWinningCombo(room.board);

    final bool isXActive = room.isXTurn && room.winner == null && room.guestName != null;
    final bool isOActive = !room.isXTurn && room.winner == null && room.guestName != null;

    final String myName = state.currentPlayName ?? "";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left Player (X) Card - Host
        Expanded(
          child: _PlayerCard(
            name: room.creatorName,
            isX: true,
            isActive: isXActive,
            score: room.player1Score,
            isCurrentPlayer: room.creatorName == myName,
          ),
        ),
        const Gap(30),

        // Interactive game grid
        SizedBox(
          width: 380,
          height: 380,
          child: Stack(
            children: [
              _Board(
                board: room.board,
                onTapCell: (index) {
                  context.read<GameManagerBloc>().add(MakeMoveEvent(index));
                },
                winningCombo: winningCombo,
              ),
              if (room.winner != null)
                WinnerOverlay(
                  room: room,
                  onPlayAgain: () {
                    context.read<GameManagerBloc>().add(const ResetRoundEvent());
                  },
                ),
            ],
          ),
        ),
        const Gap(30),

        // Right Player (O) Card - Guest
        Expanded(
          child: _PlayerCard(
            name: room.guestName ?? "Waiting for Opponent...",
            isX: false,
            isActive: isOActive,
            score: room.player2Score,
            isCurrentPlayer: room.guestName == myName,
          ),
        ),
      ],
    );
  }

  // Responsive layout: Mobile (Stacked cards, grid centered)
  Widget _buildMobileLayout(BuildContext context, Room room, GameManagerState state) {
    final winningCombo = _getWinningCombo(room.board);

    final bool isXActive = room.isXTurn && room.winner == null && room.guestName != null;
    final bool isOActive = !room.isXTurn && room.winner == null && room.guestName != null;

    final String myName = state.currentPlayName ?? "";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _PlayerCard(
                name: room.creatorName,
                isX: true,
                isActive: isXActive,
                score: room.player1Score,
                isCurrentPlayer: room.creatorName == myName,
                compact: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                "VS",
                style: GoogleFonts.poppins(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: _PlayerCard(
                name: room.guestName ?? "Waiting...",
                isX: false,
                isActive: isOActive,
                score: room.player2Score,
                isCurrentPlayer: room.guestName == myName,
                compact: true,
              ),
            ),
          ],
        ),
        const Gap(30),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                constraints: const BoxConstraints(
                  maxWidth: 380,
                  maxHeight: 380,
                ),
                child: Stack(
                  children: [
                    _Board(
                      board: room.board,
                      onTapCell: (index) {
                        context.read<GameManagerBloc>().add(MakeMoveEvent(index));
                      },
                      winningCombo: winningCombo,
                    ),
                    if (room.winner != null)
                      WinnerOverlay(
                        room: room,
                        onPlayAgain: () {
                          context.read<GameManagerBloc>().add(const ResetRoundEvent());
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Gap(10),
      ],
    );
  }
}

// ----------------------------------------------------
// Reusable Widgets for Board Screen
// ----------------------------------------------------

class BoardHeader extends StatelessWidget {
  const BoardHeader({
    super.key,
    required this.room,
    required this.state,
    required this.onBack,
    required this.onCopy,
    required this.onOpenGuestList,
  });

  final Room room;
  final GameManagerState state;
  final VoidCallback onBack;
  final VoidCallback onCopy;
  final VoidCallback onOpenGuestList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: onBack,
        ),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.indigoAccent.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "LOBBY: ${room.id}",
                  style: GoogleFonts.poppins(
                    color: AppColors.indigoAccent.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const Gap(6),
                Icon(
                  Icons.copy,
                  color: AppColors.indigoAccent.withValues(alpha: 0.7),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.people_alt_outlined, color: Colors.white70, size: 22),
              if (room.guests.isNotEmpty)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 13,
                      minHeight: 13,
                    ),
                    child: Text(
                      '${room.guests.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: onOpenGuestList,
        ),
      ],
    );
  }
}

class WinnerOverlay extends StatelessWidget {
  const WinnerOverlay({
    super.key,
    required this.room,
    required this.onPlayAgain,
  });

  final Room room;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final isDraw = room.winner == "Draw";
    final isXWinner = room.winner == "X";
    final themeColor = isDraw
        ? AppColors.amberAccent
        : (isXWinner ? AppColors.creatorColor : AppColors.guestColor);

    String detailText;
    if (isDraw) {
      detailText = "Both players played well.";
    } else if (isXWinner) {
      detailText = "${room.creatorName} wins this round!";
    } else {
      detailText = "${room.guestName ?? 'Guest'} wins this round!";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDraw ? Icons.handshake_outlined : Icons.emoji_events_outlined,
                  color: themeColor,
                  size: 48,
                ),
              ),
              const Gap(16),
              Text(
                isDraw ? "ROUND DRAW" : "VICTORY!",
                style: GoogleFonts.poppins(
                  color: themeColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  letterSpacing: 1.5,
                ),
              ),
              const Gap(8),
              Text(
                detailText,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const Gap(24),
              ElevatedButton.icon(
                onPressed: onPlayAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: themeColor.withValues(alpha: 0.4),
                ),
                icon: const Icon(Icons.replay, fontWeight: FontWeight.bold),
                label: Text(
                  "PLAY AGAIN",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom Board Render
class _Board extends StatelessWidget {
  const _Board({
    required this.board,
    required this.onTapCell,
    required this.winningCombo,
  });

  final List<String> board;
  final Function(int) onTapCell;
  final List<int>? winningCombo;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        children: [
          // Glowing grid lines
          Positioned.fill(
            child: Column(
              children: [
                const Spacer(),
                _BoardLine(isVertical: false, isGlowing: winningCombo != null),
                const Spacer(),
                _BoardLine(isVertical: false, isGlowing: winningCombo != null),
                const Spacer(),
              ],
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                const Spacer(),
                _BoardLine(isVertical: true, isGlowing: winningCombo != null),
                const Spacer(),
                _BoardLine(isVertical: true, isGlowing: winningCombo != null),
                const Spacer(),
              ],
            ),
          ),

          // Interactivity cells overlay
          Positioned.fill(
            child: GridView.count(
              padding: const EdgeInsets.all(8),
              crossAxisCount: 3,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(9, (index) {
                final cellValue = board[index];
                final isWinningTile = winningCombo?.contains(index) ?? false;

                return GestureDetector(
                  onTap: () => onTapCell(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isWinningTile
                          ? (cellValue == "X" ? AppColors.creatorColor : AppColors.guestColor)
                              .withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: isWinningTile
                          ? Border.all(
                              color: cellValue == "X" ? AppColors.creatorColor : AppColors.guestColor,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) {
                          return ScaleTransition(
                            scale: CurvedAnimation(
                              parent: animation,
                              curve: Curves.elasticOut,
                            ),
                            child: child,
                          );
                        },
                        child: cellValue.isEmpty
                            ? const SizedBox.shrink()
                            : Image.asset(
                                cellValue == "X" ? AppAssets.cross : AppAssets.circle,
                                key: ValueKey<String>("$index-$cellValue"),
                                width: 68,
                                height: 68,
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// Glowing board line builders
class _BoardLine extends StatelessWidget {
  const _BoardLine({required this.isVertical, required this.isGlowing});

  final bool isVertical;
  final bool isGlowing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isVertical ? 6 : double.infinity,
      height: isVertical ? double.infinity : 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: LinearGradient(
          colors: isGlowing
              ? [AppColors.indigoAccent, AppColors.purpleAccent, AppColors.pinkAccent]
              : [Colors.blueAccent.withValues(alpha: 0.35), Colors.blueAccent],
          begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
          end: isVertical ? Alignment.bottomCenter : Alignment.centerRight,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: AppColors.purpleAccent.withValues(alpha: 0.6),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
    );
  }
}

// Score & Player Cards
class _PlayerCard extends StatefulWidget {
  const _PlayerCard({
    required this.name,
    required this.isX,
    required this.isActive,
    required this.score,
    required this.isCurrentPlayer,
    this.compact = false,
  });

  final String name;
  final bool isX;
  final bool isActive;
  final int score;
  final bool isCurrentPlayer;
  final bool compact;

  @override
  State<_PlayerCard> createState() => _PlayerCardState();
}

class _PlayerCardState extends State<_PlayerCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseShadow;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseShadow = Tween<double>(begin: 8.0, end: 20.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _PlayerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.isX ? AppColors.creatorColor : AppColors.guestColor;

    return AnimatedBuilder(
      animation: _pulseShadow,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 12 : 20,
            vertical: widget.compact ? 12 : 20,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: widget.isActive ? 0.55 : 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isActive ? activeColor : activeColor.withValues(alpha: 0.15),
              width: widget.isActive ? 2.0 : 1.0,
            ),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      blurRadius: _pulseShadow.value,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                widget.isX ? AppAssets.cross : AppAssets.circle,
                width: widget.compact ? 24 : 32,
                height: widget.compact ? 24 : 32,
              ),
              const Gap(10),
              Flexible(
                child: Text(
                  widget.name + (widget.isCurrentPlayer ? " (You)" : ""),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: widget.isActive ? Colors.white : Colors.white70,
                    fontWeight: widget.isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: widget.compact ? 13 : 16,
                  ),
                ),
              ),
            ],
          ),
          Gap(widget.compact ? 8 : 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SCORE:",
                  style: GoogleFonts.poppins(
                    color: AppColors.textMuted,
                    fontSize: widget.compact ? 10 : 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  "${widget.score}",
                  style: GoogleFonts.poppins(
                    color: activeColor,
                    fontSize: widget.compact ? 15 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
