// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
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
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _premiumStatusMeta = const VerificationMeta(
    'premiumStatus',
  );
  @override
  late final GeneratedColumn<bool> premiumStatus = GeneratedColumn<bool>(
    'premium_status',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("premium_status" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _acceptedAllStatementTermsMeta =
      const VerificationMeta('acceptedAllStatementTerms');
  @override
  late final GeneratedColumn<bool> acceptedAllStatementTerms =
      GeneratedColumn<bool>(
        'accepted_all_statement_terms',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("accepted_all_statement_terms" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _openBankingConnectedMeta =
      const VerificationMeta('openBankingConnected');
  @override
  late final GeneratedColumn<bool> openBankingConnected = GeneratedColumn<bool>(
    'open_banking_connected',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("open_banking_connected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _subscriptionStatusMeta =
      const VerificationMeta('subscriptionStatus');
  @override
  late final GeneratedColumn<String> subscriptionStatus =
      GeneratedColumn<String>(
        'subscription_status',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tcknMeta = const VerificationMeta('tckn');
  @override
  late final GeneratedColumn<String> tckn = GeneratedColumn<String>(
    'tckn',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneNumberMeta = const VerificationMeta(
    'phoneNumber',
  );
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
    'phone_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    email,
    createdAt,
    premiumStatus,
    acceptedAllStatementTerms,
    openBankingConnected,
    subscriptionStatus,
    fullName,
    tckn,
    phoneNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('premium_status')) {
      context.handle(
        _premiumStatusMeta,
        premiumStatus.isAcceptableOrUnknown(
          data['premium_status']!,
          _premiumStatusMeta,
        ),
      );
    }
    if (data.containsKey('accepted_all_statement_terms')) {
      context.handle(
        _acceptedAllStatementTermsMeta,
        acceptedAllStatementTerms.isAcceptableOrUnknown(
          data['accepted_all_statement_terms']!,
          _acceptedAllStatementTermsMeta,
        ),
      );
    }
    if (data.containsKey('open_banking_connected')) {
      context.handle(
        _openBankingConnectedMeta,
        openBankingConnected.isAcceptableOrUnknown(
          data['open_banking_connected']!,
          _openBankingConnectedMeta,
        ),
      );
    }
    if (data.containsKey('subscription_status')) {
      context.handle(
        _subscriptionStatusMeta,
        subscriptionStatus.isAcceptableOrUnknown(
          data['subscription_status']!,
          _subscriptionStatusMeta,
        ),
      );
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('tckn')) {
      context.handle(
        _tcknMeta,
        tckn.isAcceptableOrUnknown(data['tckn']!, _tcknMeta),
      );
    }
    if (data.containsKey('phone_number')) {
      context.handle(
        _phoneNumberMeta,
        phoneNumber.isAcceptableOrUnknown(
          data['phone_number']!,
          _phoneNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      premiumStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}premium_status'],
      ),
      acceptedAllStatementTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}accepted_all_statement_terms'],
      ),
      openBankingConnected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}open_banking_connected'],
      ),
      subscriptionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscription_status'],
      ),
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      tckn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tckn'],
      ),
      phoneNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_number'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String userId;
  final String? email;
  final DateTime? createdAt;
  final bool? premiumStatus;
  final bool? acceptedAllStatementTerms;
  final bool? openBankingConnected;
  final String? subscriptionStatus;
  final String? fullName;
  final String? tckn;
  final String? phoneNumber;
  const Profile({
    required this.userId,
    this.email,
    this.createdAt,
    this.premiumStatus,
    this.acceptedAllStatementTerms,
    this.openBankingConnected,
    this.subscriptionStatus,
    this.fullName,
    this.tckn,
    this.phoneNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(userId);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || premiumStatus != null) {
      map['premium_status'] = Variable<bool>(premiumStatus);
    }
    if (!nullToAbsent || acceptedAllStatementTerms != null) {
      map['accepted_all_statement_terms'] = Variable<bool>(
        acceptedAllStatementTerms,
      );
    }
    if (!nullToAbsent || openBankingConnected != null) {
      map['open_banking_connected'] = Variable<bool>(openBankingConnected);
    }
    if (!nullToAbsent || subscriptionStatus != null) {
      map['subscription_status'] = Variable<String>(subscriptionStatus);
    }
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    if (!nullToAbsent || tckn != null) {
      map['tckn'] = Variable<String>(tckn);
    }
    if (!nullToAbsent || phoneNumber != null) {
      map['phone_number'] = Variable<String>(phoneNumber);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      userId: Value(userId),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      premiumStatus: premiumStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(premiumStatus),
      acceptedAllStatementTerms:
          acceptedAllStatementTerms == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAllStatementTerms),
      openBankingConnected: openBankingConnected == null && nullToAbsent
          ? const Value.absent()
          : Value(openBankingConnected),
      subscriptionStatus: subscriptionStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(subscriptionStatus),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      tckn: tckn == null && nullToAbsent ? const Value.absent() : Value(tckn),
      phoneNumber: phoneNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneNumber),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      userId: serializer.fromJson<String>(json['userId']),
      email: serializer.fromJson<String?>(json['email']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      premiumStatus: serializer.fromJson<bool?>(json['premiumStatus']),
      acceptedAllStatementTerms: serializer.fromJson<bool?>(
        json['acceptedAllStatementTerms'],
      ),
      openBankingConnected: serializer.fromJson<bool?>(
        json['openBankingConnected'],
      ),
      subscriptionStatus: serializer.fromJson<String?>(
        json['subscriptionStatus'],
      ),
      fullName: serializer.fromJson<String?>(json['fullName']),
      tckn: serializer.fromJson<String?>(json['tckn']),
      phoneNumber: serializer.fromJson<String?>(json['phoneNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'email': serializer.toJson<String?>(email),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'premiumStatus': serializer.toJson<bool?>(premiumStatus),
      'acceptedAllStatementTerms': serializer.toJson<bool?>(
        acceptedAllStatementTerms,
      ),
      'openBankingConnected': serializer.toJson<bool?>(openBankingConnected),
      'subscriptionStatus': serializer.toJson<String?>(subscriptionStatus),
      'fullName': serializer.toJson<String?>(fullName),
      'tckn': serializer.toJson<String?>(tckn),
      'phoneNumber': serializer.toJson<String?>(phoneNumber),
    };
  }

  Profile copyWith({
    String? userId,
    Value<String?> email = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<bool?> premiumStatus = const Value.absent(),
    Value<bool?> acceptedAllStatementTerms = const Value.absent(),
    Value<bool?> openBankingConnected = const Value.absent(),
    Value<String?> subscriptionStatus = const Value.absent(),
    Value<String?> fullName = const Value.absent(),
    Value<String?> tckn = const Value.absent(),
    Value<String?> phoneNumber = const Value.absent(),
  }) => Profile(
    userId: userId ?? this.userId,
    email: email.present ? email.value : this.email,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    premiumStatus: premiumStatus.present
        ? premiumStatus.value
        : this.premiumStatus,
    acceptedAllStatementTerms: acceptedAllStatementTerms.present
        ? acceptedAllStatementTerms.value
        : this.acceptedAllStatementTerms,
    openBankingConnected: openBankingConnected.present
        ? openBankingConnected.value
        : this.openBankingConnected,
    subscriptionStatus: subscriptionStatus.present
        ? subscriptionStatus.value
        : this.subscriptionStatus,
    fullName: fullName.present ? fullName.value : this.fullName,
    tckn: tckn.present ? tckn.value : this.tckn,
    phoneNumber: phoneNumber.present ? phoneNumber.value : this.phoneNumber,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      userId: data.userId.present ? data.userId.value : this.userId,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      premiumStatus: data.premiumStatus.present
          ? data.premiumStatus.value
          : this.premiumStatus,
      acceptedAllStatementTerms: data.acceptedAllStatementTerms.present
          ? data.acceptedAllStatementTerms.value
          : this.acceptedAllStatementTerms,
      openBankingConnected: data.openBankingConnected.present
          ? data.openBankingConnected.value
          : this.openBankingConnected,
      subscriptionStatus: data.subscriptionStatus.present
          ? data.subscriptionStatus.value
          : this.subscriptionStatus,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      tckn: data.tckn.present ? data.tckn.value : this.tckn,
      phoneNumber: data.phoneNumber.present
          ? data.phoneNumber.value
          : this.phoneNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('premiumStatus: $premiumStatus, ')
          ..write('acceptedAllStatementTerms: $acceptedAllStatementTerms, ')
          ..write('openBankingConnected: $openBankingConnected, ')
          ..write('subscriptionStatus: $subscriptionStatus, ')
          ..write('fullName: $fullName, ')
          ..write('tckn: $tckn, ')
          ..write('phoneNumber: $phoneNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    email,
    createdAt,
    premiumStatus,
    acceptedAllStatementTerms,
    openBankingConnected,
    subscriptionStatus,
    fullName,
    tckn,
    phoneNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.userId == this.userId &&
          other.email == this.email &&
          other.createdAt == this.createdAt &&
          other.premiumStatus == this.premiumStatus &&
          other.acceptedAllStatementTerms == this.acceptedAllStatementTerms &&
          other.openBankingConnected == this.openBankingConnected &&
          other.subscriptionStatus == this.subscriptionStatus &&
          other.fullName == this.fullName &&
          other.tckn == this.tckn &&
          other.phoneNumber == this.phoneNumber);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> userId;
  final Value<String?> email;
  final Value<DateTime?> createdAt;
  final Value<bool?> premiumStatus;
  final Value<bool?> acceptedAllStatementTerms;
  final Value<bool?> openBankingConnected;
  final Value<String?> subscriptionStatus;
  final Value<String?> fullName;
  final Value<String?> tckn;
  final Value<String?> phoneNumber;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.userId = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.premiumStatus = const Value.absent(),
    this.acceptedAllStatementTerms = const Value.absent(),
    this.openBankingConnected = const Value.absent(),
    this.subscriptionStatus = const Value.absent(),
    this.fullName = const Value.absent(),
    this.tckn = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String userId,
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.premiumStatus = const Value.absent(),
    this.acceptedAllStatementTerms = const Value.absent(),
    this.openBankingConnected = const Value.absent(),
    this.subscriptionStatus = const Value.absent(),
    this.fullName = const Value.absent(),
    this.tckn = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<Profile> custom({
    Expression<String>? userId,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
    Expression<bool>? premiumStatus,
    Expression<bool>? acceptedAllStatementTerms,
    Expression<bool>? openBankingConnected,
    Expression<String>? subscriptionStatus,
    Expression<String>? fullName,
    Expression<String>? tckn,
    Expression<String>? phoneNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'id': userId,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
      if (premiumStatus != null) 'premium_status': premiumStatus,
      if (acceptedAllStatementTerms != null)
        'accepted_all_statement_terms': acceptedAllStatementTerms,
      if (openBankingConnected != null)
        'open_banking_connected': openBankingConnected,
      if (subscriptionStatus != null) 'subscription_status': subscriptionStatus,
      if (fullName != null) 'full_name': fullName,
      if (tckn != null) 'tckn': tckn,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String?>? email,
    Value<DateTime?>? createdAt,
    Value<bool?>? premiumStatus,
    Value<bool?>? acceptedAllStatementTerms,
    Value<bool?>? openBankingConnected,
    Value<String?>? subscriptionStatus,
    Value<String?>? fullName,
    Value<String?>? tckn,
    Value<String?>? phoneNumber,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      acceptedAllStatementTerms:
          acceptedAllStatementTerms ?? this.acceptedAllStatementTerms,
      openBankingConnected: openBankingConnected ?? this.openBankingConnected,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      fullName: fullName ?? this.fullName,
      tckn: tckn ?? this.tckn,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['id'] = Variable<String>(userId.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (premiumStatus.present) {
      map['premium_status'] = Variable<bool>(premiumStatus.value);
    }
    if (acceptedAllStatementTerms.present) {
      map['accepted_all_statement_terms'] = Variable<bool>(
        acceptedAllStatementTerms.value,
      );
    }
    if (openBankingConnected.present) {
      map['open_banking_connected'] = Variable<bool>(
        openBankingConnected.value,
      );
    }
    if (subscriptionStatus.present) {
      map['subscription_status'] = Variable<String>(subscriptionStatus.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (tckn.present) {
      map['tckn'] = Variable<String>(tckn.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('premiumStatus: $premiumStatus, ')
          ..write('acceptedAllStatementTerms: $acceptedAllStatementTerms, ')
          ..write('openBankingConnected: $openBankingConnected, ')
          ..write('subscriptionStatus: $subscriptionStatus, ')
          ..write('fullName: $fullName, ')
          ..write('tckn: $tckn, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plateMeta = const VerificationMeta('plate');
  @override
  late final GeneratedColumn<String> plate = GeneratedColumn<String>(
    'plate',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 15,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialOdometerMeta = const VerificationMeta(
    'initialOdometer',
  );
  @override
  late final GeneratedColumn<int> initialOdometer = GeneratedColumn<int>(
    'initial_odometer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (initial_odometer >= 0)',
  );
  static const VerificationMeta _currentOdometerMeta = const VerificationMeta(
    'currentOdometer',
  );
  @override
  late final GeneratedColumn<int> currentOdometer = GeneratedColumn<int>(
    'current_odometer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (current_odometer >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    vehicleId,
    userId,
    plate,
    brand,
    model,
    fuelType,
    initialOdometer,
    currentOdometer,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('plate')) {
      context.handle(
        _plateMeta,
        plate.isAcceptableOrUnknown(data['plate']!, _plateMeta),
      );
    } else if (isInserting) {
      context.missing(_plateMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelTypeMeta);
    }
    if (data.containsKey('initial_odometer')) {
      context.handle(
        _initialOdometerMeta,
        initialOdometer.isAcceptableOrUnknown(
          data['initial_odometer']!,
          _initialOdometerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialOdometerMeta);
    }
    if (data.containsKey('current_odometer')) {
      context.handle(
        _currentOdometerMeta,
        currentOdometer.isAcceptableOrUnknown(
          data['current_odometer']!,
          _currentOdometerMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentOdometerMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {vehicleId};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      plate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plate'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      initialOdometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_odometer'],
      )!,
      currentOdometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_odometer'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final String vehicleId;
  final String userId;
  final String plate;
  final String brand;
  final String model;
  final String fuelType;
  final int initialOdometer;
  final int currentOdometer;
  const Vehicle({
    required this.vehicleId,
    required this.userId,
    required this.plate,
    required this.brand,
    required this.model,
    required this.fuelType,
    required this.initialOdometer,
    required this.currentOdometer,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(vehicleId);
    map['user_id'] = Variable<String>(userId);
    map['plate'] = Variable<String>(plate);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    map['fuel_type'] = Variable<String>(fuelType);
    map['initial_odometer'] = Variable<int>(initialOdometer);
    map['current_odometer'] = Variable<int>(currentOdometer);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      vehicleId: Value(vehicleId),
      userId: Value(userId),
      plate: Value(plate),
      brand: Value(brand),
      model: Value(model),
      fuelType: Value(fuelType),
      initialOdometer: Value(initialOdometer),
      currentOdometer: Value(currentOdometer),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      userId: serializer.fromJson<String>(json['userId']),
      plate: serializer.fromJson<String>(json['plate']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      initialOdometer: serializer.fromJson<int>(json['initialOdometer']),
      currentOdometer: serializer.fromJson<int>(json['currentOdometer']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vehicleId': serializer.toJson<String>(vehicleId),
      'userId': serializer.toJson<String>(userId),
      'plate': serializer.toJson<String>(plate),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'fuelType': serializer.toJson<String>(fuelType),
      'initialOdometer': serializer.toJson<int>(initialOdometer),
      'currentOdometer': serializer.toJson<int>(currentOdometer),
    };
  }

  Vehicle copyWith({
    String? vehicleId,
    String? userId,
    String? plate,
    String? brand,
    String? model,
    String? fuelType,
    int? initialOdometer,
    int? currentOdometer,
  }) => Vehicle(
    vehicleId: vehicleId ?? this.vehicleId,
    userId: userId ?? this.userId,
    plate: plate ?? this.plate,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    fuelType: fuelType ?? this.fuelType,
    initialOdometer: initialOdometer ?? this.initialOdometer,
    currentOdometer: currentOdometer ?? this.currentOdometer,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      userId: data.userId.present ? data.userId.value : this.userId,
      plate: data.plate.present ? data.plate.value : this.plate,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      initialOdometer: data.initialOdometer.present
          ? data.initialOdometer.value
          : this.initialOdometer,
      currentOdometer: data.currentOdometer.present
          ? data.currentOdometer.value
          : this.currentOdometer,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('vehicleId: $vehicleId, ')
          ..write('userId: $userId, ')
          ..write('plate: $plate, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('fuelType: $fuelType, ')
          ..write('initialOdometer: $initialOdometer, ')
          ..write('currentOdometer: $currentOdometer')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vehicleId,
    userId,
    plate,
    brand,
    model,
    fuelType,
    initialOdometer,
    currentOdometer,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.vehicleId == this.vehicleId &&
          other.userId == this.userId &&
          other.plate == this.plate &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.fuelType == this.fuelType &&
          other.initialOdometer == this.initialOdometer &&
          other.currentOdometer == this.currentOdometer);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<String> vehicleId;
  final Value<String> userId;
  final Value<String> plate;
  final Value<String> brand;
  final Value<String> model;
  final Value<String> fuelType;
  final Value<int> initialOdometer;
  final Value<int> currentOdometer;
  final Value<int> rowid;
  const VehiclesCompanion({
    this.vehicleId = const Value.absent(),
    this.userId = const Value.absent(),
    this.plate = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.initialOdometer = const Value.absent(),
    this.currentOdometer = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VehiclesCompanion.insert({
    required String vehicleId,
    required String userId,
    required String plate,
    required String brand,
    required String model,
    required String fuelType,
    required int initialOdometer,
    required int currentOdometer,
    this.rowid = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       userId = Value(userId),
       plate = Value(plate),
       brand = Value(brand),
       model = Value(model),
       fuelType = Value(fuelType),
       initialOdometer = Value(initialOdometer),
       currentOdometer = Value(currentOdometer);
  static Insertable<Vehicle> custom({
    Expression<String>? vehicleId,
    Expression<String>? userId,
    Expression<String>? plate,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? fuelType,
    Expression<int>? initialOdometer,
    Expression<int>? currentOdometer,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vehicleId != null) 'id': vehicleId,
      if (userId != null) 'user_id': userId,
      if (plate != null) 'plate': plate,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (fuelType != null) 'fuel_type': fuelType,
      if (initialOdometer != null) 'initial_odometer': initialOdometer,
      if (currentOdometer != null) 'current_odometer': currentOdometer,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VehiclesCompanion copyWith({
    Value<String>? vehicleId,
    Value<String>? userId,
    Value<String>? plate,
    Value<String>? brand,
    Value<String>? model,
    Value<String>? fuelType,
    Value<int>? initialOdometer,
    Value<int>? currentOdometer,
    Value<int>? rowid,
  }) {
    return VehiclesCompanion(
      vehicleId: vehicleId ?? this.vehicleId,
      userId: userId ?? this.userId,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      fuelType: fuelType ?? this.fuelType,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vehicleId.present) {
      map['id'] = Variable<String>(vehicleId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (plate.present) {
      map['plate'] = Variable<String>(plate.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (initialOdometer.present) {
      map['initial_odometer'] = Variable<int>(initialOdometer.value);
    }
    if (currentOdometer.present) {
      map['current_odometer'] = Variable<int>(currentOdometer.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('vehicleId: $vehicleId, ')
          ..write('userId: $userId, ')
          ..write('plate: $plate, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('fuelType: $fuelType, ')
          ..write('initialOdometer: $initialOdometer, ')
          ..write('currentOdometer: $currentOdometer, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StationsTable extends Stations with TableInfo<$StationsTable, Station> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _districtMeta = const VerificationMeta(
    'district',
  );
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
    'district',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    stationId,
    brandName,
    latitude,
    longitude,
    city,
    district,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Station> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['id']!, _stationIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stationIdMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    } else if (isInserting) {
      context.missing(_brandNameMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('district')) {
      context.handle(
        _districtMeta,
        district.isAcceptableOrUnknown(data['district']!, _districtMeta),
      );
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stationId};
  @override
  Station map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Station(
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      district: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}district'],
      )!,
    );
  }

  @override
  $StationsTable createAlias(String alias) {
    return $StationsTable(attachedDatabase, alias);
  }
}

class Station extends DataClass implements Insertable<Station> {
  final String stationId;
  final String brandName;
  final double latitude;
  final double longitude;
  final String city;
  final String district;
  const Station({
    required this.stationId,
    required this.brandName,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.district,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(stationId);
    map['brand_name'] = Variable<String>(brandName);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['city'] = Variable<String>(city);
    map['district'] = Variable<String>(district);
    return map;
  }

  StationsCompanion toCompanion(bool nullToAbsent) {
    return StationsCompanion(
      stationId: Value(stationId),
      brandName: Value(brandName),
      latitude: Value(latitude),
      longitude: Value(longitude),
      city: Value(city),
      district: Value(district),
    );
  }

  factory Station.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Station(
      stationId: serializer.fromJson<String>(json['stationId']),
      brandName: serializer.fromJson<String>(json['brandName']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      city: serializer.fromJson<String>(json['city']),
      district: serializer.fromJson<String>(json['district']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stationId': serializer.toJson<String>(stationId),
      'brandName': serializer.toJson<String>(brandName),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'city': serializer.toJson<String>(city),
      'district': serializer.toJson<String>(district),
    };
  }

  Station copyWith({
    String? stationId,
    String? brandName,
    double? latitude,
    double? longitude,
    String? city,
    String? district,
  }) => Station(
    stationId: stationId ?? this.stationId,
    brandName: brandName ?? this.brandName,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    city: city ?? this.city,
    district: district ?? this.district,
  );
  Station copyWithCompanion(StationsCompanion data) {
    return Station(
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      city: data.city.present ? data.city.value : this.city,
      district: data.district.present ? data.district.value : this.district,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Station(')
          ..write('stationId: $stationId, ')
          ..write('brandName: $brandName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('district: $district')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(stationId, brandName, latitude, longitude, city, district);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Station &&
          other.stationId == this.stationId &&
          other.brandName == this.brandName &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.city == this.city &&
          other.district == this.district);
}

class StationsCompanion extends UpdateCompanion<Station> {
  final Value<String> stationId;
  final Value<String> brandName;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> city;
  final Value<String> district;
  final Value<int> rowid;
  const StationsCompanion({
    this.stationId = const Value.absent(),
    this.brandName = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.city = const Value.absent(),
    this.district = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StationsCompanion.insert({
    required String stationId,
    required String brandName,
    required double latitude,
    required double longitude,
    required String city,
    required String district,
    this.rowid = const Value.absent(),
  }) : stationId = Value(stationId),
       brandName = Value(brandName),
       latitude = Value(latitude),
       longitude = Value(longitude),
       city = Value(city),
       district = Value(district);
  static Insertable<Station> custom({
    Expression<String>? stationId,
    Expression<String>? brandName,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? city,
    Expression<String>? district,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (stationId != null) 'id': stationId,
      if (brandName != null) 'brand_name': brandName,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (city != null) 'city': city,
      if (district != null) 'district': district,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StationsCompanion copyWith({
    Value<String>? stationId,
    Value<String>? brandName,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? city,
    Value<String>? district,
    Value<int>? rowid,
  }) {
    return StationsCompanion(
      stationId: stationId ?? this.stationId,
      brandName: brandName ?? this.brandName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      district: district ?? this.district,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stationId.present) {
      map['id'] = Variable<String>(stationId.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StationsCompanion(')
          ..write('stationId: $stationId, ')
          ..write('brandName: $brandName, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('city: $city, ')
          ..write('district: $district, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefuelingsTable extends Refuelings
    with TableInfo<$RefuelingsTable, Refueling> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefuelingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _refuelingIdMeta = const VerificationMeta(
    'refuelingId',
  );
  @override
  late final GeneratedColumn<String> refuelingId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<String> stationId = GeneratedColumn<String>(
    'station_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _litersMeta = const VerificationMeta('liters');
  @override
  late final GeneratedColumn<double> liters = GeneratedColumn<double>(
    'liters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (liters > 0)',
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (unit_price > 0)',
  );
  static const VerificationMeta _totalPriceMeta = const VerificationMeta(
    'totalPrice',
  );
  @override
  late final GeneratedColumn<double> totalPrice = GeneratedColumn<double>(
    'total_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (total_price > 0)',
  );
  static const VerificationMeta _odometerMeta = const VerificationMeta(
    'odometer',
  );
  @override
  late final GeneratedColumn<int> odometer = GeneratedColumn<int>(
    'odometer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (odometer >= 0)',
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isFullTankMeta = const VerificationMeta(
    'isFullTank',
  );
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
    'is_full_tank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full_tank" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    refuelingId,
    vehicleId,
    stationId,
    liters,
    unitPrice,
    totalPrice,
    odometer,
    purchaseDate,
    isFullTank,
    imagePath,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refuelings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Refueling> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _refuelingIdMeta,
        refuelingId.isAcceptableOrUnknown(data['id']!, _refuelingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_refuelingIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    }
    if (data.containsKey('liters')) {
      context.handle(
        _litersMeta,
        liters.isAcceptableOrUnknown(data['liters']!, _litersMeta),
      );
    } else if (isInserting) {
      context.missing(_litersMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('total_price')) {
      context.handle(
        _totalPriceMeta,
        totalPrice.isAcceptableOrUnknown(data['total_price']!, _totalPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_totalPriceMeta);
    }
    if (data.containsKey('odometer')) {
      context.handle(
        _odometerMeta,
        odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
        _isFullTankMeta,
        isFullTank.isAcceptableOrUnknown(
          data['is_full_tank']!,
          _isFullTankMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {refuelingId};
  @override
  Refueling map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Refueling(
      refuelingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_id'],
      ),
      liters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liters'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      totalPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_price'],
      )!,
      odometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      isFullTank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full_tank'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
    );
  }

  @override
  $RefuelingsTable createAlias(String alias) {
    return $RefuelingsTable(attachedDatabase, alias);
  }
}

class Refueling extends DataClass implements Insertable<Refueling> {
  final String refuelingId;
  final String vehicleId;
  final String? stationId;
  final double liters;
  final double unitPrice;
  final double totalPrice;
  final int odometer;
  final DateTime purchaseDate;
  final bool isFullTank;
  final String? imagePath;
  const Refueling({
    required this.refuelingId,
    required this.vehicleId,
    this.stationId,
    required this.liters,
    required this.unitPrice,
    required this.totalPrice,
    required this.odometer,
    required this.purchaseDate,
    required this.isFullTank,
    this.imagePath,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(refuelingId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    if (!nullToAbsent || stationId != null) {
      map['station_id'] = Variable<String>(stationId);
    }
    map['liters'] = Variable<double>(liters);
    map['unit_price'] = Variable<double>(unitPrice);
    map['total_price'] = Variable<double>(totalPrice);
    map['odometer'] = Variable<int>(odometer);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['is_full_tank'] = Variable<bool>(isFullTank);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    return map;
  }

  RefuelingsCompanion toCompanion(bool nullToAbsent) {
    return RefuelingsCompanion(
      refuelingId: Value(refuelingId),
      vehicleId: Value(vehicleId),
      stationId: stationId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationId),
      liters: Value(liters),
      unitPrice: Value(unitPrice),
      totalPrice: Value(totalPrice),
      odometer: Value(odometer),
      purchaseDate: Value(purchaseDate),
      isFullTank: Value(isFullTank),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
    );
  }

  factory Refueling.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Refueling(
      refuelingId: serializer.fromJson<String>(json['refuelingId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      stationId: serializer.fromJson<String?>(json['stationId']),
      liters: serializer.fromJson<double>(json['liters']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      totalPrice: serializer.fromJson<double>(json['totalPrice']),
      odometer: serializer.fromJson<int>(json['odometer']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'refuelingId': serializer.toJson<String>(refuelingId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'stationId': serializer.toJson<String?>(stationId),
      'liters': serializer.toJson<double>(liters),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'totalPrice': serializer.toJson<double>(totalPrice),
      'odometer': serializer.toJson<int>(odometer),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'isFullTank': serializer.toJson<bool>(isFullTank),
      'imagePath': serializer.toJson<String?>(imagePath),
    };
  }

  Refueling copyWith({
    String? refuelingId,
    String? vehicleId,
    Value<String?> stationId = const Value.absent(),
    double? liters,
    double? unitPrice,
    double? totalPrice,
    int? odometer,
    DateTime? purchaseDate,
    bool? isFullTank,
    Value<String?> imagePath = const Value.absent(),
  }) => Refueling(
    refuelingId: refuelingId ?? this.refuelingId,
    vehicleId: vehicleId ?? this.vehicleId,
    stationId: stationId.present ? stationId.value : this.stationId,
    liters: liters ?? this.liters,
    unitPrice: unitPrice ?? this.unitPrice,
    totalPrice: totalPrice ?? this.totalPrice,
    odometer: odometer ?? this.odometer,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    isFullTank: isFullTank ?? this.isFullTank,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
  );
  Refueling copyWithCompanion(RefuelingsCompanion data) {
    return Refueling(
      refuelingId: data.refuelingId.present
          ? data.refuelingId.value
          : this.refuelingId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      liters: data.liters.present ? data.liters.value : this.liters,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      totalPrice: data.totalPrice.present
          ? data.totalPrice.value
          : this.totalPrice,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      isFullTank: data.isFullTank.present
          ? data.isFullTank.value
          : this.isFullTank,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Refueling(')
          ..write('refuelingId: $refuelingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('stationId: $stationId, ')
          ..write('liters: $liters, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('odometer: $odometer, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('imagePath: $imagePath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    refuelingId,
    vehicleId,
    stationId,
    liters,
    unitPrice,
    totalPrice,
    odometer,
    purchaseDate,
    isFullTank,
    imagePath,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Refueling &&
          other.refuelingId == this.refuelingId &&
          other.vehicleId == this.vehicleId &&
          other.stationId == this.stationId &&
          other.liters == this.liters &&
          other.unitPrice == this.unitPrice &&
          other.totalPrice == this.totalPrice &&
          other.odometer == this.odometer &&
          other.purchaseDate == this.purchaseDate &&
          other.isFullTank == this.isFullTank &&
          other.imagePath == this.imagePath);
}

class RefuelingsCompanion extends UpdateCompanion<Refueling> {
  final Value<String> refuelingId;
  final Value<String> vehicleId;
  final Value<String?> stationId;
  final Value<double> liters;
  final Value<double> unitPrice;
  final Value<double> totalPrice;
  final Value<int> odometer;
  final Value<DateTime> purchaseDate;
  final Value<bool> isFullTank;
  final Value<String?> imagePath;
  final Value<int> rowid;
  const RefuelingsCompanion({
    this.refuelingId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.stationId = const Value.absent(),
    this.liters = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.totalPrice = const Value.absent(),
    this.odometer = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefuelingsCompanion.insert({
    required String refuelingId,
    required String vehicleId,
    this.stationId = const Value.absent(),
    required double liters,
    required double unitPrice,
    required double totalPrice,
    required int odometer,
    this.purchaseDate = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : refuelingId = Value(refuelingId),
       vehicleId = Value(vehicleId),
       liters = Value(liters),
       unitPrice = Value(unitPrice),
       totalPrice = Value(totalPrice),
       odometer = Value(odometer);
  static Insertable<Refueling> custom({
    Expression<String>? refuelingId,
    Expression<String>? vehicleId,
    Expression<String>? stationId,
    Expression<double>? liters,
    Expression<double>? unitPrice,
    Expression<double>? totalPrice,
    Expression<int>? odometer,
    Expression<DateTime>? purchaseDate,
    Expression<bool>? isFullTank,
    Expression<String>? imagePath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (refuelingId != null) 'id': refuelingId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (stationId != null) 'station_id': stationId,
      if (liters != null) 'liters': liters,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (totalPrice != null) 'total_price': totalPrice,
      if (odometer != null) 'odometer': odometer,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (imagePath != null) 'image_path': imagePath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefuelingsCompanion copyWith({
    Value<String>? refuelingId,
    Value<String>? vehicleId,
    Value<String?>? stationId,
    Value<double>? liters,
    Value<double>? unitPrice,
    Value<double>? totalPrice,
    Value<int>? odometer,
    Value<DateTime>? purchaseDate,
    Value<bool>? isFullTank,
    Value<String?>? imagePath,
    Value<int>? rowid,
  }) {
    return RefuelingsCompanion(
      refuelingId: refuelingId ?? this.refuelingId,
      vehicleId: vehicleId ?? this.vehicleId,
      stationId: stationId ?? this.stationId,
      liters: liters ?? this.liters,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      odometer: odometer ?? this.odometer,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      isFullTank: isFullTank ?? this.isFullTank,
      imagePath: imagePath ?? this.imagePath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (refuelingId.present) {
      map['id'] = Variable<String>(refuelingId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (stationId.present) {
      map['station_id'] = Variable<String>(stationId.value);
    }
    if (liters.present) {
      map['liters'] = Variable<double>(liters.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (totalPrice.present) {
      map['total_price'] = Variable<double>(totalPrice.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<int>(odometer.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefuelingsCompanion(')
          ..write('refuelingId: $refuelingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('stationId: $stationId, ')
          ..write('liters: $liters, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('totalPrice: $totalPrice, ')
          ..write('odometer: $odometer, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('imagePath: $imagePath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CardTransactionsTable extends CardTransactions
    with TableInfo<$CardTransactionsTable, CardTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refuelingIdMeta = const VerificationMeta(
    'refuelingId',
  );
  @override
  late final GeneratedColumn<String> refuelingId = GeneratedColumn<String>(
    'refueling_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount > 0)',
  );
  static const VerificationMeta _merchantNameMeta = const VerificationMeta(
    'merchantName',
  );
  @override
  late final GeneratedColumn<String> merchantName = GeneratedColumn<String>(
    'merchant_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardNumberMaskMeta = const VerificationMeta(
    'cardNumberMask',
  );
  @override
  late final GeneratedColumn<String> cardNumberMask = GeneratedColumn<String>(
    'card_number_mask',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankTransactionCodeMeta =
      const VerificationMeta('bankTransactionCode');
  @override
  late final GeneratedColumn<String> bankTransactionCode =
      GeneratedColumn<String>(
        'bank_transaction_code',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _posTerminalDetailsMeta =
      const VerificationMeta('posTerminalDetails');
  @override
  late final GeneratedColumn<String> posTerminalDetails =
      GeneratedColumn<String>(
        'pos_terminal_details',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _scheduledPaymentMeta = const VerificationMeta(
    'scheduledPayment',
  );
  @override
  late final GeneratedColumn<bool> scheduledPayment = GeneratedColumn<bool>(
    'scheduled_payment',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scheduled_payment" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    transactionId,
    userId,
    refuelingId,
    transactionDate,
    amount,
    merchantName,
    source,
    cardNumberMask,
    bankTransactionCode,
    posTerminalDetails,
    scheduledPayment,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(data['id']!, _transactionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('refueling_id')) {
      context.handle(
        _refuelingIdMeta,
        refuelingId.isAcceptableOrUnknown(
          data['refueling_id']!,
          _refuelingIdMeta,
        ),
      );
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('merchant_name')) {
      context.handle(
        _merchantNameMeta,
        merchantName.isAcceptableOrUnknown(
          data['merchant_name']!,
          _merchantNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_merchantNameMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('card_number_mask')) {
      context.handle(
        _cardNumberMaskMeta,
        cardNumberMask.isAcceptableOrUnknown(
          data['card_number_mask']!,
          _cardNumberMaskMeta,
        ),
      );
    }
    if (data.containsKey('bank_transaction_code')) {
      context.handle(
        _bankTransactionCodeMeta,
        bankTransactionCode.isAcceptableOrUnknown(
          data['bank_transaction_code']!,
          _bankTransactionCodeMeta,
        ),
      );
    }
    if (data.containsKey('pos_terminal_details')) {
      context.handle(
        _posTerminalDetailsMeta,
        posTerminalDetails.isAcceptableOrUnknown(
          data['pos_terminal_details']!,
          _posTerminalDetailsMeta,
        ),
      );
    }
    if (data.containsKey('scheduled_payment')) {
      context.handle(
        _scheduledPaymentMeta,
        scheduledPayment.isAcceptableOrUnknown(
          data['scheduled_payment']!,
          _scheduledPaymentMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {transactionId};
  @override
  CardTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTransaction(
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      refuelingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}refueling_id'],
      ),
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      merchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_name'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      cardNumberMask: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_number_mask'],
      ),
      bankTransactionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_transaction_code'],
      ),
      posTerminalDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pos_terminal_details'],
      ),
      scheduledPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scheduled_payment'],
      )!,
    );
  }

  @override
  $CardTransactionsTable createAlias(String alias) {
    return $CardTransactionsTable(attachedDatabase, alias);
  }
}

class CardTransaction extends DataClass implements Insertable<CardTransaction> {
  final String transactionId;
  final String userId;
  final String? refuelingId;
  final DateTime transactionDate;
  final double amount;
  final String merchantName;
  final String source;
  final String? cardNumberMask;
  final String? bankTransactionCode;
  final String? posTerminalDetails;
  final bool scheduledPayment;
  const CardTransaction({
    required this.transactionId,
    required this.userId,
    this.refuelingId,
    required this.transactionDate,
    required this.amount,
    required this.merchantName,
    required this.source,
    this.cardNumberMask,
    this.bankTransactionCode,
    this.posTerminalDetails,
    required this.scheduledPayment,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(transactionId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || refuelingId != null) {
      map['refueling_id'] = Variable<String>(refuelingId);
    }
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['amount'] = Variable<double>(amount);
    map['merchant_name'] = Variable<String>(merchantName);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || cardNumberMask != null) {
      map['card_number_mask'] = Variable<String>(cardNumberMask);
    }
    if (!nullToAbsent || bankTransactionCode != null) {
      map['bank_transaction_code'] = Variable<String>(bankTransactionCode);
    }
    if (!nullToAbsent || posTerminalDetails != null) {
      map['pos_terminal_details'] = Variable<String>(posTerminalDetails);
    }
    map['scheduled_payment'] = Variable<bool>(scheduledPayment);
    return map;
  }

  CardTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CardTransactionsCompanion(
      transactionId: Value(transactionId),
      userId: Value(userId),
      refuelingId: refuelingId == null && nullToAbsent
          ? const Value.absent()
          : Value(refuelingId),
      transactionDate: Value(transactionDate),
      amount: Value(amount),
      merchantName: Value(merchantName),
      source: Value(source),
      cardNumberMask: cardNumberMask == null && nullToAbsent
          ? const Value.absent()
          : Value(cardNumberMask),
      bankTransactionCode: bankTransactionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(bankTransactionCode),
      posTerminalDetails: posTerminalDetails == null && nullToAbsent
          ? const Value.absent()
          : Value(posTerminalDetails),
      scheduledPayment: Value(scheduledPayment),
    );
  }

  factory CardTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTransaction(
      transactionId: serializer.fromJson<String>(json['transactionId']),
      userId: serializer.fromJson<String>(json['userId']),
      refuelingId: serializer.fromJson<String?>(json['refuelingId']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      amount: serializer.fromJson<double>(json['amount']),
      merchantName: serializer.fromJson<String>(json['merchantName']),
      source: serializer.fromJson<String>(json['source']),
      cardNumberMask: serializer.fromJson<String?>(json['cardNumberMask']),
      bankTransactionCode: serializer.fromJson<String?>(
        json['bankTransactionCode'],
      ),
      posTerminalDetails: serializer.fromJson<String?>(
        json['posTerminalDetails'],
      ),
      scheduledPayment: serializer.fromJson<bool>(json['scheduledPayment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'transactionId': serializer.toJson<String>(transactionId),
      'userId': serializer.toJson<String>(userId),
      'refuelingId': serializer.toJson<String?>(refuelingId),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'amount': serializer.toJson<double>(amount),
      'merchantName': serializer.toJson<String>(merchantName),
      'source': serializer.toJson<String>(source),
      'cardNumberMask': serializer.toJson<String?>(cardNumberMask),
      'bankTransactionCode': serializer.toJson<String?>(bankTransactionCode),
      'posTerminalDetails': serializer.toJson<String?>(posTerminalDetails),
      'scheduledPayment': serializer.toJson<bool>(scheduledPayment),
    };
  }

  CardTransaction copyWith({
    String? transactionId,
    String? userId,
    Value<String?> refuelingId = const Value.absent(),
    DateTime? transactionDate,
    double? amount,
    String? merchantName,
    String? source,
    Value<String?> cardNumberMask = const Value.absent(),
    Value<String?> bankTransactionCode = const Value.absent(),
    Value<String?> posTerminalDetails = const Value.absent(),
    bool? scheduledPayment,
  }) => CardTransaction(
    transactionId: transactionId ?? this.transactionId,
    userId: userId ?? this.userId,
    refuelingId: refuelingId.present ? refuelingId.value : this.refuelingId,
    transactionDate: transactionDate ?? this.transactionDate,
    amount: amount ?? this.amount,
    merchantName: merchantName ?? this.merchantName,
    source: source ?? this.source,
    cardNumberMask: cardNumberMask.present
        ? cardNumberMask.value
        : this.cardNumberMask,
    bankTransactionCode: bankTransactionCode.present
        ? bankTransactionCode.value
        : this.bankTransactionCode,
    posTerminalDetails: posTerminalDetails.present
        ? posTerminalDetails.value
        : this.posTerminalDetails,
    scheduledPayment: scheduledPayment ?? this.scheduledPayment,
  );
  CardTransaction copyWithCompanion(CardTransactionsCompanion data) {
    return CardTransaction(
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      refuelingId: data.refuelingId.present
          ? data.refuelingId.value
          : this.refuelingId,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      amount: data.amount.present ? data.amount.value : this.amount,
      merchantName: data.merchantName.present
          ? data.merchantName.value
          : this.merchantName,
      source: data.source.present ? data.source.value : this.source,
      cardNumberMask: data.cardNumberMask.present
          ? data.cardNumberMask.value
          : this.cardNumberMask,
      bankTransactionCode: data.bankTransactionCode.present
          ? data.bankTransactionCode.value
          : this.bankTransactionCode,
      posTerminalDetails: data.posTerminalDetails.present
          ? data.posTerminalDetails.value
          : this.posTerminalDetails,
      scheduledPayment: data.scheduledPayment.present
          ? data.scheduledPayment.value
          : this.scheduledPayment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTransaction(')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('refuelingId: $refuelingId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amount: $amount, ')
          ..write('merchantName: $merchantName, ')
          ..write('source: $source, ')
          ..write('cardNumberMask: $cardNumberMask, ')
          ..write('bankTransactionCode: $bankTransactionCode, ')
          ..write('posTerminalDetails: $posTerminalDetails, ')
          ..write('scheduledPayment: $scheduledPayment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    transactionId,
    userId,
    refuelingId,
    transactionDate,
    amount,
    merchantName,
    source,
    cardNumberMask,
    bankTransactionCode,
    posTerminalDetails,
    scheduledPayment,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTransaction &&
          other.transactionId == this.transactionId &&
          other.userId == this.userId &&
          other.refuelingId == this.refuelingId &&
          other.transactionDate == this.transactionDate &&
          other.amount == this.amount &&
          other.merchantName == this.merchantName &&
          other.source == this.source &&
          other.cardNumberMask == this.cardNumberMask &&
          other.bankTransactionCode == this.bankTransactionCode &&
          other.posTerminalDetails == this.posTerminalDetails &&
          other.scheduledPayment == this.scheduledPayment);
}

class CardTransactionsCompanion extends UpdateCompanion<CardTransaction> {
  final Value<String> transactionId;
  final Value<String> userId;
  final Value<String?> refuelingId;
  final Value<DateTime> transactionDate;
  final Value<double> amount;
  final Value<String> merchantName;
  final Value<String> source;
  final Value<String?> cardNumberMask;
  final Value<String?> bankTransactionCode;
  final Value<String?> posTerminalDetails;
  final Value<bool> scheduledPayment;
  final Value<int> rowid;
  const CardTransactionsCompanion({
    this.transactionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.refuelingId = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.amount = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.source = const Value.absent(),
    this.cardNumberMask = const Value.absent(),
    this.bankTransactionCode = const Value.absent(),
    this.posTerminalDetails = const Value.absent(),
    this.scheduledPayment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardTransactionsCompanion.insert({
    required String transactionId,
    required String userId,
    this.refuelingId = const Value.absent(),
    required DateTime transactionDate,
    required double amount,
    required String merchantName,
    required String source,
    this.cardNumberMask = const Value.absent(),
    this.bankTransactionCode = const Value.absent(),
    this.posTerminalDetails = const Value.absent(),
    this.scheduledPayment = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : transactionId = Value(transactionId),
       userId = Value(userId),
       transactionDate = Value(transactionDate),
       amount = Value(amount),
       merchantName = Value(merchantName),
       source = Value(source);
  static Insertable<CardTransaction> custom({
    Expression<String>? transactionId,
    Expression<String>? userId,
    Expression<String>? refuelingId,
    Expression<DateTime>? transactionDate,
    Expression<double>? amount,
    Expression<String>? merchantName,
    Expression<String>? source,
    Expression<String>? cardNumberMask,
    Expression<String>? bankTransactionCode,
    Expression<String>? posTerminalDetails,
    Expression<bool>? scheduledPayment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (transactionId != null) 'id': transactionId,
      if (userId != null) 'user_id': userId,
      if (refuelingId != null) 'refueling_id': refuelingId,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (amount != null) 'amount': amount,
      if (merchantName != null) 'merchant_name': merchantName,
      if (source != null) 'source': source,
      if (cardNumberMask != null) 'card_number_mask': cardNumberMask,
      if (bankTransactionCode != null)
        'bank_transaction_code': bankTransactionCode,
      if (posTerminalDetails != null)
        'pos_terminal_details': posTerminalDetails,
      if (scheduledPayment != null) 'scheduled_payment': scheduledPayment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardTransactionsCompanion copyWith({
    Value<String>? transactionId,
    Value<String>? userId,
    Value<String?>? refuelingId,
    Value<DateTime>? transactionDate,
    Value<double>? amount,
    Value<String>? merchantName,
    Value<String>? source,
    Value<String?>? cardNumberMask,
    Value<String?>? bankTransactionCode,
    Value<String?>? posTerminalDetails,
    Value<bool>? scheduledPayment,
    Value<int>? rowid,
  }) {
    return CardTransactionsCompanion(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      refuelingId: refuelingId ?? this.refuelingId,
      transactionDate: transactionDate ?? this.transactionDate,
      amount: amount ?? this.amount,
      merchantName: merchantName ?? this.merchantName,
      source: source ?? this.source,
      cardNumberMask: cardNumberMask ?? this.cardNumberMask,
      bankTransactionCode: bankTransactionCode ?? this.bankTransactionCode,
      posTerminalDetails: posTerminalDetails ?? this.posTerminalDetails,
      scheduledPayment: scheduledPayment ?? this.scheduledPayment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (transactionId.present) {
      map['id'] = Variable<String>(transactionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (refuelingId.present) {
      map['refueling_id'] = Variable<String>(refuelingId.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (merchantName.present) {
      map['merchant_name'] = Variable<String>(merchantName.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (cardNumberMask.present) {
      map['card_number_mask'] = Variable<String>(cardNumberMask.value);
    }
    if (bankTransactionCode.present) {
      map['bank_transaction_code'] = Variable<String>(
        bankTransactionCode.value,
      );
    }
    if (posTerminalDetails.present) {
      map['pos_terminal_details'] = Variable<String>(posTerminalDetails.value);
    }
    if (scheduledPayment.present) {
      map['scheduled_payment'] = Variable<bool>(scheduledPayment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardTransactionsCompanion(')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('refuelingId: $refuelingId, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('amount: $amount, ')
          ..write('merchantName: $merchantName, ')
          ..write('source: $source, ')
          ..write('cardNumberMask: $cardNumberMask, ')
          ..write('bankTransactionCode: $bankTransactionCode, ')
          ..write('posTerminalDetails: $posTerminalDetails, ')
          ..write('scheduledPayment: $scheduledPayment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CampaignsTable extends Campaigns
    with TableInfo<$CampaignsTable, Campaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stationBrandMeta = const VerificationMeta(
    'stationBrand',
  );
  @override
  late final GeneratedColumn<String> stationBrand = GeneratedColumn<String>(
    'station_brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTxCountMeta = const VerificationMeta(
    'targetTxCount',
  );
  @override
  late final GeneratedColumn<int> targetTxCount = GeneratedColumn<int>(
    'target_tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (target_tx_count > 0)',
  );
  static const VerificationMeta _currentTxCountMeta = const VerificationMeta(
    'currentTxCount',
  );
  @override
  late final GeneratedColumn<int> currentTxCount = GeneratedColumn<int>(
    'current_tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rewardAmountMeta = const VerificationMeta(
    'rewardAmount',
  );
  @override
  late final GeneratedColumn<double> rewardAmount = GeneratedColumn<double>(
    'reward_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (reward_amount > 0)',
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    campaignId,
    userId,
    bankName,
    stationBrand,
    targetTxCount,
    currentTxCount,
    rewardAmount,
    expiryDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<Campaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('station_brand')) {
      context.handle(
        _stationBrandMeta,
        stationBrand.isAcceptableOrUnknown(
          data['station_brand']!,
          _stationBrandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stationBrandMeta);
    }
    if (data.containsKey('target_tx_count')) {
      context.handle(
        _targetTxCountMeta,
        targetTxCount.isAcceptableOrUnknown(
          data['target_tx_count']!,
          _targetTxCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTxCountMeta);
    }
    if (data.containsKey('current_tx_count')) {
      context.handle(
        _currentTxCountMeta,
        currentTxCount.isAcceptableOrUnknown(
          data['current_tx_count']!,
          _currentTxCountMeta,
        ),
      );
    }
    if (data.containsKey('reward_amount')) {
      context.handle(
        _rewardAmountMeta,
        rewardAmount.isAcceptableOrUnknown(
          data['reward_amount']!,
          _rewardAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rewardAmountMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {campaignId};
  @override
  Campaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Campaign(
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      stationBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_brand'],
      )!,
      targetTxCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_tx_count'],
      )!,
      currentTxCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_tx_count'],
      )!,
      rewardAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reward_amount'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
    );
  }

  @override
  $CampaignsTable createAlias(String alias) {
    return $CampaignsTable(attachedDatabase, alias);
  }
}

class Campaign extends DataClass implements Insertable<Campaign> {
  final String campaignId;
  final String userId;
  final String bankName;
  final String stationBrand;
  final int targetTxCount;
  final int currentTxCount;
  final double rewardAmount;
  final DateTime expiryDate;
  const Campaign({
    required this.campaignId,
    required this.userId,
    required this.bankName,
    required this.stationBrand,
    required this.targetTxCount,
    required this.currentTxCount,
    required this.rewardAmount,
    required this.expiryDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(campaignId);
    map['user_id'] = Variable<String>(userId);
    map['bank_name'] = Variable<String>(bankName);
    map['station_brand'] = Variable<String>(stationBrand);
    map['target_tx_count'] = Variable<int>(targetTxCount);
    map['current_tx_count'] = Variable<int>(currentTxCount);
    map['reward_amount'] = Variable<double>(rewardAmount);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    return map;
  }

  CampaignsCompanion toCompanion(bool nullToAbsent) {
    return CampaignsCompanion(
      campaignId: Value(campaignId),
      userId: Value(userId),
      bankName: Value(bankName),
      stationBrand: Value(stationBrand),
      targetTxCount: Value(targetTxCount),
      currentTxCount: Value(currentTxCount),
      rewardAmount: Value(rewardAmount),
      expiryDate: Value(expiryDate),
    );
  }

  factory Campaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Campaign(
      campaignId: serializer.fromJson<String>(json['campaignId']),
      userId: serializer.fromJson<String>(json['userId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      stationBrand: serializer.fromJson<String>(json['stationBrand']),
      targetTxCount: serializer.fromJson<int>(json['targetTxCount']),
      currentTxCount: serializer.fromJson<int>(json['currentTxCount']),
      rewardAmount: serializer.fromJson<double>(json['rewardAmount']),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'campaignId': serializer.toJson<String>(campaignId),
      'userId': serializer.toJson<String>(userId),
      'bankName': serializer.toJson<String>(bankName),
      'stationBrand': serializer.toJson<String>(stationBrand),
      'targetTxCount': serializer.toJson<int>(targetTxCount),
      'currentTxCount': serializer.toJson<int>(currentTxCount),
      'rewardAmount': serializer.toJson<double>(rewardAmount),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
    };
  }

  Campaign copyWith({
    String? campaignId,
    String? userId,
    String? bankName,
    String? stationBrand,
    int? targetTxCount,
    int? currentTxCount,
    double? rewardAmount,
    DateTime? expiryDate,
  }) => Campaign(
    campaignId: campaignId ?? this.campaignId,
    userId: userId ?? this.userId,
    bankName: bankName ?? this.bankName,
    stationBrand: stationBrand ?? this.stationBrand,
    targetTxCount: targetTxCount ?? this.targetTxCount,
    currentTxCount: currentTxCount ?? this.currentTxCount,
    rewardAmount: rewardAmount ?? this.rewardAmount,
    expiryDate: expiryDate ?? this.expiryDate,
  );
  Campaign copyWithCompanion(CampaignsCompanion data) {
    return Campaign(
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      userId: data.userId.present ? data.userId.value : this.userId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      stationBrand: data.stationBrand.present
          ? data.stationBrand.value
          : this.stationBrand,
      targetTxCount: data.targetTxCount.present
          ? data.targetTxCount.value
          : this.targetTxCount,
      currentTxCount: data.currentTxCount.present
          ? data.currentTxCount.value
          : this.currentTxCount,
      rewardAmount: data.rewardAmount.present
          ? data.rewardAmount.value
          : this.rewardAmount,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Campaign(')
          ..write('campaignId: $campaignId, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('stationBrand: $stationBrand, ')
          ..write('targetTxCount: $targetTxCount, ')
          ..write('currentTxCount: $currentTxCount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('expiryDate: $expiryDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    campaignId,
    userId,
    bankName,
    stationBrand,
    targetTxCount,
    currentTxCount,
    rewardAmount,
    expiryDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Campaign &&
          other.campaignId == this.campaignId &&
          other.userId == this.userId &&
          other.bankName == this.bankName &&
          other.stationBrand == this.stationBrand &&
          other.targetTxCount == this.targetTxCount &&
          other.currentTxCount == this.currentTxCount &&
          other.rewardAmount == this.rewardAmount &&
          other.expiryDate == this.expiryDate);
}

class CampaignsCompanion extends UpdateCompanion<Campaign> {
  final Value<String> campaignId;
  final Value<String> userId;
  final Value<String> bankName;
  final Value<String> stationBrand;
  final Value<int> targetTxCount;
  final Value<int> currentTxCount;
  final Value<double> rewardAmount;
  final Value<DateTime> expiryDate;
  final Value<int> rowid;
  const CampaignsCompanion({
    this.campaignId = const Value.absent(),
    this.userId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.stationBrand = const Value.absent(),
    this.targetTxCount = const Value.absent(),
    this.currentTxCount = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CampaignsCompanion.insert({
    required String campaignId,
    required String userId,
    required String bankName,
    required String stationBrand,
    required int targetTxCount,
    this.currentTxCount = const Value.absent(),
    required double rewardAmount,
    required DateTime expiryDate,
    this.rowid = const Value.absent(),
  }) : campaignId = Value(campaignId),
       userId = Value(userId),
       bankName = Value(bankName),
       stationBrand = Value(stationBrand),
       targetTxCount = Value(targetTxCount),
       rewardAmount = Value(rewardAmount),
       expiryDate = Value(expiryDate);
  static Insertable<Campaign> custom({
    Expression<String>? campaignId,
    Expression<String>? userId,
    Expression<String>? bankName,
    Expression<String>? stationBrand,
    Expression<int>? targetTxCount,
    Expression<int>? currentTxCount,
    Expression<double>? rewardAmount,
    Expression<DateTime>? expiryDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (campaignId != null) 'id': campaignId,
      if (userId != null) 'user_id': userId,
      if (bankName != null) 'bank_name': bankName,
      if (stationBrand != null) 'station_brand': stationBrand,
      if (targetTxCount != null) 'target_tx_count': targetTxCount,
      if (currentTxCount != null) 'current_tx_count': currentTxCount,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CampaignsCompanion copyWith({
    Value<String>? campaignId,
    Value<String>? userId,
    Value<String>? bankName,
    Value<String>? stationBrand,
    Value<int>? targetTxCount,
    Value<int>? currentTxCount,
    Value<double>? rewardAmount,
    Value<DateTime>? expiryDate,
    Value<int>? rowid,
  }) {
    return CampaignsCompanion(
      campaignId: campaignId ?? this.campaignId,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      stationBrand: stationBrand ?? this.stationBrand,
      targetTxCount: targetTxCount ?? this.targetTxCount,
      currentTxCount: currentTxCount ?? this.currentTxCount,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      expiryDate: expiryDate ?? this.expiryDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (campaignId.present) {
      map['id'] = Variable<String>(campaignId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (stationBrand.present) {
      map['station_brand'] = Variable<String>(stationBrand.value);
    }
    if (targetTxCount.present) {
      map['target_tx_count'] = Variable<int>(targetTxCount.value);
    }
    if (currentTxCount.present) {
      map['current_tx_count'] = Variable<int>(currentTxCount.value);
    }
    if (rewardAmount.present) {
      map['reward_amount'] = Variable<double>(rewardAmount.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CampaignsCompanion(')
          ..write('campaignId: $campaignId, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('stationBrand: $stationBrand, ')
          ..write('targetTxCount: $targetTxCount, ')
          ..write('currentTxCount: $currentTxCount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ObdReadingsTable extends ObdReadings
    with TableInfo<$ObdReadingsTable, ObdReading> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObdReadingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _readingIdMeta = const VerificationMeta(
    'readingId',
  );
  @override
  late final GeneratedColumn<String> readingId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<String> vehicleId = GeneratedColumn<String>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerValueMeta = const VerificationMeta(
    'odometerValue',
  );
  @override
  late final GeneratedColumn<int> odometerValue = GeneratedColumn<int>(
    'odometer_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (odometer_value >= 0)',
  );
  static const VerificationMeta _fuelLevelRatioMeta = const VerificationMeta(
    'fuelLevelRatio',
  );
  @override
  late final GeneratedColumn<double> fuelLevelRatio = GeneratedColumn<double>(
    'fuel_level_ratio',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (fuel_level_ratio >= 0.0 AND fuel_level_ratio <= 1.0)',
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    readingId,
    vehicleId,
    odometerValue,
    fuelLevelRatio,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obd_readings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObdReading> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _readingIdMeta,
        readingId.isAcceptableOrUnknown(data['id']!, _readingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_readingIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('odometer_value')) {
      context.handle(
        _odometerValueMeta,
        odometerValue.isAcceptableOrUnknown(
          data['odometer_value']!,
          _odometerValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_odometerValueMeta);
    }
    if (data.containsKey('fuel_level_ratio')) {
      context.handle(
        _fuelLevelRatioMeta,
        fuelLevelRatio.isAcceptableOrUnknown(
          data['fuel_level_ratio']!,
          _fuelLevelRatioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fuelLevelRatioMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {readingId};
  @override
  ObdReading map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObdReading(
      readingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vehicle_id'],
      )!,
      odometerValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_value'],
      )!,
      fuelLevelRatio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_level_ratio'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $ObdReadingsTable createAlias(String alias) {
    return $ObdReadingsTable(attachedDatabase, alias);
  }
}

class ObdReading extends DataClass implements Insertable<ObdReading> {
  final String readingId;
  final String vehicleId;
  final int odometerValue;
  final double fuelLevelRatio;
  final DateTime recordedAt;
  const ObdReading({
    required this.readingId,
    required this.vehicleId,
    required this.odometerValue,
    required this.fuelLevelRatio,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(readingId);
    map['vehicle_id'] = Variable<String>(vehicleId);
    map['odometer_value'] = Variable<int>(odometerValue);
    map['fuel_level_ratio'] = Variable<double>(fuelLevelRatio);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  ObdReadingsCompanion toCompanion(bool nullToAbsent) {
    return ObdReadingsCompanion(
      readingId: Value(readingId),
      vehicleId: Value(vehicleId),
      odometerValue: Value(odometerValue),
      fuelLevelRatio: Value(fuelLevelRatio),
      recordedAt: Value(recordedAt),
    );
  }

  factory ObdReading.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObdReading(
      readingId: serializer.fromJson<String>(json['readingId']),
      vehicleId: serializer.fromJson<String>(json['vehicleId']),
      odometerValue: serializer.fromJson<int>(json['odometerValue']),
      fuelLevelRatio: serializer.fromJson<double>(json['fuelLevelRatio']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'readingId': serializer.toJson<String>(readingId),
      'vehicleId': serializer.toJson<String>(vehicleId),
      'odometerValue': serializer.toJson<int>(odometerValue),
      'fuelLevelRatio': serializer.toJson<double>(fuelLevelRatio),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  ObdReading copyWith({
    String? readingId,
    String? vehicleId,
    int? odometerValue,
    double? fuelLevelRatio,
    DateTime? recordedAt,
  }) => ObdReading(
    readingId: readingId ?? this.readingId,
    vehicleId: vehicleId ?? this.vehicleId,
    odometerValue: odometerValue ?? this.odometerValue,
    fuelLevelRatio: fuelLevelRatio ?? this.fuelLevelRatio,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  ObdReading copyWithCompanion(ObdReadingsCompanion data) {
    return ObdReading(
      readingId: data.readingId.present ? data.readingId.value : this.readingId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      odometerValue: data.odometerValue.present
          ? data.odometerValue.value
          : this.odometerValue,
      fuelLevelRatio: data.fuelLevelRatio.present
          ? data.fuelLevelRatio.value
          : this.fuelLevelRatio,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObdReading(')
          ..write('readingId: $readingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('odometerValue: $odometerValue, ')
          ..write('fuelLevelRatio: $fuelLevelRatio, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    readingId,
    vehicleId,
    odometerValue,
    fuelLevelRatio,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObdReading &&
          other.readingId == this.readingId &&
          other.vehicleId == this.vehicleId &&
          other.odometerValue == this.odometerValue &&
          other.fuelLevelRatio == this.fuelLevelRatio &&
          other.recordedAt == this.recordedAt);
}

class ObdReadingsCompanion extends UpdateCompanion<ObdReading> {
  final Value<String> readingId;
  final Value<String> vehicleId;
  final Value<int> odometerValue;
  final Value<double> fuelLevelRatio;
  final Value<DateTime> recordedAt;
  final Value<int> rowid;
  const ObdReadingsCompanion({
    this.readingId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.odometerValue = const Value.absent(),
    this.fuelLevelRatio = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ObdReadingsCompanion.insert({
    required String readingId,
    required String vehicleId,
    required int odometerValue,
    required double fuelLevelRatio,
    this.recordedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : readingId = Value(readingId),
       vehicleId = Value(vehicleId),
       odometerValue = Value(odometerValue),
       fuelLevelRatio = Value(fuelLevelRatio);
  static Insertable<ObdReading> custom({
    Expression<String>? readingId,
    Expression<String>? vehicleId,
    Expression<int>? odometerValue,
    Expression<double>? fuelLevelRatio,
    Expression<DateTime>? recordedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (readingId != null) 'id': readingId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (odometerValue != null) 'odometer_value': odometerValue,
      if (fuelLevelRatio != null) 'fuel_level_ratio': fuelLevelRatio,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ObdReadingsCompanion copyWith({
    Value<String>? readingId,
    Value<String>? vehicleId,
    Value<int>? odometerValue,
    Value<double>? fuelLevelRatio,
    Value<DateTime>? recordedAt,
    Value<int>? rowid,
  }) {
    return ObdReadingsCompanion(
      readingId: readingId ?? this.readingId,
      vehicleId: vehicleId ?? this.vehicleId,
      odometerValue: odometerValue ?? this.odometerValue,
      fuelLevelRatio: fuelLevelRatio ?? this.fuelLevelRatio,
      recordedAt: recordedAt ?? this.recordedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (readingId.present) {
      map['id'] = Variable<String>(readingId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<String>(vehicleId.value);
    }
    if (odometerValue.present) {
      map['odometer_value'] = Variable<int>(odometerValue.value);
    }
    if (fuelLevelRatio.present) {
      map['fuel_level_ratio'] = Variable<double>(fuelLevelRatio.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObdReadingsCompanion(')
          ..write('readingId: $readingId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('odometerValue: $odometerValue, ')
          ..write('fuelLevelRatio: $fuelLevelRatio, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FuelPricesTable extends FuelPrices
    with TableInfo<$FuelPricesTable, FuelPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelPricesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _provinceCodeMeta = const VerificationMeta(
    'provinceCode',
  );
  @override
  late final GeneratedColumn<String> provinceCode = GeneratedColumn<String>(
    'province_code',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelTypeMeta = const VerificationMeta(
    'fuelType',
  );
  @override
  late final GeneratedColumn<String> fuelType = GeneratedColumn<String>(
    'fuel_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceDateMeta = const VerificationMeta(
    'priceDate',
  );
  @override
  late final GeneratedColumn<DateTime> priceDate = GeneratedColumn<DateTime>(
    'price_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (price > 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    provinceCode,
    fuelType,
    priceDate,
    price,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_prices';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('province_code')) {
      context.handle(
        _provinceCodeMeta,
        provinceCode.isAcceptableOrUnknown(
          data['province_code']!,
          _provinceCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_provinceCodeMeta);
    }
    if (data.containsKey('fuel_type')) {
      context.handle(
        _fuelTypeMeta,
        fuelType.isAcceptableOrUnknown(data['fuel_type']!, _fuelTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelTypeMeta);
    }
    if (data.containsKey('price_date')) {
      context.handle(
        _priceDateMeta,
        priceDate.isAcceptableOrUnknown(data['price_date']!, _priceDateMeta),
      );
    } else if (isInserting) {
      context.missing(_priceDateMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {provinceCode, fuelType, priceDate};
  @override
  FuelPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelPrice(
      provinceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}province_code'],
      )!,
      fuelType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuel_type'],
      )!,
      priceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}price_date'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
    );
  }

  @override
  $FuelPricesTable createAlias(String alias) {
    return $FuelPricesTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class FuelPrice extends DataClass implements Insertable<FuelPrice> {
  final String provinceCode;
  final String fuelType;
  final DateTime priceDate;
  final double price;
  const FuelPrice({
    required this.provinceCode,
    required this.fuelType,
    required this.priceDate,
    required this.price,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['province_code'] = Variable<String>(provinceCode);
    map['fuel_type'] = Variable<String>(fuelType);
    map['price_date'] = Variable<DateTime>(priceDate);
    map['price'] = Variable<double>(price);
    return map;
  }

  FuelPricesCompanion toCompanion(bool nullToAbsent) {
    return FuelPricesCompanion(
      provinceCode: Value(provinceCode),
      fuelType: Value(fuelType),
      priceDate: Value(priceDate),
      price: Value(price),
    );
  }

  factory FuelPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelPrice(
      provinceCode: serializer.fromJson<String>(json['provinceCode']),
      fuelType: serializer.fromJson<String>(json['fuelType']),
      priceDate: serializer.fromJson<DateTime>(json['priceDate']),
      price: serializer.fromJson<double>(json['price']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'provinceCode': serializer.toJson<String>(provinceCode),
      'fuelType': serializer.toJson<String>(fuelType),
      'priceDate': serializer.toJson<DateTime>(priceDate),
      'price': serializer.toJson<double>(price),
    };
  }

  FuelPrice copyWith({
    String? provinceCode,
    String? fuelType,
    DateTime? priceDate,
    double? price,
  }) => FuelPrice(
    provinceCode: provinceCode ?? this.provinceCode,
    fuelType: fuelType ?? this.fuelType,
    priceDate: priceDate ?? this.priceDate,
    price: price ?? this.price,
  );
  FuelPrice copyWithCompanion(FuelPricesCompanion data) {
    return FuelPrice(
      provinceCode: data.provinceCode.present
          ? data.provinceCode.value
          : this.provinceCode,
      fuelType: data.fuelType.present ? data.fuelType.value : this.fuelType,
      priceDate: data.priceDate.present ? data.priceDate.value : this.priceDate,
      price: data.price.present ? data.price.value : this.price,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelPrice(')
          ..write('provinceCode: $provinceCode, ')
          ..write('fuelType: $fuelType, ')
          ..write('priceDate: $priceDate, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(provinceCode, fuelType, priceDate, price);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelPrice &&
          other.provinceCode == this.provinceCode &&
          other.fuelType == this.fuelType &&
          other.priceDate == this.priceDate &&
          other.price == this.price);
}

class FuelPricesCompanion extends UpdateCompanion<FuelPrice> {
  final Value<String> provinceCode;
  final Value<String> fuelType;
  final Value<DateTime> priceDate;
  final Value<double> price;
  const FuelPricesCompanion({
    this.provinceCode = const Value.absent(),
    this.fuelType = const Value.absent(),
    this.priceDate = const Value.absent(),
    this.price = const Value.absent(),
  });
  FuelPricesCompanion.insert({
    required String provinceCode,
    required String fuelType,
    required DateTime priceDate,
    required double price,
  }) : provinceCode = Value(provinceCode),
       fuelType = Value(fuelType),
       priceDate = Value(priceDate),
       price = Value(price);
  static Insertable<FuelPrice> custom({
    Expression<String>? provinceCode,
    Expression<String>? fuelType,
    Expression<DateTime>? priceDate,
    Expression<double>? price,
  }) {
    return RawValuesInsertable({
      if (provinceCode != null) 'province_code': provinceCode,
      if (fuelType != null) 'fuel_type': fuelType,
      if (priceDate != null) 'price_date': priceDate,
      if (price != null) 'price': price,
    });
  }

  FuelPricesCompanion copyWith({
    Value<String>? provinceCode,
    Value<String>? fuelType,
    Value<DateTime>? priceDate,
    Value<double>? price,
  }) {
    return FuelPricesCompanion(
      provinceCode: provinceCode ?? this.provinceCode,
      fuelType: fuelType ?? this.fuelType,
      priceDate: priceDate ?? this.priceDate,
      price: price ?? this.price,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (provinceCode.present) {
      map['province_code'] = Variable<String>(provinceCode.value);
    }
    if (fuelType.present) {
      map['fuel_type'] = Variable<String>(fuelType.value);
    }
    if (priceDate.present) {
      map['price_date'] = Variable<DateTime>(priceDate.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelPricesCompanion(')
          ..write('provinceCode: $provinceCode, ')
          ..write('fuelType: $fuelType, ')
          ..write('priceDate: $priceDate, ')
          ..write('price: $price')
          ..write(')'))
        .toString();
  }
}

class $StatementUploadsTable extends StatementUploads
    with TableInfo<$StatementUploadsTable, StatementUpload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatementUploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _uploadDateMeta = const VerificationMeta(
    'uploadDate',
  );
  @override
  late final GeneratedColumn<DateTime> uploadDate = GeneratedColumn<DateTime>(
    'upload_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _acceptedAllTermsMeta = const VerificationMeta(
    'acceptedAllTerms',
  );
  @override
  late final GeneratedColumn<bool> acceptedAllTerms = GeneratedColumn<bool>(
    'accepted_all_terms',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("accepted_all_terms" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fileName,
    filePath,
    uploadDate,
    acceptedAllTerms,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'statement_uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatementUpload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('upload_date')) {
      context.handle(
        _uploadDateMeta,
        uploadDate.isAcceptableOrUnknown(data['upload_date']!, _uploadDateMeta),
      );
    }
    if (data.containsKey('accepted_all_terms')) {
      context.handle(
        _acceptedAllTermsMeta,
        acceptedAllTerms.isAcceptableOrUnknown(
          data['accepted_all_terms']!,
          _acceptedAllTermsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatementUpload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatementUpload(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      uploadDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}upload_date'],
      )!,
      acceptedAllTerms: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}accepted_all_terms'],
      )!,
    );
  }

  @override
  $StatementUploadsTable createAlias(String alias) {
    return $StatementUploadsTable(attachedDatabase, alias);
  }
}

class StatementUpload extends DataClass implements Insertable<StatementUpload> {
  final int id;
  final String fileName;
  final String filePath;
  final DateTime uploadDate;
  final bool acceptedAllTerms;
  const StatementUpload({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.uploadDate,
    required this.acceptedAllTerms,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    map['upload_date'] = Variable<DateTime>(uploadDate);
    map['accepted_all_terms'] = Variable<bool>(acceptedAllTerms);
    return map;
  }

  StatementUploadsCompanion toCompanion(bool nullToAbsent) {
    return StatementUploadsCompanion(
      id: Value(id),
      fileName: Value(fileName),
      filePath: Value(filePath),
      uploadDate: Value(uploadDate),
      acceptedAllTerms: Value(acceptedAllTerms),
    );
  }

  factory StatementUpload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatementUpload(
      id: serializer.fromJson<int>(json['id']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      uploadDate: serializer.fromJson<DateTime>(json['uploadDate']),
      acceptedAllTerms: serializer.fromJson<bool>(json['acceptedAllTerms']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'uploadDate': serializer.toJson<DateTime>(uploadDate),
      'acceptedAllTerms': serializer.toJson<bool>(acceptedAllTerms),
    };
  }

  StatementUpload copyWith({
    int? id,
    String? fileName,
    String? filePath,
    DateTime? uploadDate,
    bool? acceptedAllTerms,
  }) => StatementUpload(
    id: id ?? this.id,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    uploadDate: uploadDate ?? this.uploadDate,
    acceptedAllTerms: acceptedAllTerms ?? this.acceptedAllTerms,
  );
  StatementUpload copyWithCompanion(StatementUploadsCompanion data) {
    return StatementUpload(
      id: data.id.present ? data.id.value : this.id,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      uploadDate: data.uploadDate.present
          ? data.uploadDate.value
          : this.uploadDate,
      acceptedAllTerms: data.acceptedAllTerms.present
          ? data.acceptedAllTerms.value
          : this.acceptedAllTerms,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatementUpload(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('uploadDate: $uploadDate, ')
          ..write('acceptedAllTerms: $acceptedAllTerms')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fileName, filePath, uploadDate, acceptedAllTerms);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatementUpload &&
          other.id == this.id &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.uploadDate == this.uploadDate &&
          other.acceptedAllTerms == this.acceptedAllTerms);
}

class StatementUploadsCompanion extends UpdateCompanion<StatementUpload> {
  final Value<int> id;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<DateTime> uploadDate;
  final Value<bool> acceptedAllTerms;
  const StatementUploadsCompanion({
    this.id = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.uploadDate = const Value.absent(),
    this.acceptedAllTerms = const Value.absent(),
  });
  StatementUploadsCompanion.insert({
    this.id = const Value.absent(),
    required String fileName,
    required String filePath,
    this.uploadDate = const Value.absent(),
    this.acceptedAllTerms = const Value.absent(),
  }) : fileName = Value(fileName),
       filePath = Value(filePath);
  static Insertable<StatementUpload> custom({
    Expression<int>? id,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<DateTime>? uploadDate,
    Expression<bool>? acceptedAllTerms,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (uploadDate != null) 'upload_date': uploadDate,
      if (acceptedAllTerms != null) 'accepted_all_terms': acceptedAllTerms,
    });
  }

  StatementUploadsCompanion copyWith({
    Value<int>? id,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<DateTime>? uploadDate,
    Value<bool>? acceptedAllTerms,
  }) {
    return StatementUploadsCompanion(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      uploadDate: uploadDate ?? this.uploadDate,
      acceptedAllTerms: acceptedAllTerms ?? this.acceptedAllTerms,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (uploadDate.present) {
      map['upload_date'] = Variable<DateTime>(uploadDate.value);
    }
    if (acceptedAllTerms.present) {
      map['accepted_all_terms'] = Variable<bool>(acceptedAllTerms.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatementUploadsCompanion(')
          ..write('id: $id, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('uploadDate: $uploadDate, ')
          ..write('acceptedAllTerms: $acceptedAllTerms')
          ..write(')'))
        .toString();
  }
}

class $DestructiveOfflineQueueTable extends DestructiveOfflineQueue
    with TableInfo<$DestructiveOfflineQueueTable, DestructiveOfflineQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DestructiveOfflineQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _queueIdMeta = const VerificationMeta(
    'queueId',
  );
  @override
  late final GeneratedColumn<String> queueId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
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
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    queueId,
    userId,
    entityType,
    entityId,
    actionType,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'destructive_offline_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<DestructiveOfflineQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _queueIdMeta,
        queueId.isAcceptableOrUnknown(data['id']!, _queueIdMeta),
      );
    } else if (isInserting) {
      context.missing(_queueIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {queueId};
  @override
  DestructiveOfflineQueueData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DestructiveOfflineQueueData(
      queueId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DestructiveOfflineQueueTable createAlias(String alias) {
    return $DestructiveOfflineQueueTable(attachedDatabase, alias);
  }
}

class DestructiveOfflineQueueData extends DataClass
    implements Insertable<DestructiveOfflineQueueData> {
  final String queueId;
  final String userId;
  final String entityType;
  final String entityId;
  final String actionType;
  final DateTime createdAt;
  const DestructiveOfflineQueueData({
    required this.queueId,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.actionType,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(queueId);
    map['user_id'] = Variable<String>(userId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action_type'] = Variable<String>(actionType);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DestructiveOfflineQueueCompanion toCompanion(bool nullToAbsent) {
    return DestructiveOfflineQueueCompanion(
      queueId: Value(queueId),
      userId: Value(userId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      actionType: Value(actionType),
      createdAt: Value(createdAt),
    );
  }

  factory DestructiveOfflineQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DestructiveOfflineQueueData(
      queueId: serializer.fromJson<String>(json['queueId']),
      userId: serializer.fromJson<String>(json['userId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'queueId': serializer.toJson<String>(queueId),
      'userId': serializer.toJson<String>(userId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'actionType': serializer.toJson<String>(actionType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DestructiveOfflineQueueData copyWith({
    String? queueId,
    String? userId,
    String? entityType,
    String? entityId,
    String? actionType,
    DateTime? createdAt,
  }) => DestructiveOfflineQueueData(
    queueId: queueId ?? this.queueId,
    userId: userId ?? this.userId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    actionType: actionType ?? this.actionType,
    createdAt: createdAt ?? this.createdAt,
  );
  DestructiveOfflineQueueData copyWithCompanion(
    DestructiveOfflineQueueCompanion data,
  ) {
    return DestructiveOfflineQueueData(
      queueId: data.queueId.present ? data.queueId.value : this.queueId,
      userId: data.userId.present ? data.userId.value : this.userId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DestructiveOfflineQueueData(')
          ..write('queueId: $queueId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(queueId, userId, entityType, entityId, actionType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DestructiveOfflineQueueData &&
          other.queueId == this.queueId &&
          other.userId == this.userId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.actionType == this.actionType &&
          other.createdAt == this.createdAt);
}

class DestructiveOfflineQueueCompanion
    extends UpdateCompanion<DestructiveOfflineQueueData> {
  final Value<String> queueId;
  final Value<String> userId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> actionType;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DestructiveOfflineQueueCompanion({
    this.queueId = const Value.absent(),
    this.userId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DestructiveOfflineQueueCompanion.insert({
    required String queueId,
    required String userId,
    required String entityType,
    required String entityId,
    required String actionType,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : queueId = Value(queueId),
       userId = Value(userId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       actionType = Value(actionType);
  static Insertable<DestructiveOfflineQueueData> custom({
    Expression<String>? queueId,
    Expression<String>? userId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? actionType,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (queueId != null) 'id': queueId,
      if (userId != null) 'user_id': userId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (actionType != null) 'action_type': actionType,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DestructiveOfflineQueueCompanion copyWith({
    Value<String>? queueId,
    Value<String>? userId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? actionType,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DestructiveOfflineQueueCompanion(
      queueId: queueId ?? this.queueId,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      actionType: actionType ?? this.actionType,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (queueId.present) {
      map['id'] = Variable<String>(queueId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
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
    return (StringBuffer('DestructiveOfflineQueueCompanion(')
          ..write('queueId: $queueId, ')
          ..write('userId: $userId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('actionType: $actionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentQueueTable extends AttachmentQueue
    with TableInfo<$AttachmentQueueTable, AttachmentQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attachmentIdMeta = const VerificationMeta(
    'attachmentId',
  );
  @override
  late final GeneratedColumn<String> attachmentId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remoteStoragePathMeta = const VerificationMeta(
    'remoteStoragePath',
  );
  @override
  late final GeneratedColumn<String> remoteStoragePath =
      GeneratedColumn<String>(
        'remote_storage_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PENDING'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attachmentId,
    userId,
    filePath,
    remoteStoragePath,
    status,
    retryCount,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _attachmentIdMeta,
        attachmentId.isAcceptableOrUnknown(data['id']!, _attachmentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attachmentIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('remote_storage_path')) {
      context.handle(
        _remoteStoragePathMeta,
        remoteStoragePath.isAcceptableOrUnknown(
          data['remote_storage_path']!,
          _remoteStoragePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_remoteStoragePathMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attachmentId};
  @override
  AttachmentQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentQueueData(
      attachmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      remoteStoragePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_storage_path'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentQueueTable createAlias(String alias) {
    return $AttachmentQueueTable(attachedDatabase, alias);
  }
}

class AttachmentQueueData extends DataClass
    implements Insertable<AttachmentQueueData> {
  final String attachmentId;
  final String userId;
  final String filePath;
  final String remoteStoragePath;
  final String status;
  final int retryCount;
  final DateTime createdAt;
  const AttachmentQueueData({
    required this.attachmentId,
    required this.userId,
    required this.filePath,
    required this.remoteStoragePath,
    required this.status,
    required this.retryCount,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(attachmentId);
    map['user_id'] = Variable<String>(userId);
    map['file_path'] = Variable<String>(filePath);
    map['remote_storage_path'] = Variable<String>(remoteStoragePath);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentQueueCompanion toCompanion(bool nullToAbsent) {
    return AttachmentQueueCompanion(
      attachmentId: Value(attachmentId),
      userId: Value(userId),
      filePath: Value(filePath),
      remoteStoragePath: Value(remoteStoragePath),
      status: Value(status),
      retryCount: Value(retryCount),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentQueueData(
      attachmentId: serializer.fromJson<String>(json['attachmentId']),
      userId: serializer.fromJson<String>(json['userId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      remoteStoragePath: serializer.fromJson<String>(json['remoteStoragePath']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attachmentId': serializer.toJson<String>(attachmentId),
      'userId': serializer.toJson<String>(userId),
      'filePath': serializer.toJson<String>(filePath),
      'remoteStoragePath': serializer.toJson<String>(remoteStoragePath),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentQueueData copyWith({
    String? attachmentId,
    String? userId,
    String? filePath,
    String? remoteStoragePath,
    String? status,
    int? retryCount,
    DateTime? createdAt,
  }) => AttachmentQueueData(
    attachmentId: attachmentId ?? this.attachmentId,
    userId: userId ?? this.userId,
    filePath: filePath ?? this.filePath,
    remoteStoragePath: remoteStoragePath ?? this.remoteStoragePath,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentQueueData copyWithCompanion(AttachmentQueueCompanion data) {
    return AttachmentQueueData(
      attachmentId: data.attachmentId.present
          ? data.attachmentId.value
          : this.attachmentId,
      userId: data.userId.present ? data.userId.value : this.userId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      remoteStoragePath: data.remoteStoragePath.present
          ? data.remoteStoragePath.value
          : this.remoteStoragePath,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentQueueData(')
          ..write('attachmentId: $attachmentId, ')
          ..write('userId: $userId, ')
          ..write('filePath: $filePath, ')
          ..write('remoteStoragePath: $remoteStoragePath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attachmentId,
    userId,
    filePath,
    remoteStoragePath,
    status,
    retryCount,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentQueueData &&
          other.attachmentId == this.attachmentId &&
          other.userId == this.userId &&
          other.filePath == this.filePath &&
          other.remoteStoragePath == this.remoteStoragePath &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.createdAt == this.createdAt);
}

class AttachmentQueueCompanion extends UpdateCompanion<AttachmentQueueData> {
  final Value<String> attachmentId;
  final Value<String> userId;
  final Value<String> filePath;
  final Value<String> remoteStoragePath;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentQueueCompanion({
    this.attachmentId = const Value.absent(),
    this.userId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.remoteStoragePath = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentQueueCompanion.insert({
    required String attachmentId,
    required String userId,
    required String filePath,
    required String remoteStoragePath,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : attachmentId = Value(attachmentId),
       userId = Value(userId),
       filePath = Value(filePath),
       remoteStoragePath = Value(remoteStoragePath);
  static Insertable<AttachmentQueueData> custom({
    Expression<String>? attachmentId,
    Expression<String>? userId,
    Expression<String>? filePath,
    Expression<String>? remoteStoragePath,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attachmentId != null) 'id': attachmentId,
      if (userId != null) 'user_id': userId,
      if (filePath != null) 'file_path': filePath,
      if (remoteStoragePath != null) 'remote_storage_path': remoteStoragePath,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentQueueCompanion copyWith({
    Value<String>? attachmentId,
    Value<String>? userId,
    Value<String>? filePath,
    Value<String>? remoteStoragePath,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentQueueCompanion(
      attachmentId: attachmentId ?? this.attachmentId,
      userId: userId ?? this.userId,
      filePath: filePath ?? this.filePath,
      remoteStoragePath: remoteStoragePath ?? this.remoteStoragePath,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attachmentId.present) {
      map['id'] = Variable<String>(attachmentId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (remoteStoragePath.present) {
      map['remote_storage_path'] = Variable<String>(remoteStoragePath.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
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
    return (StringBuffer('AttachmentQueueCompanion(')
          ..write('attachmentId: $attachmentId, ')
          ..write('userId: $userId, ')
          ..write('filePath: $filePath, ')
          ..write('remoteStoragePath: $remoteStoragePath, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GlobalCampaignsTable extends GlobalCampaigns
    with TableInfo<$GlobalCampaignsTable, GlobalCampaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalCampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stationBrandMeta = const VerificationMeta(
    'stationBrand',
  );
  @override
  late final GeneratedColumn<String> stationBrand = GeneratedColumn<String>(
    'station_brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTxCountMeta = const VerificationMeta(
    'targetTxCount',
  );
  @override
  late final GeneratedColumn<int> targetTxCount = GeneratedColumn<int>(
    'target_tx_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (target_tx_count > 0)',
  );
  static const VerificationMeta _minTxAmountMeta = const VerificationMeta(
    'minTxAmount',
  );
  @override
  late final GeneratedColumn<double> minTxAmount = GeneratedColumn<double>(
    'min_tx_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (min_tx_amount >= 0)',
  );
  static const VerificationMeta _rewardAmountMeta = const VerificationMeta(
    'rewardAmount',
  );
  @override
  late final GeneratedColumn<double> rewardAmount = GeneratedColumn<double>(
    'reward_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (reward_amount > 0)',
  );
  static const VerificationMeta _isDifferentDaysRequiredMeta =
      const VerificationMeta('isDifferentDaysRequired');
  @override
  late final GeneratedColumn<bool> isDifferentDaysRequired =
      GeneratedColumn<bool>(
        'is_different_days_required',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_different_days_required" IN (0, 1))',
        ),
        defaultValue: const Constant(true),
      );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<DateTime> expiryDate = GeneratedColumn<DateTime>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    campaignId,
    bankName,
    stationBrand,
    targetTxCount,
    minTxAmount,
    rewardAmount,
    isDifferentDaysRequired,
    expiryDate,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'global_campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlobalCampaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['id']!, _campaignIdMeta),
      );
    } else if (isInserting) {
      context.missing(_campaignIdMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('station_brand')) {
      context.handle(
        _stationBrandMeta,
        stationBrand.isAcceptableOrUnknown(
          data['station_brand']!,
          _stationBrandMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stationBrandMeta);
    }
    if (data.containsKey('target_tx_count')) {
      context.handle(
        _targetTxCountMeta,
        targetTxCount.isAcceptableOrUnknown(
          data['target_tx_count']!,
          _targetTxCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTxCountMeta);
    }
    if (data.containsKey('min_tx_amount')) {
      context.handle(
        _minTxAmountMeta,
        minTxAmount.isAcceptableOrUnknown(
          data['min_tx_amount']!,
          _minTxAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minTxAmountMeta);
    }
    if (data.containsKey('reward_amount')) {
      context.handle(
        _rewardAmountMeta,
        rewardAmount.isAcceptableOrUnknown(
          data['reward_amount']!,
          _rewardAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rewardAmountMeta);
    }
    if (data.containsKey('is_different_days_required')) {
      context.handle(
        _isDifferentDaysRequiredMeta,
        isDifferentDaysRequired.isAcceptableOrUnknown(
          data['is_different_days_required']!,
          _isDifferentDaysRequiredMeta,
        ),
      );
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {campaignId};
  @override
  GlobalCampaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalCampaign(
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      stationBrand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}station_brand'],
      )!,
      targetTxCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_tx_count'],
      )!,
      minTxAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_tx_amount'],
      )!,
      rewardAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reward_amount'],
      )!,
      isDifferentDaysRequired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_different_days_required'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expiry_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $GlobalCampaignsTable createAlias(String alias) {
    return $GlobalCampaignsTable(attachedDatabase, alias);
  }
}

class GlobalCampaign extends DataClass implements Insertable<GlobalCampaign> {
  final String campaignId;
  final String bankName;
  final String stationBrand;
  final int targetTxCount;
  final double minTxAmount;
  final double rewardAmount;
  final bool isDifferentDaysRequired;
  final DateTime expiryDate;
  final bool isActive;
  const GlobalCampaign({
    required this.campaignId,
    required this.bankName,
    required this.stationBrand,
    required this.targetTxCount,
    required this.minTxAmount,
    required this.rewardAmount,
    required this.isDifferentDaysRequired,
    required this.expiryDate,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(campaignId);
    map['bank_name'] = Variable<String>(bankName);
    map['station_brand'] = Variable<String>(stationBrand);
    map['target_tx_count'] = Variable<int>(targetTxCount);
    map['min_tx_amount'] = Variable<double>(minTxAmount);
    map['reward_amount'] = Variable<double>(rewardAmount);
    map['is_different_days_required'] = Variable<bool>(isDifferentDaysRequired);
    map['expiry_date'] = Variable<DateTime>(expiryDate);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  GlobalCampaignsCompanion toCompanion(bool nullToAbsent) {
    return GlobalCampaignsCompanion(
      campaignId: Value(campaignId),
      bankName: Value(bankName),
      stationBrand: Value(stationBrand),
      targetTxCount: Value(targetTxCount),
      minTxAmount: Value(minTxAmount),
      rewardAmount: Value(rewardAmount),
      isDifferentDaysRequired: Value(isDifferentDaysRequired),
      expiryDate: Value(expiryDate),
      isActive: Value(isActive),
    );
  }

  factory GlobalCampaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalCampaign(
      campaignId: serializer.fromJson<String>(json['campaignId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      stationBrand: serializer.fromJson<String>(json['stationBrand']),
      targetTxCount: serializer.fromJson<int>(json['targetTxCount']),
      minTxAmount: serializer.fromJson<double>(json['minTxAmount']),
      rewardAmount: serializer.fromJson<double>(json['rewardAmount']),
      isDifferentDaysRequired: serializer.fromJson<bool>(
        json['isDifferentDaysRequired'],
      ),
      expiryDate: serializer.fromJson<DateTime>(json['expiryDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'campaignId': serializer.toJson<String>(campaignId),
      'bankName': serializer.toJson<String>(bankName),
      'stationBrand': serializer.toJson<String>(stationBrand),
      'targetTxCount': serializer.toJson<int>(targetTxCount),
      'minTxAmount': serializer.toJson<double>(minTxAmount),
      'rewardAmount': serializer.toJson<double>(rewardAmount),
      'isDifferentDaysRequired': serializer.toJson<bool>(
        isDifferentDaysRequired,
      ),
      'expiryDate': serializer.toJson<DateTime>(expiryDate),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  GlobalCampaign copyWith({
    String? campaignId,
    String? bankName,
    String? stationBrand,
    int? targetTxCount,
    double? minTxAmount,
    double? rewardAmount,
    bool? isDifferentDaysRequired,
    DateTime? expiryDate,
    bool? isActive,
  }) => GlobalCampaign(
    campaignId: campaignId ?? this.campaignId,
    bankName: bankName ?? this.bankName,
    stationBrand: stationBrand ?? this.stationBrand,
    targetTxCount: targetTxCount ?? this.targetTxCount,
    minTxAmount: minTxAmount ?? this.minTxAmount,
    rewardAmount: rewardAmount ?? this.rewardAmount,
    isDifferentDaysRequired:
        isDifferentDaysRequired ?? this.isDifferentDaysRequired,
    expiryDate: expiryDate ?? this.expiryDate,
    isActive: isActive ?? this.isActive,
  );
  GlobalCampaign copyWithCompanion(GlobalCampaignsCompanion data) {
    return GlobalCampaign(
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      stationBrand: data.stationBrand.present
          ? data.stationBrand.value
          : this.stationBrand,
      targetTxCount: data.targetTxCount.present
          ? data.targetTxCount.value
          : this.targetTxCount,
      minTxAmount: data.minTxAmount.present
          ? data.minTxAmount.value
          : this.minTxAmount,
      rewardAmount: data.rewardAmount.present
          ? data.rewardAmount.value
          : this.rewardAmount,
      isDifferentDaysRequired: data.isDifferentDaysRequired.present
          ? data.isDifferentDaysRequired.value
          : this.isDifferentDaysRequired,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalCampaign(')
          ..write('campaignId: $campaignId, ')
          ..write('bankName: $bankName, ')
          ..write('stationBrand: $stationBrand, ')
          ..write('targetTxCount: $targetTxCount, ')
          ..write('minTxAmount: $minTxAmount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('isDifferentDaysRequired: $isDifferentDaysRequired, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    campaignId,
    bankName,
    stationBrand,
    targetTxCount,
    minTxAmount,
    rewardAmount,
    isDifferentDaysRequired,
    expiryDate,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlobalCampaign &&
          other.campaignId == this.campaignId &&
          other.bankName == this.bankName &&
          other.stationBrand == this.stationBrand &&
          other.targetTxCount == this.targetTxCount &&
          other.minTxAmount == this.minTxAmount &&
          other.rewardAmount == this.rewardAmount &&
          other.isDifferentDaysRequired == this.isDifferentDaysRequired &&
          other.expiryDate == this.expiryDate &&
          other.isActive == this.isActive);
}

class GlobalCampaignsCompanion extends UpdateCompanion<GlobalCampaign> {
  final Value<String> campaignId;
  final Value<String> bankName;
  final Value<String> stationBrand;
  final Value<int> targetTxCount;
  final Value<double> minTxAmount;
  final Value<double> rewardAmount;
  final Value<bool> isDifferentDaysRequired;
  final Value<DateTime> expiryDate;
  final Value<bool> isActive;
  final Value<int> rowid;
  const GlobalCampaignsCompanion({
    this.campaignId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.stationBrand = const Value.absent(),
    this.targetTxCount = const Value.absent(),
    this.minTxAmount = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.isDifferentDaysRequired = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlobalCampaignsCompanion.insert({
    required String campaignId,
    required String bankName,
    required String stationBrand,
    required int targetTxCount,
    required double minTxAmount,
    required double rewardAmount,
    this.isDifferentDaysRequired = const Value.absent(),
    required DateTime expiryDate,
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : campaignId = Value(campaignId),
       bankName = Value(bankName),
       stationBrand = Value(stationBrand),
       targetTxCount = Value(targetTxCount),
       minTxAmount = Value(minTxAmount),
       rewardAmount = Value(rewardAmount),
       expiryDate = Value(expiryDate);
  static Insertable<GlobalCampaign> custom({
    Expression<String>? campaignId,
    Expression<String>? bankName,
    Expression<String>? stationBrand,
    Expression<int>? targetTxCount,
    Expression<double>? minTxAmount,
    Expression<double>? rewardAmount,
    Expression<bool>? isDifferentDaysRequired,
    Expression<DateTime>? expiryDate,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (campaignId != null) 'id': campaignId,
      if (bankName != null) 'bank_name': bankName,
      if (stationBrand != null) 'station_brand': stationBrand,
      if (targetTxCount != null) 'target_tx_count': targetTxCount,
      if (minTxAmount != null) 'min_tx_amount': minTxAmount,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (isDifferentDaysRequired != null)
        'is_different_days_required': isDifferentDaysRequired,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlobalCampaignsCompanion copyWith({
    Value<String>? campaignId,
    Value<String>? bankName,
    Value<String>? stationBrand,
    Value<int>? targetTxCount,
    Value<double>? minTxAmount,
    Value<double>? rewardAmount,
    Value<bool>? isDifferentDaysRequired,
    Value<DateTime>? expiryDate,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return GlobalCampaignsCompanion(
      campaignId: campaignId ?? this.campaignId,
      bankName: bankName ?? this.bankName,
      stationBrand: stationBrand ?? this.stationBrand,
      targetTxCount: targetTxCount ?? this.targetTxCount,
      minTxAmount: minTxAmount ?? this.minTxAmount,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      isDifferentDaysRequired:
          isDifferentDaysRequired ?? this.isDifferentDaysRequired,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (campaignId.present) {
      map['id'] = Variable<String>(campaignId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (stationBrand.present) {
      map['station_brand'] = Variable<String>(stationBrand.value);
    }
    if (targetTxCount.present) {
      map['target_tx_count'] = Variable<int>(targetTxCount.value);
    }
    if (minTxAmount.present) {
      map['min_tx_amount'] = Variable<double>(minTxAmount.value);
    }
    if (rewardAmount.present) {
      map['reward_amount'] = Variable<double>(rewardAmount.value);
    }
    if (isDifferentDaysRequired.present) {
      map['is_different_days_required'] = Variable<bool>(
        isDifferentDaysRequired.value,
      );
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<DateTime>(expiryDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlobalCampaignsCompanion(')
          ..write('campaignId: $campaignId, ')
          ..write('bankName: $bankName, ')
          ..write('stationBrand: $stationBrand, ')
          ..write('targetTxCount: $targetTxCount, ')
          ..write('minTxAmount: $minTxAmount, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('isDifferentDaysRequired: $isDifferentDaysRequired, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCardsTable extends UserCards
    with TableInfo<$UserCardsTable, UserCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardProgramMeta = const VerificationMeta(
    'cardProgram',
  );
  @override
  late final GeneratedColumn<String> cardProgram = GeneratedColumn<String>(
    'card_program',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cardId, userId, bankName, cardProgram];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('card_program')) {
      context.handle(
        _cardProgramMeta,
        cardProgram.isAcceptableOrUnknown(
          data['card_program']!,
          _cardProgramMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardProgramMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  UserCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCard(
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      )!,
      cardProgram: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}card_program'],
      )!,
    );
  }

  @override
  $UserCardsTable createAlias(String alias) {
    return $UserCardsTable(attachedDatabase, alias);
  }
}

class UserCard extends DataClass implements Insertable<UserCard> {
  final String cardId;
  final String userId;
  final String bankName;
  final String cardProgram;
  const UserCard({
    required this.cardId,
    required this.userId,
    required this.bankName,
    required this.cardProgram,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(cardId);
    map['user_id'] = Variable<String>(userId);
    map['bank_name'] = Variable<String>(bankName);
    map['card_program'] = Variable<String>(cardProgram);
    return map;
  }

  UserCardsCompanion toCompanion(bool nullToAbsent) {
    return UserCardsCompanion(
      cardId: Value(cardId),
      userId: Value(userId),
      bankName: Value(bankName),
      cardProgram: Value(cardProgram),
    );
  }

  factory UserCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCard(
      cardId: serializer.fromJson<String>(json['cardId']),
      userId: serializer.fromJson<String>(json['userId']),
      bankName: serializer.fromJson<String>(json['bankName']),
      cardProgram: serializer.fromJson<String>(json['cardProgram']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'userId': serializer.toJson<String>(userId),
      'bankName': serializer.toJson<String>(bankName),
      'cardProgram': serializer.toJson<String>(cardProgram),
    };
  }

  UserCard copyWith({
    String? cardId,
    String? userId,
    String? bankName,
    String? cardProgram,
  }) => UserCard(
    cardId: cardId ?? this.cardId,
    userId: userId ?? this.userId,
    bankName: bankName ?? this.bankName,
    cardProgram: cardProgram ?? this.cardProgram,
  );
  UserCard copyWithCompanion(UserCardsCompanion data) {
    return UserCard(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      userId: data.userId.present ? data.userId.value : this.userId,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      cardProgram: data.cardProgram.present
          ? data.cardProgram.value
          : this.cardProgram,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCard(')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('cardProgram: $cardProgram')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cardId, userId, bankName, cardProgram);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCard &&
          other.cardId == this.cardId &&
          other.userId == this.userId &&
          other.bankName == this.bankName &&
          other.cardProgram == this.cardProgram);
}

class UserCardsCompanion extends UpdateCompanion<UserCard> {
  final Value<String> cardId;
  final Value<String> userId;
  final Value<String> bankName;
  final Value<String> cardProgram;
  final Value<int> rowid;
  const UserCardsCompanion({
    this.cardId = const Value.absent(),
    this.userId = const Value.absent(),
    this.bankName = const Value.absent(),
    this.cardProgram = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCardsCompanion.insert({
    required String cardId,
    required String userId,
    required String bankName,
    required String cardProgram,
    this.rowid = const Value.absent(),
  }) : cardId = Value(cardId),
       userId = Value(userId),
       bankName = Value(bankName),
       cardProgram = Value(cardProgram);
  static Insertable<UserCard> custom({
    Expression<String>? cardId,
    Expression<String>? userId,
    Expression<String>? bankName,
    Expression<String>? cardProgram,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'id': cardId,
      if (userId != null) 'user_id': userId,
      if (bankName != null) 'bank_name': bankName,
      if (cardProgram != null) 'card_program': cardProgram,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCardsCompanion copyWith({
    Value<String>? cardId,
    Value<String>? userId,
    Value<String>? bankName,
    Value<String>? cardProgram,
    Value<int>? rowid,
  }) {
    return UserCardsCompanion(
      cardId: cardId ?? this.cardId,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      cardProgram: cardProgram ?? this.cardProgram,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['id'] = Variable<String>(cardId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (cardProgram.present) {
      map['card_program'] = Variable<String>(cardProgram.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCardsCompanion(')
          ..write('cardId: $cardId, ')
          ..write('userId: $userId, ')
          ..write('bankName: $bankName, ')
          ..write('cardProgram: $cardProgram, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $StationsTable stations = $StationsTable(this);
  late final $RefuelingsTable refuelings = $RefuelingsTable(this);
  late final $CardTransactionsTable cardTransactions = $CardTransactionsTable(
    this,
  );
  late final $CampaignsTable campaigns = $CampaignsTable(this);
  late final $ObdReadingsTable obdReadings = $ObdReadingsTable(this);
  late final $FuelPricesTable fuelPrices = $FuelPricesTable(this);
  late final $StatementUploadsTable statementUploads = $StatementUploadsTable(
    this,
  );
  late final $DestructiveOfflineQueueTable destructiveOfflineQueue =
      $DestructiveOfflineQueueTable(this);
  late final $AttachmentQueueTable attachmentQueue = $AttachmentQueueTable(
    this,
  );
  late final $GlobalCampaignsTable globalCampaigns = $GlobalCampaignsTable(
    this,
  );
  late final $UserCardsTable userCards = $UserCardsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    vehicles,
    stations,
    refuelings,
    cardTransactions,
    campaigns,
    obdReadings,
    fuelPrices,
    statementUploads,
    destructiveOfflineQueue,
    attachmentQueue,
    globalCampaigns,
    userCards,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String userId,
      Value<String?> email,
      Value<DateTime?> createdAt,
      Value<bool?> premiumStatus,
      Value<bool?> acceptedAllStatementTerms,
      Value<bool?> openBankingConnected,
      Value<String?> subscriptionStatus,
      Value<String?> fullName,
      Value<String?> tckn,
      Value<String?> phoneNumber,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> userId,
      Value<String?> email,
      Value<DateTime?> createdAt,
      Value<bool?> premiumStatus,
      Value<bool?> acceptedAllStatementTerms,
      Value<bool?> openBankingConnected,
      Value<String?> subscriptionStatus,
      Value<String?> fullName,
      Value<String?> tckn,
      Value<String?> phoneNumber,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get premiumStatus => $composableBuilder(
    column: $table.premiumStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acceptedAllStatementTerms => $composableBuilder(
    column: $table.acceptedAllStatementTerms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get openBankingConnected => $composableBuilder(
    column: $table.openBankingConnected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subscriptionStatus => $composableBuilder(
    column: $table.subscriptionStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tckn => $composableBuilder(
    column: $table.tckn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get premiumStatus => $composableBuilder(
    column: $table.premiumStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acceptedAllStatementTerms => $composableBuilder(
    column: $table.acceptedAllStatementTerms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get openBankingConnected => $composableBuilder(
    column: $table.openBankingConnected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subscriptionStatus => $composableBuilder(
    column: $table.subscriptionStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tckn => $composableBuilder(
    column: $table.tckn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get premiumStatus => $composableBuilder(
    column: $table.premiumStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get acceptedAllStatementTerms => $composableBuilder(
    column: $table.acceptedAllStatementTerms,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get openBankingConnected => $composableBuilder(
    column: $table.openBankingConnected,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subscriptionStatus => $composableBuilder(
    column: $table.subscriptionStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get tckn =>
      $composableBuilder(column: $table.tckn, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
    column: $table.phoneNumber,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool?> premiumStatus = const Value.absent(),
                Value<bool?> acceptedAllStatementTerms = const Value.absent(),
                Value<bool?> openBankingConnected = const Value.absent(),
                Value<String?> subscriptionStatus = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> tckn = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                userId: userId,
                email: email,
                createdAt: createdAt,
                premiumStatus: premiumStatus,
                acceptedAllStatementTerms: acceptedAllStatementTerms,
                openBankingConnected: openBankingConnected,
                subscriptionStatus: subscriptionStatus,
                fullName: fullName,
                tckn: tckn,
                phoneNumber: phoneNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String?> email = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<bool?> premiumStatus = const Value.absent(),
                Value<bool?> acceptedAllStatementTerms = const Value.absent(),
                Value<bool?> openBankingConnected = const Value.absent(),
                Value<String?> subscriptionStatus = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String?> tckn = const Value.absent(),
                Value<String?> phoneNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                userId: userId,
                email: email,
                createdAt: createdAt,
                premiumStatus: premiumStatus,
                acceptedAllStatementTerms: acceptedAllStatementTerms,
                openBankingConnected: openBankingConnected,
                subscriptionStatus: subscriptionStatus,
                fullName: fullName,
                tckn: tckn,
                phoneNumber: phoneNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      required String vehicleId,
      required String userId,
      required String plate,
      required String brand,
      required String model,
      required String fuelType,
      required int initialOdometer,
      required int currentOdometer,
      Value<int> rowid,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<String> vehicleId,
      Value<String> userId,
      Value<String> plate,
      Value<String> brand,
      Value<String> model,
      Value<String> fuelType,
      Value<int> initialOdometer,
      Value<int> currentOdometer,
      Value<int> rowid,
    });

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialOdometer => $composableBuilder(
    column: $table.initialOdometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plate => $composableBuilder(
    column: $table.plate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialOdometer => $composableBuilder(
    column: $table.initialOdometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get plate =>
      $composableBuilder(column: $table.plate, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<int> get initialOdometer => $composableBuilder(
    column: $table.initialOdometer,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentOdometer => $composableBuilder(
    column: $table.currentOdometer,
    builder: (column) => column,
  );
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
          Vehicle,
          PrefetchHooks Function()
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vehicleId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> plate = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<int> initialOdometer = const Value.absent(),
                Value<int> currentOdometer = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion(
                vehicleId: vehicleId,
                userId: userId,
                plate: plate,
                brand: brand,
                model: model,
                fuelType: fuelType,
                initialOdometer: initialOdometer,
                currentOdometer: currentOdometer,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vehicleId,
                required String userId,
                required String plate,
                required String brand,
                required String model,
                required String fuelType,
                required int initialOdometer,
                required int currentOdometer,
                Value<int> rowid = const Value.absent(),
              }) => VehiclesCompanion.insert(
                vehicleId: vehicleId,
                userId: userId,
                plate: plate,
                brand: brand,
                model: model,
                fuelType: fuelType,
                initialOdometer: initialOdometer,
                currentOdometer: currentOdometer,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
      Vehicle,
      PrefetchHooks Function()
    >;
typedef $$StationsTableCreateCompanionBuilder =
    StationsCompanion Function({
      required String stationId,
      required String brandName,
      required double latitude,
      required double longitude,
      required String city,
      required String district,
      Value<int> rowid,
    });
typedef $$StationsTableUpdateCompanionBuilder =
    StationsCompanion Function({
      Value<String> stationId,
      Value<String> brandName,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> city,
      Value<String> district,
      Value<int> rowid,
    });

class $$StationsTableFilterComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get district => $composableBuilder(
    column: $table.district,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => column);

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);
}

class $$StationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StationsTable,
          Station,
          $$StationsTableFilterComposer,
          $$StationsTableOrderingComposer,
          $$StationsTableAnnotationComposer,
          $$StationsTableCreateCompanionBuilder,
          $$StationsTableUpdateCompanionBuilder,
          (Station, BaseReferences<_$AppDatabase, $StationsTable, Station>),
          Station,
          PrefetchHooks Function()
        > {
  $$StationsTableTableManager(_$AppDatabase db, $StationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> stationId = const Value.absent(),
                Value<String> brandName = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<String> district = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion(
                stationId: stationId,
                brandName: brandName,
                latitude: latitude,
                longitude: longitude,
                city: city,
                district: district,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String stationId,
                required String brandName,
                required double latitude,
                required double longitude,
                required String city,
                required String district,
                Value<int> rowid = const Value.absent(),
              }) => StationsCompanion.insert(
                stationId: stationId,
                brandName: brandName,
                latitude: latitude,
                longitude: longitude,
                city: city,
                district: district,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StationsTable,
      Station,
      $$StationsTableFilterComposer,
      $$StationsTableOrderingComposer,
      $$StationsTableAnnotationComposer,
      $$StationsTableCreateCompanionBuilder,
      $$StationsTableUpdateCompanionBuilder,
      (Station, BaseReferences<_$AppDatabase, $StationsTable, Station>),
      Station,
      PrefetchHooks Function()
    >;
typedef $$RefuelingsTableCreateCompanionBuilder =
    RefuelingsCompanion Function({
      required String refuelingId,
      required String vehicleId,
      Value<String?> stationId,
      required double liters,
      required double unitPrice,
      required double totalPrice,
      required int odometer,
      Value<DateTime> purchaseDate,
      Value<bool> isFullTank,
      Value<String?> imagePath,
      Value<int> rowid,
    });
typedef $$RefuelingsTableUpdateCompanionBuilder =
    RefuelingsCompanion Function({
      Value<String> refuelingId,
      Value<String> vehicleId,
      Value<String?> stationId,
      Value<double> liters,
      Value<double> unitPrice,
      Value<double> totalPrice,
      Value<int> odometer,
      Value<DateTime> purchaseDate,
      Value<bool> isFullTank,
      Value<String?> imagePath,
      Value<int> rowid,
    });

class $$RefuelingsTableFilterComposer
    extends Composer<_$AppDatabase, $RefuelingsTable> {
  $$RefuelingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RefuelingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RefuelingsTable> {
  $$RefuelingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationId => $composableBuilder(
    column: $table.stationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RefuelingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RefuelingsTable> {
  $$RefuelingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get stationId =>
      $composableBuilder(column: $table.stationId, builder: (column) => column);

  GeneratedColumn<double> get liters =>
      $composableBuilder(column: $table.liters, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get totalPrice => $composableBuilder(
    column: $table.totalPrice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);
}

class $$RefuelingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RefuelingsTable,
          Refueling,
          $$RefuelingsTableFilterComposer,
          $$RefuelingsTableOrderingComposer,
          $$RefuelingsTableAnnotationComposer,
          $$RefuelingsTableCreateCompanionBuilder,
          $$RefuelingsTableUpdateCompanionBuilder,
          (
            Refueling,
            BaseReferences<_$AppDatabase, $RefuelingsTable, Refueling>,
          ),
          Refueling,
          PrefetchHooks Function()
        > {
  $$RefuelingsTableTableManager(_$AppDatabase db, $RefuelingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefuelingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefuelingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefuelingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> refuelingId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<String?> stationId = const Value.absent(),
                Value<double> liters = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<double> totalPrice = const Value.absent(),
                Value<int> odometer = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefuelingsCompanion(
                refuelingId: refuelingId,
                vehicleId: vehicleId,
                stationId: stationId,
                liters: liters,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                odometer: odometer,
                purchaseDate: purchaseDate,
                isFullTank: isFullTank,
                imagePath: imagePath,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String refuelingId,
                required String vehicleId,
                Value<String?> stationId = const Value.absent(),
                required double liters,
                required double unitPrice,
                required double totalPrice,
                required int odometer,
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefuelingsCompanion.insert(
                refuelingId: refuelingId,
                vehicleId: vehicleId,
                stationId: stationId,
                liters: liters,
                unitPrice: unitPrice,
                totalPrice: totalPrice,
                odometer: odometer,
                purchaseDate: purchaseDate,
                isFullTank: isFullTank,
                imagePath: imagePath,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RefuelingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RefuelingsTable,
      Refueling,
      $$RefuelingsTableFilterComposer,
      $$RefuelingsTableOrderingComposer,
      $$RefuelingsTableAnnotationComposer,
      $$RefuelingsTableCreateCompanionBuilder,
      $$RefuelingsTableUpdateCompanionBuilder,
      (Refueling, BaseReferences<_$AppDatabase, $RefuelingsTable, Refueling>),
      Refueling,
      PrefetchHooks Function()
    >;
typedef $$CardTransactionsTableCreateCompanionBuilder =
    CardTransactionsCompanion Function({
      required String transactionId,
      required String userId,
      Value<String?> refuelingId,
      required DateTime transactionDate,
      required double amount,
      required String merchantName,
      required String source,
      Value<String?> cardNumberMask,
      Value<String?> bankTransactionCode,
      Value<String?> posTerminalDetails,
      Value<bool> scheduledPayment,
      Value<int> rowid,
    });
typedef $$CardTransactionsTableUpdateCompanionBuilder =
    CardTransactionsCompanion Function({
      Value<String> transactionId,
      Value<String> userId,
      Value<String?> refuelingId,
      Value<DateTime> transactionDate,
      Value<double> amount,
      Value<String> merchantName,
      Value<String> source,
      Value<String?> cardNumberMask,
      Value<String?> bankTransactionCode,
      Value<String?> posTerminalDetails,
      Value<bool> scheduledPayment,
      Value<int> rowid,
    });

class $$CardTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardNumberMask => $composableBuilder(
    column: $table.cardNumberMask,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankTransactionCode => $composableBuilder(
    column: $table.bankTransactionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posTerminalDetails => $composableBuilder(
    column: $table.posTerminalDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scheduledPayment => $composableBuilder(
    column: $table.scheduledPayment,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardNumberMask => $composableBuilder(
    column: $table.cardNumberMask,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankTransactionCode => $composableBuilder(
    column: $table.bankTransactionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posTerminalDetails => $composableBuilder(
    column: $table.posTerminalDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scheduledPayment => $composableBuilder(
    column: $table.scheduledPayment,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardTransactionsTable> {
  $$CardTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get refuelingId => $composableBuilder(
    column: $table.refuelingId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get cardNumberMask => $composableBuilder(
    column: $table.cardNumberMask,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankTransactionCode => $composableBuilder(
    column: $table.bankTransactionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get posTerminalDetails => $composableBuilder(
    column: $table.posTerminalDetails,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get scheduledPayment => $composableBuilder(
    column: $table.scheduledPayment,
    builder: (column) => column,
  );
}

class $$CardTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardTransactionsTable,
          CardTransaction,
          $$CardTransactionsTableFilterComposer,
          $$CardTransactionsTableOrderingComposer,
          $$CardTransactionsTableAnnotationComposer,
          $$CardTransactionsTableCreateCompanionBuilder,
          $$CardTransactionsTableUpdateCompanionBuilder,
          (
            CardTransaction,
            BaseReferences<
              _$AppDatabase,
              $CardTransactionsTable,
              CardTransaction
            >,
          ),
          CardTransaction,
          PrefetchHooks Function()
        > {
  $$CardTransactionsTableTableManager(
    _$AppDatabase db,
    $CardTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardTransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> transactionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> refuelingId = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> merchantName = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> cardNumberMask = const Value.absent(),
                Value<String?> bankTransactionCode = const Value.absent(),
                Value<String?> posTerminalDetails = const Value.absent(),
                Value<bool> scheduledPayment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTransactionsCompanion(
                transactionId: transactionId,
                userId: userId,
                refuelingId: refuelingId,
                transactionDate: transactionDate,
                amount: amount,
                merchantName: merchantName,
                source: source,
                cardNumberMask: cardNumberMask,
                bankTransactionCode: bankTransactionCode,
                posTerminalDetails: posTerminalDetails,
                scheduledPayment: scheduledPayment,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String transactionId,
                required String userId,
                Value<String?> refuelingId = const Value.absent(),
                required DateTime transactionDate,
                required double amount,
                required String merchantName,
                required String source,
                Value<String?> cardNumberMask = const Value.absent(),
                Value<String?> bankTransactionCode = const Value.absent(),
                Value<String?> posTerminalDetails = const Value.absent(),
                Value<bool> scheduledPayment = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CardTransactionsCompanion.insert(
                transactionId: transactionId,
                userId: userId,
                refuelingId: refuelingId,
                transactionDate: transactionDate,
                amount: amount,
                merchantName: merchantName,
                source: source,
                cardNumberMask: cardNumberMask,
                bankTransactionCode: bankTransactionCode,
                posTerminalDetails: posTerminalDetails,
                scheduledPayment: scheduledPayment,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardTransactionsTable,
      CardTransaction,
      $$CardTransactionsTableFilterComposer,
      $$CardTransactionsTableOrderingComposer,
      $$CardTransactionsTableAnnotationComposer,
      $$CardTransactionsTableCreateCompanionBuilder,
      $$CardTransactionsTableUpdateCompanionBuilder,
      (
        CardTransaction,
        BaseReferences<_$AppDatabase, $CardTransactionsTable, CardTransaction>,
      ),
      CardTransaction,
      PrefetchHooks Function()
    >;
typedef $$CampaignsTableCreateCompanionBuilder =
    CampaignsCompanion Function({
      required String campaignId,
      required String userId,
      required String bankName,
      required String stationBrand,
      required int targetTxCount,
      Value<int> currentTxCount,
      required double rewardAmount,
      required DateTime expiryDate,
      Value<int> rowid,
    });
typedef $$CampaignsTableUpdateCompanionBuilder =
    CampaignsCompanion Function({
      Value<String> campaignId,
      Value<String> userId,
      Value<String> bankName,
      Value<String> stationBrand,
      Value<int> targetTxCount,
      Value<int> currentTxCount,
      Value<double> rewardAmount,
      Value<DateTime> expiryDate,
      Value<int> rowid,
    });

class $$CampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentTxCount => $composableBuilder(
    column: $table.currentTxCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentTxCount => $composableBuilder(
    column: $table.currentTxCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CampaignsTable> {
  $$CampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentTxCount => $composableBuilder(
    column: $table.currentTxCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );
}

class $$CampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CampaignsTable,
          Campaign,
          $$CampaignsTableFilterComposer,
          $$CampaignsTableOrderingComposer,
          $$CampaignsTableAnnotationComposer,
          $$CampaignsTableCreateCompanionBuilder,
          $$CampaignsTableUpdateCompanionBuilder,
          (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
          Campaign,
          PrefetchHooks Function()
        > {
  $$CampaignsTableTableManager(_$AppDatabase db, $CampaignsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> campaignId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> stationBrand = const Value.absent(),
                Value<int> targetTxCount = const Value.absent(),
                Value<int> currentTxCount = const Value.absent(),
                Value<double> rewardAmount = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion(
                campaignId: campaignId,
                userId: userId,
                bankName: bankName,
                stationBrand: stationBrand,
                targetTxCount: targetTxCount,
                currentTxCount: currentTxCount,
                rewardAmount: rewardAmount,
                expiryDate: expiryDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String campaignId,
                required String userId,
                required String bankName,
                required String stationBrand,
                required int targetTxCount,
                Value<int> currentTxCount = const Value.absent(),
                required double rewardAmount,
                required DateTime expiryDate,
                Value<int> rowid = const Value.absent(),
              }) => CampaignsCompanion.insert(
                campaignId: campaignId,
                userId: userId,
                bankName: bankName,
                stationBrand: stationBrand,
                targetTxCount: targetTxCount,
                currentTxCount: currentTxCount,
                rewardAmount: rewardAmount,
                expiryDate: expiryDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CampaignsTable,
      Campaign,
      $$CampaignsTableFilterComposer,
      $$CampaignsTableOrderingComposer,
      $$CampaignsTableAnnotationComposer,
      $$CampaignsTableCreateCompanionBuilder,
      $$CampaignsTableUpdateCompanionBuilder,
      (Campaign, BaseReferences<_$AppDatabase, $CampaignsTable, Campaign>),
      Campaign,
      PrefetchHooks Function()
    >;
typedef $$ObdReadingsTableCreateCompanionBuilder =
    ObdReadingsCompanion Function({
      required String readingId,
      required String vehicleId,
      required int odometerValue,
      required double fuelLevelRatio,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });
typedef $$ObdReadingsTableUpdateCompanionBuilder =
    ObdReadingsCompanion Function({
      Value<String> readingId,
      Value<String> vehicleId,
      Value<int> odometerValue,
      Value<double> fuelLevelRatio,
      Value<DateTime> recordedAt,
      Value<int> rowid,
    });

class $$ObdReadingsTableFilterComposer
    extends Composer<_$AppDatabase, $ObdReadingsTable> {
  $$ObdReadingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get readingId => $composableBuilder(
    column: $table.readingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerValue => $composableBuilder(
    column: $table.odometerValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelLevelRatio => $composableBuilder(
    column: $table.fuelLevelRatio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ObdReadingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObdReadingsTable> {
  $$ObdReadingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get readingId => $composableBuilder(
    column: $table.readingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerValue => $composableBuilder(
    column: $table.odometerValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelLevelRatio => $composableBuilder(
    column: $table.fuelLevelRatio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ObdReadingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObdReadingsTable> {
  $$ObdReadingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get readingId =>
      $composableBuilder(column: $table.readingId, builder: (column) => column);

  GeneratedColumn<String> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<int> get odometerValue => $composableBuilder(
    column: $table.odometerValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fuelLevelRatio => $composableBuilder(
    column: $table.fuelLevelRatio,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );
}

class $$ObdReadingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObdReadingsTable,
          ObdReading,
          $$ObdReadingsTableFilterComposer,
          $$ObdReadingsTableOrderingComposer,
          $$ObdReadingsTableAnnotationComposer,
          $$ObdReadingsTableCreateCompanionBuilder,
          $$ObdReadingsTableUpdateCompanionBuilder,
          (
            ObdReading,
            BaseReferences<_$AppDatabase, $ObdReadingsTable, ObdReading>,
          ),
          ObdReading,
          PrefetchHooks Function()
        > {
  $$ObdReadingsTableTableManager(_$AppDatabase db, $ObdReadingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObdReadingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObdReadingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObdReadingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> readingId = const Value.absent(),
                Value<String> vehicleId = const Value.absent(),
                Value<int> odometerValue = const Value.absent(),
                Value<double> fuelLevelRatio = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObdReadingsCompanion(
                readingId: readingId,
                vehicleId: vehicleId,
                odometerValue: odometerValue,
                fuelLevelRatio: fuelLevelRatio,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String readingId,
                required String vehicleId,
                required int odometerValue,
                required double fuelLevelRatio,
                Value<DateTime> recordedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ObdReadingsCompanion.insert(
                readingId: readingId,
                vehicleId: vehicleId,
                odometerValue: odometerValue,
                fuelLevelRatio: fuelLevelRatio,
                recordedAt: recordedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ObdReadingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObdReadingsTable,
      ObdReading,
      $$ObdReadingsTableFilterComposer,
      $$ObdReadingsTableOrderingComposer,
      $$ObdReadingsTableAnnotationComposer,
      $$ObdReadingsTableCreateCompanionBuilder,
      $$ObdReadingsTableUpdateCompanionBuilder,
      (
        ObdReading,
        BaseReferences<_$AppDatabase, $ObdReadingsTable, ObdReading>,
      ),
      ObdReading,
      PrefetchHooks Function()
    >;
typedef $$FuelPricesTableCreateCompanionBuilder =
    FuelPricesCompanion Function({
      required String provinceCode,
      required String fuelType,
      required DateTime priceDate,
      required double price,
    });
typedef $$FuelPricesTableUpdateCompanionBuilder =
    FuelPricesCompanion Function({
      Value<String> provinceCode,
      Value<String> fuelType,
      Value<DateTime> priceDate,
      Value<double> price,
    });

class $$FuelPricesTableFilterComposer
    extends Composer<_$AppDatabase, $FuelPricesTable> {
  $$FuelPricesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get priceDate => $composableBuilder(
    column: $table.priceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FuelPricesTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelPricesTable> {
  $$FuelPricesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuelType => $composableBuilder(
    column: $table.fuelType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get priceDate => $composableBuilder(
    column: $table.priceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FuelPricesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelPricesTable> {
  $$FuelPricesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get provinceCode => $composableBuilder(
    column: $table.provinceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuelType =>
      $composableBuilder(column: $table.fuelType, builder: (column) => column);

  GeneratedColumn<DateTime> get priceDate =>
      $composableBuilder(column: $table.priceDate, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);
}

class $$FuelPricesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelPricesTable,
          FuelPrice,
          $$FuelPricesTableFilterComposer,
          $$FuelPricesTableOrderingComposer,
          $$FuelPricesTableAnnotationComposer,
          $$FuelPricesTableCreateCompanionBuilder,
          $$FuelPricesTableUpdateCompanionBuilder,
          (
            FuelPrice,
            BaseReferences<_$AppDatabase, $FuelPricesTable, FuelPrice>,
          ),
          FuelPrice,
          PrefetchHooks Function()
        > {
  $$FuelPricesTableTableManager(_$AppDatabase db, $FuelPricesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelPricesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelPricesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelPricesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> provinceCode = const Value.absent(),
                Value<String> fuelType = const Value.absent(),
                Value<DateTime> priceDate = const Value.absent(),
                Value<double> price = const Value.absent(),
              }) => FuelPricesCompanion(
                provinceCode: provinceCode,
                fuelType: fuelType,
                priceDate: priceDate,
                price: price,
              ),
          createCompanionCallback:
              ({
                required String provinceCode,
                required String fuelType,
                required DateTime priceDate,
                required double price,
              }) => FuelPricesCompanion.insert(
                provinceCode: provinceCode,
                fuelType: fuelType,
                priceDate: priceDate,
                price: price,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FuelPricesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelPricesTable,
      FuelPrice,
      $$FuelPricesTableFilterComposer,
      $$FuelPricesTableOrderingComposer,
      $$FuelPricesTableAnnotationComposer,
      $$FuelPricesTableCreateCompanionBuilder,
      $$FuelPricesTableUpdateCompanionBuilder,
      (FuelPrice, BaseReferences<_$AppDatabase, $FuelPricesTable, FuelPrice>),
      FuelPrice,
      PrefetchHooks Function()
    >;
typedef $$StatementUploadsTableCreateCompanionBuilder =
    StatementUploadsCompanion Function({
      Value<int> id,
      required String fileName,
      required String filePath,
      Value<DateTime> uploadDate,
      Value<bool> acceptedAllTerms,
    });
typedef $$StatementUploadsTableUpdateCompanionBuilder =
    StatementUploadsCompanion Function({
      Value<int> id,
      Value<String> fileName,
      Value<String> filePath,
      Value<DateTime> uploadDate,
      Value<bool> acceptedAllTerms,
    });

class $$StatementUploadsTableFilterComposer
    extends Composer<_$AppDatabase, $StatementUploadsTable> {
  $$StatementUploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get acceptedAllTerms => $composableBuilder(
    column: $table.acceptedAllTerms,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatementUploadsTableOrderingComposer
    extends Composer<_$AppDatabase, $StatementUploadsTable> {
  $$StatementUploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get acceptedAllTerms => $composableBuilder(
    column: $table.acceptedAllTerms,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatementUploadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StatementUploadsTable> {
  $$StatementUploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get acceptedAllTerms => $composableBuilder(
    column: $table.acceptedAllTerms,
    builder: (column) => column,
  );
}

class $$StatementUploadsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StatementUploadsTable,
          StatementUpload,
          $$StatementUploadsTableFilterComposer,
          $$StatementUploadsTableOrderingComposer,
          $$StatementUploadsTableAnnotationComposer,
          $$StatementUploadsTableCreateCompanionBuilder,
          $$StatementUploadsTableUpdateCompanionBuilder,
          (
            StatementUpload,
            BaseReferences<
              _$AppDatabase,
              $StatementUploadsTable,
              StatementUpload
            >,
          ),
          StatementUpload,
          PrefetchHooks Function()
        > {
  $$StatementUploadsTableTableManager(
    _$AppDatabase db,
    $StatementUploadsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatementUploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatementUploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatementUploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> uploadDate = const Value.absent(),
                Value<bool> acceptedAllTerms = const Value.absent(),
              }) => StatementUploadsCompanion(
                id: id,
                fileName: fileName,
                filePath: filePath,
                uploadDate: uploadDate,
                acceptedAllTerms: acceptedAllTerms,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fileName,
                required String filePath,
                Value<DateTime> uploadDate = const Value.absent(),
                Value<bool> acceptedAllTerms = const Value.absent(),
              }) => StatementUploadsCompanion.insert(
                id: id,
                fileName: fileName,
                filePath: filePath,
                uploadDate: uploadDate,
                acceptedAllTerms: acceptedAllTerms,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatementUploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StatementUploadsTable,
      StatementUpload,
      $$StatementUploadsTableFilterComposer,
      $$StatementUploadsTableOrderingComposer,
      $$StatementUploadsTableAnnotationComposer,
      $$StatementUploadsTableCreateCompanionBuilder,
      $$StatementUploadsTableUpdateCompanionBuilder,
      (
        StatementUpload,
        BaseReferences<_$AppDatabase, $StatementUploadsTable, StatementUpload>,
      ),
      StatementUpload,
      PrefetchHooks Function()
    >;
typedef $$DestructiveOfflineQueueTableCreateCompanionBuilder =
    DestructiveOfflineQueueCompanion Function({
      required String queueId,
      required String userId,
      required String entityType,
      required String entityId,
      required String actionType,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$DestructiveOfflineQueueTableUpdateCompanionBuilder =
    DestructiveOfflineQueueCompanion Function({
      Value<String> queueId,
      Value<String> userId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> actionType,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$DestructiveOfflineQueueTableFilterComposer
    extends Composer<_$AppDatabase, $DestructiveOfflineQueueTable> {
  $$DestructiveOfflineQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get queueId => $composableBuilder(
    column: $table.queueId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DestructiveOfflineQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $DestructiveOfflineQueueTable> {
  $$DestructiveOfflineQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get queueId => $composableBuilder(
    column: $table.queueId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DestructiveOfflineQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $DestructiveOfflineQueueTable> {
  $$DestructiveOfflineQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get queueId =>
      $composableBuilder(column: $table.queueId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DestructiveOfflineQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DestructiveOfflineQueueTable,
          DestructiveOfflineQueueData,
          $$DestructiveOfflineQueueTableFilterComposer,
          $$DestructiveOfflineQueueTableOrderingComposer,
          $$DestructiveOfflineQueueTableAnnotationComposer,
          $$DestructiveOfflineQueueTableCreateCompanionBuilder,
          $$DestructiveOfflineQueueTableUpdateCompanionBuilder,
          (
            DestructiveOfflineQueueData,
            BaseReferences<
              _$AppDatabase,
              $DestructiveOfflineQueueTable,
              DestructiveOfflineQueueData
            >,
          ),
          DestructiveOfflineQueueData,
          PrefetchHooks Function()
        > {
  $$DestructiveOfflineQueueTableTableManager(
    _$AppDatabase db,
    $DestructiveOfflineQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DestructiveOfflineQueueTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DestructiveOfflineQueueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DestructiveOfflineQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> queueId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestructiveOfflineQueueCompanion(
                queueId: queueId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                actionType: actionType,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String queueId,
                required String userId,
                required String entityType,
                required String entityId,
                required String actionType,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DestructiveOfflineQueueCompanion.insert(
                queueId: queueId,
                userId: userId,
                entityType: entityType,
                entityId: entityId,
                actionType: actionType,
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

typedef $$DestructiveOfflineQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DestructiveOfflineQueueTable,
      DestructiveOfflineQueueData,
      $$DestructiveOfflineQueueTableFilterComposer,
      $$DestructiveOfflineQueueTableOrderingComposer,
      $$DestructiveOfflineQueueTableAnnotationComposer,
      $$DestructiveOfflineQueueTableCreateCompanionBuilder,
      $$DestructiveOfflineQueueTableUpdateCompanionBuilder,
      (
        DestructiveOfflineQueueData,
        BaseReferences<
          _$AppDatabase,
          $DestructiveOfflineQueueTable,
          DestructiveOfflineQueueData
        >,
      ),
      DestructiveOfflineQueueData,
      PrefetchHooks Function()
    >;
typedef $$AttachmentQueueTableCreateCompanionBuilder =
    AttachmentQueueCompanion Function({
      required String attachmentId,
      required String userId,
      required String filePath,
      required String remoteStoragePath,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentQueueTableUpdateCompanionBuilder =
    AttachmentQueueCompanion Function({
      Value<String> attachmentId,
      Value<String> userId,
      Value<String> filePath,
      Value<String> remoteStoragePath,
      Value<String> status,
      Value<int> retryCount,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentQueueTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteStoragePath => $composableBuilder(
    column: $table.remoteStoragePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteStoragePath => $composableBuilder(
    column: $table.remoteStoragePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentQueueTable> {
  $$AttachmentQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attachmentId => $composableBuilder(
    column: $table.attachmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get remoteStoragePath => $composableBuilder(
    column: $table.remoteStoragePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentQueueTable,
          AttachmentQueueData,
          $$AttachmentQueueTableFilterComposer,
          $$AttachmentQueueTableOrderingComposer,
          $$AttachmentQueueTableAnnotationComposer,
          $$AttachmentQueueTableCreateCompanionBuilder,
          $$AttachmentQueueTableUpdateCompanionBuilder,
          (
            AttachmentQueueData,
            BaseReferences<
              _$AppDatabase,
              $AttachmentQueueTable,
              AttachmentQueueData
            >,
          ),
          AttachmentQueueData,
          PrefetchHooks Function()
        > {
  $$AttachmentQueueTableTableManager(
    _$AppDatabase db,
    $AttachmentQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attachmentId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> remoteStoragePath = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentQueueCompanion(
                attachmentId: attachmentId,
                userId: userId,
                filePath: filePath,
                remoteStoragePath: remoteStoragePath,
                status: status,
                retryCount: retryCount,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attachmentId,
                required String userId,
                required String filePath,
                required String remoteStoragePath,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentQueueCompanion.insert(
                attachmentId: attachmentId,
                userId: userId,
                filePath: filePath,
                remoteStoragePath: remoteStoragePath,
                status: status,
                retryCount: retryCount,
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

typedef $$AttachmentQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentQueueTable,
      AttachmentQueueData,
      $$AttachmentQueueTableFilterComposer,
      $$AttachmentQueueTableOrderingComposer,
      $$AttachmentQueueTableAnnotationComposer,
      $$AttachmentQueueTableCreateCompanionBuilder,
      $$AttachmentQueueTableUpdateCompanionBuilder,
      (
        AttachmentQueueData,
        BaseReferences<
          _$AppDatabase,
          $AttachmentQueueTable,
          AttachmentQueueData
        >,
      ),
      AttachmentQueueData,
      PrefetchHooks Function()
    >;
typedef $$GlobalCampaignsTableCreateCompanionBuilder =
    GlobalCampaignsCompanion Function({
      required String campaignId,
      required String bankName,
      required String stationBrand,
      required int targetTxCount,
      required double minTxAmount,
      required double rewardAmount,
      Value<bool> isDifferentDaysRequired,
      required DateTime expiryDate,
      Value<bool> isActive,
      Value<int> rowid,
    });
typedef $$GlobalCampaignsTableUpdateCompanionBuilder =
    GlobalCampaignsCompanion Function({
      Value<String> campaignId,
      Value<String> bankName,
      Value<String> stationBrand,
      Value<int> targetTxCount,
      Value<double> minTxAmount,
      Value<double> rewardAmount,
      Value<bool> isDifferentDaysRequired,
      Value<DateTime> expiryDate,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$GlobalCampaignsTableFilterComposer
    extends Composer<_$AppDatabase, $GlobalCampaignsTable> {
  $$GlobalCampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minTxAmount => $composableBuilder(
    column: $table.minTxAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDifferentDaysRequired => $composableBuilder(
    column: $table.isDifferentDaysRequired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlobalCampaignsTableOrderingComposer
    extends Composer<_$AppDatabase, $GlobalCampaignsTable> {
  $$GlobalCampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minTxAmount => $composableBuilder(
    column: $table.minTxAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDifferentDaysRequired => $composableBuilder(
    column: $table.isDifferentDaysRequired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlobalCampaignsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlobalCampaignsTable> {
  $$GlobalCampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get stationBrand => $composableBuilder(
    column: $table.stationBrand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetTxCount => $composableBuilder(
    column: $table.targetTxCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minTxAmount => $composableBuilder(
    column: $table.minTxAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDifferentDaysRequired => $composableBuilder(
    column: $table.isDifferentDaysRequired,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$GlobalCampaignsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GlobalCampaignsTable,
          GlobalCampaign,
          $$GlobalCampaignsTableFilterComposer,
          $$GlobalCampaignsTableOrderingComposer,
          $$GlobalCampaignsTableAnnotationComposer,
          $$GlobalCampaignsTableCreateCompanionBuilder,
          $$GlobalCampaignsTableUpdateCompanionBuilder,
          (
            GlobalCampaign,
            BaseReferences<
              _$AppDatabase,
              $GlobalCampaignsTable,
              GlobalCampaign
            >,
          ),
          GlobalCampaign,
          PrefetchHooks Function()
        > {
  $$GlobalCampaignsTableTableManager(
    _$AppDatabase db,
    $GlobalCampaignsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlobalCampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlobalCampaignsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlobalCampaignsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> campaignId = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> stationBrand = const Value.absent(),
                Value<int> targetTxCount = const Value.absent(),
                Value<double> minTxAmount = const Value.absent(),
                Value<double> rewardAmount = const Value.absent(),
                Value<bool> isDifferentDaysRequired = const Value.absent(),
                Value<DateTime> expiryDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlobalCampaignsCompanion(
                campaignId: campaignId,
                bankName: bankName,
                stationBrand: stationBrand,
                targetTxCount: targetTxCount,
                minTxAmount: minTxAmount,
                rewardAmount: rewardAmount,
                isDifferentDaysRequired: isDifferentDaysRequired,
                expiryDate: expiryDate,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String campaignId,
                required String bankName,
                required String stationBrand,
                required int targetTxCount,
                required double minTxAmount,
                required double rewardAmount,
                Value<bool> isDifferentDaysRequired = const Value.absent(),
                required DateTime expiryDate,
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlobalCampaignsCompanion.insert(
                campaignId: campaignId,
                bankName: bankName,
                stationBrand: stationBrand,
                targetTxCount: targetTxCount,
                minTxAmount: minTxAmount,
                rewardAmount: rewardAmount,
                isDifferentDaysRequired: isDifferentDaysRequired,
                expiryDate: expiryDate,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlobalCampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GlobalCampaignsTable,
      GlobalCampaign,
      $$GlobalCampaignsTableFilterComposer,
      $$GlobalCampaignsTableOrderingComposer,
      $$GlobalCampaignsTableAnnotationComposer,
      $$GlobalCampaignsTableCreateCompanionBuilder,
      $$GlobalCampaignsTableUpdateCompanionBuilder,
      (
        GlobalCampaign,
        BaseReferences<_$AppDatabase, $GlobalCampaignsTable, GlobalCampaign>,
      ),
      GlobalCampaign,
      PrefetchHooks Function()
    >;
typedef $$UserCardsTableCreateCompanionBuilder =
    UserCardsCompanion Function({
      required String cardId,
      required String userId,
      required String bankName,
      required String cardProgram,
      Value<int> rowid,
    });
typedef $$UserCardsTableUpdateCompanionBuilder =
    UserCardsCompanion Function({
      Value<String> cardId,
      Value<String> userId,
      Value<String> bankName,
      Value<String> cardProgram,
      Value<int> rowid,
    });

class $$UserCardsTableFilterComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardProgram => $composableBuilder(
    column: $table.cardProgram,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardProgram => $composableBuilder(
    column: $table.cardProgram,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCardsTable> {
  $$UserCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get cardProgram => $composableBuilder(
    column: $table.cardProgram,
    builder: (column) => column,
  );
}

class $$UserCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserCardsTable,
          UserCard,
          $$UserCardsTableFilterComposer,
          $$UserCardsTableOrderingComposer,
          $$UserCardsTableAnnotationComposer,
          $$UserCardsTableCreateCompanionBuilder,
          $$UserCardsTableUpdateCompanionBuilder,
          (UserCard, BaseReferences<_$AppDatabase, $UserCardsTable, UserCard>),
          UserCard,
          PrefetchHooks Function()
        > {
  $$UserCardsTableTableManager(_$AppDatabase db, $UserCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cardId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> bankName = const Value.absent(),
                Value<String> cardProgram = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion(
                cardId: cardId,
                userId: userId,
                bankName: bankName,
                cardProgram: cardProgram,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cardId,
                required String userId,
                required String bankName,
                required String cardProgram,
                Value<int> rowid = const Value.absent(),
              }) => UserCardsCompanion.insert(
                cardId: cardId,
                userId: userId,
                bankName: bankName,
                cardProgram: cardProgram,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserCardsTable,
      UserCard,
      $$UserCardsTableFilterComposer,
      $$UserCardsTableOrderingComposer,
      $$UserCardsTableAnnotationComposer,
      $$UserCardsTableCreateCompanionBuilder,
      $$UserCardsTableUpdateCompanionBuilder,
      (UserCard, BaseReferences<_$AppDatabase, $UserCardsTable, UserCard>),
      UserCard,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$StationsTableTableManager get stations =>
      $$StationsTableTableManager(_db, _db.stations);
  $$RefuelingsTableTableManager get refuelings =>
      $$RefuelingsTableTableManager(_db, _db.refuelings);
  $$CardTransactionsTableTableManager get cardTransactions =>
      $$CardTransactionsTableTableManager(_db, _db.cardTransactions);
  $$CampaignsTableTableManager get campaigns =>
      $$CampaignsTableTableManager(_db, _db.campaigns);
  $$ObdReadingsTableTableManager get obdReadings =>
      $$ObdReadingsTableTableManager(_db, _db.obdReadings);
  $$FuelPricesTableTableManager get fuelPrices =>
      $$FuelPricesTableTableManager(_db, _db.fuelPrices);
  $$StatementUploadsTableTableManager get statementUploads =>
      $$StatementUploadsTableTableManager(_db, _db.statementUploads);
  $$DestructiveOfflineQueueTableTableManager get destructiveOfflineQueue =>
      $$DestructiveOfflineQueueTableTableManager(
        _db,
        _db.destructiveOfflineQueue,
      );
  $$AttachmentQueueTableTableManager get attachmentQueue =>
      $$AttachmentQueueTableTableManager(_db, _db.attachmentQueue);
  $$GlobalCampaignsTableTableManager get globalCampaigns =>
      $$GlobalCampaignsTableTableManager(_db, _db.globalCampaigns);
  $$UserCardsTableTableManager get userCards =>
      $$UserCardsTableTableManager(_db, _db.userCards);
}
