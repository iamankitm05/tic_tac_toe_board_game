import 'package:equatable/equatable.dart';

class Room extends Equatable {
  const Room({
    required this.id,
    required this.creatorName,
    this.guestName,
    required this.board,
    required this.isXTurn,
    required this.player1Score,
    required this.player2Score,
    this.winner,
    required this.isGameActive,
    required this.guests,
    this.requestingPlayer,
  });

  final String id;
  final String creatorName;
  final String? guestName;
  final List<String> board;
  final bool isXTurn;
  final int player1Score;
  final int player2Score;
  final String? winner;
  final bool isGameActive;
  final List<String> guests;
  final String? requestingPlayer;

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] as String,
      creatorName: map['creatorName'] as String,
      guestName: map['guestName'] as String?,
      board: List<String>.from(map['board'] as List),
      isXTurn: map['isXTurn'] as bool,
      player1Score: map['player1Score'] as int,
      player2Score: map['player2Score'] as int,
      winner: map['winner'] as String?,
      isGameActive: map['isGameActive'] as bool? ?? true,
      guests: List<String>.from((map['guests'] as List?) ?? []),
      requestingPlayer: map['requestingPlayer'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorName': creatorName,
      'guestName': guestName,
      'board': board,
      'isXTurn': isXTurn,
      'player1Score': player1Score,
      'player2Score': player2Score,
      'winner': winner,
      'isGameActive': isGameActive,
      'guests': guests,
      'requestingPlayer': requestingPlayer,
    };
  }

  Room copyWith({
    String? id,
    String? creatorName,
    String? guestName,
    bool clearGuestName = false,
    List<String>? board,
    bool? isXTurn,
    int? player1Score,
    int? player2Score,
    String? winner,
    bool clearWinner = false,
    bool? isGameActive,
    List<String>? guests,
    String? requestingPlayer,
    bool clearRequestingPlayer = false,
  }) {
    return Room(
      id: id ?? this.id,
      creatorName: creatorName ?? this.creatorName,
      guestName: clearGuestName ? null : (guestName ?? this.guestName),
      board: board ?? this.board,
      isXTurn: isXTurn ?? this.isXTurn,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
      winner: clearWinner ? null : (winner ?? this.winner),
      isGameActive: isGameActive ?? this.isGameActive,
      guests: guests ?? this.guests,
      requestingPlayer: clearRequestingPlayer ? null : (requestingPlayer ?? this.requestingPlayer),
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorName,
        guestName,
        board,
        isXTurn,
        player1Score,
        player2Score,
        winner,
        isGameActive,
        guests,
        requestingPlayer,
      ];
}
