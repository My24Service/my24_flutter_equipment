import 'package:flutter/material.dart';

import 'package:my24_flutter_core/widgets/slivers/base_widgets.dart';

class EquipmentDetailErrorWidget extends BaseErrorWidget  {
  const EquipmentDetailErrorWidget({
    super.key,
    required super.error,
    required super.memberPicture,
    required super.widgetsIn,
    required super.i18nIn,
  });

  @override
  Widget getBottomSection(BuildContext context) {
    return const SizedBox(height: 1);
  }
}
