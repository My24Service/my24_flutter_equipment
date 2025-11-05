import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my24_flutter_core/i18n.dart';

import 'package:my24_flutter_core/models/base_models.dart';
import 'package:my24_flutter_core/utils.dart';
import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

import '../../blocs/equipment_bloc.dart';
import '../../models/equipment/models.dart';
import '../common.dart';

enum EquipmentListType {
  history,
  documents
}

typedef OnTapEquipmentLocation = Function(EquipmentListType type);

class EquipmentTabs extends StatefulWidget {
  final OnTapEquipmentLocation onTap;
  final EquipmentListType currentListType;
  final My24i18n i18n;
  const EquipmentTabs({
    this.currentListType=EquipmentListType.history,
    required this.onTap,
    required this.i18n,
    super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentTabsState();
}

class _EquipmentTabsState extends State<EquipmentTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;

  int _getIndex(EquipmentListType listType) {
    if (listType == EquipmentListType.history) {
      return 0;
    }

    return 1;
  }

  EquipmentListType _getType(int index) {
    if (index == 0) {
      return EquipmentListType.history;
    }

    return EquipmentListType.documents;
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(
        length: 2,
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
          Tab( text: widget.i18n.$trans('detail.order_history') ),
          Tab( text: widget.i18n.$trans('detail.documents') ),
        ]
    );
  }
}

class EquipmentView extends StatefulWidget {
  final Orders orders;
  final List<EquipmentDocument>? documents;
  final My24i18n i18n;
  final CoreWidgets widgets;
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;

  const EquipmentView({required this.i18n, required this.widgets,
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
    required this.orders,
    required this.documents,
    super.key});

  @override
  State<StatefulWidget> createState() => _EquipmentViewState();
}

class _EquipmentViewState extends State<EquipmentView> {
  EquipmentListType _listType = EquipmentListType.history;

  bool isHistoryActive() => _listType == EquipmentListType.history;
  bool isDocumentsActive() => _listType == EquipmentListType.documents;

  @override
  void initState() {
    super.initState();
  }

  void _onTap(EquipmentListType listType) {
    if (listType != _listType) {
      setState(() {
        _listType = listType;
      });
    }
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
    if (isHistoryActive()) {
      totalItems += widget.orders.results?.length ?? 0;
    } else if (isDocumentsActive()) {
      totalItems += widget.documents?.length ?? 0;
    }

    return SliverList.builder(
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return EquipmentTabs(onTap: _onTap, i18n: widget.i18n);
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

class EquipmentDetailWidget extends BaseStatelessWidget{
  final Equipment equipment;
  final Orders orders;
  final TextEditingController searchController = TextEditingController();
  final String? searchQuery;
  final int? pk;
  final String? uuid;
  final NavDetailFunction navDetailFunction;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;
  final List<String> orderTypes;

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
    required this.navDetailFunction,
    required this.navFormFromEquipmentFunction,
    required this.orderTypes
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
                EquipmentInfoCard(
                  equipment: equipment,
                  i18n: i18n,
                ),
                if (orderTypes.isNotEmpty) widgets.getMy24Divider(context),
                if (orderTypes.isNotEmpty) CreateOrderButtons(
                  orderTypes: orderTypes,
                  uuid: uuid!,
                  navFormFromEquipmentFunction: navFormFromEquipmentFunction,
                  i18n: i18n,
                  widgets: widgets,
                ),
                // widgets.getMy24Divider(context),
                // widgets.createHeader(i18n.$trans('detail.order_history'))
              ],
            );
          },
          childCount: 1,
        )
    );
  }

  // @override
  // SliverList getSliverList(BuildContext context) {
  //   return SliverList(
  //       delegate: SliverChildBuilderDelegate(
  //         (BuildContext context, int index) {
  //           final Order order = orders.results![index];
  //           final Widget content = _getContent(context, order);
  //
  //           return Column(
  //             children: [
  //               content,
  //               const SizedBox(height: 2),
  //               if (index < orders.results!.length-1)
  //                 widgets.getMy24Divider(context)
  //             ],
  //           );
  //         },
  //         childCount: orders.results!.length,
  //       )
  //   );
  // }

  // private methods
  // Widget _getContent(BuildContext context, Order order) {
  //   return Column(
  //     children: [
  //       ListTile(
  //         title: OrderHistoryWithAcceptedListHeader(
  //           date: order.orderDate!,
  //           customerOrderAccepted: order.customerOrderAccepted!,
  //         ),
  //         subtitle: OrderHistoryListSubtitle(
  //             order: order,
  //             workorderWidget: order.customerOrderAccepted! ? widgets.buildItemListCustomWidget(
  //                 i18n.$trans('detail.info_workorder'),
  //                 _createWorkorderText(order, context)
  //             ) : null,
  //         ),
  //         onTap: () {
  //           _navOrderDetail(context, order.id!);
  //         }
  //       ),
  //       Padding(
  //           padding: const EdgeInsets.only(left: 20),
  //           child: _createOrderlinesSection(context, order.orderLines)
  //       )
  //     ],
  //   );
  // }
  //
  // Widget _createWorkorderText(Order order, BuildContext context) {
  //   return widgets.createViewWorkOrderButton(order.workorderPdfUrl, context);
  // }
  //
  // Widget _createOrderlinesSection(BuildContext context, List<Orderline>? orderLines) {
  //   return widgets.buildItemsSection(
  //       context,
  //       i18n.$trans('detail.header_orderlines'),
  //       orderLines,
  //           (Orderline orderline) {
  //         String equipmentLocationTitle = "${i18n.$trans('info_equipment', pathOverride: 'generic')} / ${i18n.$trans('info_location', pathOverride: 'generic')}";
  //         String equipmentLocationValue = "${orderline.product?? '-'} / ${orderline.location?? '-'}";
  //         return <Widget>[
  //           ...widgets.buildItemListKeyValueList(equipmentLocationTitle, equipmentLocationValue),
  //           if (orderline.remarks != null && orderline.remarks != "")
  //             ...widgets.buildItemListKeyValueList(i18n.$trans('info_remarks', pathOverride: 'generic'), orderline.remarks)
  //         ];
  //       },
  //           (Orderline orderline) {
  //         return <Widget>[];
  //       },
  //       withLastDivider: false
  //   );
  // }
  //
  // void _navOrderDetail(BuildContext context, int orderPk) {
  //   navDetailFunction(context, orderPk);
  // }

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

  @override
  Widget getContentSliver(BuildContext context) {
    return EquipmentView(
      orders: orders,
      documents: equipment.documents,
      i18n: i18n,
      widgets: widgets,
      navDetailFunction: navDetailFunction,
      navFormFromEquipmentFunction: navFormFromEquipmentFunction,
    );
  }
}

class EquipmentInfoCard extends StatelessWidget {
  final Equipment equipment;
  final My24i18n i18n;

  const EquipmentInfoCard({
    super.key,
    required this.equipment,
    required this.i18n
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
        if (equipment.brand != null && equipment.brand != "")
          ListTile(
            title: Text(checkNull(equipment.brand)),
            subtitle: Text(i18n.$trans('brand')),
          ),
        if (equipment.installationDate != null)
          ListTile(
            title: Text(checkNull(equipment.installationDate)),
            subtitle: Text(i18n.$trans('installation_date')),
          ),
        if (equipment.productionDate != null)
          ListTile(
            title: Text(checkNull(equipment.productionDate)),
            subtitle: Text(i18n.$trans('production_date')),
          ),
        if (equipment.serialnumber != null)
          ListTile(
            title: Text(checkNull(equipment.serialnumber)),
            subtitle: Text(i18n.$trans('serialnumber')),
          ),
        if (equipment.description != null)
          ListTile(
            title: Text(checkNull(equipment.description)),
            subtitle: Text(i18n.$trans('description')),
          ),
      ],
    );
  }
}

class CreateOrderButtons extends StatelessWidget {
  final List<String> orderTypes;
  final String uuid;
  final NavFormFromEquipmentFunction navFormFromEquipmentFunction;
  final My24i18n i18n;
  final CoreWidgets widgets;

  const CreateOrderButtons({
    super.key,
    required this.orderTypes,
    required this.uuid,
    required this.navFormFromEquipmentFunction,
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
            () => navFormFromEquipmentFunction(context, uuid, orderTypes[i])
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