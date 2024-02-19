import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class EquipmentPartApi extends BaseCrud<EquipmentPart, EquipmentParts> {
  @override
  get basePath {
    return "/equipment/equipment-part";
  }

  @override
  EquipmentPart fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return EquipmentPart.fromJson(parsedJson!);
  }

  @override
  EquipmentParts fromJsonList(Map<String, dynamic>? parsedJson) {
    return EquipmentParts.fromJson(parsedJson!);
  }
}
