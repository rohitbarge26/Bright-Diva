import 'package:equatable/equatable.dart';


abstract class MisEvent extends Equatable {
  const MisEvent();

  @override
  List<Object> get props => [];
}

class MISFilterEvent extends MisEvent {
  String type;
  String fromDate;
  String toDate;
  String? customerId;

  MISFilterEvent({required this.type, required this.fromDate, required this.toDate, this.customerId});

  @override
  List<Object> get props => [type,fromDate,toDate,customerId!];
}
