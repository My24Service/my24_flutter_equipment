import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/location_bloc.dart';
import '../../models/location/models.dart';
import '../common.dart';

enum EquipmentLocationListType {
  equipment,
  history,
  documents
}

typedef OnTapEquipmentLocation = Function(EquipmentLocationListType type);

class EquipmentLocationTabs extends StatefulWidget {
  final OnTapEquipmentLocation onTap;
  final EquipmentLocationListType currentListType;
  final My24i18n i18n;
  const EquipmentLocationTabs({
    this.currentListType=EquipmentLocationListType.equipment,
    required this.onTap,
    required this.i18n,
    super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentLocationTabsState();
}

class _EquipmentLocationTabsState extends State<EquipmentLocationTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;

  int _getIndex(EquipmentLocationListType listType) {
    if (listType == EquipmentLocationListType.equipment) {
      return 0;
    } else if(listType == EquipmentLocationListType.history) {
      return 1;
    }

    return 2;
  }

  EquipmentLocationListType _getType(int index) {
    if (index == 0) {
      return EquipmentLocationListType.equipment;
    } else if(index == 1) {
      return EquipmentLocationListType.history;
    }

    return EquipmentLocationListType.documents;
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(
        length: 3,
        vsync: this,
        initialIndex: _getIndex(widget.currentListType))
      ..addListener(_onTap);
  }

  void _onTap() {
    if (!tabController.indexIsChanging) {
      widget.onTap(_getType(tabController.index));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      tabs: [
        Tab( text: widget.i18n.$trans('detail.equipment_header') ),
        Tab( text: widget.i18n.$trans('detail.order_history') ),
        Tab( text: widget.i18n.$trans('detail.documents') ),
      ]
    );
  }
}

class EquipmentLocationView extends StatefulWidget {
  final EquipmentPaginated equipment;
  final Orders orders;
  final List<EquipmentLocationDocument>? documents;
  final My24i18n i18n;
  final CoreWidgets widgets;
  final NavDetailFunction navDetailFunction;
  final NavFormFromLocationFunction navFormFromLocationFunction;
  final NavDetailFunction navEquipmentDetailFunction;

  const EquipmentLocationView({required this.i18n, required this.widgets,
    required this.navDetailFunction,
    required this.navFormFromLocationFunction,
    required this.navEquipmentDetailFunction,
    required this.orders,
    required this.equipment,
    required this.documents,
    super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentLocationViewState();
}

class _EquipmentLocationViewState extends State<EquipmentLocationView> {
  EquipmentLocationListType _listType = EquipmentLocationListType.equipment;

  bool isEquipmentActive() => _listType == EquipmentLocationListType.equipment;
  bool isHistoryActive() => _listType == EquipmentLocationListType.history;
  bool isDocumentsActive() => _listType == EquipmentLocationListType.documents;

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
          title: Text(equipment.name ?? widget.i18n.$trans("detail.no_name")),
          subtitle: Column(
            children: [
              Text(equipment.identifier ?? widget.i18n.$trans("detail.no_identifier")),
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
      return OrderSection(
        order: order,
        widgets: widget.widgets,
        i18n: widget.i18n,
        navDetailFunction: widget.navDetailFunction,
      );
    }
    return null;
  }

  Widget _buildDocumentsSection(BuildContext context, int index) {
    return widget.widgets.buildItemsSection(
      context,
      "",
      widget.documents,
      (item) {
        String? nameDescValue = item.name;
        if (item.description != null && item.description != "") {
          nameDescValue = "$nameDescValue (${item.description})";
        }

        return widget.widgets.buildItemListKeyValueList(
            "", nameDescValue);
      },
      (item) {
        return <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.widgets.createViewButton(
                  () async {
                    String url = await coreUtils.getUrl(item.url);
                    url = url.replaceAll('/api', '');
                    Map<String, dynamic> openResult = await coreUtils
                        .openDocument(url);
                    if (!openResult['result'] && context.mounted) {
                      widget.widgets.createSnackBar(
                          context,
                          widget.i18n.$trans('error_arg',
                              namedArgs: {'error': openResult['message']},
                              pathOverride: 'generic')
                      );
                    }
                  }
              ),
            ],
          )
        ];
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = 1; // tabs
    if (isEquipmentActive()) {
      totalItems += widget.equipment.results?.length ?? 0;
    } else if (isHistoryActive()) {
      totalItems += widget.orders.results?.length ?? 0;
    } else if (isDocumentsActive()) {
      totalItems += widget.documents?.length ?? 0;
    }

    return SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return EquipmentLocationTabs(onTap: _onTap, i18n: widget.i18n);
          }

          if (isEquipmentActive()) {
            return _buildEquipment(context, index-1);
          }

          if (isDocumentsActive()) {
            return _buildDocumentsSection(context, index-1);
          }

          if (isHistoryActive()) {
            return _buildOrder(context, index-1);
          }

          return const SizedBox(height: 1);
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
  final NavFormFromLocationFunction navFormFromLocationFunction;
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
    required this.navFormFromLocationFunction,
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
                if (orderTypes.isNotEmpty) widgets.getMy24Divider(context),
                if (orderTypes.isNotEmpty) CreateOrderButtons(
                  orderTypes: orderTypes,
                  uuid: uuid!,
                  navFormFromLocationFunction: navFormFromLocationFunction,
                  i18n: i18n,
                  widgets: widgets,
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
      documents: location.documents,
      i18n: i18n,
      widgets: widgets,
      navDetailFunction: navDetailFunction,
      navFormFromLocationFunction: navFormFromLocationFunction,
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

class CreateOrderButtons extends StatelessWidget {
  final List<String> orderTypes;
  final String uuid;
  final NavFormFromLocationFunction navFormFromLocationFunction;
  final My24i18n i18n;
  final CoreWidgets widgets;

  const CreateOrderButtons({
    super.key,
    required this.orderTypes,
    required this.uuid,
    required this.navFormFromLocationFunction,
    required this.i18n,
    required this.widgets
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = [];
    for (int i=0; i<orderTypes.length; i++) {
      buttons.add(
          widgets.createElevatedButtonColored(
              orderTypes[i],
              () => navFormFromLocationFunction(context, uuid, orderTypes[i])
          )
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox();
    }

    return ListTile(
      title: widgets.createHeader(i18n.$trans('detail.new_order')),
      subtitle: Column(
        children: buttons,
      ),
    );
  }

}