import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:logging/logging.dart';

import 'package:my24_flutter_equipment/models/equipment/api.dart';
import 'package:my24_flutter_orders/models/order/api.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import '../models/equipment/models.dart';
import 'equipment_states.dart';

enum EquipmentEventStatus {
  fetchDetailByUuid,
  fetchDetail,
  doAsync,
  doSearch,
}

final log = Logger('blocs.equipment_bloc');

class EquipmentEvent {
  final String? uuid;
  final int? pk;
  final EquipmentEventStatus? status;
  final int? page;
  final String? query;

  const EquipmentEvent({
    this.status,
    this.uuid,
    this.pk,
    this.query,
    this.page
  });
}

class EquipmentBloc extends Bloc<EquipmentEvent, EquipmentBaseState> {
  final EquipmentApi equipmentApi = EquipmentApi();
  final OrderApi orderApi = OrderApi();

  EquipmentBloc() : super(EquipmentInitialState()) {
    on<EquipmentEvent>((event, emit) async {
      if (event.status == EquipmentEventStatus.fetchDetailByUuid) {
        await _handleFetchDetailByUuidEvent(event, emit);
      }
      if (event.status == EquipmentEventStatus.fetchDetail) {
        await _handleFetchDetailEvent(event, emit);
      }
      if (event.status == EquipmentEventStatus.doAsync) {
        _handleDoAsyncState(event, emit);
      }
      else if (event.status == EquipmentEventStatus.doSearch) {
        _handleDoSearchState(event, emit);
      }
    },
    transformer: sequential());
  }

  void _handleDoAsyncState(EquipmentEvent event, Emitter<EquipmentBaseState> emit) {
    emit(EquipmentLoadingState());
  }

  void _handleDoSearchState(EquipmentEvent event, Emitter<EquipmentBaseState> emit) {
    emit(EquipmentSearchState());
  }

  Future<void> _handleFetchDetailByUuidEvent(EquipmentEvent event, Emitter<EquipmentBaseState> emit) async {
    try {
      final Equipment equipment = await equipmentApi.getByUuid(event.uuid!);
      final Orders orders = await orderApi.fetchAllForEquipmentOrders(
          equipmentPk: equipment.id!,
          page: event.page,
          query: event.query
      );
      emit(EquipmentDetailLoadedState(
        equipment: equipment,
        orders: orders
      ));
    } catch(e) {
      log.severe("error fetching by uuid: $e");
      emit(EquipmentErrorState(message: e.toString()));
    }
  }

  Future<void> _handleFetchDetailEvent(EquipmentEvent event, Emitter<EquipmentBaseState> emit) async {
    try {
      final Equipment equipment = await equipmentApi.detail(event.pk!);
      final Orders orders = await orderApi.fetchAllForEquipmentOrders(
        equipmentPk: equipment.id!,
        page: event.page,
        query: event.query
      );
      emit(EquipmentDetailLoadedState(
          equipment: equipment,
          orders: orders
      ));
    } catch(e) {
      log.severe("error fetching detail: $e");
      emit(EquipmentErrorState(message: e.toString()));
    }
  }
}
