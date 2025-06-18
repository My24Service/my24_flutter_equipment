import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_orders/models/order/api.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/location_bloc.dart';
import '../../blocs/location_states.dart';
import '../../models/location/models.dart';
import '../../widgets/location/detail.dart';
import '../../widgets/location/error.dart';

abstract class BaseLocationDetailPage extends StatelessWidget {
  final i18n = My24i18n(basePath: "equipment.location");
  final EquipmentLocationBloc bloc;
  final int? pk;
  final String? uuid;
  final CoreWidgets widgets = CoreWidgets();
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;
  final OrderApi orderApi = OrderApi();

  Future<Widget?> getDrawerForUserWithSubmodel(
      BuildContext context, String? submodel);

  void navEquipmentDetail(int equipmentPk);

  Future<EquipmentLocationPageMetaData> getPageData(BuildContext context) async {
    String? memberPicture = await coreUtils.getMemberPicture();
    String? submodel = await coreUtils.getUserSubmodel();
    Widget? drawer = context.mounted ? await getDrawerForUserWithSubmodel(context, submodel) : null;
    final OrderTypes orderTypes = await orderApi.fetchOrderTypes();

    EquipmentLocationPageMetaData result = EquipmentLocationPageMetaData(
      memberPicture: memberPicture,
      submodel: submodel,
      drawer: drawer,
      orderTypes: orderTypes.getForEquipmentDetail()
    );

    return result;
  }

  BaseLocationDetailPage({
    super.key,
    this.pk,
    this.uuid,
    required this.bloc,
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
  });

  EquipmentLocationBloc _initialBlocCall() {
    bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));

    if (uuid != null) {
      bloc.add(EquipmentLocationEvent(
          status: EquipmentLocationEventStatus.fetchDetailByUuid,
          uuid: uuid
      ));
    } else if (pk != null) {
      bloc.add(EquipmentLocationEvent(
          status: EquipmentLocationEventStatus.fetchDetail,
          pk: pk!
      ));
    } else {
      throw Exception("No pk and no uuid");
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EquipmentLocationPageMetaData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            EquipmentLocationPageMetaData? pageData = snapshot.data;

            return BlocProvider<EquipmentLocationBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<EquipmentLocationBloc, EquipmentLocationBaseState>(
                    listener: (context, state) {
                    },
                    builder: (context, state) {
                      return Scaffold(
                        drawer: pageData!.drawer,
                        body: _getBody(context, state, pageData),
                      );
                    }
                )
            );
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    i18n.$trans("error_arg", pathOverride: "generic",
                        namedArgs: {"error": "${snapshot.error}"}
                    )
                )
            );
          } else {
            return Scaffold(
                body: widgets.loadingNotice()
            );
          }
        }
    );
  }

  Widget _getBody(context, state, EquipmentLocationPageMetaData? pageData) {
    if (state is EquipmentLocationInitialState) {
      return widgets.loadingNotice();
    }

    if (state is EquipmentLocationLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is EquipmentLocationErrorState) {
      return EquipmentDetailErrorWidget(
        error: state.message,
        memberPicture: pageData!.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is EquipmentLocationDetailLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders.count,
          next: state.orders.next,
          previous: state.orders.previous,
          currentPage: state.page ?? 1,
          pageSize: 20
      );

      return LocationDetailWidget(
        location: state.location,
        memberPicture: pageData!.memberPicture,
        orders: state.orders,
        paginationInfo: paginationInfo,
        searchQuery: state.query,
        widgets: widgets,
        i18n: i18n,
        pk: pk,
        uuid: uuid,
        navDetailFunction: navDetailFunction,
        navFormFromEquipmentFunction: navFormFromEquipmentFunction,
        orderTypes: pageData.orderTypes,
        equipment: state.equipment,
        navEquipmentDetailFunction: navDetailFunction,
      );
    }

    return widgets.loadingNotice();
  }
}
