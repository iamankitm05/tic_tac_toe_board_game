part of 'game_manager_bloc.dart';

sealed class GameManagerEvent extends Equatable {
  const GameManagerEvent();

  @override
  List<Object?> get props => [];
}

class CreateRoomEvent extends GameManagerEvent {
  const CreateRoomEvent(this.creatorName);
  final String creatorName;

  @override
  List<Object?> get props => [creatorName];
}

class JoinRoomEvent extends GameManagerEvent {
  const JoinRoomEvent({required this.guestName, required this.roomId});
  final String guestName;
  final String roomId;

  @override
  List<Object?> get props => [guestName, roomId];
}

class UpdateRoomStreamEvent extends GameManagerEvent {
  const UpdateRoomStreamEvent(this.room);
  final Room room;

  @override
  List<Object?> get props => [room];
}

class MakeMoveEvent extends GameManagerEvent {
  const MakeMoveEvent(this.index);
  final int index;

  @override
  List<Object?> get props => [index];
}

class ResetRoundEvent extends GameManagerEvent {
  const ResetRoundEvent();
}

class LeaveRoomEvent extends GameManagerEvent {
  const LeaveRoomEvent();
}

class RequestToPlayEvent extends GameManagerEvent {
  const RequestToPlayEvent();
}

class AcceptPlayRequestEvent extends GameManagerEvent {
  const AcceptPlayRequestEvent(this.accept);
  final bool accept;

  @override
  List<Object?> get props => [accept];
}
