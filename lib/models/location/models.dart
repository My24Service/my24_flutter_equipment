import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:my24_flutter_core/models/base_models.dart';

class EquipmentLocationPageMetaData {
  final String? memberPicture;
  final String? submodel;
  final Widget? drawer;
  final List<String> orderTypes;

  EquipmentLocationPageMetaData({
    required this.memberPicture,
    required this.submodel,
    required this.drawer,
    required this.orderTypes,
  }) : super();
}

class EquipmentLocation extends BaseModel {
  final int? id;
  final int? customer;
  final int? branch;
  final String? identifier;
  final String? name;
  final List<EquipmentLocationDocument>? documents;

  EquipmentLocation({
    this.id,
    this.customer,
    this.branch,
    this.identifier,
    this.name,
    this.documents
  });

  static List<EquipmentLocation> getListFromResponse(String response) {
    var list = json.decode(response) as List;

    return list.map((i) => EquipmentLocation.fromJson(i)).toList();
  }

  factory EquipmentLocation.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['documents'] as List;
    List<EquipmentLocationDocument> documents = list.map((i) => EquipmentLocationDocument.fromJson(i)).toList();

    return EquipmentLocation(
      id: parsedJson['id'],
      customer: parsedJson['customer'],
      branch: parsedJson['branch'],
      identifier: parsedJson['identifier'],
      name: parsedJson['name'],
      documents: documents
    );
  }

  @override
  String toJson() {
    return '';
  }
}

class EquipmentLocations extends BaseModelPagination {
  final int? count;
  final String? next;
  final String? previous;
  final List<EquipmentLocation>? results;

  EquipmentLocations({
    this.count,
    this.next,
    this.previous,
    this.results,
  });

  factory EquipmentLocations.fromJson(Map<String, dynamic> parsedJson) {
    var list = parsedJson['results'] as List;
    List<EquipmentLocation> results = list.map((i) => EquipmentLocation.fromJson(i)).toList();

    return EquipmentLocations(
      count: parsedJson['count'],
      next: parsedJson['next'],
      previous: parsedJson['previous'],
      results: results,
    );
  }
}

class EquipmentLocationTypeAheadModel {
  final int? id;
  final String? name;
  final String? identifier;
  final String? value;

  EquipmentLocationTypeAheadModel({
    this.id,
    this.name,
    this.identifier,
    this.value,
  });

  factory EquipmentLocationTypeAheadModel.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationTypeAheadModel(
      id: parsedJson['id'],
      name: parsedJson['name'],
      identifier: parsedJson['identifier'],
      value: parsedJson['value'],
    );
  }
}


abstract class BaseEquipmentLocationCreateQuick extends BaseModel {
  final int? id;
  final String? name;

  BaseEquipmentLocationCreateQuick({
    this.id,
    this.name,
  });
}

class EquipmentLocationCreateQuickCustomer extends BaseEquipmentLocationCreateQuick {
  final int? customer;

  EquipmentLocationCreateQuickCustomer({
    int? id,
    required String name,
    required this.customer
  }) : super(
    id: id,
    name: name
  );

  factory EquipmentLocationCreateQuickCustomer.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickCustomer(
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

class EquipmentLocationCreateQuickBranch extends BaseEquipmentLocationCreateQuick {
  final int? branch;

  EquipmentLocationCreateQuickBranch({
    int? id,
    required String name,
    required this.branch
  }) : super(
    id: id,
    name: name
  );

  factory EquipmentLocationCreateQuickBranch.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickBranch(
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

class EquipmentLocationCreateQuickResponse extends BaseModel {
  final int? id;
  final String? name;

  EquipmentLocationCreateQuickResponse({
    this.id,
    this.name,
  });

  factory EquipmentLocationCreateQuickResponse.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationCreateQuickResponse(
      id: parsedJson['id'],
      name: parsedJson['name'],
    );
  }

  @override
  String toJson() {
    return '';
  }
}

class EquipmentLocationDocument extends BaseModel {
  final int? id;
  int? location;
  final String? name;
  final String? description;
  final String? file;
  final String? filename;
  final String? url;

  EquipmentLocationDocument({
    this.id,
    this.location,
    this.name,
    this.description,
    this.file,
    this.filename,
    this.url,
  });

  factory EquipmentLocationDocument.fromJson(Map<String, dynamic> parsedJson) {
    return EquipmentLocationDocument(
      id: parsedJson['id'],
      location: parsedJson['location'],
      name: parsedJson['name'],
      description: parsedJson['description'],
      file: parsedJson['file'],
      filename: parsedJson['filename'],
      url: parsedJson['url'],
    );
  }

  @override
  String toJson() {
    // only add file when it's base64 encoded
    String? useFile;

    try {
      base64Decode(file!);
      useFile = file!;
    } catch(e) {
      useFile = null;
    }

    Map body = {
      'location': location,
      'name': name,
      'description': description,
    };

    if (useFile != null) {
      body['file'] = useFile;
    }

    return json.encode(body);
  }
}
