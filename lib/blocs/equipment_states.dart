import 'package:equatable/equatable.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import '../models/equipment/models.dart';


abstract class EquipmentBaseState extends Equatable {}

class EquipmentInitialState extends EquipmentBaseState {
  @override
  List<Object> get props => [];
}

class EquipmentLoadingState extends EquipmentBaseState {
  @override
  List<Object> get props => [];
}

class EquipmentDetailLoadedState extends EquipmentBaseState {
  final Equipment equipment;
  final Orders orders;
  final String? query;
  final int? page;

  EquipmentDetailLoadedState({
    required this.equipment,
    required this.orders,
    this.query,
    this.page
  });

  @override
  List<dynamic> get props => [equipment, orders, query, page];
}

class EquipmentErrorState extends EquipmentBaseState {
  final String? message;

  EquipmentErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class EquipmentSearchState extends EquipmentBaseState {
  @override
  List<Object> get props => [];
}
