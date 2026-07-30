// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FacilitiesTable extends Facilities
    with TableInfo<$FacilitiesTable, Facility> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FacilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FacilityType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FacilityType>($FacilitiesTable.$convertertype);
  @override
  late final GeneratedColumnWithTypeConverter<FacilityStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<FacilityStatus>($FacilitiesTable.$converterstatus);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalMeta = const VerificationMeta(
    'canonical',
  );
  @override
  late final GeneratedColumn<bool> canonical = GeneratedColumn<bool>(
    'canonical',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("canonical" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    status,
    lat,
    lng,
    canonical,
    verifiedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'facilities';
  @override
  VerificationContext validateIntegrity(
    Insertable<Facility> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('canonical')) {
      context.handle(
        _canonicalMeta,
        canonical.isAcceptableOrUnknown(data['canonical']!, _canonicalMeta),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Facility map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Facility(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $FacilitiesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      status: $FacilitiesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      )!,
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      )!,
      canonical: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}canonical'],
      )!,
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FacilitiesTable createAlias(String alias) {
    return $FacilitiesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<FacilityType, String, String> $convertertype =
      const EnumNameConverter<FacilityType>(FacilityType.values);
  static JsonTypeConverter2<FacilityStatus, String, String> $converterstatus =
      const EnumNameConverter<FacilityStatus>(FacilityStatus.values);
}

class Facility extends DataClass implements Insertable<Facility> {
  final String id;
  final String name;
  final FacilityType type;
  final FacilityStatus status;
  final double lat;
  final double lng;
  final bool canonical;
  final DateTime? verifiedAt;
  final DateTime updatedAt;
  const Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.lat,
    required this.lng,
    required this.canonical,
    this.verifiedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $FacilitiesTable.$convertertype.toSql(type),
      );
    }
    {
      map['status'] = Variable<String>(
        $FacilitiesTable.$converterstatus.toSql(status),
      );
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['canonical'] = Variable<bool>(canonical);
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FacilitiesCompanion toCompanion(bool nullToAbsent) {
    return FacilitiesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      status: Value(status),
      lat: Value(lat),
      lng: Value(lng),
      canonical: Value(canonical),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Facility.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Facility(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $FacilitiesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      status: $FacilitiesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      canonical: serializer.fromJson<bool>(json['canonical']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $FacilitiesTable.$convertertype.toJson(type),
      ),
      'status': serializer.toJson<String>(
        $FacilitiesTable.$converterstatus.toJson(status),
      ),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'canonical': serializer.toJson<bool>(canonical),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Facility copyWith({
    String? id,
    String? name,
    FacilityType? type,
    FacilityStatus? status,
    double? lat,
    double? lng,
    bool? canonical,
    Value<DateTime?> verifiedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => Facility(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    status: status ?? this.status,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    canonical: canonical ?? this.canonical,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Facility copyWithCompanion(FacilitiesCompanion data) {
    return Facility(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      canonical: data.canonical.present ? data.canonical.value : this.canonical,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Facility(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('canonical: $canonical, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    status,
    lat,
    lng,
    canonical,
    verifiedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Facility &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.status == this.status &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.canonical == this.canonical &&
          other.verifiedAt == this.verifiedAt &&
          other.updatedAt == this.updatedAt);
}

class FacilitiesCompanion extends UpdateCompanion<Facility> {
  final Value<String> id;
  final Value<String> name;
  final Value<FacilityType> type;
  final Value<FacilityStatus> status;
  final Value<double> lat;
  final Value<double> lng;
  final Value<bool> canonical;
  final Value<DateTime?> verifiedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FacilitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.canonical = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FacilitiesCompanion.insert({
    required String id,
    required String name,
    required FacilityType type,
    required FacilityStatus status,
    required double lat,
    required double lng,
    this.canonical = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       status = Value(status),
       lat = Value(lat),
       lng = Value(lng),
       updatedAt = Value(updatedAt);
  static Insertable<Facility> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? status,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<bool>? canonical,
    Expression<DateTime>? verifiedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (canonical != null) 'canonical': canonical,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FacilitiesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<FacilityType>? type,
    Value<FacilityStatus>? status,
    Value<double>? lat,
    Value<double>? lng,
    Value<bool>? canonical,
    Value<DateTime?>? verifiedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FacilitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      canonical: canonical ?? this.canonical,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $FacilitiesTable.$convertertype.toSql(type.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $FacilitiesTable.$converterstatus.toSql(status.value),
      );
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (canonical.present) {
      map['canonical'] = Variable<bool>(canonical.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FacilitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('canonical: $canonical, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapacityReadingsTable extends CapacityReadings
    with TableInfo<$CapacityReadingsTable, CapacityReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapacityReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES facilities (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<ResourceType, String> resource =
      GeneratedColumn<String>(
        'resource',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ResourceType>($CapacityReadingsTable.$converterresource);
  static const VerificationMeta _forPeopleMeta = const VerificationMeta(
    'forPeople',
  );
  @override
  late final GeneratedColumn<int> forPeople = GeneratedColumn<int>(
    'for_people',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verifiedByMeta = const VerificationMeta(
    'verifiedBy',
  );
  @override
  late final GeneratedColumn<String> verifiedBy = GeneratedColumn<String>(
    'verified_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    facilityId,
    resource,
    forPeople,
    verifiedBy,
    verifiedAt,
    expiresAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capacity_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapacityReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_facilityIdMeta);
    }
    if (data.containsKey('for_people')) {
      context.handle(
        _forPeopleMeta,
        forPeople.isAcceptableOrUnknown(data['for_people']!, _forPeopleMeta),
      );
    } else if (isInserting) {
      context.missing(_forPeopleMeta);
    }
    if (data.containsKey('verified_by')) {
      context.handle(
        _verifiedByMeta,
        verifiedBy.isAcceptableOrUnknown(data['verified_by']!, _verifiedByMeta),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapacityReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapacityReading(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      )!,
      resource: $CapacityReadingsTable.$converterresource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}resource'],
        )!,
      ),
      forPeople: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}for_people'],
      )!,
      verifiedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verified_by'],
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CapacityReadingsTable createAlias(String alias) {
    return $CapacityReadingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ResourceType, String, String> $converterresource =
      const EnumNameConverter<ResourceType>(ResourceType.values);
}

class CapacityReading extends DataClass implements Insertable<CapacityReading> {
  final String id;
  final String facilityId;
  final ResourceType resource;
  final int forPeople;
  final String? verifiedBy;
  final DateTime? verifiedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  const CapacityReading({
    required this.id,
    required this.facilityId,
    required this.resource,
    required this.forPeople,
    this.verifiedBy,
    this.verifiedAt,
    required this.expiresAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['facility_id'] = Variable<String>(facilityId);
    {
      map['resource'] = Variable<String>(
        $CapacityReadingsTable.$converterresource.toSql(resource),
      );
    }
    map['for_people'] = Variable<int>(forPeople);
    if (!nullToAbsent || verifiedBy != null) {
      map['verified_by'] = Variable<String>(verifiedBy);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CapacityReadingsCompanion toCompanion(bool nullToAbsent) {
    return CapacityReadingsCompanion(
      id: Value(id),
      facilityId: Value(facilityId),
      resource: Value(resource),
      forPeople: Value(forPeople),
      verifiedBy: verifiedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedBy),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory CapacityReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapacityReading(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String>(json['facilityId']),
      resource: $CapacityReadingsTable.$converterresource.fromJson(
        serializer.fromJson<String>(json['resource']),
      ),
      forPeople: serializer.fromJson<int>(json['forPeople']),
      verifiedBy: serializer.fromJson<String?>(json['verifiedBy']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String>(facilityId),
      'resource': serializer.toJson<String>(
        $CapacityReadingsTable.$converterresource.toJson(resource),
      ),
      'forPeople': serializer.toJson<int>(forPeople),
      'verifiedBy': serializer.toJson<String?>(verifiedBy),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CapacityReading copyWith({
    String? id,
    String? facilityId,
    ResourceType? resource,
    int? forPeople,
    Value<String?> verifiedBy = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
    DateTime? expiresAt,
    DateTime? createdAt,
  }) => CapacityReading(
    id: id ?? this.id,
    facilityId: facilityId ?? this.facilityId,
    resource: resource ?? this.resource,
    forPeople: forPeople ?? this.forPeople,
    verifiedBy: verifiedBy.present ? verifiedBy.value : this.verifiedBy,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    createdAt: createdAt ?? this.createdAt,
  );
  CapacityReading copyWithCompanion(CapacityReadingsCompanion data) {
    return CapacityReading(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      resource: data.resource.present ? data.resource.value : this.resource,
      forPeople: data.forPeople.present ? data.forPeople.value : this.forPeople,
      verifiedBy: data.verifiedBy.present
          ? data.verifiedBy.value
          : this.verifiedBy,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapacityReading(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('resource: $resource, ')
          ..write('forPeople: $forPeople, ')
          ..write('verifiedBy: $verifiedBy, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    facilityId,
    resource,
    forPeople,
    verifiedBy,
    verifiedAt,
    expiresAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapacityReading &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.resource == this.resource &&
          other.forPeople == this.forPeople &&
          other.verifiedBy == this.verifiedBy &&
          other.verifiedAt == this.verifiedAt &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt);
}

class CapacityReadingsCompanion extends UpdateCompanion<CapacityReading> {
  final Value<String> id;
  final Value<String> facilityId;
  final Value<ResourceType> resource;
  final Value<int> forPeople;
  final Value<String?> verifiedBy;
  final Value<DateTime?> verifiedAt;
  final Value<DateTime> expiresAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CapacityReadingsCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.resource = const Value.absent(),
    this.forPeople = const Value.absent(),
    this.verifiedBy = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapacityReadingsCompanion.insert({
    required String id,
    required String facilityId,
    required ResourceType resource,
    required int forPeople,
    this.verifiedBy = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    required DateTime expiresAt,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       facilityId = Value(facilityId),
       resource = Value(resource),
       forPeople = Value(forPeople),
       expiresAt = Value(expiresAt),
       createdAt = Value(createdAt);
  static Insertable<CapacityReading> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<String>? resource,
    Expression<int>? forPeople,
    Expression<String>? verifiedBy,
    Expression<DateTime>? verifiedAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (resource != null) 'resource': resource,
      if (forPeople != null) 'for_people': forPeople,
      if (verifiedBy != null) 'verified_by': verifiedBy,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapacityReadingsCompanion copyWith({
    Value<String>? id,
    Value<String>? facilityId,
    Value<ResourceType>? resource,
    Value<int>? forPeople,
    Value<String?>? verifiedBy,
    Value<DateTime?>? verifiedAt,
    Value<DateTime>? expiresAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CapacityReadingsCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      resource: resource ?? this.resource,
      forPeople: forPeople ?? this.forPeople,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (resource.present) {
      map['resource'] = Variable<String>(
        $CapacityReadingsTable.$converterresource.toSql(resource.value),
      );
    }
    if (forPeople.present) {
      map['for_people'] = Variable<int>(forPeople.value);
    }
    if (verifiedBy.present) {
      map['verified_by'] = Variable<String>(verifiedBy.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapacityReadingsCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('resource: $resource, ')
          ..write('forPeople: $forPeople, ')
          ..write('verifiedBy: $verifiedBy, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubmissionsTable extends Submissions
    with TableInfo<$SubmissionsTable, Submission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubmissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _facilityIdMeta = const VerificationMeta(
    'facilityId',
  );
  @override
  late final GeneratedColumn<String> facilityId = GeneratedColumn<String>(
    'facility_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SubmissionState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SubmissionState>($SubmissionsTable.$converterstate);
  static const VerificationMeta _rejectReasonMeta = const VerificationMeta(
    'rejectReason',
  );
  @override
  late final GeneratedColumn<String> rejectReason = GeneratedColumn<String>(
    'reject_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    facilityId,
    lat,
    lng,
    payload,
    photoPath,
    state,
    rejectReason,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'submissions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Submission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('facility_id')) {
      context.handle(
        _facilityIdMeta,
        facilityId.isAcceptableOrUnknown(data['facility_id']!, _facilityIdMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('reject_reason')) {
      context.handle(
        _rejectReasonMeta,
        rejectReason.isAcceptableOrUnknown(
          data['reject_reason']!,
          _rejectReasonMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Submission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Submission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      facilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}facility_id'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      state: $SubmissionsTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      rejectReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reject_reason'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SubmissionsTable createAlias(String alias) {
    return $SubmissionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SubmissionState, String, String> $converterstate =
      const EnumNameConverter<SubmissionState>(SubmissionState.values);
}

class Submission extends DataClass implements Insertable<Submission> {
  final String id;
  final String? facilityId;
  final double? lat;
  final double? lng;

  /// JSON payload: category, capacity, status, note… Schema is validated
  /// server-side (SECURITY.md) — the client never trusts itself either.
  final String payload;
  final String? photoPath;
  final SubmissionState state;
  final String? rejectReason;
  final DateTime createdAt;
  const Submission({
    required this.id,
    this.facilityId,
    this.lat,
    this.lng,
    required this.payload,
    this.photoPath,
    required this.state,
    this.rejectReason,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || facilityId != null) {
      map['facility_id'] = Variable<String>(facilityId);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    {
      map['state'] = Variable<String>(
        $SubmissionsTable.$converterstate.toSql(state),
      );
    }
    if (!nullToAbsent || rejectReason != null) {
      map['reject_reason'] = Variable<String>(rejectReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubmissionsCompanion toCompanion(bool nullToAbsent) {
    return SubmissionsCompanion(
      id: Value(id),
      facilityId: facilityId == null && nullToAbsent
          ? const Value.absent()
          : Value(facilityId),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      payload: Value(payload),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      state: Value(state),
      rejectReason: rejectReason == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectReason),
      createdAt: Value(createdAt),
    );
  }

  factory Submission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Submission(
      id: serializer.fromJson<String>(json['id']),
      facilityId: serializer.fromJson<String?>(json['facilityId']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      payload: serializer.fromJson<String>(json['payload']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      state: $SubmissionsTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      rejectReason: serializer.fromJson<String?>(json['rejectReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'facilityId': serializer.toJson<String?>(facilityId),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'payload': serializer.toJson<String>(payload),
      'photoPath': serializer.toJson<String?>(photoPath),
      'state': serializer.toJson<String>(
        $SubmissionsTable.$converterstate.toJson(state),
      ),
      'rejectReason': serializer.toJson<String?>(rejectReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Submission copyWith({
    String? id,
    Value<String?> facilityId = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    String? payload,
    Value<String?> photoPath = const Value.absent(),
    SubmissionState? state,
    Value<String?> rejectReason = const Value.absent(),
    DateTime? createdAt,
  }) => Submission(
    id: id ?? this.id,
    facilityId: facilityId.present ? facilityId.value : this.facilityId,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    payload: payload ?? this.payload,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    state: state ?? this.state,
    rejectReason: rejectReason.present ? rejectReason.value : this.rejectReason,
    createdAt: createdAt ?? this.createdAt,
  );
  Submission copyWithCompanion(SubmissionsCompanion data) {
    return Submission(
      id: data.id.present ? data.id.value : this.id,
      facilityId: data.facilityId.present
          ? data.facilityId.value
          : this.facilityId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      payload: data.payload.present ? data.payload.value : this.payload,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      state: data.state.present ? data.state.value : this.state,
      rejectReason: data.rejectReason.present
          ? data.rejectReason.value
          : this.rejectReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Submission(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('payload: $payload, ')
          ..write('photoPath: $photoPath, ')
          ..write('state: $state, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    facilityId,
    lat,
    lng,
    payload,
    photoPath,
    state,
    rejectReason,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Submission &&
          other.id == this.id &&
          other.facilityId == this.facilityId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.payload == this.payload &&
          other.photoPath == this.photoPath &&
          other.state == this.state &&
          other.rejectReason == this.rejectReason &&
          other.createdAt == this.createdAt);
}

class SubmissionsCompanion extends UpdateCompanion<Submission> {
  final Value<String> id;
  final Value<String?> facilityId;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String> payload;
  final Value<String?> photoPath;
  final Value<SubmissionState> state;
  final Value<String?> rejectReason;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SubmissionsCompanion({
    this.id = const Value.absent(),
    this.facilityId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.payload = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.state = const Value.absent(),
    this.rejectReason = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubmissionsCompanion.insert({
    required String id,
    this.facilityId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    required String payload,
    this.photoPath = const Value.absent(),
    required SubmissionState state,
    this.rejectReason = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       payload = Value(payload),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<Submission> custom({
    Expression<String>? id,
    Expression<String>? facilityId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? payload,
    Expression<String>? photoPath,
    Expression<String>? state,
    Expression<String>? rejectReason,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (facilityId != null) 'facility_id': facilityId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (payload != null) 'payload': payload,
      if (photoPath != null) 'photo_path': photoPath,
      if (state != null) 'state': state,
      if (rejectReason != null) 'reject_reason': rejectReason,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubmissionsCompanion copyWith({
    Value<String>? id,
    Value<String?>? facilityId,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String>? payload,
    Value<String?>? photoPath,
    Value<SubmissionState>? state,
    Value<String?>? rejectReason,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SubmissionsCompanion(
      id: id ?? this.id,
      facilityId: facilityId ?? this.facilityId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      payload: payload ?? this.payload,
      photoPath: photoPath ?? this.photoPath,
      state: state ?? this.state,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (facilityId.present) {
      map['facility_id'] = Variable<String>(facilityId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $SubmissionsTable.$converterstate.toSql(state.value),
      );
    }
    if (rejectReason.present) {
      map['reject_reason'] = Variable<String>(rejectReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubmissionsCompanion(')
          ..write('id: $id, ')
          ..write('facilityId: $facilityId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('payload: $payload, ')
          ..write('photoPath: $photoPath, ')
          ..write('state: $state, ')
          ..write('rejectReason: $rejectReason, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, Alert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlertSeverity, String> severity =
      GeneratedColumn<String>(
        'severity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AlertSeverity>($AlertsTable.$converterseverity);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    severity,
    body,
    lat,
    lng,
    radiusMeters,
    createdBy,
    createdAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Alert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Alert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Alert(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      severity: $AlertsTable.$converterseverity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}severity'],
        )!,
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlertSeverity, String, String> $converterseverity =
      const EnumNameConverter<AlertSeverity>(AlertSeverity.values);
}

class Alert extends DataClass implements Insertable<Alert> {
  final String id;
  final AlertSeverity severity;
  final String body;
  final double? lat;
  final double? lng;
  final double? radiusMeters;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime expiresAt;
  const Alert({
    required this.id,
    required this.severity,
    required this.body,
    this.lat,
    this.lng,
    this.radiusMeters,
    this.createdBy,
    required this.createdAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['severity'] = Variable<String>(
        $AlertsTable.$converterseverity.toSql(severity),
      );
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || radiusMeters != null) {
      map['radius_meters'] = Variable<double>(radiusMeters);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      severity: Value(severity),
      body: Value(body),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      radiusMeters: radiusMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(radiusMeters),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory Alert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Alert(
      id: serializer.fromJson<String>(json['id']),
      severity: $AlertsTable.$converterseverity.fromJson(
        serializer.fromJson<String>(json['severity']),
      ),
      body: serializer.fromJson<String>(json['body']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      radiusMeters: serializer.fromJson<double?>(json['radiusMeters']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'severity': serializer.toJson<String>(
        $AlertsTable.$converterseverity.toJson(severity),
      ),
      'body': serializer.toJson<String>(body),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'radiusMeters': serializer.toJson<double?>(radiusMeters),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  Alert copyWith({
    String? id,
    AlertSeverity? severity,
    String? body,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<double?> radiusMeters = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    DateTime? createdAt,
    DateTime? expiresAt,
  }) => Alert(
    id: id ?? this.id,
    severity: severity ?? this.severity,
    body: body ?? this.body,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    radiusMeters: radiusMeters.present ? radiusMeters.value : this.radiusMeters,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  Alert copyWithCompanion(AlertsCompanion data) {
    return Alert(
      id: data.id.present ? data.id.value : this.id,
      severity: data.severity.present ? data.severity.value : this.severity,
      body: data.body.present ? data.body.value : this.body,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Alert(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('body: $body, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    severity,
    body,
    lat,
    lng,
    radiusMeters,
    createdBy,
    createdAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Alert &&
          other.id == this.id &&
          other.severity == this.severity &&
          other.body == this.body &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.radiusMeters == this.radiusMeters &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.expiresAt == this.expiresAt);
}

class AlertsCompanion extends UpdateCompanion<Alert> {
  final Value<String> id;
  final Value<AlertSeverity> severity;
  final Value<String> body;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<double?> radiusMeters;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.severity = const Value.absent(),
    this.body = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required AlertSeverity severity,
    required String body,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       severity = Value(severity),
       body = Value(body),
       createdAt = Value(createdAt),
       expiresAt = Value(expiresAt);
  static Insertable<Alert> custom({
    Expression<String>? id,
    Expression<String>? severity,
    Expression<String>? body,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? radiusMeters,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (severity != null) 'severity': severity,
      if (body != null) 'body': body,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith({
    Value<String>? id,
    Value<AlertSeverity>? severity,
    Value<String>? body,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<double?>? radiusMeters,
    Value<String?>? createdBy,
    Value<DateTime>? createdAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return AlertsCompanion(
      id: id ?? this.id,
      severity: severity ?? this.severity,
      body: body ?? this.body,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(
        $AlertsTable.$converterseverity.toSql(severity.value),
      );
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('severity: $severity, ')
          ..write('body: $body, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<int> localId = GeneratedColumn<int>(
    'local_id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncOp, String> op =
      GeneratedColumn<String>(
        'op',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<SyncOp>($SyncQueueEntriesTable.$converterop);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncState, String> state =
      GeneratedColumn<String>(
        'state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncState.pending.name),
      ).withConverter<SyncState>($SyncQueueEntriesTable.$converterstate);
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    op,
    entity,
    entityId,
    payload,
    state,
    attempts,
    nextAttemptAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_id'],
      )!,
      op: $SyncQueueEntriesTable.$converterop.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}op'],
        )!,
      ),
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      state: $SyncQueueEntriesTable.$converterstate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}state'],
        )!,
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncOp, String, String> $converterop =
      const EnumNameConverter<SyncOp>(SyncOp.values);
  static JsonTypeConverter2<SyncState, String, String> $converterstate =
      const EnumNameConverter<SyncState>(SyncState.values);
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final int localId;
  final SyncOp op;
  final String entity;
  final String entityId;
  final String payload;
  final SyncState state;
  final int attempts;
  final DateTime nextAttemptAt;
  final DateTime createdAt;
  const SyncQueueEntry({
    required this.localId,
    required this.op,
    required this.entity,
    required this.entityId,
    required this.payload,
    required this.state,
    required this.attempts,
    required this.nextAttemptAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<int>(localId);
    {
      map['op'] = Variable<String>(
        $SyncQueueEntriesTable.$converterop.toSql(op),
      );
    }
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    {
      map['state'] = Variable<String>(
        $SyncQueueEntriesTable.$converterstate.toSql(state),
      );
    }
    map['attempts'] = Variable<int>(attempts);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      localId: Value(localId),
      op: Value(op),
      entity: Value(entity),
      entityId: Value(entityId),
      payload: Value(payload),
      state: Value(state),
      attempts: Value(attempts),
      nextAttemptAt: Value(nextAttemptAt),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      localId: serializer.fromJson<int>(json['localId']),
      op: $SyncQueueEntriesTable.$converterop.fromJson(
        serializer.fromJson<String>(json['op']),
      ),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      state: $SyncQueueEntriesTable.$converterstate.fromJson(
        serializer.fromJson<String>(json['state']),
      ),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<int>(localId),
      'op': serializer.toJson<String>(
        $SyncQueueEntriesTable.$converterop.toJson(op),
      ),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'state': serializer.toJson<String>(
        $SyncQueueEntriesTable.$converterstate.toJson(state),
      ),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueEntry copyWith({
    int? localId,
    SyncOp? op,
    String? entity,
    String? entityId,
    String? payload,
    SyncState? state,
    int? attempts,
    DateTime? nextAttemptAt,
    DateTime? createdAt,
  }) => SyncQueueEntry(
    localId: localId ?? this.localId,
    op: op ?? this.op,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    state: state ?? this.state,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      op: data.op.present ? data.op.value : this.op,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      state: data.state.present ? data.state.value : this.state,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('localId: $localId, ')
          ..write('op: $op, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    op,
    entity,
    entityId,
    payload,
    state,
    attempts,
    nextAttemptAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.localId == this.localId &&
          other.op == this.op &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.state == this.state &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.createdAt == this.createdAt);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<int> localId;
  final Value<SyncOp> op;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<SyncState> state;
  final Value<int> attempts;
  final Value<DateTime> nextAttemptAt;
  final Value<DateTime> createdAt;
  const SyncQueueEntriesCompanion({
    this.localId = const Value.absent(),
    this.op = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    this.localId = const Value.absent(),
    required SyncOp op,
    required String entity,
    required String entityId,
    required String payload,
    this.state = const Value.absent(),
    this.attempts = const Value.absent(),
    required DateTime nextAttemptAt,
    required DateTime createdAt,
  }) : op = Value(op),
       entity = Value(entity),
       entityId = Value(entityId),
       payload = Value(payload),
       nextAttemptAt = Value(nextAttemptAt),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueEntry> custom({
    Expression<int>? localId,
    Expression<String>? op,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<String>? state,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (op != null) 'op': op,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (state != null) 'state': state,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueEntriesCompanion copyWith({
    Value<int>? localId,
    Value<SyncOp>? op,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? payload,
    Value<SyncState>? state,
    Value<int>? attempts,
    Value<DateTime>? nextAttemptAt,
    Value<DateTime>? createdAt,
  }) {
    return SyncQueueEntriesCompanion(
      localId: localId ?? this.localId,
      op: op ?? this.op,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      state: state ?? this.state,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<int>(localId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(
        $SyncQueueEntriesTable.$converterop.toSql(op.value),
      );
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(
        $SyncQueueEntriesTable.$converterstate.toSql(state.value),
      );
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('localId: $localId, ')
          ..write('op: $op, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('state: $state, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CachedGroupMessagesTable extends CachedGroupMessages
    with TableInfo<$CachedGroupMessagesTable, CachedGroupMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedGroupMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ciphertextMeta = const VerificationMeta(
    'ciphertext',
  );
  @override
  late final GeneratedColumn<String> ciphertext = GeneratedColumn<String>(
    'ciphertext',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyEpochMeta = const VerificationMeta(
    'keyEpoch',
  );
  @override
  late final GeneratedColumn<int> keyEpoch = GeneratedColumn<int>(
    'key_epoch',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _pendingMeta = const VerificationMeta(
    'pending',
  );
  @override
  late final GeneratedColumn<bool> pending = GeneratedColumn<bool>(
    'pending',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pending" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    senderId,
    ciphertext,
    keyEpoch,
    pending,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_group_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedGroupMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('ciphertext')) {
      context.handle(
        _ciphertextMeta,
        ciphertext.isAcceptableOrUnknown(data['ciphertext']!, _ciphertextMeta),
      );
    } else if (isInserting) {
      context.missing(_ciphertextMeta);
    }
    if (data.containsKey('key_epoch')) {
      context.handle(
        _keyEpochMeta,
        keyEpoch.isAcceptableOrUnknown(data['key_epoch']!, _keyEpochMeta),
      );
    }
    if (data.containsKey('pending')) {
      context.handle(
        _pendingMeta,
        pending.isAcceptableOrUnknown(data['pending']!, _pendingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedGroupMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedGroupMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      ciphertext: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ciphertext'],
      )!,
      keyEpoch: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}key_epoch'],
      )!,
      pending: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pending'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CachedGroupMessagesTable createAlias(String alias) {
    return $CachedGroupMessagesTable(attachedDatabase, alias);
  }
}

class CachedGroupMessage extends DataClass
    implements Insertable<CachedGroupMessage> {
  /// Server message id once acknowledged; a `local:` id while pending.
  final String id;
  final String groupId;
  final String senderId;
  final String ciphertext;

  /// Which group-key epoch this ciphertext was sealed under. Keys rotate when
  /// a member is removed, and old keys are kept so history stays readable.
  final int keyEpoch;
  final bool pending;
  final DateTime createdAt;
  const CachedGroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.ciphertext,
    required this.keyEpoch,
    required this.pending,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['sender_id'] = Variable<String>(senderId);
    map['ciphertext'] = Variable<String>(ciphertext);
    map['key_epoch'] = Variable<int>(keyEpoch);
    map['pending'] = Variable<bool>(pending);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CachedGroupMessagesCompanion toCompanion(bool nullToAbsent) {
    return CachedGroupMessagesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      senderId: Value(senderId),
      ciphertext: Value(ciphertext),
      keyEpoch: Value(keyEpoch),
      pending: Value(pending),
      createdAt: Value(createdAt),
    );
  }

  factory CachedGroupMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedGroupMessage(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      ciphertext: serializer.fromJson<String>(json['ciphertext']),
      keyEpoch: serializer.fromJson<int>(json['keyEpoch']),
      pending: serializer.fromJson<bool>(json['pending']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'senderId': serializer.toJson<String>(senderId),
      'ciphertext': serializer.toJson<String>(ciphertext),
      'keyEpoch': serializer.toJson<int>(keyEpoch),
      'pending': serializer.toJson<bool>(pending),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CachedGroupMessage copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? ciphertext,
    int? keyEpoch,
    bool? pending,
    DateTime? createdAt,
  }) => CachedGroupMessage(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    senderId: senderId ?? this.senderId,
    ciphertext: ciphertext ?? this.ciphertext,
    keyEpoch: keyEpoch ?? this.keyEpoch,
    pending: pending ?? this.pending,
    createdAt: createdAt ?? this.createdAt,
  );
  CachedGroupMessage copyWithCompanion(CachedGroupMessagesCompanion data) {
    return CachedGroupMessage(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      ciphertext: data.ciphertext.present
          ? data.ciphertext.value
          : this.ciphertext,
      keyEpoch: data.keyEpoch.present ? data.keyEpoch.value : this.keyEpoch,
      pending: data.pending.present ? data.pending.value : this.pending,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroupMessage(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('senderId: $senderId, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('keyEpoch: $keyEpoch, ')
          ..write('pending: $pending, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    senderId,
    ciphertext,
    keyEpoch,
    pending,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedGroupMessage &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.senderId == this.senderId &&
          other.ciphertext == this.ciphertext &&
          other.keyEpoch == this.keyEpoch &&
          other.pending == this.pending &&
          other.createdAt == this.createdAt);
}

class CachedGroupMessagesCompanion extends UpdateCompanion<CachedGroupMessage> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> senderId;
  final Value<String> ciphertext;
  final Value<int> keyEpoch;
  final Value<bool> pending;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CachedGroupMessagesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.ciphertext = const Value.absent(),
    this.keyEpoch = const Value.absent(),
    this.pending = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedGroupMessagesCompanion.insert({
    required String id,
    required String groupId,
    required String senderId,
    required String ciphertext,
    this.keyEpoch = const Value.absent(),
    this.pending = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       groupId = Value(groupId),
       senderId = Value(senderId),
       ciphertext = Value(ciphertext),
       createdAt = Value(createdAt);
  static Insertable<CachedGroupMessage> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? senderId,
    Expression<String>? ciphertext,
    Expression<int>? keyEpoch,
    Expression<bool>? pending,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (senderId != null) 'sender_id': senderId,
      if (ciphertext != null) 'ciphertext': ciphertext,
      if (keyEpoch != null) 'key_epoch': keyEpoch,
      if (pending != null) 'pending': pending,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedGroupMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? senderId,
    Value<String>? ciphertext,
    Value<int>? keyEpoch,
    Value<bool>? pending,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CachedGroupMessagesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      ciphertext: ciphertext ?? this.ciphertext,
      keyEpoch: keyEpoch ?? this.keyEpoch,
      pending: pending ?? this.pending,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (ciphertext.present) {
      map['ciphertext'] = Variable<String>(ciphertext.value);
    }
    if (keyEpoch.present) {
      map['key_epoch'] = Variable<int>(keyEpoch.value);
    }
    if (pending.present) {
      map['pending'] = Variable<bool>(pending.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedGroupMessagesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('senderId: $senderId, ')
          ..write('ciphertext: $ciphertext, ')
          ..write('keyEpoch: $keyEpoch, ')
          ..write('pending: $pending, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RouteReportsTable extends RouteReports
    with TableInfo<$RouteReportsTable, RouteReport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteReportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<RouteCondition, String>
  condition = GeneratedColumn<String>(
    'condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<RouteCondition>($RouteReportsTable.$convertercondition);
  @override
  late final GeneratedColumnWithTypeConverter<RouteCause, String> cause =
      GeneratedColumn<String>(
        'cause',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RouteCause>($RouteReportsTable.$convertercause);
  static const VerificationMeta _startLatMeta = const VerificationMeta(
    'startLat',
  );
  @override
  late final GeneratedColumn<double> startLat = GeneratedColumn<double>(
    'start_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startLngMeta = const VerificationMeta(
    'startLng',
  );
  @override
  late final GeneratedColumn<double> startLng = GeneratedColumn<double>(
    'start_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLatMeta = const VerificationMeta('endLat');
  @override
  late final GeneratedColumn<double> endLat = GeneratedColumn<double>(
    'end_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endLngMeta = const VerificationMeta('endLng');
  @override
  late final GeneratedColumn<double> endLng = GeneratedColumn<double>(
    'end_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    condition,
    cause,
    startLat,
    startLng,
    endLat,
    endLng,
    note,
    verifiedAt,
    expiresAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_reports';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteReport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_lat')) {
      context.handle(
        _startLatMeta,
        startLat.isAcceptableOrUnknown(data['start_lat']!, _startLatMeta),
      );
    } else if (isInserting) {
      context.missing(_startLatMeta);
    }
    if (data.containsKey('start_lng')) {
      context.handle(
        _startLngMeta,
        startLng.isAcceptableOrUnknown(data['start_lng']!, _startLngMeta),
      );
    } else if (isInserting) {
      context.missing(_startLngMeta);
    }
    if (data.containsKey('end_lat')) {
      context.handle(
        _endLatMeta,
        endLat.isAcceptableOrUnknown(data['end_lat']!, _endLatMeta),
      );
    } else if (isInserting) {
      context.missing(_endLatMeta);
    }
    if (data.containsKey('end_lng')) {
      context.handle(
        _endLngMeta,
        endLng.isAcceptableOrUnknown(data['end_lng']!, _endLngMeta),
      );
    } else if (isInserting) {
      context.missing(_endLngMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RouteReport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteReport(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      condition: $RouteReportsTable.$convertercondition.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}condition'],
        )!,
      ),
      cause: $RouteReportsTable.$convertercause.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cause'],
        )!,
      ),
      startLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lat'],
      )!,
      startLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_lng'],
      )!,
      endLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lat'],
      )!,
      endLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_lng'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RouteReportsTable createAlias(String alias) {
    return $RouteReportsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<RouteCondition, String, String>
  $convertercondition = const EnumNameConverter<RouteCondition>(
    RouteCondition.values,
  );
  static JsonTypeConverter2<RouteCause, String, String> $convertercause =
      const EnumNameConverter<RouteCause>(RouteCause.values);
}

class RouteReport extends DataClass implements Insertable<RouteReport> {
  final String id;
  final String name;
  final RouteCondition condition;
  final RouteCause cause;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String? note;
  final DateTime? verifiedAt;
  final DateTime expiresAt;
  final DateTime updatedAt;
  const RouteReport({
    required this.id,
    required this.name,
    required this.condition,
    required this.cause,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    this.note,
    this.verifiedAt,
    required this.expiresAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['condition'] = Variable<String>(
        $RouteReportsTable.$convertercondition.toSql(condition),
      );
    }
    {
      map['cause'] = Variable<String>(
        $RouteReportsTable.$convertercause.toSql(cause),
      );
    }
    map['start_lat'] = Variable<double>(startLat);
    map['start_lng'] = Variable<double>(startLng);
    map['end_lat'] = Variable<double>(endLat);
    map['end_lng'] = Variable<double>(endLng);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || verifiedAt != null) {
      map['verified_at'] = Variable<DateTime>(verifiedAt);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RouteReportsCompanion toCompanion(bool nullToAbsent) {
    return RouteReportsCompanion(
      id: Value(id),
      name: Value(name),
      condition: Value(condition),
      cause: Value(cause),
      startLat: Value(startLat),
      startLng: Value(startLng),
      endLat: Value(endLat),
      endLng: Value(endLng),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      verifiedAt: verifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(verifiedAt),
      expiresAt: Value(expiresAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory RouteReport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteReport(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      condition: $RouteReportsTable.$convertercondition.fromJson(
        serializer.fromJson<String>(json['condition']),
      ),
      cause: $RouteReportsTable.$convertercause.fromJson(
        serializer.fromJson<String>(json['cause']),
      ),
      startLat: serializer.fromJson<double>(json['startLat']),
      startLng: serializer.fromJson<double>(json['startLng']),
      endLat: serializer.fromJson<double>(json['endLat']),
      endLng: serializer.fromJson<double>(json['endLng']),
      note: serializer.fromJson<String?>(json['note']),
      verifiedAt: serializer.fromJson<DateTime?>(json['verifiedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'condition': serializer.toJson<String>(
        $RouteReportsTable.$convertercondition.toJson(condition),
      ),
      'cause': serializer.toJson<String>(
        $RouteReportsTable.$convertercause.toJson(cause),
      ),
      'startLat': serializer.toJson<double>(startLat),
      'startLng': serializer.toJson<double>(startLng),
      'endLat': serializer.toJson<double>(endLat),
      'endLng': serializer.toJson<double>(endLng),
      'note': serializer.toJson<String?>(note),
      'verifiedAt': serializer.toJson<DateTime?>(verifiedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RouteReport copyWith({
    String? id,
    String? name,
    RouteCondition? condition,
    RouteCause? cause,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    Value<String?> note = const Value.absent(),
    Value<DateTime?> verifiedAt = const Value.absent(),
    DateTime? expiresAt,
    DateTime? updatedAt,
  }) => RouteReport(
    id: id ?? this.id,
    name: name ?? this.name,
    condition: condition ?? this.condition,
    cause: cause ?? this.cause,
    startLat: startLat ?? this.startLat,
    startLng: startLng ?? this.startLng,
    endLat: endLat ?? this.endLat,
    endLng: endLng ?? this.endLng,
    note: note.present ? note.value : this.note,
    verifiedAt: verifiedAt.present ? verifiedAt.value : this.verifiedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  RouteReport copyWithCompanion(RouteReportsCompanion data) {
    return RouteReport(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      condition: data.condition.present ? data.condition.value : this.condition,
      cause: data.cause.present ? data.cause.value : this.cause,
      startLat: data.startLat.present ? data.startLat.value : this.startLat,
      startLng: data.startLng.present ? data.startLng.value : this.startLng,
      endLat: data.endLat.present ? data.endLat.value : this.endLat,
      endLng: data.endLng.present ? data.endLng.value : this.endLng,
      note: data.note.present ? data.note.value : this.note,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteReport(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('condition: $condition, ')
          ..write('cause: $cause, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('note: $note, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    condition,
    cause,
    startLat,
    startLng,
    endLat,
    endLng,
    note,
    verifiedAt,
    expiresAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteReport &&
          other.id == this.id &&
          other.name == this.name &&
          other.condition == this.condition &&
          other.cause == this.cause &&
          other.startLat == this.startLat &&
          other.startLng == this.startLng &&
          other.endLat == this.endLat &&
          other.endLng == this.endLng &&
          other.note == this.note &&
          other.verifiedAt == this.verifiedAt &&
          other.expiresAt == this.expiresAt &&
          other.updatedAt == this.updatedAt);
}

class RouteReportsCompanion extends UpdateCompanion<RouteReport> {
  final Value<String> id;
  final Value<String> name;
  final Value<RouteCondition> condition;
  final Value<RouteCause> cause;
  final Value<double> startLat;
  final Value<double> startLng;
  final Value<double> endLat;
  final Value<double> endLng;
  final Value<String?> note;
  final Value<DateTime?> verifiedAt;
  final Value<DateTime> expiresAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const RouteReportsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.condition = const Value.absent(),
    this.cause = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.endLat = const Value.absent(),
    this.endLng = const Value.absent(),
    this.note = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RouteReportsCompanion.insert({
    required String id,
    required String name,
    required RouteCondition condition,
    required RouteCause cause,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    this.note = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    required DateTime expiresAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       condition = Value(condition),
       cause = Value(cause),
       startLat = Value(startLat),
       startLng = Value(startLng),
       endLat = Value(endLat),
       endLng = Value(endLng),
       expiresAt = Value(expiresAt),
       updatedAt = Value(updatedAt);
  static Insertable<RouteReport> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? condition,
    Expression<String>? cause,
    Expression<double>? startLat,
    Expression<double>? startLng,
    Expression<double>? endLat,
    Expression<double>? endLng,
    Expression<String>? note,
    Expression<DateTime>? verifiedAt,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (condition != null) 'condition': condition,
      if (cause != null) 'cause': cause,
      if (startLat != null) 'start_lat': startLat,
      if (startLng != null) 'start_lng': startLng,
      if (endLat != null) 'end_lat': endLat,
      if (endLng != null) 'end_lng': endLng,
      if (note != null) 'note': note,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RouteReportsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<RouteCondition>? condition,
    Value<RouteCause>? cause,
    Value<double>? startLat,
    Value<double>? startLng,
    Value<double>? endLat,
    Value<double>? endLng,
    Value<String?>? note,
    Value<DateTime?>? verifiedAt,
    Value<DateTime>? expiresAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return RouteReportsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      condition: condition ?? this.condition,
      cause: cause ?? this.cause,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      note: note ?? this.note,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(
        $RouteReportsTable.$convertercondition.toSql(condition.value),
      );
    }
    if (cause.present) {
      map['cause'] = Variable<String>(
        $RouteReportsTable.$convertercause.toSql(cause.value),
      );
    }
    if (startLat.present) {
      map['start_lat'] = Variable<double>(startLat.value);
    }
    if (startLng.present) {
      map['start_lng'] = Variable<double>(startLng.value);
    }
    if (endLat.present) {
      map['end_lat'] = Variable<double>(endLat.value);
    }
    if (endLng.present) {
      map['end_lng'] = Variable<double>(endLng.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteReportsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('condition: $condition, ')
          ..write('cause: $cause, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('endLat: $endLat, ')
          ..write('endLng: $endLng, ')
          ..write('note: $note, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FacilitiesTable facilities = $FacilitiesTable(this);
  late final $CapacityReadingsTable capacityReadings = $CapacityReadingsTable(
    this,
  );
  late final $SubmissionsTable submissions = $SubmissionsTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries = $SyncQueueEntriesTable(
    this,
  );
  late final $CachedGroupMessagesTable cachedGroupMessages =
      $CachedGroupMessagesTable(this);
  late final $RouteReportsTable routeReports = $RouteReportsTable(this);
  late final Index idxCachedGroupMessagesGroup = Index(
    'idx_cached_group_messages_group',
    'CREATE INDEX idx_cached_group_messages_group ON cached_group_messages (group_id)',
  );
  late final Index idxRouteReportsExpiry = Index(
    'idx_route_reports_expiry',
    'CREATE INDEX idx_route_reports_expiry ON route_reports (expires_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    facilities,
    capacityReadings,
    submissions,
    alerts,
    syncQueueEntries,
    cachedGroupMessages,
    routeReports,
    idxCachedGroupMessagesGroup,
    idxRouteReportsExpiry,
  ];
}

typedef $$FacilitiesTableCreateCompanionBuilder =
    FacilitiesCompanion Function({
      required String id,
      required String name,
      required FacilityType type,
      required FacilityStatus status,
      required double lat,
      required double lng,
      Value<bool> canonical,
      Value<DateTime?> verifiedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FacilitiesTableUpdateCompanionBuilder =
    FacilitiesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<FacilityType> type,
      Value<FacilityStatus> status,
      Value<double> lat,
      Value<double> lng,
      Value<bool> canonical,
      Value<DateTime?> verifiedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FacilitiesTableReferences
    extends BaseReferences<_$AppDatabase, $FacilitiesTable, Facility> {
  $$FacilitiesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CapacityReadingsTable, List<CapacityReading>>
  _capacityReadingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.capacityReadings,
    aliasName: $_aliasNameGenerator(
      db.facilities.id,
      db.capacityReadings.facilityId,
    ),
  );

  $$CapacityReadingsTableProcessedTableManager get capacityReadingsRefs {
    final manager = $$CapacityReadingsTableTableManager(
      $_db,
      $_db.capacityReadings,
    ).filter((f) => f.facilityId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _capacityReadingsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FacilitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FacilityType, FacilityType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<FacilityStatus, FacilityStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> capacityReadingsRefs(
    Expression<bool> Function($$CapacityReadingsTableFilterComposer f) f,
  ) {
    final $$CapacityReadingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capacityReadings,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapacityReadingsTableFilterComposer(
            $db: $db,
            $table: $db.capacityReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canonical => $composableBuilder(
    column: $table.canonical,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FacilitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FacilitiesTable> {
  $$FacilitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FacilityType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FacilityStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<bool> get canonical =>
      $composableBuilder(column: $table.canonical, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> capacityReadingsRefs<T extends Object>(
    Expression<T> Function($$CapacityReadingsTableAnnotationComposer a) f,
  ) {
    final $$CapacityReadingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.capacityReadings,
      getReferencedColumn: (t) => t.facilityId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CapacityReadingsTableAnnotationComposer(
            $db: $db,
            $table: $db.capacityReadings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FacilitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FacilitiesTable,
          Facility,
          $$FacilitiesTableFilterComposer,
          $$FacilitiesTableOrderingComposer,
          $$FacilitiesTableAnnotationComposer,
          $$FacilitiesTableCreateCompanionBuilder,
          $$FacilitiesTableUpdateCompanionBuilder,
          (Facility, $$FacilitiesTableReferences),
          Facility,
          PrefetchHooks Function({bool capacityReadingsRefs})
        > {
  $$FacilitiesTableTableManager(_$AppDatabase db, $FacilitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FacilitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FacilitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FacilitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<FacilityType> type = const Value.absent(),
                Value<FacilityStatus> status = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<bool> canonical = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FacilitiesCompanion(
                id: id,
                name: name,
                type: type,
                status: status,
                lat: lat,
                lng: lng,
                canonical: canonical,
                verifiedAt: verifiedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required FacilityType type,
                required FacilityStatus status,
                required double lat,
                required double lng,
                Value<bool> canonical = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FacilitiesCompanion.insert(
                id: id,
                name: name,
                type: type,
                status: status,
                lat: lat,
                lng: lng,
                canonical: canonical,
                verifiedAt: verifiedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FacilitiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({capacityReadingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (capacityReadingsRefs) db.capacityReadings,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (capacityReadingsRefs)
                    await $_getPrefetchedData<
                      Facility,
                      $FacilitiesTable,
                      CapacityReading
                    >(
                      currentTable: table,
                      referencedTable: $$FacilitiesTableReferences
                          ._capacityReadingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FacilitiesTableReferences(
                            db,
                            table,
                            p0,
                          ).capacityReadingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.facilityId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FacilitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FacilitiesTable,
      Facility,
      $$FacilitiesTableFilterComposer,
      $$FacilitiesTableOrderingComposer,
      $$FacilitiesTableAnnotationComposer,
      $$FacilitiesTableCreateCompanionBuilder,
      $$FacilitiesTableUpdateCompanionBuilder,
      (Facility, $$FacilitiesTableReferences),
      Facility,
      PrefetchHooks Function({bool capacityReadingsRefs})
    >;
typedef $$CapacityReadingsTableCreateCompanionBuilder =
    CapacityReadingsCompanion Function({
      required String id,
      required String facilityId,
      required ResourceType resource,
      required int forPeople,
      Value<String?> verifiedBy,
      Value<DateTime?> verifiedAt,
      required DateTime expiresAt,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CapacityReadingsTableUpdateCompanionBuilder =
    CapacityReadingsCompanion Function({
      Value<String> id,
      Value<String> facilityId,
      Value<ResourceType> resource,
      Value<int> forPeople,
      Value<String?> verifiedBy,
      Value<DateTime?> verifiedAt,
      Value<DateTime> expiresAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CapacityReadingsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CapacityReadingsTable, CapacityReading> {
  $$CapacityReadingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $FacilitiesTable _facilityIdTable(_$AppDatabase db) =>
      db.facilities.createAlias(
        $_aliasNameGenerator(db.capacityReadings.facilityId, db.facilities.id),
      );

  $$FacilitiesTableProcessedTableManager get facilityId {
    final $_column = $_itemColumn<String>('facility_id')!;

    final manager = $$FacilitiesTableTableManager(
      $_db,
      $_db.facilities,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_facilityIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CapacityReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $CapacityReadingsTable> {
  $$CapacityReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ResourceType, ResourceType, String>
  get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get forPeople => $composableBuilder(
    column: $table.forPeople,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verifiedBy => $composableBuilder(
    column: $table.verifiedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FacilitiesTableFilterComposer get facilityId {
    final $$FacilitiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableFilterComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapacityReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CapacityReadingsTable> {
  $$CapacityReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resource => $composableBuilder(
    column: $table.resource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get forPeople => $composableBuilder(
    column: $table.forPeople,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verifiedBy => $composableBuilder(
    column: $table.verifiedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FacilitiesTableOrderingComposer get facilityId {
    final $$FacilitiesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableOrderingComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapacityReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapacityReadingsTable> {
  $$CapacityReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ResourceType, String> get resource =>
      $composableBuilder(column: $table.resource, builder: (column) => column);

  GeneratedColumn<int> get forPeople =>
      $composableBuilder(column: $table.forPeople, builder: (column) => column);

  GeneratedColumn<String> get verifiedBy => $composableBuilder(
    column: $table.verifiedBy,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FacilitiesTableAnnotationComposer get facilityId {
    final $$FacilitiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.facilityId,
      referencedTable: $db.facilities,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FacilitiesTableAnnotationComposer(
            $db: $db,
            $table: $db.facilities,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CapacityReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapacityReadingsTable,
          CapacityReading,
          $$CapacityReadingsTableFilterComposer,
          $$CapacityReadingsTableOrderingComposer,
          $$CapacityReadingsTableAnnotationComposer,
          $$CapacityReadingsTableCreateCompanionBuilder,
          $$CapacityReadingsTableUpdateCompanionBuilder,
          (CapacityReading, $$CapacityReadingsTableReferences),
          CapacityReading,
          PrefetchHooks Function({bool facilityId})
        > {
  $$CapacityReadingsTableTableManager(
    _$AppDatabase db,
    $CapacityReadingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapacityReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapacityReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapacityReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> facilityId = const Value.absent(),
                Value<ResourceType> resource = const Value.absent(),
                Value<int> forPeople = const Value.absent(),
                Value<String?> verifiedBy = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapacityReadingsCompanion(
                id: id,
                facilityId: facilityId,
                resource: resource,
                forPeople: forPeople,
                verifiedBy: verifiedBy,
                verifiedAt: verifiedAt,
                expiresAt: expiresAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String facilityId,
                required ResourceType resource,
                required int forPeople,
                Value<String?> verifiedBy = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                required DateTime expiresAt,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CapacityReadingsCompanion.insert(
                id: id,
                facilityId: facilityId,
                resource: resource,
                forPeople: forPeople,
                verifiedBy: verifiedBy,
                verifiedAt: verifiedAt,
                expiresAt: expiresAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CapacityReadingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({facilityId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (facilityId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.facilityId,
                                referencedTable:
                                    $$CapacityReadingsTableReferences
                                        ._facilityIdTable(db),
                                referencedColumn:
                                    $$CapacityReadingsTableReferences
                                        ._facilityIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CapacityReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapacityReadingsTable,
      CapacityReading,
      $$CapacityReadingsTableFilterComposer,
      $$CapacityReadingsTableOrderingComposer,
      $$CapacityReadingsTableAnnotationComposer,
      $$CapacityReadingsTableCreateCompanionBuilder,
      $$CapacityReadingsTableUpdateCompanionBuilder,
      (CapacityReading, $$CapacityReadingsTableReferences),
      CapacityReading,
      PrefetchHooks Function({bool facilityId})
    >;
typedef $$SubmissionsTableCreateCompanionBuilder =
    SubmissionsCompanion Function({
      required String id,
      Value<String?> facilityId,
      Value<double?> lat,
      Value<double?> lng,
      required String payload,
      Value<String?> photoPath,
      required SubmissionState state,
      Value<String?> rejectReason,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SubmissionsTableUpdateCompanionBuilder =
    SubmissionsCompanion Function({
      Value<String> id,
      Value<String?> facilityId,
      Value<double?> lat,
      Value<double?> lng,
      Value<String> payload,
      Value<String?> photoPath,
      Value<SubmissionState> state,
      Value<String?> rejectReason,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SubmissionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubmissionState, SubmissionState, String>
  get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubmissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubmissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubmissionsTable> {
  $$SubmissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get facilityId => $composableBuilder(
    column: $table.facilityId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubmissionState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get rejectReason => $composableBuilder(
    column: $table.rejectReason,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubmissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubmissionsTable,
          Submission,
          $$SubmissionsTableFilterComposer,
          $$SubmissionsTableOrderingComposer,
          $$SubmissionsTableAnnotationComposer,
          $$SubmissionsTableCreateCompanionBuilder,
          $$SubmissionsTableUpdateCompanionBuilder,
          (
            Submission,
            BaseReferences<_$AppDatabase, $SubmissionsTable, Submission>,
          ),
          Submission,
          PrefetchHooks Function()
        > {
  $$SubmissionsTableTableManager(_$AppDatabase db, $SubmissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubmissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubmissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubmissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> facilityId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<SubmissionState> state = const Value.absent(),
                Value<String?> rejectReason = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubmissionsCompanion(
                id: id,
                facilityId: facilityId,
                lat: lat,
                lng: lng,
                payload: payload,
                photoPath: photoPath,
                state: state,
                rejectReason: rejectReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> facilityId = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                required String payload,
                Value<String?> photoPath = const Value.absent(),
                required SubmissionState state,
                Value<String?> rejectReason = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SubmissionsCompanion.insert(
                id: id,
                facilityId: facilityId,
                lat: lat,
                lng: lng,
                payload: payload,
                photoPath: photoPath,
                state: state,
                rejectReason: rejectReason,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubmissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubmissionsTable,
      Submission,
      $$SubmissionsTableFilterComposer,
      $$SubmissionsTableOrderingComposer,
      $$SubmissionsTableAnnotationComposer,
      $$SubmissionsTableCreateCompanionBuilder,
      $$SubmissionsTableUpdateCompanionBuilder,
      (
        Submission,
        BaseReferences<_$AppDatabase, $SubmissionsTable, Submission>,
      ),
      Submission,
      PrefetchHooks Function()
    >;
typedef $$AlertsTableCreateCompanionBuilder =
    AlertsCompanion Function({
      required String id,
      required AlertSeverity severity,
      required String body,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> radiusMeters,
      Value<String?> createdBy,
      required DateTime createdAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$AlertsTableUpdateCompanionBuilder =
    AlertsCompanion Function({
      Value<String> id,
      Value<AlertSeverity> severity,
      Value<String> body,
      Value<double?> lat,
      Value<double?> lng,
      Value<double?> radiusMeters,
      Value<String?> createdBy,
      Value<DateTime> createdAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertSeverity, AlertSeverity, String>
  get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertSeverity, String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$AlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertsTable,
          Alert,
          $$AlertsTableFilterComposer,
          $$AlertsTableOrderingComposer,
          $$AlertsTableAnnotationComposer,
          $$AlertsTableCreateCompanionBuilder,
          $$AlertsTableUpdateCompanionBuilder,
          (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
          Alert,
          PrefetchHooks Function()
        > {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<AlertSeverity> severity = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> radiusMeters = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertsCompanion(
                id: id,
                severity: severity,
                body: body,
                lat: lat,
                lng: lng,
                radiusMeters: radiusMeters,
                createdBy: createdBy,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required AlertSeverity severity,
                required String body,
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<double?> radiusMeters = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                required DateTime createdAt,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => AlertsCompanion.insert(
                id: id,
                severity: severity,
                body: body,
                lat: lat,
                lng: lng,
                radiusMeters: radiusMeters,
                createdBy: createdBy,
                createdAt: createdAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertsTable,
      Alert,
      $$AlertsTableFilterComposer,
      $$AlertsTableOrderingComposer,
      $$AlertsTableAnnotationComposer,
      $$AlertsTableCreateCompanionBuilder,
      $$AlertsTableUpdateCompanionBuilder,
      (Alert, BaseReferences<_$AppDatabase, $AlertsTable, Alert>),
      Alert,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> localId,
      required SyncOp op,
      required String entity,
      required String entityId,
      required String payload,
      Value<SyncState> state,
      Value<int> attempts,
      required DateTime nextAttemptAt,
      required DateTime createdAt,
    });
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder =
    SyncQueueEntriesCompanion Function({
      Value<int> localId,
      Value<SyncOp> op,
      Value<String> entity,
      Value<String> entityId,
      Value<String> payload,
      Value<SyncState> state,
      Value<int> attempts,
      Value<DateTime> nextAttemptAt,
      Value<DateTime> createdAt,
    });

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncOp, SyncOp, String> get op =>
      $composableBuilder(
        column: $table.op,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncState, SyncState, String> get state =>
      $composableBuilder(
        column: $table.state,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncOp, String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncState, String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueEntriesTable,
          SyncQueueEntry,
          $$SyncQueueEntriesTableFilterComposer,
          $$SyncQueueEntriesTableOrderingComposer,
          $$SyncQueueEntriesTableAnnotationComposer,
          $$SyncQueueEntriesTableCreateCompanionBuilder,
          $$SyncQueueEntriesTableUpdateCompanionBuilder,
          (
            SyncQueueEntry,
            BaseReferences<
              _$AppDatabase,
              $SyncQueueEntriesTable,
              SyncQueueEntry
            >,
          ),
          SyncQueueEntry,
          PrefetchHooks Function()
        > {
  $$SyncQueueEntriesTableTableManager(
    _$AppDatabase db,
    $SyncQueueEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                Value<SyncOp> op = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<SyncState> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncQueueEntriesCompanion(
                localId: localId,
                op: op,
                entity: entity,
                entityId: entityId,
                payload: payload,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> localId = const Value.absent(),
                required SyncOp op,
                required String entity,
                required String entityId,
                required String payload,
                Value<SyncState> state = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                required DateTime nextAttemptAt,
                required DateTime createdAt,
              }) => SyncQueueEntriesCompanion.insert(
                localId: localId,
                op: op,
                entity: entity,
                entityId: entityId,
                payload: payload,
                state: state,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueEntriesTable,
      SyncQueueEntry,
      $$SyncQueueEntriesTableFilterComposer,
      $$SyncQueueEntriesTableOrderingComposer,
      $$SyncQueueEntriesTableAnnotationComposer,
      $$SyncQueueEntriesTableCreateCompanionBuilder,
      $$SyncQueueEntriesTableUpdateCompanionBuilder,
      (
        SyncQueueEntry,
        BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>,
      ),
      SyncQueueEntry,
      PrefetchHooks Function()
    >;
typedef $$CachedGroupMessagesTableCreateCompanionBuilder =
    CachedGroupMessagesCompanion Function({
      required String id,
      required String groupId,
      required String senderId,
      required String ciphertext,
      Value<int> keyEpoch,
      Value<bool> pending,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CachedGroupMessagesTableUpdateCompanionBuilder =
    CachedGroupMessagesCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> senderId,
      Value<String> ciphertext,
      Value<int> keyEpoch,
      Value<bool> pending,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CachedGroupMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedGroupMessagesTable> {
  $$CachedGroupMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get keyEpoch => $composableBuilder(
    column: $table.keyEpoch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedGroupMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedGroupMessagesTable> {
  $$CachedGroupMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get keyEpoch => $composableBuilder(
    column: $table.keyEpoch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pending => $composableBuilder(
    column: $table.pending,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedGroupMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedGroupMessagesTable> {
  $$CachedGroupMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get ciphertext => $composableBuilder(
    column: $table.ciphertext,
    builder: (column) => column,
  );

  GeneratedColumn<int> get keyEpoch =>
      $composableBuilder(column: $table.keyEpoch, builder: (column) => column);

  GeneratedColumn<bool> get pending =>
      $composableBuilder(column: $table.pending, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CachedGroupMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedGroupMessagesTable,
          CachedGroupMessage,
          $$CachedGroupMessagesTableFilterComposer,
          $$CachedGroupMessagesTableOrderingComposer,
          $$CachedGroupMessagesTableAnnotationComposer,
          $$CachedGroupMessagesTableCreateCompanionBuilder,
          $$CachedGroupMessagesTableUpdateCompanionBuilder,
          (
            CachedGroupMessage,
            BaseReferences<
              _$AppDatabase,
              $CachedGroupMessagesTable,
              CachedGroupMessage
            >,
          ),
          CachedGroupMessage,
          PrefetchHooks Function()
        > {
  $$CachedGroupMessagesTableTableManager(
    _$AppDatabase db,
    $CachedGroupMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedGroupMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedGroupMessagesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CachedGroupMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> ciphertext = const Value.absent(),
                Value<int> keyEpoch = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedGroupMessagesCompanion(
                id: id,
                groupId: groupId,
                senderId: senderId,
                ciphertext: ciphertext,
                keyEpoch: keyEpoch,
                pending: pending,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String groupId,
                required String senderId,
                required String ciphertext,
                Value<int> keyEpoch = const Value.absent(),
                Value<bool> pending = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedGroupMessagesCompanion.insert(
                id: id,
                groupId: groupId,
                senderId: senderId,
                ciphertext: ciphertext,
                keyEpoch: keyEpoch,
                pending: pending,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedGroupMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedGroupMessagesTable,
      CachedGroupMessage,
      $$CachedGroupMessagesTableFilterComposer,
      $$CachedGroupMessagesTableOrderingComposer,
      $$CachedGroupMessagesTableAnnotationComposer,
      $$CachedGroupMessagesTableCreateCompanionBuilder,
      $$CachedGroupMessagesTableUpdateCompanionBuilder,
      (
        CachedGroupMessage,
        BaseReferences<
          _$AppDatabase,
          $CachedGroupMessagesTable,
          CachedGroupMessage
        >,
      ),
      CachedGroupMessage,
      PrefetchHooks Function()
    >;
typedef $$RouteReportsTableCreateCompanionBuilder =
    RouteReportsCompanion Function({
      required String id,
      required String name,
      required RouteCondition condition,
      required RouteCause cause,
      required double startLat,
      required double startLng,
      required double endLat,
      required double endLng,
      Value<String?> note,
      Value<DateTime?> verifiedAt,
      required DateTime expiresAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$RouteReportsTableUpdateCompanionBuilder =
    RouteReportsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<RouteCondition> condition,
      Value<RouteCause> cause,
      Value<double> startLat,
      Value<double> startLng,
      Value<double> endLat,
      Value<double> endLng,
      Value<String?> note,
      Value<DateTime?> verifiedAt,
      Value<DateTime> expiresAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$RouteReportsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteReportsTable> {
  $$RouteReportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RouteCondition, RouteCondition, String>
  get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<RouteCause, RouteCause, String> get cause =>
      $composableBuilder(
        column: $table.cause,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RouteReportsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteReportsTable> {
  $$RouteReportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get condition => $composableBuilder(
    column: $table.condition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cause => $composableBuilder(
    column: $table.cause,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLat => $composableBuilder(
    column: $table.startLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLng => $composableBuilder(
    column: $table.startLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLat => $composableBuilder(
    column: $table.endLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLng => $composableBuilder(
    column: $table.endLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RouteReportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteReportsTable> {
  $$RouteReportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RouteCondition, String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RouteCause, String> get cause =>
      $composableBuilder(column: $table.cause, builder: (column) => column);

  GeneratedColumn<double> get startLat =>
      $composableBuilder(column: $table.startLat, builder: (column) => column);

  GeneratedColumn<double> get startLng =>
      $composableBuilder(column: $table.startLng, builder: (column) => column);

  GeneratedColumn<double> get endLat =>
      $composableBuilder(column: $table.endLat, builder: (column) => column);

  GeneratedColumn<double> get endLng =>
      $composableBuilder(column: $table.endLng, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RouteReportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteReportsTable,
          RouteReport,
          $$RouteReportsTableFilterComposer,
          $$RouteReportsTableOrderingComposer,
          $$RouteReportsTableAnnotationComposer,
          $$RouteReportsTableCreateCompanionBuilder,
          $$RouteReportsTableUpdateCompanionBuilder,
          (
            RouteReport,
            BaseReferences<_$AppDatabase, $RouteReportsTable, RouteReport>,
          ),
          RouteReport,
          PrefetchHooks Function()
        > {
  $$RouteReportsTableTableManager(_$AppDatabase db, $RouteReportsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteReportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RouteReportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RouteReportsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<RouteCondition> condition = const Value.absent(),
                Value<RouteCause> cause = const Value.absent(),
                Value<double> startLat = const Value.absent(),
                Value<double> startLng = const Value.absent(),
                Value<double> endLat = const Value.absent(),
                Value<double> endLng = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RouteReportsCompanion(
                id: id,
                name: name,
                condition: condition,
                cause: cause,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                note: note,
                verifiedAt: verifiedAt,
                expiresAt: expiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required RouteCondition condition,
                required RouteCause cause,
                required double startLat,
                required double startLng,
                required double endLat,
                required double endLng,
                Value<String?> note = const Value.absent(),
                Value<DateTime?> verifiedAt = const Value.absent(),
                required DateTime expiresAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RouteReportsCompanion.insert(
                id: id,
                name: name,
                condition: condition,
                cause: cause,
                startLat: startLat,
                startLng: startLng,
                endLat: endLat,
                endLng: endLng,
                note: note,
                verifiedAt: verifiedAt,
                expiresAt: expiresAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RouteReportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteReportsTable,
      RouteReport,
      $$RouteReportsTableFilterComposer,
      $$RouteReportsTableOrderingComposer,
      $$RouteReportsTableAnnotationComposer,
      $$RouteReportsTableCreateCompanionBuilder,
      $$RouteReportsTableUpdateCompanionBuilder,
      (
        RouteReport,
        BaseReferences<_$AppDatabase, $RouteReportsTable, RouteReport>,
      ),
      RouteReport,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FacilitiesTableTableManager get facilities =>
      $$FacilitiesTableTableManager(_db, _db.facilities);
  $$CapacityReadingsTableTableManager get capacityReadings =>
      $$CapacityReadingsTableTableManager(_db, _db.capacityReadings);
  $$SubmissionsTableTableManager get submissions =>
      $$SubmissionsTableTableManager(_db, _db.submissions);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
  $$CachedGroupMessagesTableTableManager get cachedGroupMessages =>
      $$CachedGroupMessagesTableTableManager(_db, _db.cachedGroupMessages);
  $$RouteReportsTableTableManager get routeReports =>
      $$RouteReportsTableTableManager(_db, _db.routeReports);
}
