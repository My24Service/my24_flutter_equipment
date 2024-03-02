import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:network_image_mock/network_image_mock.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my24_flutter_core/tests/http_client.mocks.dart';

import 'package:my24_flutter_equipment/blocs/equipment_bloc.dart';
import 'package:my24_flutter_equipment/pages/equipment/detail.dart';
import 'package:my24_flutter_equipment/widgets/equipment/detail.dart';
import 'fixtures.dart';

void navDetailFunction(BuildContext context, int orderPk) {}

class EquipmentDetailPage extends BaseEquipmentDetailPage {
  EquipmentDetailPage({
    super.key,
    super.pk,
    super.uuid,
    required super.bloc,
  }) : super(
      navDetailFunction: navDetailFunction
  );
}


Widget createWidget({Widget? child}) {
  return MaterialApp(
      home: Scaffold(
          body: Container(
              child: child
          )
      ),
  );
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  testWidgets('loads equipment detail by uuid', (tester) async {
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

    EquipmentDetailPage widget = EquipmentDetailPage(
        bloc: equipmentBloc,
        uuid: "c56ddfe1-f51b-4045-9d85-776e8ab0dcd4"
    );

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(EquipmentInfoCard), findsOneWidget);
    expect(find.byType(EquipmentDetailWidget), findsOneWidget);
  });

  testWidgets('loads equipment detail by pk', (tester) async {
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

    EquipmentDetailPage widget = EquipmentDetailPage(
        bloc: equipmentBloc,
        pk: 1
    );

    await mockNetworkImagesFor(() async => await tester.pumpWidget(
        createWidget(child: widget))
    );
    await mockNetworkImagesFor(() async => await tester.pumpAndSettle());

    expect(find.byType(EquipmentInfoCard), findsOneWidget);
    expect(find.byType(EquipmentDetailWidget), findsOneWidget);
  });
}
