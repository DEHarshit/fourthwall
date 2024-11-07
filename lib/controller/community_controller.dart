import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/core/constants/constants.dart';
import 'package:socialwall/core/failure.dart';
import 'package:socialwall/core/providers/storage_providers.dart';
import 'package:socialwall/models/community.dart';
import 'package:socialwall/models/post_model.dart';
import 'package:socialwall/services/community_repository.dart';
import 'package:socialwall/core/utils.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserDepartments();
});

final communitiesProvider = StreamProvider((ref) {
  final communityController = ref.read(communityControllerProvider.notifier);
  return communityController.getDepartments();
});

final getCommunityPostsProvider = StreamProvider.family((ref, String name) {
  return ref.read(communityControllerProvider.notifier).getCommunityPosts(name);
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return CommunityController(
    communityRepository: communityRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required storageRepository})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? ''; //read user uid
    Community community = Community(
      id: name,
      name: name.replaceAll(RegExp(r"\s+"), "").toLowerCase(),
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      subjects: [],
      members: [uid],
      mods: [uid],
    );

    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Department created successfully!');
      Routemaster.of(context).pop();
    });
  }

  void joinDepartment(Community department, BuildContext context) async {
    final user = _ref.read(userProvider)!;

    Either<Failure, void> res;

    if (department.members.contains(user.uid)) {
      res =
          await _communityRepository.leaveDepartment(department.name, user.uid);
    } else {
      res =
          await _communityRepository.joinDepartment(department.name, user.uid);
    }
    res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => {
              if (department.members.contains(user.uid))
                {showSnackBar(context, 'Department left successfully!')}
              else
                {showSnackBar(context, 'Department joined successfully!')}
            });
  }

  Stream<List<Community>> getUserDepartments() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserDepartments(uid);
  }

  Stream<List<Community>> getDepartments() {
    return _communityRepository.getDepartments();
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editDepartment({
    required File? avatarFile,
    required File? bannerFile,
    required BuildContext context,
    required Community department,
  }) async {
    state = true;
    if (avatarFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'departments/avatar',
        id: department.name,
        file: avatarFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => department = department.copyWith(avatar: r),
      );
    }

    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
        path: 'departments/banner',
        id: department.name,
        file: bannerFile,
      );
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => department = department.copyWith(banner: r),
      );
    }

    final res = await _communityRepository.editDepartment(department);
    state = false;
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void addMods(
      String departmentName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.addMods(departmentName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }

  Stream<List<Post>> getCommunityPosts(String name) {
    return _communityRepository.getCommunityPosts(name);
  }

  void addCategoryToCommunity(
      String communityName, String category, BuildContext context) async {
    state = true;

    try {
      final communityStream = getCommunityByName(communityName);
      final community = await communityStream.first;
      community.subjects.add(category);
      final res =
          await _communityRepository.updateCommunity(community, category);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'Category added successfully!');
        },
      );

      state = false;
    } catch (e) {
      state = false;
      showSnackBar(context, 'Failed to add category: $e');
    }
  }

  Future<void> fetchSubjectsForCommunity(
      String communityName, BuildContext context) async {
    state = true;
    try {
      // Call repository to fetch the subjects
      final subjects =
          await _communityRepository.getSubjectsForCommunity(communityName);

      // Handle success, e.g., show subjects in the UI
      showSnackBar(context, 'Subjects fetched successfully: $subjects');

      state = false;
    } catch (e) {
      // Handle error
      showSnackBar(context, 'Failed to fetch subjects: $e');
      state = false;
    }
  }
}
