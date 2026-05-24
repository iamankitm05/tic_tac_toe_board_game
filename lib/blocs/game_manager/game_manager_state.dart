part of 'game_manager_bloc.dart';

final class GameManagerState extends Equatable {
  const GameManagerState({
    this.isLoading = false,
    this.error,
    this.success,
    this.warning,
    this.info,
    this.room,
    this.currentPlayName,
    this.isCreator = false,
  });

  final bool isLoading;
  final String? error;
  final String? success;
  final String? warning;
  final String? info;
  final Room? room;
  final String? currentPlayName;
  final bool isCreator;

  GameManagerState copyWith({
    bool? isLoading,
    String? error,
    String? success,
    String? warning,
    String? info,
    Room? room,
    String? currentPlayName,
    bool? isCreator,
  }) {
    return GameManagerState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success,
      warning: warning,
      info: info,
      room: room ?? this.room,
      currentPlayName: currentPlayName ?? this.currentPlayName,
      isCreator: isCreator ?? this.isCreator,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    success,
    warning,
    info,
    room,
    currentPlayName,
    isCreator,
  ];
}
