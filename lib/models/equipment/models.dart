import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/base_models.dart';

class EquipmentPageMetaData {
  final String? memberPicture;
  final String? submodel;
  final Widget? drawer;

  EquipmentPageMetaData({
    required this.memberPicture,
    required this.submodel,
    required this.drawer,
  }) : super();
}

class Equipment extends BaseModel {
  final int? id;
  final int? customer;
  final int? branch;
  final String? identifier;
  final String? name;
  final String? brand;
  final String? description;
  final String? installationDate;
  final String? productionDate;
  final String? serialnumber;
  final int? location;
  final String? locationName;

  Equipment({
    this.id,
    this.customer,
    this.branch,
    this.identifier,
    this.name,
    this.brand,
    this.description,
    this.installationDate,
    this.productionDate,
    this.serialnumber,
    this.location,
    this.locationName
  });

  factory Equipment.fromJson(Map<String, dynamic> parsedJson) {
    return Equipment(
      id: parsedJson['id'],
      customer: parsedJson['customer'],
      branch: parsedJson['branch'],
      identifier: parsedJson['identifier'],
      name: parsedJson['name'],
      brand: parsedJson['brand'],
      description: parsedJson['description'],
      installationDate: parsedJson['installation_date'],
      productionDate: parsedJson['production_date'],
      serialnumber: parsedJson['serialnumber'],
      location: parsedJson['location'],
      locationName: parsedJson['location_name']
    );
  }

  @override
  String toJson() {
    Map body = {
      'id': id,
    };

    if (location != null) {
      body['location'] = location;
    }

    if (name != null) {
      body['name'] = name;
    }

    if (identifier != null) {
      body['identifier'] = identifier;
    }

    return json.encode(body);
  }
}

class EquipmentPaginated extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<Equipment>? results;

  EquipmentPaginated({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EquipmentPaginated.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<Equipment> results = list.map((i) => Equipment.fromJson(i)).toList();

    return EquipmentPaginated(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class LocationResult {
  final int? id;
  final String? name;

  LocationResult({
    this.id,
    this.name
  });

  factory LocationResult.fromJson(Map<String, dynamic> parsedJson) {
    return LocationResult(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }
}

class EquipmentTypeAheadModel {
  final int? id;
  final String? name;
  final String? identifier;
  final String? description;
  final String? value;
  final LocationResult? location;

  EquipmentTypeAheadModel({
    this.id,
    this.name,
    this.identifier,
    this.description,
    this.value,
    this.location
  });

  factory EquipmentTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    LocationResult? location = parsedJson['location'] != null ? LocationResult.fromJson(parsedJson['location']) : null;

    return EquipmentTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      identifier: parsedJson['identifier'],
      description: parsedJson['description'],
      value: parsedJson['value'],
      location: location
    );
  }
}


abstract class BaseEquipmentCreateQuick extends BaseModel {
  final int? id;
  set id(int? id) {
    this.id = id;
  }

  final String name;
  set name(String name) {
    this.name = name;
  }

  BaseEquipmentCreateQuick({
    required this.id,
    required this.name,
  });
}

class EquipmentCreateQuickCustomer extends BaseEquipmentCreateQuick {
  final int? customer;

  EquipmentCreateQuickCustomer({
    int? id,
    required String name,
    required this.customer
  }) : super(
    id: id,
    name: name
  );

  factory EquipmentCreateQuickCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickCustomer(
      id: parsedJson['id'],
      name: parsedJson['name'],
      customer: parsedJson['customer'],
    );
  }

  Map toMap() {
    return {
      'name': name,
      'customer': customer,
    };
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }
}

class EquipmentCreateQuickBranch extends BaseEquipmentCreateQuick {
  final int? branch;

  EquipmentCreateQuickBranch({
    int? id,
    required String name,
    required this.branch
  }) : super(
    id: id,
    name: name
  );

  factory EquipmentCreateQuickBranch.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickBranch(
      id: parsedJson['id'],
      name: parsedJson['name'],
      branch: parsedJson['branch'],
    );
  }

  Map toMap() {
    return {
      'name': name,
      'branch': branch,
    };
  }

  @override
  String toJson() {
    return json.encode(toMap());
  }
}

class EquipmentCreateQuickResponse extends BaseModel {
  final int? id;
  final String? name;

  EquipmentCreateQuickResponse({
    this.id,
    this.name,
  });

  factory EquipmentCreateQuickResponse.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentCreateQuickResponse(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}
