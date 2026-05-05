import 'dart:async';
import 'package:get/get.dart';

class ActionItem {
  final String title;
  final String assignee;
  final String dueDate;

  ActionItem({
    required this.title,
    required this.assignee,
    required this.dueDate,
  });
}

class KeyInsight {
  final String text;
  KeyInsight({required this.text});
}

class ArchivedMeeting {
  final String title;
  final String preview;
  final String date;
  final String duration;

  ArchivedMeeting({
    required this.title,
    required this.preview,
    required this.date,
    required this.duration,
  });
}

class NotulenController extends GetxController {
  // Recording state
  final isRecording = false.obs;
  final recordingDuration = 0.obs;
  Timer? _timer;

  // Transcription text
  final transcriptionText =
      'Sarah Koenig: So the main objective for Q4 is to migrate our legacy database to the cloud. We need to ensure zero downtime during the transition. Marcus Aurelius: That\'s a tall order. Have we considered the security implications for the financial records? I\'m worried about the encryption protocols on the new provider. Sarah Koenig: The migration needs to be completed by the end of November at the latest. We will conduct a thorough vendor assessment and security review before final sign-off.'
          .obs;

  // Current meeting title
  final meetingTitle = 'Product Sync Meeting'.obs;

  // Key Insights
  final keyInsights = <KeyInsight>[
    KeyInsight(
        text: 'Cloud migration is the priority for Q4 with a hard deadline in late November.'),
    KeyInsight(
        text: 'Database security concerns raised specifically regarding financial records.'),
  ].obs;

  // Action Items
  final actionItems = <ActionItem>[
    ActionItem(
        title: 'Review encryption docs',
        assignee: 'Marcus',
        dueDate: 'Oct 12'),
    ActionItem(
        title: 'Vendor assessment',
        assignee: 'Tech Team',
        dueDate: 'Oct 15'),
  ].obs;

  // Archived meetings
  final archivedMeetings = <ArchivedMeeting>[
    ArchivedMeeting(
      title: 'Marketing Strategy Sync',
      preview: 'Discussed campaign rollout for the upcoming holiday season...',
      date: '28 Apr 2025',
      duration: '32:10',
    ),
    ArchivedMeeting(
      title: 'Weekly All-Hands',
      preview: 'General updates on company performance and new hires...',
      date: '21 Apr 2025',
      duration: '45:00',
    ),
    ArchivedMeeting(
      title: 'QA Post-Mortem',
      preview: 'Root cause analysis of the v2.4 deployment incident...',
      date: '15 Apr 2025',
      duration: '28:40',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void toggleRecording() {
    if (isRecording.value) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    isRecording.value = true;
    recordingDuration.value = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      recordingDuration.value++;
    });
  }

  void _stopRecording() {
    isRecording.value = false;
    _timer?.cancel();
  }

  String get formattedDuration {
    final m = (recordingDuration.value ~/ 60).toString().padLeft(2, '0');
    final s = (recordingDuration.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
