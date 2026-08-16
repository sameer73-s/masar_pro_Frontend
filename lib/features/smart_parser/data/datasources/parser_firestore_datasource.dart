import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/upload_orchestrator.dart';
import '../models/order_model.dart';

abstract class ParserFirestoreDataSource {
  Future<void> createOrder(OrderModel order);
  Future<void> updateOrder(String orderId, Map<String, dynamic> data);
  Stream<List<OrderModel>> getOrdersStream();
  Future<String> uploadAttachmentAndLink(
    String orderId,
    File file, {
    Function(double)? onProgress,
  });
}

class ParserFirestoreDataSourceImpl implements ParserFirestoreDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final UploadOrchestrator _uploadOrchestrator;

  ParserFirestoreDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required UploadOrchestrator uploadOrchestrator,
  })  : _firestore = firestore,
        _auth = auth,
        _uploadOrchestrator = uploadOrchestrator;

  @override
  Future<void> createOrder(OrderModel order) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final orderWithUser = OrderModel(
      id: order.id,
      subject: order.subject,
      taskType: order.taskType,
      deadline: order.deadline,
      status: order.status,
      attachments: order.attachments,
      missingInfo: order.missingInfo,
      taskNameAr: order.taskNameAr,
      isReady: order.isReady,
      dynamicMissingFields: order.dynamicMissingFields,
      generatedContentUrl: order.generatedContentUrl,
      createdAt: order.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      userId: currentUser.uid,
    );

    await _firestore
        .collection('orders')
        .doc(orderWithUser.id)
        .set(orderWithUser.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    final updatedData = Map<String, dynamic>.from(data);
    updatedData['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection('orders').doc(orderId).update(updatedData);
  }

  @override
  Stream<List<OrderModel>> getOrdersStream() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('[DEBUG] getOrdersStream: currentUser is NULL');
      return Stream.value([]);
    }

    debugPrint('[DEBUG] getOrdersStream: currentUser.uid = ${currentUser.uid}');

    return _firestore
        .collection('orders')
        .where('user_id', isEqualTo: currentUser.uid)
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      debugPrint('[DEBUG] getOrdersStream: received snapshot with ${snapshot.docs.length} docs');
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<String> uploadAttachmentAndLink(
    String orderId,
    File file, {
    Function(double)? onProgress,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    return await _uploadOrchestrator.uploadAndTrack(
      file: file,
      collection: 'orders',
      docId: orderId,
      fieldName: 'attachments',
      isArrayField: true,
      userId: currentUser.uid,
      onProgress: onProgress,
    );
  }
}
