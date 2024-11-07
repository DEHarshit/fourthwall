import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:socialwall/core/constants/firebase_constants.dart';
import 'package:socialwall/core/failure.dart';
import 'package:socialwall/core/providers/firebase_providers.dart';
import 'package:socialwall/core/type_defs.dart';
import 'package:socialwall/models/comment_model.dart';
import 'package:socialwall/models/community.dart';
import 'package:socialwall/models/post_model.dart';
import 'package:socialwall/models/question_model.dart';

final questionRepositoryProvider = Provider((ref) {
  return QuestionRepository(firestore: ref.watch(firestoreProvider));
});

class QuestionRepository {
  final FirebaseFirestore _firestore;
  QuestionRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference get _questions =>
      _firestore.collection(FirebaseConstants.questionsCollection);

  CollectionReference get _comments =>
      _firestore.collection(FirebaseConstants.commentsCollection);

  FutureVoid addQuestion(Question question) async {
    try {
      return right(_questions.doc(question.id).set(question.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Question>> getCommunityQuestions(String name) {
    return _questions
        .where('communityName', isEqualTo: name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map((e) => Question.fromMap(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  void upvote(Question question, String uid) async {
    if (question.downvotes.contains(uid)) {
      _questions.doc(question.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (question.upvotes.contains(uid)) {
      _questions.doc(question.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _questions.doc(question.id).update({
        'upvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  void downvote(Question question, String uid) async {
    if (question.upvotes.contains(uid)) {
      _questions.doc(question.id).update({
        'upvotes': FieldValue.arrayRemove([uid]),
      });
    }
    if (question.downvotes.contains(uid)) {
      _questions.doc(question.id).update({
        'downvotes': FieldValue.arrayRemove([uid]),
      });
    } else {
      _questions.doc(question.id).update({
        'downvotes': FieldValue.arrayUnion([uid]),
      });
    }
  }

  Stream<Question> getQuestionById(String id) {
    return _questions
        .doc(id)
        .snapshots()
        .map((event) => Question.fromMap(event.data() as Map<String, dynamic>));
  }

  FutureVoid addComment(Comment comment) async {
    try {
      await _comments.doc(comment.id).set(comment.toMap());
      return right(_questions.doc(comment.actualPost).update({
        'commentCount': FieldValue.increment(1),
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  // comments

  Stream<List<Comment>> getCommentsOfQuestion(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (event) => event.docs
              .map(
                (e) => Comment.fromMap(
                  e.data() as Map<String, dynamic>,
                ),
              )
              .toList(),
        );
  }
}
