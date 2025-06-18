import 'package:equatable/equatable.dart';
import 'package:my24_flutter_orders/models/order/models.dart';

import '../models/equipment/models.dart';
import '../models/location/models.dart';


abstract class EquipmentLocationBaseState extends Equatable {}

class EquipmentLocationInitialState extends EquipmentLocationBaseState {
  @override
  List<Object> get props => [];
}

class EquipmentLocationLoadingState extends EquipmentLocationBaseState {
  @override
  List<Object> get props => [];
}

class EquipmentLocationDetailLoadedState extends EquipmentLocationBaseState {
  final EquipmentLocation location;
  final EquipmentPaginated equipment;
  final Orders orders;
  final String? query;
  final int? page;

  EquipmentLocationDetailLoadedState({
    required this.location,
    required this.equipment,
    required this.orders,
    this.query,
    this.page
  });

  @override
  List<dynamic> get props => [location, orders, query, page];
}

class EquipmentLocationErrorState extends EquipmentLocationBaseState {
  final String? message;

  EquipmentLocationErrorState({this.message});

  @override
  List<Object?> get props => [message];
}

class EquipmentLocationSearchState extends EquipmentLocationBaseState {
  @override
  List<Object> get props => [];
}
