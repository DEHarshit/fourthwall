import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:socialwall/controller/auth_controller.dart';
import 'package:socialwall/core/providers/storage_providers.dart';
import 'package:socialwall/core/utils.dart';
import 'package:socialwall/models/comment_model.dart';
import 'package:socialwall/models/community.dart';
import 'package:socialwall/models/post_model.dart';
import 'package:socialwall/models/question_model.dart';
import 'package:socialwall/services/question_repository.dart';
import 'package:uuid/uuid.dart';

final questionControllerProvider =
    StateNotifierProvider<QuestionController, bool>((ref) {
  final questionRepository = ref.watch(questionRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return QuestionController(
    questionRepository: questionRepository,
    storageRepository: storageRepository,
    ref: ref,
  );
});

final getQuestionByIdProvider = StreamProvider.family((ref, String postId) {
  final questionController = ref.watch(questionControllerProvider.notifier);
  return questionController.getQuestionById(postId);
});

final getQuestionCommentsProvider = StreamProvider.family((ref, String postId) {
  final questionController = ref.watch(questionControllerProvider.notifier);
  return questionController.fetchQuestionComments(postId);
});

final getCommunityQuestionsProvider = StreamProvider.family((ref, String name) {
  final questionController = ref.watch(questionControllerProvider.notifier);
  return questionController.getCommunityQuestions(name);
});

class QuestionController extends StateNotifier<bool> {
  final QuestionRepository _questionRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;
  QuestionController(
      {required QuestionRepository questionRepository,
      required Ref ref,
      required storageRepository})
      : _questionRepository = questionRepository,
        _ref = ref,
        _storageRepository = storageRepository,
        super(false);

  Stream<Question> getQuestionById(String postId) {
    return _questionRepository.getQuestionById(postId);
  }

  void upvote(Question question) async {
    final uid = _ref.read(userProvider)!.uid;
    _questionRepository.upvote(question, uid);
  }

  void downvote(Question question) async {
    final uid = _ref.read(userProvider)!.uid;
    _questionRepository.downvote(question, uid);
  }

  Stream<List<Question>> getCommunityQuestions(String name) {
    return _questionRepository.getCommunityQuestions(name);
  }

  void shareQuestion({
    required BuildContext context,
    required String title,
    required String communityName,
    required String category,
    required String date,
    required File? file
  }) async {
    state = true;
    String questionId = const Uuid().v1();
    final user = _ref.read(userProvider)!;

    if (file != null) {
      final fileRes = await _storageRepository.storeFile(
        path:
            'questions/$communityName', 
        id: questionId,
        file: file,
      );

      fileRes.fold((l) => showSnackBar(context, l.message), (r) async {
        final Question question = Question(
          id: questionId,
          title: title,
          link: r,
          communityName: communityName,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: category,
          date: date,
          createdAt: DateTime.now(),
        );

        final res = await _questionRepository.addQuestion(question);
        state = false;
        res.fold((l) => showSnackBar(context, l.message), (r) {
          showSnackBar(context, 'Posted Question Paper successfully!');
          Routemaster.of(context).push('/post/$questionId/comments');
        });
      });
    } else {
      showSnackBar(context, 'Please select a PDF file to upload');
      state = false;
    }
  }

  Stream<List<Comment>> fetchQuestionComments(String postId) {
    return _questionRepository.getCommentsOfQuestion(postId);
  }

  void addComment({
    required BuildContext context,
    required String text,
    required Question question,
    required String type,
  }) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: question.id,
      username: user.name,
      profilePic: user.propic,
      type: type,
      uid: user.uid,
      upvotes: [],
      downvotes: [],
      actualPost: question.id,
    );
    final res = await _questionRepository.addComment(comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}
