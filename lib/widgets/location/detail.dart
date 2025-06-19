import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_orders/common/widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/location_bloc.dart';
import '../../models/location/models.dart';

class LocationDetailWidget extends BaseSliverListStatelessWidget{
  final EquipmentLocation location;
  final Orders orders;
  final EquipmentPaginated equipment;
  final TextEditingController searchController = TextEditingController();
  final String? searchQuery;
  final int? pk;
  final String? uuid;
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;
  final List<String> orderTypes;
  // TODO use a function-type with signature
  final Function navEquipmentDetailFunction;

  LocationDetailWidget({
    super.key,
    required this.location,
    required this.orders,
    required this.equipment,
    required super.paginationInfo,
    required super.memberPicture,
    required this.searchQuery,
    required super.widgets,
    required super.i18n,
    required this.pk,
    required this.uuid,
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
    required this.orderTypes,
    required this.navEquipmentDetailFunction,
  }) {
    searchController.text = searchQuery ?? '';
  }

  @override
  String getAppBarTitle(BuildContext context) {
    return i18n.$trans('detail.app_bar_title');
  }

  @override
  void doRefresh(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentLocationBloc>(context);

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
                LocationInfoCard(
                  location: location,
                  i18n: i18n,
                ),
                widgets.createHeader(i18n.$trans('detail.equipment_header')),
                EquipmentListWidget(
                  equipment: equipment,
                  widgets: widgets,
                  i18n: i18n,
                  navEquipmentDetailFunction: navEquipmentDetailFunction,
                ),
                widgets.getMy24Divider(context),
                widgets.createHeader(i18n.$trans('detail.order_history'))
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
          title: OrderHistoryWithAcceptedListHeader(
            date: order.orderDate!,
            customerOrderAccepted: order.customerOrderAccepted!,
          ),
          subtitle: OrderHistoryListSubtitle(
              order: order,
              workorderWidget: order.customerOrderAccepted! ? widgets.buildItemListCustomWidget(
                  i18n.$trans('detail.info_workorder'),
                  _createWorkorderText(order, context)
              ) : null,
          ),
          onTap: () {
            _navOrderDetail(context, order.id!);
          }
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
    final bloc = BlocProvider.of<EquipmentLocationBloc>(context);

    if (uuid != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: paginationInfo!.currentPage! + 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetail,
        pk: pk!,
        page: paginationInfo!.currentPage! + 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }

  _previousPage(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentLocationBloc>(context);

    if (uuid != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: paginationInfo!.currentPage! - 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetail,
        pk: pk!,
        page: paginationInfo!.currentPage! - 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }

  _doSearch(BuildContext context) {
    final bloc = BlocProvider.of<EquipmentLocationBloc>(context);

    bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
    bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doSearch));

    if (uuid != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetailByUuid,
        uuid: uuid,
        page: 1,
        query: searchController.text,
      ));
    } else if (pk != null) {
      bloc.add(const EquipmentLocationEvent(status: EquipmentLocationEventStatus.doAsync));
      bloc.add(EquipmentLocationEvent(
        status: EquipmentLocationEventStatus.fetchDetail,
        pk: pk!,
        page: 1,
        query: searchController.text,
      ));
    } else {
      throw Exception("No pk and no uuid");
    }
  }
}

class LocationInfoCard extends StatelessWidget {
  final EquipmentLocation location;
  final My24i18n i18n;

  const LocationInfoCard({
    super.key,
    required this.location,
    required this.i18n
  });

  @override
  Widget build(BuildContext context) {
    final String name = location.name ?? "no name";
    return Column(
      // mainAxisSize: MainAxisSize.max,
      children: [
        ListTile(
          title: Text(name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              checkNull(location.identifier)),
          leading: Icon(
            Icons.construction,
            color: Colors.blue[500],
          ),
        ),
      ],
    );
  }
}

class EquipmentListWidget extends StatelessWidget {
  final EquipmentPaginated equipment;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final Function navEquipmentDetailFunction;

  const EquipmentListWidget({
    super.key,
    required this.equipment,
    required this.widgets,
    required this.i18n,
    required this.navEquipmentDetailFunction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ListTile(
                    title: Text(equipment.results![index].name!),
                    subtitle: Column(
                      children: [
                        Text(equipment.results![index].identifier!),
                        widgets.createElevatedButtonColored(
                          i18n.$trans('detail.nav_equipment_detail'),
                          () => navEquipmentDetailFunction(
                              context,
                              equipment.results![index].id
                          )
                        )
                      ],
                    )
                );
              },
              childCount: equipment.count,
            )
          )
        ]
    );
  }
}