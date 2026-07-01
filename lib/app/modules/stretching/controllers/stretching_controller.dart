import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../data/repositories/stretching_repository.dart';

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
  var warningMessage = "Posisikan tubuh Anda di depan kamera".obs;
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
      return "Miringkan kepala Anda secara perlahan ke kiri dan ke kanan secara bergantian. Tahan di setiap sisi beberapa detik untuk merilekskan otot leher.";
    } else if (currentExercise.value == "Shoulder Rolls") {
      return "Angkat kedua bahu Anda mendekati telinga, lalu putar perlahan ke arah belakang dan turunkan kembali. Ulangi gerakan secara berirama.";
    } else if (currentExercise.value == "Upper Back") {
      return "Satukan kedua tangan di depan dada, lalu dorong ke depan sambil membungkukkan punggung atas. Tahan beberapa detik lalu kembali tegak.";
    } else if (currentExercise.value == "Seated Twist") {
      return "Duduk tegak lalu putar tubuh bagian atas ke kanan dan ke kiri secara bergantian. Gunakan tangan untuk membantu rotasi dan tahan sejenak di setiap sisi.";
    } else if (currentExercise.value == "Wrist Circle") {
      return "Rentangkan tangan ke depan, lalu putar pergelangan membentuk lingkaran penuh. Lakukan searah jarum jam 5 kali, lalu ulangi berlawanan. Kerjakan pada kedua tangan.";
    } else if (currentExercise.value == "Hamstring") {
      return "Berdiri tegak dengan kaki selebar bahu. Bungkukkan tubuh ke depan perlahan, raih ujung kaki atau lantai sambil menjaga lutut tetap lurus. Tahan posisi 15–20 detik, lalu tegakkan kembali.";
    }
    return "Lakukan gerakan peregangan secara perlahan dan teratur sesuai instruksi di layar.";
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
        warningMessage.value = "Tahan! $remaining detik lagi...";
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
            warningMessage.value = "Selesai! Peregangan berhasil diselesaikan";
          } else {
            warningMessage.value = "Set ${reps.value} selesai! Kembali ke posisi awal";
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

  Future<void> _completeStretchingSession() async {
    if (_sessionId == null || isSessionCompleted.value) return;
    isSessionCompleted.value = true;
    final success = await _repository.completeSession(sessionId: _sessionId!);
    print('[Stretching] Session completed → success=$success');
    _sessionId = null;
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
        warningMessage.value = "Bagus! Sekarang tegakkan kepala Anda";
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
              if (reps.value >= targetReps) {
                _completeStretchingSession();
              }
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

  /// Upper Back Stretch
  /// Deteksi: bahu bergerak ke depan (z-depth dari pose 3D) atau
  /// rasio lebar bahu mengecil saat membungkuk (proyeksi 2D).
  void _analyzeUpperBack(Pose pose) {
    final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
    final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || leftHip == null || rightHip == null) {
      warningMessage.value = "Pastikan bahu dan pinggang terlihat";
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
      warningMessage.value = "Bersiap... dorong tangan ke depan dan bulatkan punggung";
      percentage.value = 0.0;
      return;
    }

    double winMax = _backRoundHistory.reduce(max);
    double winMin = _backRoundHistory.reduce(min);
    double range = winMax - winMin;

    const double minRange = 0.06;
    if (range < minRange) {
      warningMessage.value = _hasRoundedBack
          ? "Tegakkan punggung kembali"
          : "Bulatkan punggung Anda ke depan";
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
      warningMessage.value = "Bulatkan punggung Anda ke depan lagi";
      percentage.value = 0.1;
    } else {
      if (_hasRoundedBack) {
        // Masih membungkuk tapi kurang dalam
        warningMessage.value = "Tahan posisi, jangan bergerak!";
      } else {
        _stopHoldTimer();
        warningMessage.value = "Bulatkan punggung Anda lebih jauh";
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
      warningMessage.value = "Pastikan bahu dan pinggang terlihat";
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
      warningMessage.value = "Duduk tegak, siap untuk berputar";
      percentage.value = 0.0;
      return;
    }

    double winMax = _twistHistory.reduce(max);
    double winMin = _twistHistory.reduce(min);
    double range = winMax - winMin;

    const double minRange = 0.05;
    if (range < minRange) {
      _stopHoldTimer();
      warningMessage.value = "Putar tubuh Anda ke kanan atau ke kiri";
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
        warningMessage.value = "Putar ke sisi yang lain";
      } else {
        warningMessage.value = "Putar tubuh Anda ke kanan atau ke kiri";
      }
      percentage.value = 0.1;
    } else {
      _stopHoldTimer();
      warningMessage.value = "Putar tubuh lebih jauh ke samping";
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
      warningMessage.value = "Pastikan lengan dan tangan terlihat di kamera";
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
      warningMessage.value = "Putaran ke-${reps.value} selesai! Lanjutkan";
      percentage.value = 0.1;
    } else {
      double progress = (_wristAngleAccum / fullCircleDeg).clamp(0.0, 1.0);
      percentage.value = progress;
      warningMessage.value = progress < 0.4
          ? "Putar pergelangan membentuk lingkaran penuh"
          : progress < 0.8
              ? "Lanjutkan putaran..."
              : "Hampir selesai, teruskan!";
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
      warningMessage.value = "Pastikan seluruh tubuh terlihat di kamera";
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
      warningMessage.value = "Pastikan kaki terlihat di kamera";
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
      warningMessage.value = "Berdiri tegak, siap membungkuk ke depan";
      percentage.value = 0.0;
      return;
    }

    if (bendRatio > 0.7) {
      // Membungkuk dalam → mulai hold timer
      _startHoldTimer();
      double p = ((bendRatio - 0.7) / 0.5).clamp(0.0, 0.5) + 0.5;
      percentage.value = p.clamp(0.0, 1.0);
      warningMessage.value = "Bagus! Tahan dan rasakan regangan di paha belakang";
    } else if (bendRatio < 0.3) {
      // Kembali tegak → stop hold timer
      _stopHoldTimer();
      if (bendRatio <= 0.0) {
        warningMessage.value = "Bungkukkan tubuh ke depan, raih ujung kaki";
      } else {
        warningMessage.value = "Bungkukkan lebih dalam";
      }
      percentage.value = 0.0;
    } else {
      // Posisi menengah
      _stopHoldTimer();
      double p = (bendRatio / 0.7).clamp(0.0, 1.0) * 0.5;
      percentage.value = p;
      warningMessage.value = bendRatio < 0.5
          ? "Bungkukkan lebih dalam, raih lutut atau lantai"
          : "Hampir! Turunkan tangan mendekati lantai";
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
    _holdTimer?.cancel();
    cameraController?.dispose();
    poseDetector?.close();
    super.onClose();
  }
}
