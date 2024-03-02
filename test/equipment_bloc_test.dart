import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:my24_flutter_equipment/blocs/equipment_bloc.dart';
import 'package:my24_flutter_equipment/blocs/equipment_states.dart';
import 'package:my24_flutter_equipment/models/equipment/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'fixtures.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Test fetch equipment detail by pk', () async {
    final client = MockClient();
    final EquipmentBloc equipmentBloc = EquipmentBloc();
    equipmentBloc.orderApi.httpClient = client;
    equipmentBloc.equipmentApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': true,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(tokenData, 200));

    // return orders data with a 200
    when(client.get(
        Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_equipment_location/?equipment=1'),
        headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(ordersEmpty, 200));

    // return equipment data with a 200
    when(client.get(Uri.parse(
        'https://demo.my24service-dev.com/api/equipment/equipment/1/'),
        headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(equipment, 200));

    equipmentBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<EquipmentDetailLoadedState>());
          expect(event.props[0], isA<Equipment>());
        })
    );

    expectLater(equipmentBloc.stream, emits(isA<EquipmentDetailLoadedState>()));

    equipmentBloc.add(
        const EquipmentEvent(
            status: EquipmentEventStatus.fetchDetail,
            pk: 1
        ));
  });

  test('Test fetch equipment detail by uuid', () async {
    final client = MockClient();
    final EquipmentBloc equipmentBloc = EquipmentBloc();
    equipmentBloc.orderApi.httpClient = client;
    equipmentBloc.equipmentApi.httpClient = client;

    SharedPreferences.setMockInitialValues({
      'member_has_branches': true,
      'submodel': 'planning_user'
    });

    // return token request with a 200
    when(client.post(
        Uri.parse('https://demo.my24service-dev.com/api/jwt-token/refresh/'),
        headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => http.Response(tokenData, 200));

    // return orders data with a 200
    when(client.get(
        Uri.parse('https://demo.my24service-dev.com/api/order/order/all_for_equipment_location/?equipment=1'),
        headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(ordersEmpty, 200));

    // return equipment data with a 200
    when(client.get(Uri.parse(
        'https://demo.my24service-dev.com/api/equipment/equipment/c56ddfe1-f51b-4045-9d85-776e8ab0dcd4/uuid/'),
        headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(equipment, 200));

    equipmentBloc.stream.listen(
        expectAsync1((event) {
          expect(event, isA<EquipmentDetailLoadedState>());
          expect(event.props[0], isA<Equipment>());
        })
    );

    expectLater(equipmentBloc.stream, emits(isA<EquipmentDetailLoadedState>()));

    equipmentBloc.add(
        const EquipmentEvent(
            status: EquipmentEventStatus.fetchDetailByUuid,
            uuid: "c56ddfe1-f51b-4045-9d85-776e8ab0dcd4"
        ));
  });
}
