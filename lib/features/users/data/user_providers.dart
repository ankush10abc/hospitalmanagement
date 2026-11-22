import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/firestore_user_repository.dart';
import '../domain/user_entities.dart';

final userRepositoryProvider = Provider<UserRepository>(
  (_) => FirestoreUserRepository(),
);

// ── Users list ────────────────────────────────────────────────────────────────

class UsersFilter {
  const UsersFilter({this.search, this.role, this.status});
  final String? search;
  final AdminRole? role;
  final AccountStatus? status;

  UsersFilter copyWith({
    Object? search = _sentinel,
    Object? role = _sentinel,
    Object? status = _sentinel,
  }) =>
      UsersFilter(
        search: search == _sentinel ? this.search : search as String?,
        role: role == _sentinel ? this.role : role as AdminRole?,
        status: status == _sentinel ? this.status : status as AccountStatus?,
      );
}

const _sentinel = Object();

final usersFilterProvider = StateProvider((_) => const UsersFilter());

final usersProvider = FutureProvider.autoDispose<List<AdminUser>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  final filter = ref.watch(usersFilterProvider);
  return repo.getUsers(
    search: filter.search,
    role: filter.role,
    status: filter.status,
  );
});

final userDetailProvider =
    FutureProvider.autoDispose.family<AdminUser, String>((ref, id) {
  return ref.watch(userRepositoryProvider).getUserById(id);
});

// ── Organizations list ────────────────────────────────────────────────────────

class OrgsFilter {
  const OrgsFilter({this.search, this.type, this.status});
  final String? search;
  final OrgType? type;
  final AccountStatus? status;

  OrgsFilter copyWith({
    Object? search = _sentinel,
    Object? type = _sentinel,
    Object? status = _sentinel,
  }) =>
      OrgsFilter(
        search: search == _sentinel ? this.search : search as String?,
        type: type == _sentinel ? this.type : type as OrgType?,
        status: status == _sentinel ? this.status : status as AccountStatus?,
      );
}

final orgsFilterProvider = StateProvider((_) => const OrgsFilter());

final organizationsProvider =
    FutureProvider.autoDispose<List<Organization>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  final filter = ref.watch(orgsFilterProvider);
  return repo.getOrganizations(
    search: filter.search,
    type: filter.type,
    status: filter.status,
  );
});

final orgDetailProvider =
    FutureProvider.autoDispose.family<Organization, String>((ref, id) {
  return ref.watch(userRepositoryProvider).getOrganizationById(id);
});

final orgMembersProvider =
    FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, orgId) {
  return ref.watch(userRepositoryProvider).getOrganizationMembers(orgId);
});
