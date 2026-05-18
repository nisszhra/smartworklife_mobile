import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

class StretchingController extends GetxController {
  CameraController? cameraController;
  PoseDetector? poseDetector;
  bool isBusy = false;
  
  // Observables for UI
  var isCameraInitialized = false.obs;
  var isPoseDetected = false.obs;
  var percentage = 0.0.obs;
  var warningMessage = "Posisikan tubuh Anda di depan kamera".obs;
  var currentExercise = "".obs;
  var reps = 0.obs;
  final int targetReps = 8;

  // Exercise State
  int _counter = 0;
  bool _isMovingUp = false;
  bool _hasTilted = false;
  double _lastNeckAngle = 0.0;
  final List<double> _shoulderRatioHistory = [];

  String get exerciseInstruction {
    if (currentExercise.value == "Neck Tilt") {
      return "Miringkan kepala Anda secara perlahan ke kiri dan ke kanan secara bergantian. Tahan di setiap sisi beberapa detik untuk merilekskan otot leher.";
    } else if (currentExercise.value == "Shoulder Rolls") {
      return "Angkat kedua bahu Anda mendekati telinga, lalu putar perlahan ke arah belakang dan turunkan kembali. Ulangi gerakan secara berirama.";
    }
    return "Lakukan gerakan peregangan secara perlahan dan teratur sesuai instruksi di layar.";
  }

  @override
  void onInit() {
    super.onInit();
    currentExercise.value = Get.arguments ?? "Neck Tilt";
    reps.value = 0;
    _isMovingUp = false;
    _hasTilted = false;
    _shoulderRatioHistory.clear();
    _initializeCamera();
    _initializePoseDetector();
  }

  void _initializePoseDetector() {
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
    );
    poseDetector = PoseDetector(options: options);
  }

  Future<void> _initializeCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final cameras = await availableCameras();
      // Use front camera
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21, // Better for Android
      );

      await cameraController?.initialize();
      isCameraInitialized.value = true;

      cameraController?.startImageStream((CameraImage image) {
        if (!isBusy) {
          isBusy = true;
          _processImage(image);
        }
      });
    } else {
      warningMessage.value = "Izin kamera ditolak";
    }
  }

  Future<void> _processImage(CameraImage image) async {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      isBusy = false;
      return;
    }

    final poses = await poseDetector?.processImage(inputImage);
    
    if (poses != null && poses.isNotEmpty) {
      isPoseDetected.value = true;
      _analyzePose(poses.first);
    } else {
      isPoseDetected.value = false;
      warningMessage.value = "Pose tidak terdeteksi";
      percentage.value = 0.0;
    }

    isBusy = false;
  }

  void _analyzePose(Pose pose) {
    if (currentExercise.value == "Neck Tilt") {
      _analyzeNeckTilt(pose);
    } else if (currentExercise.value == "Shoulder Rolls") {
      _analyzeShoulderRolls(pose);
    }
  }

  void _analyzeNeckTilt(Pose pose) {
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final rightEar = pose.landmarks[PoseLandmarkType.rightEar];
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];

    if (leftEar != null && rightEar != null && leftShoulder != null && rightShoulder != null) {
      // Calculate angle of the line between ears
      double dy = leftEar.y - rightEar.y;
      double dx = leftEar.x - rightEar.x;
      double angle = atan2(dy, dx) * 180 / pi;

      // Normalize angle: 0 is horizontal
      double absAngle = angle.abs();
      
      if (absAngle > 12) {
        _hasTilted = true;
        warningMessage.value = "Bagus! Sekarang tegakkan kepala Anda";
        // Map angle 12-30 to 0.5-1.0
        double p = 0.5 + (((absAngle - 12) / 18) * 0.5).clamp(0.0, 0.5);
        percentage.value = p;
      } else if (absAngle < 4 && _hasTilted) {
        _hasTilted = false;
        if (reps.value < targetReps) {
          reps.value++;
        }
        warningMessage.value = "Miringkan leher Anda ke samping";
        percentage.value = 0.0;
      } else {
        if (!_hasTilted) {
          warningMessage.value = "Miringkan leher Anda ke samping";
          percentage.value = 0.0;
        } else {
          warningMessage.value = "Tahan dan perlahan kembali tegak";
          percentage.value = 0.3;
        }
      }
    } else {
      warningMessage.value = "Pastikan kepala dan bahu terlihat";
    }
  }

  void _analyzeShoulderRolls(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftEar = pose.landmarks[PoseLandmarkType.leftEar];
    final rightEar = pose.landmarks[PoseLandmarkType.rightEar];

    if (leftShoulder != null && rightShoulder != null) {
      // Calculate shoulder width in pixels as baseline reference to make it size-invariant
      double dx = leftShoulder.x - rightShoulder.x;
      double dy = leftShoulder.y - rightShoulder.y;
      double shoulderWidth = sqrt(dx * dx + dy * dy);
      if (shoulderWidth < 1.0) shoulderWidth = 1.0;

      double? leftDist;
      if (leftEar != null) {
        leftDist = leftShoulder.y - leftEar.y;
      }

      double? rightDist;
      if (rightEar != null) {
        rightDist = rightShoulder.y - rightEar.y;
      }

      double avgDist;
      if (leftDist != null && rightDist != null) {
        avgDist = (leftDist + rightDist) / 2.0;
      } else if (leftDist != null) {
        avgDist = leftDist;
      } else if (rightDist != null) {
        avgDist = rightDist;
      } else {
        warningMessage.value = "Pastikan kepala terlihat jelas";
        percentage.value = 0.0;
        return;
      }

      // Normalize ear-to-shoulder vertical distance by shoulder width
      double ratio = avgDist / shoulderWidth;

      // Keep a rolling history of the ratio to dynamically adapt to the user's posture, neck size, and camera distance.
      _shoulderRatioHistory.add(ratio);
      if (_shoulderRatioHistory.length > 90) { // Keep last 90 frames (~3-6 seconds)
        _shoulderRatioHistory.removeAt(0);
      }

      // Find min and max in the window to establish dynamic range
      double winMin = _shoulderRatioHistory.reduce(min);
      double winMax = _shoulderRatioHistory.reduce(max);
      double range = winMax - winMin;

      // Noise threshold: if range is too small, user is static or it's just pixel noise
      const double minMovementRange = 0.07;

      if (range < minMovementRange) {
        // Not enough active movement detected yet, prompt the user
        if (_isMovingUp) {
          warningMessage.value = "Turunkan bahu Anda sepenuhnya";
        } else {
          warningMessage.value = "Angkat bahu Anda ke atas mendekati telinga";
        }
        percentage.value = 0.0;
      } else {
        // Calculate where the current ratio sits in the observed min-max range
        double relativePos = (ratio - winMin) / range; // 0.0 = shoulders up (min dist), 1.0 = shoulders down (max dist)

        // Thresholds:
        // relativePos < 0.35 means shoulders are up (near the observed minimum distance)
        // relativePos > 0.65 means shoulders are down (near the observed maximum distance)
        if (relativePos < 0.35) {
          _isMovingUp = true;
          warningMessage.value = "Bagus! Sekarang turunkan dan putar bahu";
          
          // Map progress from UP (0.0 to 0.35) to percentage (0.5 to 1.0)
          double p = 0.5 + ((0.35 - relativePos) / 0.35 * 0.5).clamp(0.0, 0.5);
          percentage.value = p;
        } else if (relativePos > 0.65) {
          if (_isMovingUp) {
            _isMovingUp = false;
            if (reps.value < targetReps) {
              reps.value++;
            }
          }
          warningMessage.value = "Angkat bahu Anda ke atas mendekati telinga";
          percentage.value = 0.1;
        } else {
          // Transition / intermediate state
          if (_isMovingUp) {
            warningMessage.value = "Putar leher/bahu Anda ke belakang dan turunkan";
            percentage.value = 0.4;
          } else {
            warningMessage.value = "Angkat bahu Anda lebih tinggi";
            // Map progress from DOWN (0.65 to 1.0) to percentage (0.1 to 0.5)
            double p = 0.1 + ((1.0 - relativePos) / 0.35 * 0.4).clamp(0.0, 0.4);
            percentage.value = p;
          }
        }
      }
    } else {
      warningMessage.value = "Pastikan bahu terlihat jelas";
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = cameraController?.description.sensorOrientation ?? 0;
    InputImageRotation? rotation;
    if (defaultTargetPlatform == TargetPlatform.android) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (defaultTargetPlatform == TargetPlatform.android && format != InputImageFormat.nv21) ||
        (defaultTargetPlatform == TargetPlatform.iOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  @override
  void onClose() {
    cameraController?.dispose();
    poseDetector?.close();
    super.onClose();
  }
}
