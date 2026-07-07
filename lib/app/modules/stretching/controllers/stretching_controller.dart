import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/repositories/stretching_repository.dart';
import '../../home/controllers/home_controller.dart';

class StretchingController extends GetxController {
  final StretchingRepository _repository;
  StretchingController(this._repository);
  CameraController? cameraController;
  PoseDetector? poseDetector;
  bool isBusy = false;
  
  // Observables for UI
  var isCameraInitialized = false.obs;
  var isPoseDetected = false.obs;
  var percentage = 0.0.obs;
  var warningMessage = "pos_body_camera".tr.obs;
  var currentExercise = "".obs;
  var reps = 0.obs;
  int get targetReps => isTimerBased ? 2 : 8;
  bool get isTimerBased =>
      currentExercise.value == "Hamstring" ||
      currentExercise.value == "Seated Twist" ||
      currentExercise.value == "Upper Back";
  var isSessionCompleted = false.obs;

  // Hold-timer (untuk exercise berbasis waktu tahan)
  var holdSeconds = 0.obs;
  var isHolding = false.obs;
  final int targetHoldSeconds = 8;
  Timer? _holdTimer;

  // API tracking
  String? _sessionId;

  // Exercise State
  int _counter = 0;
  bool _isMovingUp = false;
  bool _hasTilted = false;
  double _lastNeckAngle = 0.0;
  final List<double> _shoulderRatioHistory = [];

  // Upper Back state
  bool _hasRoundedBack = false;
  final List<double> _backRoundHistory = [];

  // Seated Twist state
  bool _hasTwistedLeft = false;
  bool _hasTwistedRight = false;
  final List<double> _twistHistory = [];

  // Wrist Circle state
  int _wristCircleCount = 0;
  double _lastWristAngle = 0.0;
  double _wristAngleAccum = 0.0;
  final List<double> _wristAngleHistory = [];

  // Hamstring state
  bool _hasStretchedLeft = false;
  bool _hasStretchedRight = false;
  final List<double> _hipAngleHistory = [];

  String get exerciseInstruction {
    if (currentExercise.value == "Neck Tilt") {
      return "neck_tilt_inst".tr;
    } else if (currentExercise.value == "Shoulder Rolls") {
      return "shoulder_rolls_inst".tr;
    } else if (currentExercise.value == "Upper Back") {
      return "upper_back_inst".tr;
    } else if (currentExercise.value == "Seated Twist") {
      return "seated_twist_inst".tr;
    } else if (currentExercise.value == "Wrist Circle") {
      return "wrist_circle_inst".tr;
    } else if (currentExercise.value == "Hamstring") {
      return "hamstring_inst".tr;
    }
    return "";
  }

  @override
  void onInit() {
    super.onInit();
    currentExercise.value = Get.arguments ?? "Neck Tilt";
    reps.value = 0;
    isSessionCompleted.value = false;
    _isMovingUp = false;
    _hasTilted = false;
    _hasRoundedBack = false;
    _hasTwistedLeft = false;
    _hasTwistedRight = false;
    _wristCircleCount = 0;
    _lastWristAngle = 0.0;
    _wristAngleAccum = 0.0;
    _hasStretchedLeft = false;
    _hasStretchedRight = false;
    _shoulderRatioHistory.clear();
    _backRoundHistory.clear();
    _twistHistory.clear();
    _wristAngleHistory.clear();
    _hipAngleHistory.clear();
    holdSeconds.value = 0;
    isHolding.value = false;
    _holdTimer?.cancel();
    _holdTimer = null;
    _initializeCamera();
    _initializePoseDetector();
    _startStretchingSession();
  }

  // ── Hold Timer ─────────────────────────────────────────────────────────────
  void _startHoldTimer() {
    if (isHolding.value) return; // sudah berjalan
    isHolding.value = true;
    holdSeconds.value = 0;
    _holdTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      holdSeconds.value++;
      final remaining = targetHoldSeconds - holdSeconds.value;
      if (remaining > 0) {
        warningMessage.value = "hold_remaining".trParams({'remaining': remaining.toString()});
      }
      if (holdSeconds.value >= targetHoldSeconds) {
        _holdTimer?.cancel();
        _holdTimer = null;
        isHolding.value = false;
        holdSeconds.value = 0;
        if (reps.value < targetReps) {
          reps.value++;
          if (reps.value >= targetReps) {
            _completeStretchingSession();
            warningMessage.value = "stretch_completed".tr;
          } else {
            warningMessage.value = "set_completed".trParams({'rep': reps.value.toString()});
          }
        }
      }
    });
  }

  void _stopHoldTimer() {
    if (!isHolding.value) return;
    _holdTimer?.cancel();
    _holdTimer = null;
    isHolding.value = false;
    holdSeconds.value = 0;
  }
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _startStretchingSession() async {
    // exerciseId dipakai sebagai nama latihan (backend akan fallback jika UUID tidak valid)
    // Idealnya exercise_id dari GET /stretching/exercises, tapi bisa pakai nama sebagai placeholder
    try {
      final sessionId = await _repository.startSession(
        exerciseId: currentExercise.value,
      );
      if (sessionId != null) {
        _sessionId = sessionId;
        print('[Stretching] Session started → ID: $sessionId');
      }
    } catch (e) {
      print('[Stretching] Warning: could not start session: $e');
    }
  }

  Future<void> _completeStretchingSession({String status = 'completed'}) async {
    if (_sessionId == null || isSessionCompleted.value) return;
    isSessionCompleted.value = true;
    final success = await _repository.completeSession(
      sessionId: _sessionId!,
      totalReps: targetReps,
      correctReps: reps.value,
      status: status,
    );
    print('[Stretching] Session completed → success=$success, status=$status');
    _sessionId = null;

    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().fetchDashboardSummary();
    }
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
      warningMessage.value = "camera_denied".tr;
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
      warningMessage.value = "pose_not_found".tr;
      percentage.value = 0.0;
    }

    isBusy = false;
  }

  void _analyzePose(Pose pose) {
    if (currentExercise.value == "Neck Tilt") {
      _analyzeNeckTilt(pose);
    } else if (currentExercise.value == "Shoulder Rolls") {
      _analyzeShoulderRolls(pose);
    } else if (currentExercise.value == "Upper Back") {
      _analyzeUpperBack(pose);
    } else if (currentExercise.value == "Seated Twist") {
      _analyzeSeatedTwist(pose);
    } else if (currentExercise.value == "Wrist Circle") {
      _analyzeWristCircle(pose);
    } else if (currentExercise.value == "Hamstring") {
      _analyzeHamstring(pose);
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
        warningMessage.value = "neck_straighten".tr;
        // Map angle 12-30 to 0.5-1.0
        double p = 0.5 + (((absAngle - 12) / 18) * 0.5).clamp(0.0, 0.5);
        percentage.value = p;
      } else if (absAngle < 4 && _hasTilted) {
        _hasTilted = false;
        if (reps.value < targetReps) {
          reps.value++;
          if (reps.value >= targetReps) {
            _completeStretchingSession();
          }
        }
        warningMessage.value = "neck_tilt_side".tr;
        percentage.value = 0.0;
      } else {
        if (!_hasTilted) {
          warningMessage.value = "neck_tilt_side".tr;
          percentage.value = 0.0;
        } else {
          warningMessage.value = "neck_hold_return".tr;
          percentage.value = 0.3;
        }
      }
    } else {
      warningMessage.value = "ensure_head_shoulder".tr;
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
        warningMessage.value = "ensure_head".tr;
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
          warningMessage.value = "shoulder_lower_fully".tr;
        } else {
          warningMessage.value = "shoulder_raise".tr;
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
          warningMessage.value = "shoulder_lower_rotate".tr;
          
          // Map progress from UP (0.0 to 0.35) to percentage (0.5 to 1.0)
          double p = 0.5 + ((0.35 - relativePos) / 0.35 * 0.5).clamp(0.0, 0.5);
          percentage.value = p;
        } else if (relativePos > 0.65) {
          if (_isMovingUp) {
            _isMovingUp = false;
            if (reps.value < targetReps) {
              reps.value++;
              if (reps.value >= targetReps) {
                _completeStretchingSession();
              }
            }
          }
          warningMessage.value = "shoulder_raise".tr;
          percentage.value = 0.1;
        } else {
          // Transition / intermediate state
          if (_isMovingUp) {
            warningMessage.value = "shoulder_rotate_back".tr;
            percentage.value = 0.4;
          } else {
            warningMessage.value = "shoulder_raise_higher".tr;
            // Map progress from DOWN (0.65 to 1.0) to percentage (0.1 to 0.5)
            double p = 0.1 + ((1.0 - relativePos) / 0.35 * 0.4).clamp(0.0, 0.4);
            percentage.value = p;
          }
        }
      }
    } else {
      warningMessage.value = "ensure_shoulder".tr;
    }
  }

  /// Upper Back Stretch
  /// Deteksi: bahu bergerak ke depan (z-depth dari pose 3D) atau
  /// rasio lebar bahu mengecil saat membungkuk (proyeksi 2D).
  void _analyzeUpperBack(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      warningMessage.value = "ensure_shoulder_waist".tr;
      return;
    }

    // Rasio lebar bahu terhadap lebar pinggul.
    // Saat membungkuk ke depan (rounded upper back), bahu tampak lebih sempit
    // relatif terhadap pinggul dalam proyeksi frontal kamera.
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double hipWidth = (leftHip.x - rightHip.x).abs();
    if (hipWidth < 1.0) hipWidth = 1.0;
    double ratio = shoulderWidth / hipWidth;

    _backRoundHistory.add(ratio);
    if (_backRoundHistory.length > 60) _backRoundHistory.removeAt(0);

    if (_backRoundHistory.length < 10) {
      warningMessage.value = "back_ready".tr;
      percentage.value = 0.0;
      return;
    }

    double winMax = _backRoundHistory.reduce(max);
    double winMin = _backRoundHistory.reduce(min);
    double range = winMax - winMin;

    const double minRange = 0.06;
    if (range < minRange) {
      warningMessage.value = _hasRoundedBack
          ? "back_straighten".tr
          : "back_round_fwd".tr;
      percentage.value = 0.0;
      return;
    }

    // relativePos rendah = bahu sempit = membungkuk; tinggi = tegak
    double relativePos = (ratio - winMin) / range;

    if (relativePos < 0.35) {
      // Membungkuk → mulai hold timer
      _hasRoundedBack = true;
      _startHoldTimer();
      double p = 0.5 + ((0.35 - relativePos) / 0.35 * 0.5).clamp(0.0, 0.5);
      percentage.value = p;
    } else if (relativePos > 0.65 && _hasRoundedBack) {
      // Kembali tegak → reset hold
      _hasRoundedBack = false;
      _stopHoldTimer();
      warningMessage.value = "back_round_fwd_again".tr;
      percentage.value = 0.1;
    } else {
      if (_hasRoundedBack) {
        // Masih membungkuk tapi kurang dalam
        warningMessage.value = "back_hold".tr;
      } else {
        _stopHoldTimer();
        warningMessage.value = "back_round_more".tr;
      }
      percentage.value = relativePos * 0.5;
    }
  }

  /// Seated Twist
  /// Deteksi: rotasi bahu relatif terhadap pinggul.
  /// Saat berputar, satu bahu bergerak maju dan lainnya mundur,
  /// diukur dari perbedaan koordinat z (kedalaman) antar bahu.
  void _analyzeSeatedTwist(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      warningMessage.value = "ensure_shoulder_waist".tr;
      return;
    }

    // Dalam proyeksi 2D frontal kamera, saat berputar ke kanan,
    // lebar bahu tampak mengecil karena kedua bahu berputar ke samping.
    // Gunakan rasio lebar bahu saat ini vs referensi baseline.
    double shoulderWidth = (leftShoulder.x - rightShoulder.x).abs();
    double hipWidth = (leftHip.x - rightHip.x).abs();
    if (hipWidth < 1.0) hipWidth = 1.0;
    double ratio = shoulderWidth / hipWidth;

    _twistHistory.add(ratio);
    if (_twistHistory.length > 60) _twistHistory.removeAt(0);

    if (_twistHistory.length < 10) {
      warningMessage.value = "twist_ready".tr;
      percentage.value = 0.0;
      return;
    }

    double winMax = _twistHistory.reduce(max);
    double winMin = _twistHistory.reduce(min);
    double range = winMax - winMin;

    const double minRange = 0.05;
    if (range < minRange) {
      _stopHoldTimer();
      warningMessage.value = "twist_body".tr;
      percentage.value = 0.0;
      return;
    }

    double relativePos = (ratio - winMin) / range;

    if (relativePos < 0.35) {
      // Bahu sempit → sedang berputar → mulai hold timer
      _hasTwistedLeft = true;
      _startHoldTimer();
      double p = 0.5 + ((0.35 - relativePos) / 0.35 * 0.5).clamp(0.0, 0.5);
      percentage.value = p;
    } else if (relativePos > 0.65) {
      // Kembali ke tengah → hentikan hold
      _stopHoldTimer();
      if (_hasTwistedLeft) {
        _hasTwistedLeft = false;
        warningMessage.value = "twist_other_side".tr;
      } else {
        warningMessage.value = "twist_body".tr;
      }
      percentage.value = 0.1;
    } else {
      _stopHoldTimer();
      warningMessage.value = "twist_further".tr;
      percentage.value = 0.3;
    }
  }

  /// Wrist Circle
  /// Menggunakan sudut antara elbow – wrist – index finger untuk mendeteksi
  /// rotasi pergelangan tangan (lingkaran penuh).
  void _analyzeWristCircle(Pose pose) {
    final leftElbow = pose.landmarks[PoseLandmarkType.leftElbow];
    final leftWrist = pose.landmarks[PoseLandmarkType.leftWrist];
    final leftIndex = pose.landmarks[PoseLandmarkType.leftIndex];

    if (leftElbow == null || leftWrist == null || leftIndex == null) {
      warningMessage.value = "ensure_arm_hand".tr;
      percentage.value = 0.0;
      return;
    }

    // Vektor dari wrist ke elbow dan wrist ke index finger
    double v1x = leftElbow.x - leftWrist.x;
    double v1y = leftElbow.y - leftWrist.y;
    double v2x = leftIndex.x - leftWrist.x;
    double v2y = leftIndex.y - leftWrist.y;

    // Sudut antara dua vektor (0–180 derajat)
    double dot = v1x * v2x + v1y * v2y;
    double mag1 = sqrt(v1x * v1x + v1y * v1y);
    double mag2 = sqrt(v2x * v2x + v2y * v2y);
    if (mag1 < 1.0 || mag2 < 1.0) {
      isBusy = false;
      return;
    }
    double cosAngle = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
    double angle = acos(cosAngle) * 180 / pi;

    _wristAngleHistory.add(angle);
    if (_wristAngleHistory.length > 30) _wristAngleHistory.removeAt(0);

    // Deteksi perubahan arah sudut yang signifikan → satu putaran penuh
    double angleDelta = (angle - _lastWristAngle).abs();
    if (_lastWristAngle > 0 && angleDelta > 5) {
      _wristAngleAccum += angleDelta;
    }
    _lastWristAngle = angle;

    // ~360 derajat akumulasi = 1 putaran penuh (satu rep)
    const double fullCircleDeg = 300.0; // toleransi sedikit lebih rendah dari 360
    if (_wristAngleAccum >= fullCircleDeg) {
      _wristAngleAccum = 0.0;
      _wristCircleCount++;
      if (reps.value < targetReps) {
        reps.value++;
        if (reps.value >= targetReps) _completeStretchingSession();
      }
      warningMessage.value = "wrist_rep_done".trParams({'rep': reps.value.toString()});
      percentage.value = 0.1;
    } else {
      double progress = (_wristAngleAccum / fullCircleDeg).clamp(0.0, 1.0);
      percentage.value = progress;
      warningMessage.value = progress < 0.4
          ? "wrist_full_circle".tr
          : progress < 0.8
              ? "wrist_continue".tr
              : "wrist_almost".tr;
    }
  }

  /// Hamstring Stretch (Standing Forward Bend)
  /// Deteksi: rasio posisi bahu terhadap rentang pinggul–lutut.
  /// Saat membungkuk ke depan, bahu turun mendekati atau melewati level lutut.
  void _analyzeHamstring(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];
    final leftKnee = pose.landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = pose.landmarks[PoseLandmarkType.rightKnee];

    if (leftShoulder == null || rightShoulder == null ||
        leftHip == null || rightHip == null ||
        leftKnee == null || rightKnee == null) {
      warningMessage.value = "ensure_full_body".tr;
      percentage.value = 0.0;
      return;
    }

    // Rata-rata titik kiri & kanan
    double shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    double hipY = (leftHip.y + rightHip.y) / 2;
    double kneeY = (leftKnee.y + rightKnee.y) / 2;

    // Jarak pinggul ke lutut sebagai unit referensi
    double hipToKneeDist = kneeY - hipY;
    if (hipToKneeDist < 1.0) {
      warningMessage.value = "ensure_feet".tr;
      return;
    }

    // bendRatio:
    //  < 0.0  = berdiri tegak (bahu di atas pinggul)
    //  ~ 0.0  = bahu sejajar pinggul
    //  ~ 1.0  = bahu sejajar lutut (membungkuk dalam)
    //  > 1.0  = bahu di bawah lutut (sangat dalam)
    double bendRatio = (shoulderY - hipY) / hipToKneeDist;

    _hipAngleHistory.add(bendRatio);
    if (_hipAngleHistory.length > 60) _hipAngleHistory.removeAt(0);

    if (_hipAngleHistory.length < 10) {
      warningMessage.value = "hamstring_ready".tr;
      percentage.value = 0.0;
      return;
    }

    if (bendRatio > 0.7) {
      // Membungkuk dalam → mulai hold timer
      _startHoldTimer();
      double p = ((bendRatio - 0.7) / 0.5).clamp(0.0, 0.5) + 0.5;
      percentage.value = p.clamp(0.0, 1.0);
      warningMessage.value = "hamstring_hold".tr;
    } else if (bendRatio < 0.3) {
      // Kembali tegak → stop hold timer
      _stopHoldTimer();
      if (bendRatio <= 0.0) {
        warningMessage.value = "hamstring_bend".tr;
      } else {
        warningMessage.value = "hamstring_bend_deeper".tr;
      }
      percentage.value = 0.0;
    } else {
      // Posisi menengah
      _stopHoldTimer();
      double p = (bendRatio / 0.7).clamp(0.0, 1.0) * 0.5;
      percentage.value = p;
      warningMessage.value = bendRatio < 0.5
          ? "hamstring_bend_floor".tr
          : "hamstring_almost".tr;
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
    if (!isSessionCompleted.value && _sessionId != null) {
      _completeStretchingSession(status: 'cancelled');
    }
    _holdTimer?.cancel();
    cameraController?.dispose();
    poseDetector?.close();
    super.onClose();
  }
}
