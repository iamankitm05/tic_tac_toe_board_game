import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:tic_tac_toe_board_game/modals/room.dart';

part 'game_manager_event.dart';
part 'game_manager_state.dart';

class GameManagerBloc extends Bloc<GameManagerEvent, GameManagerState> {
  GameManagerBloc() : super(const GameManagerState()) {
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<UpdateRoomStreamEvent>(_onUpdateRoomStream);
    on<MakeMoveEvent>(_onMakeMove);
    on<ResetRoundEvent>(_onResetRound);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<RequestToPlayEvent>(_onRequestToPlay);
    on<AcceptPlayRequestEvent>(_onAcceptPlayRequest);
  }

  StreamSubscription<DocumentSnapshot>? _roomSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique 6-digit hexadecimal uppercase room ID
  String _generateHexRoomId() {
    final rand = math.Random();
    const chars = '0123456789ABCDEF';
    return List.generate(6, (_) => chars[rand.nextInt(16)]).join();
  }

  Future<void> _onCreateRoom(
    CreateRoomEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final roomId = _generateHexRoomId();
      final room = Room(
        id: roomId,
        creatorName: event.creatorName,
        guestName: null,
        board: List.filled(9, ""),
        isXTurn: true,
        player1Score: 0,
        player2Score: 0,
        winner: null,
        isGameActive: true,
        guests: const [],
        requestingPlayer: null,
      );

      // Save room to Firestore
      await _firestore.collection('rooms').doc(roomId).set(room.toMap());

      // Subscribe to realtime snapshots
      _roomSubscription?.cancel();
      _roomSubscription = _firestore
          .collection('rooms')
          .doc(roomId)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              final roomData = Room.fromMap(snapshot.data()!);
              add(UpdateRoomStreamEvent(roomData));
            }
          });

      emit(
        state.copyWith(
          isLoading: false,
          room: room,
          currentPlayName: event.creatorName,
          isCreator: true,
          success: 'room_created',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onJoinRoom(
    JoinRoomEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final roomId = event.roomId.toUpperCase().trim();
      final docRef = _firestore.collection('rooms').doc(roomId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        emit(
          state.copyWith(
            isLoading: false,
            error: "Room not found! Check code.",
          ),
        );
        return;
      }

      final room = Room.fromMap(docSnapshot.data()!);

      // Add guest to the guests list and automatically request play permission
      await docRef.update({
        'guests': FieldValue.arrayUnion([event.guestName]),
        'requestingPlayer': event.guestName,
      });

      // Subscribe to realtime snapshots
      _roomSubscription?.cancel();
      _roomSubscription = docRef.snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final roomData = Room.fromMap(snapshot.data()!);
          add(UpdateRoomStreamEvent(roomData));
        }
      });

      emit(
        state.copyWith(
          isLoading: false,
          room: room,
          currentPlayName: event.guestName,
          isCreator: false,
          success: 'room_joined',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _onUpdateRoomStream(
    UpdateRoomStreamEvent event,
    Emitter<GameManagerState> emit,
  ) {
    emit(state.copyWith(room: event.room));
  }

  Future<void> _onMakeMove(
    MakeMoveEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    final room = state.room;
    if (room == null || room.winner != null) return;

    // Verify both players are joined
    if (room.guestName == null) {
      emit(
        state.copyWith(warning: "Waiting for an opponent to join the room!"),
      );
      return;
    }

    final String myName = state.currentPlayName ?? "";
    final bool isPlayer1 = room.creatorName == myName;
    final bool isPlayer2 = room.guestName == myName;

    // Reject move if the caller is just a viewer/guest
    if (!isPlayer1 && !isPlayer2) {
      emit(
        state.copyWith(
          warning:
              "You are viewing the game as a Guest. Click the Guest list to request to play!",
        ),
      );
      return;
    }

    // Check if cell is empty
    if (room.board[event.index].isNotEmpty) return;

    // Check turn locks: Player 1 is X, Player 2 is O
    final String mySymbol = isPlayer1 ? "X" : "O";
    final bool isMyTurn =
        (room.isXTurn && mySymbol == "X") || (!room.isXTurn && mySymbol == "O");
    if (!isMyTurn) {
      final String activePlayerName = room.isXTurn
          ? room.creatorName
          : room.guestName!;
      emit(state.copyWith(info: "It's $activePlayerName's turn!"));
      return;
    }

    try {
      final newBoard = List<String>.from(room.board);
      newBoard[event.index] = mySymbol;

      // Check winning logic
      final result = _evaluateBoard(newBoard, room);

      final updatedRoom = room.copyWith(
        board: newBoard,
        isXTurn: !room.isXTurn,
        winner: result['winner'] as String?,
        player1Score: result['player1Score'] as int,
        player2Score: result['player2Score'] as int,
      );

      // Push updates to Firestore
      await _firestore
          .collection('rooms')
          .doc(room.id)
          .update(updatedRoom.toMap());
    } catch (e) {
      emit(state.copyWith(error: "Failed to place marker: ${e.toString()}"));
    }
  }

  Future<void> _onResetRound(
    ResetRoundEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    final room = state.room;
    if (room == null) return;

    try {
      final docRef = _firestore.collection('rooms').doc(room.id);
      await docRef.update({
        'board': List.filled(9, ""),
        'isXTurn': true,
        'winner': null,
        'isGameActive': true,
      });
    } catch (e) {
      emit(state.copyWith(error: "Failed to reset round: ${e.toString()}"));
    }
  }

  Future<void> _onLeaveRoom(
    LeaveRoomEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    _roomSubscription?.cancel();
    _roomSubscription = null;

    final room = state.room;
    final isCreator = state.isCreator;
    final myName = state.currentPlayName;

    emit(const GameManagerState()); // Reset BLoC state

    if (room != null && myName != null) {
      try {
        final docRef = _firestore.collection('rooms').doc(room.id);
        if (isCreator) {
          // If host leaves, delete the lobby from Firestore
          await docRef.delete();
        } else {
          final Map<String, dynamic> updates = {
            'guests': FieldValue.arrayRemove([myName]),
          };
          if (room.guestName == myName) {
            updates['guestName'] = null;
          }
          if (room.requestingPlayer == myName) {
            updates['requestingPlayer'] = null;
          }
          await docRef.update(updates);
        }
      } catch (_) {
        // Safe catch to ensure navigation pops out successfully
      }
    }
  }

  Future<void> _onRequestToPlay(
    RequestToPlayEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    final room = state.room;
    if (room == null || state.currentPlayName == null) return;

    try {
      await _firestore.collection('rooms').doc(room.id).update({
        'requestingPlayer': state.currentPlayName,
      });
    } catch (e) {
      emit(state.copyWith(error: "Play request failed: ${e.toString()}"));
    }
  }

  Future<void> _onAcceptPlayRequest(
    AcceptPlayRequestEvent event,
    Emitter<GameManagerState> emit,
  ) async {
    final room = state.room;
    if (room == null || room.requestingPlayer == null) return;

    try {
      final docRef = _firestore.collection('rooms').doc(room.id);
      if (event.accept) {
        // If accepted: make guest, reset board scores, and clear request
        await docRef.update({
          'guestName': room.requestingPlayer,
          'board': List.filled(9, ""),
          'isXTurn': true,
          'player1Score': 0,
          'player2Score': 0,
          'winner': null,
          'requestingPlayer': null,
        });
      } else {
        // If declined: just clear requestingPlayer
        await docRef.update({'requestingPlayer': null});
      }
    } catch (e) {
      emit(state.copyWith(error: "Failed to resolve request: ${e.toString()}"));
    }
  }

  // Internal board evaluator
  Map<String, dynamic> _evaluateBoard(List<String> board, Room room) {
    final List<List<int>> winLines = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
      [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
      [0, 4, 8], [2, 4, 6], // Diagonals
    ];

    String? winner;
    int p1Score = room.player1Score;
    int p2Score = room.player2Score;

    for (var line in winLines) {
      final a = board[line[0]];
      final b = board[line[1]];
      final c = board[line[2]];

      if (a.isNotEmpty && a == b && a == c) {
        winner = a;
        if (a == "X") {
          p1Score++;
        } else {
          p2Score++;
        }
        return {
          'winner': winner,
          'player1Score': p1Score,
          'player2Score': p2Score,
        };
      }
    }

    if (!board.contains("")) {
      winner = "Draw";
    }

    return {'winner': winner, 'player1Score': p1Score, 'player2Score': p2Score};
  }
}
