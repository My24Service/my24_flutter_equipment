import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/models/models.dart';
import 'package:my24_flutter_equipment/blocs/equipment_states.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/equipment_bloc.dart';
import '../../models/equipment/models.dart';
import '../../widgets/equipment/detail.dart';
import '../../widgets/equipment/error.dart';

abstract class BaseEquipmentDetailPage extends StatelessWidget{
  final i18n = My24i18n(basePath: "equipment");
  final EquipmentBloc bloc;
  final int? pk;
  final String? uuid;
  final CoreWidgets widgets = CoreWidgets();
  final NavDetailFunction navDetailFunction;

  Future<EquipmentPageMetaData> getPageData() async {
    String? memberPicture = await coreUtils.getMemberPicture();
    String? submodel = await coreUtils.getUserSubmodel();

    EquipmentPageMetaData result = EquipmentPageMetaData(
        memberPicture: memberPicture,
        submodel: submodel,
        drawer: null
    );

    return result;
  }

  BaseEquipmentDetailPage({
    super.key,
    this.pk,
    this.uuid,
    required this.bloc,
    required this.navDetailFunction,
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
        future: getPageData(),
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

      return EquipmentDetailWidget(
        equipment: state.equipment,
        memberPicture: pageData!.memberPicture,
        orders: state.orders,
        paginationInfo: paginationInfo,
        searchQuery: state.query,
        widgets: widgets,
        i18n: i18n,
        pk: pk,
        uuid: uuid,
        navDetailFunction: navDetailFunction
      );
    }

    return widgets.loadingNotice();
  }
}
