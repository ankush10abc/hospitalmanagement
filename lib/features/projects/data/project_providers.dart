import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_project_repository.dart';
import '../domain/project_entities.dart';

final projectRepositoryProvider = Provider<ProjectRepository>(
  (_) => FirestoreProjectRepository(),
);

class ProjectsFilter {
  const ProjectsFilter({this.search, this.status, this.type});
  final String? search;
  final ProjectStatus? status;
  final HospitalType? type;

  ProjectsFilter copyWith({
    Object? search = _s,
    Object? status = _s,
    Object? type = _s,
  }) =>
      ProjectsFilter(
        search: search == _s ? this.search : search as String?,
        status: status == _s ? this.status : status as ProjectStatus?,
        type: type == _s ? this.type : type as HospitalType?,
      );
}

const _s = Object();

final projectsFilterProvider =
    StateProvider((_) => const ProjectsFilter());

final projectsProvider =
    FutureProvider.autoDispose<List<HospitalProject>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  final f = ref.watch(projectsFilterProvider);
  return repo.getProjects(search: f.search, status: f.status, type: f.type);
});

final projectDetailProvider =
    FutureProvider.autoDispose.family<HospitalProject, String>((ref, id) {
  return ref.watch(projectRepositoryProvider).getProjectById(id);
});

final recentProjectsProvider =
    StreamProvider.autoDispose<List<HospitalProject>>((ref) {
  return ref.watch(projectRepositoryProvider).watchRecentProjects();
});
