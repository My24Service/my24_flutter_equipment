import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';
import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';

import 'package:my24_flutter_equipment/models/location/api.dart';
import 'package:my24_flutter_orders/models/order/api.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import '../models/location/models.dart';
import 'location_states.dart';

enum EquipmentLocationEventStatus {
  fetchDetailByUuid,
  fetchDetail,
  doAsync,
  doSearch,
}

final log = Logger('blocs.equipment_bloc');

class EquipmentLocationEvent {
  final String? uuid;
  final int? pk;
  final EquipmentLocationEventStatus? status;
  final int? page;
  final String? query;

  const EquipmentLocationEvent({
    this.status,
    this.uuid,
    this.pk,
    this.query,
    this.page
  });
}

class EquipmentLocationBloc extends Bloc<EquipmentLocationEvent, EquipmentLocationBaseState> {
  final EquipmentLocationApi locationApi = EquipmentLocationApi();
  final EquipmentApi equipmentApi = EquipmentApi();
  final OrderApi orderApi = OrderApi();

  EquipmentLocationBloc() : super(EquipmentLocationInitialState()) {
    on<EquipmentLocationEvent>((event, emit) async {
      if (event.status == EquipmentLocationEventStatus.fetchDetailByUuid) {
        await _handleFetchDetailByUuidEvent(event, emit);
      }
      if (event.status == EquipmentLocationEventStatus.fetchDetail) {
        await _handleFetchDetailEvent(event, emit);
      }
      if (event.status == EquipmentLocationEventStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == EquipmentLocationEventStatus.doSearch) {
        _handleDoSearchState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(EquipmentLocationEvent event, Emitter<EquipmentLocationBaseState> emit) {
    emit(EquipmentLocationLoadingState());
  }

  void _handleDoSearchState(EquipmentLocationEvent event, Emitter<EquipmentLocationBaseState> emit) {
    emit(EquipmentLocationSearchState());
  }

  Future<void> _handleFetchDetailByUuidEvent(EquipmentLocationEvent event, Emitter<EquipmentLocationBaseState> emit) async {
    try {
      final EquipmentLocation location = await locationApi.getByUuid(event.uuid!);
      final Orders orders = await orderApi.fetchAllForLocationOrders(
          locationPk: location.id!,
          page: event.page,
          query: event.query
      );
      final EquipmentPaginated equipment = await equipmentApi.getForLocation(location.id!);
      emit(EquipmentLocationDetailLoadedState(
        location: location,
        equipment: equipment,
        orders: orders
      ));
    } catch(e) {
      log.severe("error fetching by uuid: $e");
      emit(EquipmentLocationErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailEvent(EquipmentLocationEvent event, Emitter<EquipmentLocationBaseState> emit) async {
    try {
      final EquipmentLocation location = await locationApi.detail(event.pk!);
      final EquipmentPaginated equipment = await equipmentApi.getForLocation(location.id!);
      final Orders orders = await orderApi.fetchAllForLocationOrders(
          locationPk: location.id!,
        page: event.page,
        query: event.query
      );
      emit(EquipmentLocationDetailLoadedState(
          location: location,
          equipment: equipment,
          orders: orders
      ));
    } catch(e) {
      log.severe("error fetching detail: $e");
      emit(EquipmentLocationErrorState(message: e.toString()));
    }
  }
}
