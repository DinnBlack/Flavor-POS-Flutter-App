class PermissionModel {
  final String permissionName;
  final String description;
  final String resourceServerIdentifier;
  final String resourceServerName;
  final List<Source> sources;

  PermissionModel({
    required this.permissionName,
    required this.description,
    required this.resourceServerIdentifier,
    required this.resourceServerName,
    required this.sources,
  });

  factory PermissionModel.fromMap(Map<String, dynamic> map) {
    return PermissionModel(
      permissionName: map['permission_name'] as String,
      description: map['description'] as String,
      resourceServerIdentifier: map['resource_server_identifier'] as String,
      resourceServerName: map['resource_server_name'] as String,
      sources: map['sources'] != null
          ? List<Source>.from(
        map['sources'].map((x) => Source.fromMap(x)),
      )
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'permission_name': permissionName,
      'description': description,
      'resource_server_identifier': resourceServerIdentifier,
      'resource_server_name': resourceServerName,
      'sources': sources.map((x) => x.toMap()).toList(),
    };
  }
}

class Source {
  final String sourceType;
  final String sourceName;
  final String sourceId;

  Source({
    required this.sourceType,
    required this.sourceName,
    required this.sourceId,
  });

  factory Source.fromMap(Map<String, dynamic> map) {
    return Source(
      sourceType: map['source_type'] as String,
      sourceName: map['source_name'] as String,
      sourceId: map['source_id'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'source_type': sourceType,
      'source_name': sourceName,
      'source_id': sourceId,
    };
  }
}
