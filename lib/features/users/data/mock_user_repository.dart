import '../domain/user_entities.dart';

/// Stub implementation — replace with Dio/API calls once backend is ready.
class MockUserRepository implements UserRepository {
  static final _users = <AdminUser>[
    AdminUser(
      id: '1',
      email: 'superadmin@carecapital.in',
      name: 'Rajesh Kumar',
      mobile: '+91 98765 43210',
      role: AdminRole.superAdmin,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 1, 10),
      organizationId: 'org1',
      organizationName: 'Care & Capital HQ',
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AdminUser(
      id: '2',
      email: 'admin@carecapital.in',
      name: 'Priya Sharma',
      mobile: '+91 87654 32109',
      role: AdminRole.admin,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 2, 5),
      organizationId: 'org1',
      organizationName: 'Care & Capital HQ',
      lastLoginAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    AdminUser(
      id: '3',
      email: 'finance@cityhospital.in',
      name: 'Anil Mehta',
      role: AdminRole.financeReviewer,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 3, 12),
      organizationId: 'org2',
      organizationName: 'City Hospital Group',
      lastLoginAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    AdminUser(
      id: '4',
      email: 'data@carecapital.in',
      name: 'Sunita Patel',
      role: AdminRole.dataManager,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 3, 20),
      organizationId: 'org1',
      organizationName: 'Care & Capital HQ',
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AdminUser(
      id: '5',
      email: 'support@carecapital.in',
      name: 'Vikram Singh',
      role: AdminRole.supportOperator,
      status: AccountStatus.suspended,
      createdAt: DateTime(2024, 4, 1),
      organizationId: 'org1',
      organizationName: 'Care & Capital HQ',
      lastLoginAt: DateTime(2024, 5, 10),
    ),
    AdminUser(
      id: '6',
      email: 'auditor@regulator.gov.in',
      name: 'Meena Iyer',
      role: AdminRole.readOnlyAuditor,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 5, 15),
      lastLoginAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    AdminUser(
      id: '7',
      email: 'owner@apolloclinic.in',
      name: 'Dr. Suresh Nair',
      mobile: '+91 76543 21098',
      role: AdminRole.readOnlyAuditor,
      status: AccountStatus.pendingVerification,
      createdAt: DateTime(2024, 6, 1),
      organizationId: 'org3',
      organizationName: 'Apollo Clinic Pvt Ltd',
    ),
  ];

  static final _orgs = <Organization>[
    Organization(
      id: 'org1',
      name: 'Care & Capital HQ',
      type: OrgType.consultantFirm,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 1, 1),
      contactEmail: 'info@carecapital.in',
      contactMobile: '+91 98765 00000',
      city: 'Mumbai',
      state: 'Maharashtra',
      memberCount: 4,
      projectCount: 52,
    ),
    Organization(
      id: 'org2',
      name: 'City Hospital Group',
      type: OrgType.hospitalOwner,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 2, 14),
      contactEmail: 'admin@cityhospital.in',
      city: 'Pune',
      state: 'Maharashtra',
      memberCount: 2,
      projectCount: 8,
    ),
    Organization(
      id: 'org3',
      name: 'Apollo Clinic Pvt Ltd',
      type: OrgType.hospitalOwner,
      status: AccountStatus.active,
      createdAt: DateTime(2024, 3, 5),
      contactEmail: 'owner@apolloclinic.in',
      city: 'Bengaluru',
      state: 'Karnataka',
      memberCount: 1,
      projectCount: 3,
    ),
    Organization(
      id: 'org4',
      name: 'HealthScan Diagnostics',
      type: OrgType.diagnosticCentre,
      status: AccountStatus.suspended,
      createdAt: DateTime(2024, 4, 20),
      contactEmail: 'info@healthscan.in',
      city: 'Chennai',
      state: 'Tamil Nadu',
      memberCount: 0,
      projectCount: 1,
    ),
  ];

  @override
  Future<List<AdminUser>> getUsers({
    String? search,
    AdminRole? role,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var result = _users.where((u) {
      if (role != null && u.role != role) return false;
      if (status != null && u.status != status) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }
      return true;
    }).toList();
    final start = (page - 1) * pageSize;
    return result.skip(start).take(pageSize).toList();
  }

  @override
  Future<AdminUser> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _users.firstWhere((u) => u.id == id);
  }

  @override
  Future<void> updateUserRole(String id, AdminRole role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real impl: PATCH /api/admin/users/:id/role
  }

  @override
  Future<void> updateUserStatus(String id, AccountStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real impl: PATCH /api/admin/users/:id/status
  }

  @override
  Future<List<Organization>> getOrganizations({
    String? search,
    OrgType? type,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var result = _orgs.where((o) {
      if (type != null && o.type != type) return false;
      if (status != null && o.status != status) return false;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        return o.name.toLowerCase().contains(q) ||
            (o.contactEmail?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
    final start = (page - 1) * pageSize;
    return result.skip(start).take(pageSize).toList();
  }

  @override
  Future<Organization> getOrganizationById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _orgs.firstWhere((o) => o.id == id);
  }

  @override
  Future<List<AdminUser>> getOrganizationMembers(String orgId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _users.where((u) => u.organizationId == orgId).toList();
  }

  @override
  Future<void> updateOrganizationStatus(
      String orgId, AccountStatus status) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
