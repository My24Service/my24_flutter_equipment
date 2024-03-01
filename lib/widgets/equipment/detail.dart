import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/equipment_bloc.dart';
import '../../models/equipment/models.dart';

class EquipmentDetailWidget extends BaseSliverListStatelessWidget{
  final Equipment equipment;
  final Orders orders;
  final TextEditingController searchController = TextEditingController();
  final String? searchQuery;
  final int? pk;
  final String? uuid;
  final NavDetailFunction navDetailFunction;

  EquipmentDetailWidget({
    super.key,
    required this.equipment,
    required this.orders,
    required super.paginationInfo,
    required super.memberPicture,
    required this.searchQuery,
    required super.widgets,
    required super.i18n,
    required this.pk,
    required this.uuid,
    required this.navDetailFunction
  }) {
    searchController.text = searchQuery ?? '';
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('detail.app_bar_title');
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentBloc>(context);

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
  }

  @override
  Widget getBottomSection(BuildContext context) {
    return widgets.showPaginationSearchSection(
        context,
        paginationInfo,
        searchController,
        _nextPage,
        _previousPage,
        _doSearch
    );
  }

  @override
  String getAppBarSubtitle(BuildContext context) {
    return "";
  }

  @override
  SliverList getPreSliverListContent(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            return Column(
              children: [
                EquipmentInfoCard(equipment: equipment),
                widgets.getMy24Divider(context),
              ],
            );
          },
          childCount: 1,
        )
    );
  }

  @override
  SliverList getSliverList(BuildContext context) {
    return SliverList(
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int index) {
            Order order = orders.results![index];
            Widget content = _getContent(context, order);

            return Column(
              children: [
                content,
                const SizedBox(height: 2),
                if (index < orders.results!.length-1)
                  widgets.getMy24Divider(context)
              ],
            );
          },
          childCount: orders.results!.length,
        )
    );
  }

  // private methods
  Widget _getContent(BuildContext context, Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: widgets.createOrderHistoryListHeader2(order.orderDate!),
          subtitle: widgets.createOrderHistoryListSubtitle2(
              order,
              widgets.buildItemListCustomWidget(
                  i18n.$trans('detail.info_workorder'),
                  _createWorkorderText(order, context)
              ),
              widgets.buildItemListCustomWidget(
                  i18n.$trans('detail.info_view_order'),
                  _createOrderDetailButton(context, order)
              )
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _createOrderlinesSection(context, order.orderLines)
        )
      ],
    );
  }

  Widget _createWorkorderText(Order order, BuildContext context) {
    return widgets.createViewWorkOrderButton(order.workorderPdfUrl, context);
  }

  Widget _createOrderDetailButton(BuildContext context, Order order) {
    return widgets.createElevatedButtonColored(
        i18n.$trans('detail.button_view_order'),
        () => _navOrderDetail(context, order.id!)
    );
  }

  Widget _createOrderlinesSection(BuildContext context, List<Orderline>? orderLines) {
    return widgets.buildItemsSection(
        context,
        i18n.$trans('detail.header_orderlines'),
        orderLines,
            (Orderline orderline) {
          String equipmentLocationTitle = "${i18n.$trans('info_equipment', pathOverride: 'generic')} / ${i18n.$trans('info_location', pathOverride: 'generic')}";
          String equipmentLocationValue = "${orderline.product?? '-'} / ${orderline.location?? '-'}";
          return <Widget>[
            ...widgets.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
            if (orderline.remarks != null && orderline.remarks != "")
              ...widgets.buildItemListKeyValueList(i18n.$trans('info_remarks', pathOverride: 'generic'), orderline.remarks)
          ];
        },
            (Orderline orderline) {
          return <Widget>[];
        },
        withLastDivider: false
    );
  }

  void _navOrderDetail(BuildContext context, int orderPk) {
    navDetailFunction(context, orderPk);
  }

  _nextPage(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentBloc>(context);

    if (uuid != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: paginationInfo!.currentPage! + 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetail,
        pk: pk!,
        page: paginationInfo!.currentPage! + 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentBloc>(context);

    if (uuid != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: paginationInfo!.currentPage! - 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetail,
        pk: pk!,
        page: paginationInfo!.currentPage! - 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentBloc>(context);

    bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
    bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doSearch));

    if (uuid != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentEvent(status: EquipmentEventStatus.doAsync));
      bloc.add(EquipmentEvent(
        status: EquipmentEventStatus.fetchDetail,
        pk: pk!,
        page: 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }
}

class EquipmentInfoCard extends StatelessWidget {
  final Equipment equipment;

  const EquipmentInfoCard({
    super.key,
    required this.equipment
  });

  @override
  Widget build(BuildContext context) {
    final String name = equipment.locationName != null ? '${equipment.name} - ${equipment.locationName}' : equipment.name!;
    return Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text(name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              checkNull(equipment.identifier)),
          leading: Icon(
            Icons.construction,
            color: Colors.blue[500],
          ),
        ),
      ],
    );
  }
}
