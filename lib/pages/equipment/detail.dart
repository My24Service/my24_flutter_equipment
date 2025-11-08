import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_equipment/blocs/equipment_states.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/equipment_bloc.dart';
import '../../models/equipment/models.dart';
import '../../widgets/equipment/detail.dart';
import '../../widgets/equipment/error.dart';

abstract class BaseEquipmentDetailPage extends StatelessWidget {
  final i18n = My24i18n(basePath: "equipment");
  final EquipmentBloc bloc;
  final int? pk;
  final String? uuid;
  final CoreWidgets widgets = CoreWidgets();
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;

  Future<Widget?> getDrawer(
      BuildContext context, String? submodel);

  Future<EquipmentPageMetaData> getPageData(BuildContext context) async {
    String? memberPicture = await bloc.coreUtils.getMemberPicture();
    String? submodel = await bloc.coreUtils.getUserSubmodel();
    Widget? drawer = context.mounted ? await getDrawer(context, submodel) : null;
    final OrderTypes orderTypes = await bloc.orderApi.fetchOrderTypes();

    EquipmentPageMetaData result = EquipmentPageMetaData(
      memberPicture: memberPicture,
      submodel: submodel,
      drawer: drawer,
      orderTypes: orderTypes.getForEquipmentDetail()
    );

    return result;
  }

  BaseEquipmentDetailPage({
    super.key,
    this.pk,
    this.uuid,
    required this.bloc,
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
  });

  EquipmentBloc _initialBlocCall() {
    bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));

    if (uuid != null) {
      bloc.add(EquipmentEvent(
          status: EquipmentEventStatus.fetchDetailByUuid,
          uuid: uuid
      ));
    } else if (pk != null) {
      bloc.add(EquipmentEvent(
          status: EquipmentEventStatus.fetchDetail,
          pk: pk!
      ));
    } else {
      throw Exception("No pk and no uuid");
    }

    return bloc;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EquipmentPageMetaData>(
        future: getPageData(context),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            EquipmentPageMetaData? pageData = snapshot.data;
            return BlocProvider<EquipmentBloc>(
                create: (context) => _initialBlocCall(),
                child: BlocConsumer<EquipmentBloc, EquipmentBaseState>(
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
            // print("ERROR: ${snapshot.error}");
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

  Widget _getBody(context, state, EquipmentPageMetaData? pageData) {
    if (state is EquipmentInitialState) {
      return widgets.loadingNotice();
    }

    if (state is EquipmentLoadingState) {
      return widgets.loadingNotice();
    }

    if (state is EquipmentErrorState) {
      return EquipmentDetailErrorWidget(
        error: state.message,
        memberPicture: pageData!.memberPicture,
        widgetsIn: widgets,
        i18nIn: i18n,
      );
    }

    if (state is EquipmentDetailLoadedState) {
      PaginationInfo paginationInfo = PaginationInfo(
          count: state.orders.count,
          next: state.orders.next,
          previous: state.orders.previous,
          currentPage: state.page ?? 1,
          pageSize: 20
      );

      // So the `uuid` is null at this point, likely because we didn't receive that data
      // from the backend. The `state.equipment` does not hold this information.
      return EquipmentDetailWidget(
        equipment: state.equipment,
        memberPicture: pageData!.memberPicture,
        orders: state.orders,
        paginationInfo: paginationInfo,
        searchQuery: state.query,
        widgets: widgets,
        i18n: i18n,
        pk: pk,
        uuid: state.equipment.uuid,
        navDetailFunction: navDetailFunction,
        navFormFromEquipmentFunction: navFormFromEquipmentFunction,
        orderTypes: pageData.orderTypes,
      );
    }

    return widgets.loadingNotice();
  }
}
