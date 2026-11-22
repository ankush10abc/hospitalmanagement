import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/project_entities.dart';

class FirestoreProjectRepository implements ProjectRepository {
  FirestoreProjectRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('projects');

  @override
  Future<List<HospitalProject>> getProjects({
    String? search,
    ProjectStatus? status,
    HospitalType? type,
    int page = 1,
    int pageSize = 20,
  }) async {
    Query<Map<String, dynamic>> q = _col;
    if (status != null) q = q.where('status', isEqualTo: status.name);
    if (type != null) q = q.where('hospitalType', isEqualTo: type.name);
    q = q.orderBy('createdAt', descending: true).limit(pageSize);

    final snap = await q.get();
    var projects = snap.docs.map(_docToProject).toList();

    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      projects = projects
          .where((p) =>
              p.projectName.toLowerCase().contains(s) ||
              p.hospitalName.toLowerCase().contains(s) ||
              p.ownerName.toLowerCase().contains(s))
          .toList();
    }
    return projects;
  }

  @override
  Future<HospitalProject> getProjectById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) throw Exception('Project not found');
    return _docToProject(doc);
  }

  @override
  Future<String> createProject(Map<String, dynamic> data) async {
    data['createdAt'] = FieldValue.serverTimestamp();
    data['lastUpdatedAt'] = FieldValue.serverTimestamp();
    data['status'] = ProjectStatus.draft.name;
    final ref = await _col.add(data);
    return ref.id;
  }

  @override
  Future<void> updateProjectStatus(
    String id,
    ProjectStatus status, {
    String? comment,
  }) async {
    final update = <String, dynamic>{
      'status': status.name,
      'lastUpdatedAt': FieldValue.serverTimestamp(),
    };
    if (comment != null) update['reviewComment'] = comment;
    await _col.doc(id).update(update);
  }

  @override
  Stream<List<HospitalProject>> watchRecentProjects({int limit = 5}) {
    return _col
        .orderBy('lastUpdatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(_docToProject).toList());
  }

  HospitalProject _docToProject(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return HospitalProject(
      id: doc.id,
      projectName: d['projectName'] as String? ?? '',
      hospitalName: d['hospitalName'] as String? ?? '',
      hospitalType:
          HospitalType.fromString(d['hospitalType'] as String? ?? 'general'),
      status:
          ProjectStatus.fromString(d['status'] as String? ?? 'draft'),
      ownerName: d['ownerName'] as String? ?? '',
      ownerEmail: d['ownerEmail'] as String? ?? '',
      state: d['state'] as String? ?? '',
      city: d['city'] as String? ?? '',
      address: d['address'] as String?,
      totalBeds: (d['totalBeds'] as num?)?.toInt() ?? 0,
      projectStartYear: (d['projectStartYear'] as num?)?.toInt(),
      organizationId: d['organizationId'] as String?,
      totalProjectCost: (d['totalProjectCost'] as num?)?.toDouble(),
      assumptionTemplateVersion:
          d['assumptionTemplateVersion'] as String?,
      calculationRuleVersion: d['calculationRuleVersion'] as String?,
      createdAt:
          (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdBy: d['createdBy'] as String? ?? '',
      lastUpdatedAt: (d['lastUpdatedAt'] as Timestamp?)?.toDate(),
      reviewComment: d['reviewComment'] as String?,
    );
  }
}
