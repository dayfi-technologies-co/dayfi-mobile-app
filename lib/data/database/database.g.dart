// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DumpedRecordsTable extends DumpedRecords
    with TableInfo<$DumpedRecordsTable, DumpedRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DumpedRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
      'config', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(DEFAULT_CONFIG));
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, time, config, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dumped_records';
  @override
  VerificationContext validateIntegrity(Insertable<DumpedRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(_configMeta,
          config.isAcceptableOrUnknown(data['config']!, _configMeta));
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DumpedRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DumpedRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}time'])!,
      config: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}config'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $DumpedRecordsTable createAlias(String alias) {
    return $DumpedRecordsTable(attachedDatabase, alias);
  }
}

class DumpedRecord extends DataClass implements Insertable<DumpedRecord> {
  final int id;
  final DateTime time;
  final String config;
  final String data;
  const DumpedRecord(
      {required this.id,
      required this.time,
      required this.config,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['time'] = Variable<DateTime>(time);
    map['config'] = Variable<String>(config);
    map['data'] = Variable<String>(data);
    return map;
  }

  DumpedRecordsCompanion toCompanion(bool nullToAbsent) {
    return DumpedRecordsCompanion(
      id: Value(id),
      time: Value(time),
      config: Value(config),
      data: Value(data),
    );
  }

  factory DumpedRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DumpedRecord(
      id: serializer.fromJson<int>(json['id']),
      time: serializer.fromJson<DateTime>(json['time']),
      config: serializer.fromJson<String>(json['config']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'time': serializer.toJson<DateTime>(time),
      'config': serializer.toJson<String>(config),
      'data': serializer.toJson<String>(data),
    };
  }

  DumpedRecord copyWith(
          {int? id, DateTime? time, String? config, String? data}) =>
      DumpedRecord(
        id: id ?? this.id,
        time: time ?? this.time,
        config: config ?? this.config,
        data: data ?? this.data,
      );
  DumpedRecord copyWithCompanion(DumpedRecordsCompanion data) {
    return DumpedRecord(
      id: data.id.present ? data.id.value : this.id,
      time: data.time.present ? data.time.value : this.time,
      config: data.config.present ? data.config.value : this.config,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DumpedRecord(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('config: $config, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, time, config, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DumpedRecord &&
          other.id == this.id &&
          other.time == this.time &&
          other.config == this.config &&
          other.data == this.data);
}

class DumpedRecordsCompanion extends UpdateCompanion<DumpedRecord> {
  final Value<int> id;
  final Value<DateTime> time;
  final Value<String> config;
  final Value<String> data;
  const DumpedRecordsCompanion({
    this.id = const Value.absent(),
    this.time = const Value.absent(),
    this.config = const Value.absent(),
    this.data = const Value.absent(),
  });
  DumpedRecordsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime time,
    this.config = const Value.absent(),
    required String data,
  })  : time = Value(time),
        data = Value(data);
  static Insertable<DumpedRecord> custom({
    Expression<int>? id,
    Expression<DateTime>? time,
    Expression<String>? config,
    Expression<String>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (time != null) 'time': time,
      if (config != null) 'config': config,
      if (data != null) 'data': data,
    });
  }

  DumpedRecordsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? time,
      Value<String>? config,
      Value<String>? data}) {
    return DumpedRecordsCompanion(
      id: id ?? this.id,
      time: time ?? this.time,
      config: config ?? this.config,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DumpedRecordsCompanion(')
          ..write('id: $id, ')
          ..write('time: $time, ')
          ..write('config: $config, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $SavedScriptsTable extends SavedScripts
    with TableInfo<$SavedScriptsTable, SavedScript> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedScriptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _creationTimeMeta =
      const VerificationMeta('creationTime');
  @override
  late final GeneratedColumn<DateTime> creationTime = GeneratedColumn<DateTime>(
      'creation_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedMeta =
      const VerificationMeta('lastUsed');
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, source, creationTime, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_scripts';
  @override
  VerificationContext validateIntegrity(Insertable<SavedScript> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('creation_time')) {
      context.handle(
          _creationTimeMeta,
          creationTime.isAcceptableOrUnknown(
              data['creation_time']!, _creationTimeMeta));
    } else if (isInserting) {
      context.missing(_creationTimeMeta);
    }
    if (data.containsKey('last_used')) {
      context.handle(_lastUsedMeta,
          lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedScript map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedScript(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      creationTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}creation_time'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used']),
    );
  }

  @override
  $SavedScriptsTable createAlias(String alias) {
    return $SavedScriptsTable(attachedDatabase, alias);
  }
}

class SavedScript extends DataClass implements Insertable<SavedScript> {
  final int id;
  final String name;
  final String source;
  final DateTime creationTime;
  final DateTime? lastUsed;
  const SavedScript(
      {required this.id,
      required this.name,
      required this.source,
      required this.creationTime,
      this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['source'] = Variable<String>(source);
    map['creation_time'] = Variable<DateTime>(creationTime);
    if (!nullToAbsent || lastUsed != null) {
      map['last_used'] = Variable<DateTime>(lastUsed);
    }
    return map;
  }

  SavedScriptsCompanion toCompanion(bool nullToAbsent) {
    return SavedScriptsCompanion(
      id: Value(id),
      name: Value(name),
      source: Value(source),
      creationTime: Value(creationTime),
      lastUsed: lastUsed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsed),
    );
  }

  factory SavedScript.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedScript(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      source: serializer.fromJson<String>(json['source']),
      creationTime: serializer.fromJson<DateTime>(json['creationTime']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'source': serializer.toJson<String>(source),
      'creationTime': serializer.toJson<DateTime>(creationTime),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  SavedScript copyWith(
          {int? id,
          String? name,
          String? source,
          DateTime? creationTime,
          Value<DateTime?> lastUsed = const Value.absent()}) =>
      SavedScript(
        id: id ?? this.id,
        name: name ?? this.name,
        source: source ?? this.source,
        creationTime: creationTime ?? this.creationTime,
        lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
      );
  SavedScript copyWithCompanion(SavedScriptsCompanion data) {
    return SavedScript(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      source: data.source.present ? data.source.value : this.source,
      creationTime: data.creationTime.present
          ? data.creationTime.value
          : this.creationTime,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedScript(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('creationTime: $creationTime, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, source, creationTime, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedScript &&
          other.id == this.id &&
          other.name == this.name &&
          other.source == this.source &&
          other.creationTime == this.creationTime &&
          other.lastUsed == this.lastUsed);
}

class SavedScriptsCompanion extends UpdateCompanion<SavedScript> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> source;
  final Value<DateTime> creationTime;
  final Value<DateTime?> lastUsed;
  const SavedScriptsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.source = const Value.absent(),
    this.creationTime = const Value.absent(),
    this.lastUsed = const Value.absent(),
  });
  SavedScriptsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String source,
    required DateTime creationTime,
    this.lastUsed = const Value.absent(),
  })  : name = Value(name),
        source = Value(source),
        creationTime = Value(creationTime);
  static Insertable<SavedScript> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? source,
    Expression<DateTime>? creationTime,
    Expression<DateTime>? lastUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (source != null) 'source': source,
      if (creationTime != null) 'creation_time': creationTime,
      if (lastUsed != null) 'last_used': lastUsed,
    });
  }

  SavedScriptsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? source,
      Value<DateTime>? creationTime,
      Value<DateTime?>? lastUsed}) {
    return SavedScriptsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      source: source ?? this.source,
      creationTime: creationTime ?? this.creationTime,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (creationTime.present) {
      map['creation_time'] = Variable<DateTime>(creationTime.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedScriptsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('source: $source, ')
          ..write('creationTime: $creationTime, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $DumpedRecordsTable dumpedRecords = $DumpedRecordsTable(this);
  late final $SavedScriptsTable savedScripts = $SavedScriptsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [dumpedRecords, savedScripts];
}

typedef $$DumpedRecordsTableCreateCompanionBuilder = DumpedRecordsCompanion
    Function({
  Value<int> id,
  required DateTime time,
  Value<String> config,
  required String data,
});
typedef $$DumpedRecordsTableUpdateCompanionBuilder = DumpedRecordsCompanion
    Function({
  Value<int> id,
  Value<DateTime> time,
  Value<String> config,
  Value<String> data,
});

class $$DumpedRecordsTableFilterComposer
    extends Composer<_$Database, $DumpedRecordsTable> {
  $$DumpedRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));
}

class $$DumpedRecordsTableOrderingComposer
    extends Composer<_$Database, $DumpedRecordsTable> {
  $$DumpedRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get time => $composableBuilder(
      column: $table.time, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get config => $composableBuilder(
      column: $table.config, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));
}

class $$DumpedRecordsTableAnnotationComposer
    extends Composer<_$Database, $DumpedRecordsTable> {
  $$DumpedRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$DumpedRecordsTableTableManager extends RootTableManager<
    _$Database,
    $DumpedRecordsTable,
    DumpedRecord,
    $$DumpedRecordsTableFilterComposer,
    $$DumpedRecordsTableOrderingComposer,
    $$DumpedRecordsTableAnnotationComposer,
    $$DumpedRecordsTableCreateCompanionBuilder,
    $$DumpedRecordsTableUpdateCompanionBuilder,
    (
      DumpedRecord,
      BaseReferences<_$Database, $DumpedRecordsTable, DumpedRecord>
    ),
    DumpedRecord,
    PrefetchHooks Function()> {
  $$DumpedRecordsTableTableManager(_$Database db, $DumpedRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DumpedRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DumpedRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DumpedRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> time = const Value.absent(),
            Value<String> config = const Value.absent(),
            Value<String> data = const Value.absent(),
          }) =>
              DumpedRecordsCompanion(
            id: id,
            time: time,
            config: config,
            data: data,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime time,
            Value<String> config = const Value.absent(),
            required String data,
          }) =>
              DumpedRecordsCompanion.insert(
            id: id,
            time: time,
            config: config,
            data: data,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DumpedRecordsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $DumpedRecordsTable,
    DumpedRecord,
    $$DumpedRecordsTableFilterComposer,
    $$DumpedRecordsTableOrderingComposer,
    $$DumpedRecordsTableAnnotationComposer,
    $$DumpedRecordsTableCreateCompanionBuilder,
    $$DumpedRecordsTableUpdateCompanionBuilder,
    (
      DumpedRecord,
      BaseReferences<_$Database, $DumpedRecordsTable, DumpedRecord>
    ),
    DumpedRecord,
    PrefetchHooks Function()>;
typedef $$SavedScriptsTableCreateCompanionBuilder = SavedScriptsCompanion
    Function({
  Value<int> id,
  required String name,
  required String source,
  required DateTime creationTime,
  Value<DateTime?> lastUsed,
});
typedef $$SavedScriptsTableUpdateCompanionBuilder = SavedScriptsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> source,
  Value<DateTime> creationTime,
  Value<DateTime?> lastUsed,
});

class $$SavedScriptsTableFilterComposer
    extends Composer<_$Database, $SavedScriptsTable> {
  $$SavedScriptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get creationTime => $composableBuilder(
      column: $table.creationTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));
}

class $$SavedScriptsTableOrderingComposer
    extends Composer<_$Database, $SavedScriptsTable> {
  $$SavedScriptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get creationTime => $composableBuilder(
      column: $table.creationTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));
}

class $$SavedScriptsTableAnnotationComposer
    extends Composer<_$Database, $SavedScriptsTable> {
  $$SavedScriptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get creationTime => $composableBuilder(
      column: $table.creationTime, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);
}

class $$SavedScriptsTableTableManager extends RootTableManager<
    _$Database,
    $SavedScriptsTable,
    SavedScript,
    $$SavedScriptsTableFilterComposer,
    $$SavedScriptsTableOrderingComposer,
    $$SavedScriptsTableAnnotationComposer,
    $$SavedScriptsTableCreateCompanionBuilder,
    $$SavedScriptsTableUpdateCompanionBuilder,
    (SavedScript, BaseReferences<_$Database, $SavedScriptsTable, SavedScript>),
    SavedScript,
    PrefetchHooks Function()> {
  $$SavedScriptsTableTableManager(_$Database db, $SavedScriptsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedScriptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedScriptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedScriptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> creationTime = const Value.absent(),
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              SavedScriptsCompanion(
            id: id,
            name: name,
            source: source,
            creationTime: creationTime,
            lastUsed: lastUsed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String source,
            required DateTime creationTime,
            Value<DateTime?> lastUsed = const Value.absent(),
          }) =>
              SavedScriptsCompanion.insert(
            id: id,
            name: name,
            source: source,
            creationTime: creationTime,
            lastUsed: lastUsed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SavedScriptsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $SavedScriptsTable,
    SavedScript,
    $$SavedScriptsTableFilterComposer,
    $$SavedScriptsTableOrderingComposer,
    $$SavedScriptsTableAnnotationComposer,
    $$SavedScriptsTableCreateCompanionBuilder,
    $$SavedScriptsTableUpdateCompanionBuilder,
    (SavedScript, BaseReferences<_$Database, $SavedScriptsTable, SavedScript>),
    SavedScript,
    PrefetchHooks Function()>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$DumpedRecordsTableTableManager get dumpedRecords =>
      $$DumpedRecordsTableTableManager(_db, _db.dumpedRecords);
  $$SavedScriptsTableTableManager get savedScripts =>
      $$SavedScriptsTableTableManager(_db, _db.savedScripts);
}
