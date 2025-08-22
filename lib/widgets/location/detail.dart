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

enum EquipmentLocationListType {
  equipment,
  history
}

typedef OnTapEquipmentLocation = Function(EquipmentLocationListType type);

class EquipmentLocationTabs extends StatefulWidget {
  final OnTapEquipmentLocation onTap;
  final EquipmentLocationListType currentListType;
  const EquipmentLocationTabs( {this.currentListType=EquipmentLocationListType.equipment,
    required this.onTap,
    super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentLocationTabsState();
}

class _EquipmentLocationTabsState extends State<EquipmentLocationTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();

    tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: widget.currentListType == EquipmentLocationListType.equipment ? 0 : 1)
      ..addListener(_onTap);
  }

  void _onTap() {
    if (!tabController.indexIsChanging) {
      widget.onTap(tabController.index == 0 ? EquipmentLocationListType.equipment : EquipmentLocationListType.history);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: const [
        Tab( text: 'Equipment' ),
        Tab( text: 'History' )
      ]
    );
  }
}


class EquipmentLocationView extends StatefulWidget {
  final EquipmentPaginated equipment;
  final Orders orders;
  final My24i18n i18n;
  final CoreWidgets widgets;
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;
  final NavDetailFunction navEquipmentDetailFunction;

  const EquipmentLocationView({required this.i18n, required this.widgets,
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
    required this.navEquipmentDetailFunction,
    required this.orders, required this.equipment, super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentLocationViewState();
}

class _EquipmentLocationViewState extends State<EquipmentLocationView> {
  EquipmentLocationListType _listType = EquipmentLocationListType.equipment;

  bool isEquipmentActive() => _listType == EquipmentLocationListType.equipment;

  @override
  void initState() {
    super.initState();
  }

  void _onTap(EquipmentLocationListType listType) {
    if (listType != _listType) {
      setState(() {
        _listType = listType;
      });
    }
  }

  Widget? _buildEquipment(BuildContext context, int index) {
    if (index < (widget.equipment.results?.length ?? 0)) {
      final Equipment equipment = widget.equipment.results![index];

      return ListTile(
          title: Text(equipment.name ?? "(no name)"),
          subtitle: Column(
            children: [
              Text(equipment.identifier ?? "(no identifier)"),
              widget.widgets.createElevatedButtonColored(
                  widget.i18n.$trans('detail.nav_equipment_detail'),
                      () => widget.navEquipmentDetailFunction(
                      context,
                      equipment.id!
                  )
              )
            ],
          )
      );
    }
    return null;
  }

  Widget? _buildOrder(BuildContext context, int index) {
    if (index < (widget.orders.results?.length ?? 0)) {
      final Order order = widget.orders.results![index];
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListTile(
            title: OrderHistoryWithAcceptedListHeader(
              date: order.orderDate!,
              customerOrderAccepted: order.customerOrderAccepted!,
            ),
            subtitle: OrderHistoryListSubtitle(
              order: order,
              workorderWidget: order.customerOrderAccepted! ? widget.widgets.buildItemListCustomWidget(
                  widget.i18n.$trans('detail.info_workorder'),
                  widget.widgets.createViewWorkOrderButton(order.workorderPdfUrl, context), // _createWorkorderText(order, context)
              ) : null,
            ),
            onTap: () {
              if (order.id != null) {
                widget.navDetailFunction(context, order.id!); // _navOrderDetail(context, order.id!);
              }
            }
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _createOrderlinesSection(context, order.orderLines),
          )
      ] );
    }
    return null;
  }

  Widget _createOrderlinesSection(BuildContext context, List<Orderline>? orderLines) {
    return widget.widgets.buildItemsSection(
        context,
        widget.i18n.$trans('detail.header_orderlines'),
        orderLines,
            (Orderline orderline) {
          String equipmentLocationTitle = "${widget.i18n.$trans('info_equipment', pathOverride: 'generic')} / ${widget.i18n.$trans('info_location', pathOverride: 'generic')}";
          String equipmentLocationValue = "${orderline.product?? '-'} / ${orderline.location?? '-'}";
          return <Widget>[
            ...widget.widgets.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
            if (orderline.remarks != null && orderline.remarks != "")
              ...widget.widgets.buildItemListKeyValueList(widget.i18n.$trans('info_remarks', pathOverride: 'generic'), orderline.remarks)
          ];
        },
            (Orderline orderline) {
          return <Widget>[];
        },
        withLastDivider: false
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = 1; // tabs
    if (isEquipmentActive()) {
      totalItems += widget.equipment.results?.length ?? 0;
    } else {
      totalItems += widget.orders.results?.length ?? 0;
    }

    return SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return EquipmentLocationTabs(onTap: _onTap);
          }

          if (isEquipmentActive())
            return _buildEquipment(context, index-1);
          else
            return _buildOrder(context, index-1);
        },
        itemCount: totalItems
    );
  }
}


class LocationDetailWidget extends BaseStatelessWidget {
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
  final NavDetailFunction navEquipmentDetailFunction;

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
              ],
            );
          },
          childCount: 1,
        )
    );
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

  @override
  Widget getContentSliver(BuildContext context) {
    return EquipmentLocationView(
      equipment: equipment,
      orders: orders,
      i18n: i18n,
      widgets: widgets,
      navDetailFunction: navDetailFunction,
      navFormFromEquipmentFunction: navFormFromEquipmentFunction,
      navEquipmentDetailFunction: navEquipmentDetailFunction,
    );
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
