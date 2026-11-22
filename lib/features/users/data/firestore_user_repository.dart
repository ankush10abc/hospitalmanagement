import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/user_entities.dart';

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── Safe get: tries server first, falls back to cache, returns [] on error ─

  Future<QuerySnapshot<Map<String, dynamic>>> _safeGet(
    Query<Map<String, dynamic>> q,
  ) async {
    try {
      return await q.get(const GetOptions(source: Source.serverAndCache));
    } on FirebaseException {
      try {
        return await q.get(const GetOptions(source: Source.cache));
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _safeDocGet(
    DocumentReference<Map<String, dynamic>> ref,
  ) async {
    try {
      return await ref.get(const GetOptions(source: Source.serverAndCache));
    } on FirebaseException {
      return await ref.get(const GetOptions(source: Source.cache));
    }
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  @override
  Future<List<AdminUser>> getUsers({
    String? search,
    AdminRole? role,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _db.collection('users');
      if (role != null) q = q.where('role', isEqualTo: role.name);
      if (status != null) q = q.where('status', isEqualTo: status.name);
      q = q.orderBy('createdAt', descending: true).limit(pageSize);

      final snap = await _safeGet(q);
      var users = snap.docs.map(_docToUser).toList();

      if (search != null && search.isNotEmpty) {
        final q2 = search.toLowerCase();
        users = users
            .where((u) =>
                u.name.toLowerCase().contains(q2) ||
                u.email.toLowerCase().contains(q2))
            .toList();
      }
      return users;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return [];
      rethrow;
    }
  }

  @override
  Future<AdminUser> getUserById(String id) async {
    final doc = await _safeDocGet(_db.collection('users').doc(id));
    if (!doc.exists) throw Exception('User not found');
    return _docToUser(doc);
  }

  @override
  Future<void> updateUserRole(String id, AdminRole role) async {
    await _db.collection('users').doc(id).update({'role': role.name});
  }

  @override
  Future<void> updateUserStatus(String id, AccountStatus status) async {
    await _db.collection('users').doc(id).update({'status': status.name});
  }

  // ── Organizations ─────────────────────────────────────────────────────────

  @override
  Future<List<Organization>> getOrganizations({
    String? search,
    OrgType? type,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      Query<Map<String, dynamic>> q = _db.collection('organizations');
      if (type != null) q = q.where('type', isEqualTo: type.name);
      if (status != null) q = q.where('status', isEqualTo: status.name);
      q = q.orderBy('createdAt', descending: true).limit(pageSize);

      final snap = await _safeGet(q);
      var orgs = snap.docs.map(_docToOrg).toList();

      if (search != null && search.isNotEmpty) {
        final q2 = search.toLowerCase();
        orgs = orgs
            .where((o) =>
                o.name.toLowerCase().contains(q2) ||
                (o.contactEmail?.toLowerCase().contains(q2) ?? false))
            .toList();
      }
      return orgs;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return [];
      rethrow;
    }
  }

  @override
  Future<Organization> getOrganizationById(String id) async {
    final doc =
        await _safeDocGet(_db.collection('organizations').doc(id));
    if (!doc.exists) throw Exception('Organization not found');
    return _docToOrg(doc);
  }

  @override
  Future<List<AdminUser>> getOrganizationMembers(String orgId) async {
    try {
      final snap = await _safeGet(
        _db.collection('users').where('organizationId', isEqualTo: orgId),
      );
      return snap.docs.map(_docToUser).toList();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return [];
      rethrow;
    }
  }

  @override
  Future<void> updateOrganizationStatus(
      String orgId, AccountStatus status) async {
    await _db
        .collection('organizations')
        .doc(orgId)
        .update({'status': status.name});
  }

  // ── Mappers ───────────────────────────────────────────────────────────────

  AdminUser _docToUser(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return AdminUser(
      id: doc.id,
      email: d['email'] as String? ?? '',
      name: d['name'] as String? ?? '',
      mobile: d['mobile'] as String?,
      role: AdminRole.fromString(d['role'] as String? ?? 'read_only_auditor'),
      status: _statusFromString(d['status'] as String? ?? 'active'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      organizationId: d['organizationId'] as String?,
      organizationName: d['organizationName'] as String?,
      lastLoginAt: (d['lastLoginAt'] as Timestamp?)?.toDate(),
    );
  }

  Organization _docToOrg(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Organization(
      id: doc.id,
      name: d['name'] as String? ?? '',
      type: _orgTypeFromString(d['type'] as String? ?? 'other'),
      status: _statusFromString(d['status'] as String? ?? 'active'),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contactEmail: d['contactEmail'] as String?,
      contactMobile: d['contactMobile'] as String?,
      city: d['city'] as String?,
      state: d['state'] as String?,
      memberCount: (d['memberCount'] as num?)?.toInt() ?? 0,
      projectCount: (d['projectCount'] as num?)?.toInt() ?? 0,
    );
  }

  AccountStatus _statusFromString(String s) => switch (s) {
        'suspended' => AccountStatus.suspended,
        'pendingVerification' => AccountStatus.pendingVerification,
        _ => AccountStatus.active,
      };

  OrgType _orgTypeFromString(String s) => switch (s) {
        'hospitalOwner' => OrgType.hospitalOwner,
        'consultantFirm' => OrgType.consultantFirm,
        'diagnosticCentre' => OrgType.diagnosticCentre,
        _ => OrgType.other,
      };
}
