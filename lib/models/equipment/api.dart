import 'dart:async';
import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class EquipmentApi extends BaseCrud<Equipment, EquipmentPaginated> {
  @override
  get basePath {
    return "/equipment/equipment";
  }

  @override
  Equipment fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return Equipment.fromJson(parsedJson!);
  }

  @override
  EquipmentPaginated fromJsonList(Map<String, dynamic>? parsedJson) {
    return EquipmentPaginated.fromJson(parsedJson!);
  }

  Future<EquipmentCreateQuickResponse> createQuickCustomer(EquipmentCreateQuickCustomer equipment) async {
    final Map body = equipment.toMap();
    return await createQuick(body);
  }

  Future<EquipmentCreateQuickResponse> createQuickBranch(EquipmentCreateQuickBranch equipment) async {
    final Map body = equipment.toMap();
    return await createQuick(body);
  }

  Future<EquipmentCreateQuickResponse> createQuick(Map body) async {
    String basePathAddition = 'create_quick/';
    final Map result = await super.insertCustom(body, basePathAddition, returnTypeBool: false);
    return EquipmentCreateQuickResponse.fromJson(result as Map<String, dynamic>);
  }

  Future<Equipment> getByUuid(String uuid) async {
    return await detail(uuid, basePathAddition: 'uuid/');
  }

  Future <List<EquipmentTypeAheadModel>> typeAhead(String query, {int? branch, int? customerPk}) async {
    Map<String, dynamic> filters = {'q': query};
    filters['branch'] = branch;
    filters['customer'] = customerPk;

    final String responseBody = await getListResponseBody(
        filters: filters, basePathAddition: 'autocomplete');
    var parsedJson = json.decode(responseBody);
    var list = parsedJson as List;
    List<EquipmentTypeAheadModel> results = list.map((i) =>
        EquipmentTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  Future<EquipmentPaginated> getForLocation(int locationPk) async {
    Map<String, dynamic> filters = { 'location': locationPk };
    return await list(filters: filters);
  }
}
