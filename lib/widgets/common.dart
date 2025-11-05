import 'package:flutter/material.dart';
import 'package:my24_flutter_core/i18n.dart';
import 'package:my24_flutter_core/widgets/widgets.dart';
import 'package:my24_flutter_orders/common/widgets.dart';
import 'package:my24_flutter_orders/models/order/models.dart';
import 'package:my24_flutter_orders/models/orderline/models.dart';
import 'package:my24_flutter_orders/pages/types.dart';

class OrderSection extends StatelessWidget {
  final Order order;
  final CoreWidgets widgets;
  final My24i18n i18n;
  final NavDetailFunction navDetailFunction;

  OrderSection({
    required this.order,
    required this.widgets,
    required this.i18n,
    required this.navDetailFunction
  });

  @override
  Widget build(BuildContext context) {
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
                workorderWidget: order.customerOrderAccepted! ? widgets.buildItemListCustomWidget(
                  i18n.$trans('detail.info_workorder'),
                  widgets.createViewWorkOrderButton(order.workorderPdfUrl, context), // _createWorkorderText(order, context)
                ) : null,
              ),
              onTap: () {
                if (order.id != null) {
                  navDetailFunction(context, order.id!); // _navOrderDetail(context, order.id!);
                }
              }
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _createOrderlinesSection(context, order.orderLines),
          )
        ] );
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
}