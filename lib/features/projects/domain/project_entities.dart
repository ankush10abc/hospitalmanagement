enum ProjectStatus {
  draft,
  submitted,
  underReview,
  approved,
  completed;

  String get label => switch (this) {
        draft => 'Draft',
        submitted => 'Submitted',
        underReview => 'Under Review',
        approved => 'Approved',
        completed => 'Completed',
      };

  static ProjectStatus fromString(String s) => switch (s) {
        'submitted' => ProjectStatus.submitted,
        'underReview' => ProjectStatus.underReview,
        'approved' => ProjectStatus.approved,
        'completed' => ProjectStatus.completed,
        _ => ProjectStatus.draft,
      };
}

enum HospitalType {
  multispeciality,
  general,
  specialty,
  eye,
  dental,
  clinic,
  diagnostic,
  nursingHome,
  dayCare;

  String get label => switch (this) {
        multispeciality => 'Multispeciality Hospital',
        general => 'General Hospital',
        specialty => 'Specialty Hospital',
        eye => 'Eye Hospital',
        dental => 'Dental Clinic',
        clinic => 'General Clinic',
        diagnostic => 'Diagnostic Centre',
        nursingHome => 'Nursing Home',
        dayCare => 'Day Care Centre',
      };

  static HospitalType fromString(String s) => HospitalType.values.firstWhere(
        (t) => t.name == s,
        orElse: () => HospitalType.general,
      );
}

class HospitalProject {
  const HospitalProject({
    required this.id,
    required this.projectName,
    required this.hospitalName,
    required this.hospitalType,
    required this.status,
    required this.ownerName,
    required this.ownerEmail,
    required this.state,
    required this.city,
    required this.totalBeds,
    required this.createdAt,
    required this.createdBy,
    this.address,
    this.projectStartYear,
    this.organizationId,
    this.totalProjectCost,
    this.assumptionTemplateVersion,
    this.calculationRuleVersion,
    this.lastUpdatedAt,
    this.reviewComment,
  });

  final String id;
  final String projectName;
  final String hospitalName;
  final HospitalType hospitalType;
  final ProjectStatus status;
  final String ownerName;
  final String ownerEmail;
  final String state;
  final String city;
  final String? address;
  final int totalBeds;
  final int? projectStartYear;
  final String? organizationId;
  final double? totalProjectCost;
  final String? assumptionTemplateVersion;
  final String? calculationRuleVersion;
  final DateTime createdAt;
  final String createdBy;
  final DateTime? lastUpdatedAt;
  final String? reviewComment;
}

abstract interface class ProjectRepository {
  Future<List<HospitalProject>> getProjects({
    String? search,
    ProjectStatus? status,
    HospitalType? type,
    int page = 1,
    int pageSize = 20,
  });

  Future<HospitalProject> getProjectById(String id);

  Future<String> createProject(Map<String, dynamic> data);

  Future<void> updateProjectStatus(
      String id, ProjectStatus status, {String? comment});

  Stream<List<HospitalProject>> watchRecentProjects({int limit = 5});
}
