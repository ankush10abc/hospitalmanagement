// ── Enums ────────────────────────────────────────────────────────────────────

enum AdminRole {
  superAdmin,
  admin,
  financeReviewer,
  dataManager,
  supportOperator,
  readOnlyAuditor;

  String get label => switch (this) {
        superAdmin => 'Super Admin',
        admin => 'Admin',
        financeReviewer => 'Finance Reviewer',
        dataManager => 'Data Manager',
        supportOperator => 'Support Operator',
        readOnlyAuditor => 'Read-only Auditor',
      };

  static AdminRole fromString(String value) {
    return AdminRole.values.firstWhere(
      (r) => r.name == value ||
          r.label.toLowerCase() == value.toLowerCase() ||
          value.replaceAll(RegExp(r'[\s-]+'), '_').toLowerCase() == r.name.toLowerCase(),
      orElse: () => AdminRole.readOnlyAuditor,
    );
  }
}

enum AccountStatus { active, suspended, pendingVerification }

enum OrgType { hospitalOwner, consultantFirm, diagnosticCentre, other }

// ── Entities ─────────────────────────────────────────────────────────────────

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.mobile,
    this.organizationId,
    this.organizationName,
    this.lastLoginAt,
  });

  final String id;
  final String email;
  final String name;
  final String? mobile;
  final AdminRole role;
  final AccountStatus status;
  final DateTime createdAt;
  final String? organizationId;
  final String? organizationName;
  final DateTime? lastLoginAt;
}

class Organization {
  const Organization({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.createdAt,
    this.contactEmail,
    this.contactMobile,
    this.city,
    this.state,
    this.memberCount = 0,
    this.projectCount = 0,
  });

  final String id;
  final String name;
  final OrgType type;
  final AccountStatus status;
  final DateTime createdAt;
  final String? contactEmail;
  final String? contactMobile;
  final String? city;
  final String? state;
  final int memberCount;
  final int projectCount;
}

// ── Repository contract ───────────────────────────────────────────────────────

abstract interface class UserRepository {
  Future<List<AdminUser>> getUsers({
    String? search,
    AdminRole? role,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<AdminUser> getUserById(String id);

  Future<void> updateUserRole(String id, AdminRole role);

  Future<void> updateUserStatus(String id, AccountStatus status);

  Future<List<Organization>> getOrganizations({
    String? search,
    OrgType? type,
    AccountStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  Future<Organization> getOrganizationById(String id);

  Future<List<AdminUser>> getOrganizationMembers(String orgId);

  Future<void> updateOrganizationStatus(String orgId, AccountStatus status);
}
