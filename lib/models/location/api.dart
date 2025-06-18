import 'dart:async';
import 'dart:convert';

import 'package:my24_flutter_core/api/base_crud.dart';
import 'models.dart';

class EquipmentLocationApi extends BaseCrud<EquipmentLocation, EquipmentLocations> {
  @override
  get basePath {
    return "/equipment/location";
  }

  @override
  EquipmentLocation fromJsonDetail(Map<String, dynamic>? parsedJson) {
    return EquipmentLocation.fromJson(parsedJson!);
  }

  @override
  EquipmentLocations fromJsonList(Map<String, dynamic>? parsedJson) {
    return EquipmentLocations.fromJson(parsedJson!);
  }

  Future<List<EquipmentLocation>> fetchLocationsForSelect({int? branch}) async {
    final Map<String, dynamic> filters = branch != null ? {'branch': branch} : {};
    final String response = await super.getListResponseBody(
      filters: filters,
      basePathAddition: 'list_for_select/'
    );

    return EquipmentLocation.getListFromResponse(response);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuickCustomer(
      EquipmentLocationCreateQuickCustomer location) async {
    final Map body = location.toMap();
    return await createQuick(body);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuickBranch(
      EquipmentLocationCreateQuickBranch location) async {
    final Map body = location.toMap();
    return await createQuick(body);
  }

  Future<EquipmentLocationCreateQuickResponse> createQuick(Map body) async {
    String basePathAddition = 'create_quick/';
    final Map result = await super.insertCustom(body, basePathAddition, returnTypeBool: false);
    return EquipmentLocationCreateQuickResponse.fromJson(result as Map<String, dynamic>);
  }

  Future <List<EquipmentLocationTypeAheadModel>> typeAhead(String query, int? branch) async {
    Map<String, dynamic> filters = {'q': query, 'page_size': 1000};
    if (branch != null) {
      filters['branch'] = branch;
    }
    final String responseBody = await getListResponseBody(
        filters: filters, basePathAddition: 'autocomplete');
    var parsedJson = json.decode(responseBody);
    var list = parsedJson as List;
    List<EquipmentLocationTypeAheadModel> results = list.map((i) =>
        EquipmentLocationTypeAheadModel.fromJson(i)).toList();

    return results;
  }

  Future<EquipmentLocation> getByUuid(String uuid) async {
    return await detail(uuid, basePathAddition: 'uuid/');
  }
}
