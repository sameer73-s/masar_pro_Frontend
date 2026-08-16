import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../network/cloudinary_service.dart';

class UploadOrchestrator {
  final CloudinaryService _cloudinaryService;
  final FirebaseFirestore _firestore;

  UploadOrchestrator({
    required CloudinaryService cloudinaryService,
    required FirebaseFirestore firestore,
  })  : _cloudinaryService = cloudinaryService,
        _firestore = firestore;

  /// Uploads a file to Cloudinary and tracks the progress and status in Firestore.
  ///
  /// State transitions:
  /// 1. Updates Firestore to `${fieldName}_status`: "pending_upload" (creates document if missing).
  /// 2. Performs the actual file upload using [CloudinaryService].
  /// 3. If successful: updates Firestore field with the secure URL and `${fieldName}_status`: "uploaded".
  /// 4. If failed: updates `${fieldName}_status`: "upload_failed", saves error description, and rethrows.
  Future<String> uploadAndTrack({
    required File file,
    required String collection,
    required String docId,
    required String fieldName,
    bool isArrayField = false,
    String? userId,
    Function(double)? onProgress,
  }) async {
    final DocumentReference docRef = _firestore.collection(collection).doc(docId);

    // a. Update status in Firestore to "pending_upload" (create document if it does not exist)
    try {
      final Map<String, dynamic> initialData = {
        '${fieldName}_status': 'pending_upload',
        '${fieldName}_error': null,
      };
      if (userId != null) {
        initialData['user_id'] = userId;
      }
      await docRef.set(initialData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('فشل تحديث حالة الرفع المبدئية في Firestore: $e');
    }

    try {
      // b. Call cloudinaryService.uploadFile()
      // Folder is set to 'masar_pro' as required.
      final String secureUrl = await _cloudinaryService.uploadFile(
        file,
        folder: 'masar_pro',
        onProgress: onProgress,
      );

      // c. On success: update field with the URL and status to "uploaded"
      final Map<String, dynamic> successData = {
        fieldName: isArrayField ? FieldValue.arrayUnion([secureUrl]) : secureUrl,
        '${fieldName}_status': 'uploaded',
        '${fieldName}_error': null,
      };
      if (userId != null) {
        successData['user_id'] = userId;
      }
      await docRef.set(successData, SetOptions(merge: true));

      return secureUrl;
    } catch (e) {
      // d. On failure: update status to "upload_failed" with error message, then rethrow
      final String errorMessage = e is Exception ? e.toString().replaceAll('Exception: ', '') : e.toString();
      try {
        final Map<String, dynamic> failureData = {
          '${fieldName}_status': 'upload_failed',
          '${fieldName}_error': errorMessage,
        };
        if (userId != null) {
          failureData['user_id'] = userId;
        }
        await docRef.set(failureData, SetOptions(merge: true));
      } catch (dbError) {
        // Log the failure to update Firestore, but do not obscure the original upload exception
        print('Failed to write failure status to Firestore: $dbError');
      }

      rethrow;
    }
  }
}
