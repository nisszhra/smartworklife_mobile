import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:worklife_mobile/app/data/providers/notulen_provider.dart';

class ArchivedMeeting {

  final String id;
  final String title;
  final String date;
  final String duration;
  final String preview;

  ArchivedMeeting({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.preview,
  });
}

class KeyInsight {
  final String text;
  KeyInsight(this.text);
}

class ActionItem {
  final String title;
  final String description;
  final String dueDate;
  ActionItem({required this.title, required this.description, required this.dueDate});
}

class NotulenController extends GetxController {
  final NotulenProvider provider = NotulenProvider();

  final archivedMeetings = <ArchivedMeeting>[].obs;
  final currentNotulenId = "".obs;

  // Multi-select state
  final isSelectionMode = false.obs;
  final selectedIds = <String>{}.obs;

  final transcriptionText = "".obs;  // teks final (dari Groq atau live STT)
  final liveText = "".obs;           // khusus tampilan live saat recording
  final meetingTitle = "".obs;

  final isAnalyzing = false.obs;
  final showAiSummary = false.obs;
  final isProcessing = false.obs;
  final processingStatusText = "Groq Whisper sedang mentranskripsikan audio...\nProses ini memakan waktu beberapa detik.".obs;


  final isRecording = false.obs;
  final hasStopped = false.obs;
  final formattedDuration = "00:00".obs;

  final isEditingTranscription = false.obs;
  final transcriptionController = TextEditingController();

  final keyInsights = <KeyInsight>[].obs;
  final actionItems = <ActionItem>[].obs;

  // Dedicated Detail variables (keeps the main smart notes view empty)
  final detailNotulenId = "".obs;
  final detailTitle = "".obs;
  final detailTranscript = "".obs;
  final detailDuration = "00:00".obs;
  final detailInsights = <KeyInsight>[].obs;
  final detailActionItems = <ActionItem>[].obs;
  final detailShowAiSummary = false.obs;
  final detailIsEditing = false.obs;
  final detailIsAnalyzing = false.obs;
  final detailTranscriptionController = TextEditingController();
  final detailTitleController = TextEditingController();

  // Audio recording
  final _audioRecorder = AudioRecorder();
  String? _recordingPath;
  Timer? _timer;
  int _recordDuration = 0;

  // Live STT
  final _speechToText = stt.SpeechToText();
  bool _speechAvailable = false;
  String _committedText = '';
  String _liveWords = '';
  String _previousTranscript = '';
  String _currentLocaleId = 'id_ID';
  bool _isRestarting = false; // Mencegah double call listen() saat timeout/reconnect

  @override
  void onInit() {
    super.onInit();
    // Pastikan state bersih saat init
    isRecording.value = false;
    hasStopped.value = false;
    isProcessing.value = false;
    fetchNotulen();
    _initSpeech();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _speechToText.cancel();
    transcriptionController.dispose();
    detailTranscriptionController.dispose();
    detailTitleController.dispose();
    super.onClose();
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speechToText.initialize(
        onError: (e) {
          print('❌ STT Error: ${e.errorMsg}');
          // Biarkan onStatus doneStatus yang mengurus restart secara terpusat
        },
        onStatus: (status) {
          print('🎤 STT Status: $status');
          if (status == stt.SpeechToText.doneStatus && isRecording.value) {
            if (_liveWords.trim().isNotEmpty) {
              _committedText += '$_liveWords ';
              _liveWords = '';
              liveText.value = _committedText;
            }
            _safeRestartLiveSpeech();
          }
        },
      );

      if (_speechAvailable) {
        final locales = await _speechToText.locales();
        final hasIndonesian = locales.any((l) => l.localeId.startsWith('id'));
        _currentLocaleId = hasIndonesian ? 'id_ID' : 'en_US';
        print('🎤 STT Locale set to: $_currentLocaleId');
      }
      print('🎤 Speech available: $_speechAvailable');
    } catch (e) {
      print('❌ STT Init Error: $e');
      _speechAvailable = false;
    }
  }

  void _safeRestartLiveSpeech() {
    if (!isRecording.value || _isRestarting) return;
    _isRestarting = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      _isRestarting = false;
      if (isRecording.value && !_speechToText.isListening) {
        _startLiveSpeech();
      }
    });
  }

  Future<void> startRecording() async {
    // 0. Batalkan sesi STT yang sedang aktif jika ada untuk menghindari konflik hardware awal
    if (_speechToText.isListening) {
      await _speechToText.cancel();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      final hasPermission = await Permission.microphone.request().isGranted;
      if (!hasPermission) {
        Get.snackbar('⚠️ Izin Diperlukan', 'Berikan izin mikrofon.',
            backgroundColor: Colors.orange, colorText: Colors.white);
        return;
      }

      // Simpan sisa transkrip sebelumnya jika ada, agar bisa disambung
      _previousTranscript = transcriptionText.value;
      _committedText = _previousTranscript.isNotEmpty ? '$_previousTranscript\n\n' : '';
      _liveWords = '';
      liveText.value = _committedText;
      
      isRecording.value = true;
      hasStopped.value = false;
      _recordDuration = 0;
      _startTimer();

      // Mulai live STT
      if (_speechAvailable) {
        _startLiveSpeech();
      } else {
        await _initSpeech();
        if (_speechAvailable) {
          _startLiveSpeech();
        } else {
          Get.snackbar('❌ Gagal', 'Layanan Speech-to-Text tidak tersedia di perangkat ini.',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      print('❌ Start recording error: $e');
      isRecording.value = false;
      Get.snackbar('❌ Error', 'Gagal memulai transkripsi: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _startLiveSpeech() {
    if (!_speechAvailable || _speechToText.isListening) return;

    _speechToText.listen(
      localeId: _currentLocaleId,
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 8),
      listenFor: const Duration(minutes: 30),
      partialResults: true,
      onResult: (result) {
        if (result.finalResult) {
          if (result.recognizedWords.trim().isNotEmpty) {
            _committedText += '${result.recognizedWords} ';
          }
          _liveWords = '';
        } else {
          _liveWords = result.recognizedWords;
        }
        liveText.value = '$_committedText$_liveWords';
      },
    );
  }

  Future<String> _refineText(String rawText) async {
    if (rawText.trim().isEmpty) return '';
    try {
      final res = await provider.refine(rawText);
      return res.data['refined_text'] as String? ?? rawText;
    } catch (e) {
      print('❌ Refine error: $e');
      return rawText;
    }
  }

  Future<void> _createDraftFromText(String transcript) async {
    try {
      final res = await provider.createFromText(transcript, durationSeconds: _recordDuration);
      currentNotulenId.value = res.data['id']?.toString() ?? '';
      // Get.snackbar('✅ Transkripsi AI Selesai', 'Notulen draft berhasil dibuat.');
    } catch (e) {
      print('❌ Create draft from text error: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      _timer?.cancel();
      
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (_liveWords.trim().isNotEmpty) {
        _committedText += '$_liveWords ';
        _liveWords = '';
      }
      final rawText = _committedText;
      liveText.value = rawText;
      
      isRecording.value = false;
      hasStopped.value = true;

      if (rawText.trim().isNotEmpty) {
        processingStatusText.value = "AI sedang menyempurnakan transkripsi...";
        isProcessing.value = true;
        final refinedText = await _refineText(rawText);
        _committedText = refinedText;
        liveText.value = refinedText;
        transcriptionText.value = refinedText;
        isProcessing.value = false;
      }
    } catch (e) {
      print('❌ Pause recording error: $e');
      isProcessing.value = false;
    }
  }

  Future<void> resumeRecording() async {
    try {
      isRecording.value = true;
      hasStopped.value = false;
      _startTimer();

      if (_speechAvailable) {
        _startLiveSpeech();
      }
    } catch (e) {
      print('❌ Resume recording error: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _timer?.cancel();
      
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      await Future.delayed(const Duration(milliseconds: 300));

      if (_liveWords.trim().isNotEmpty) {
        _committedText += '$_liveWords ';
        _liveWords = '';
      }
      final rawLiveText = _committedText;
      liveText.value = rawLiveText;

      isRecording.value = false;
      hasStopped.value = false;

      if (rawLiveText.trim().isNotEmpty) {
        processingStatusText.value = "AI sedang menyempurnakan transkripsi...";
        isProcessing.value = true;
        
        final refinedLive = await _refineText(rawLiveText);
        transcriptionText.value = refinedLive;
        liveText.value = refinedLive;
        await _createDraftFromText(refinedLive);
      } else {
        Get.snackbar('⚠️ Info', 'Tidak ada suara yang terdeteksi.');
      }
    } catch (e) {
      print('❌ Stop recording error: $e');
      isRecording.value = false;
      hasStopped.value = false;
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> _ensureUploaded() async {
    if (currentNotulenId.value.isNotEmpty) return true;

    try {
      _timer?.cancel();
      if (_speechToText.isListening) {
        await _speechToText.stop();
      }
      await Future.delayed(const Duration(milliseconds: 300));
      
      isRecording.value = false;
      hasStopped.value = false;

      if (_liveWords.trim().isNotEmpty) {
        _committedText += '$_liveWords ';
        _liveWords = '';
      }
      final rawLiveText = _committedText;

      if (rawLiveText.trim().isNotEmpty) {
        processingStatusText.value = "AI sedang menyempurnakan transkripsi...";
        isProcessing.value = true;
        
        final refinedLive = await _refineText(rawLiveText);
        transcriptionText.value = refinedLive;
        liveText.value = refinedLive;
        await _createDraftFromText(refinedLive);
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Stop and upload error: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }



  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _recordDuration++;
      final minutes = _recordDuration ~/ 60;
      final seconds = _recordDuration % 60;
      formattedDuration.value =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    });
  }

  void toggleEditTranscription() {
    if (isEditingTranscription.value) {
      transcriptionText.value = transcriptionController.text;
      liveText.value = transcriptionController.text;
      if (currentNotulenId.value.isNotEmpty) {
        updateNotulen();
      }
    } else {
      transcriptionController.text = transcriptionText.value;
    }
    isEditingTranscription.value = !isEditingTranscription.value;
  }

  Future<void> updateNotulen() async {
    if (currentNotulenId.value.isEmpty) return;

    try {
      isProcessing.value = true;
      processingStatusText.value = 'Menyimpan perubahan...';
      
      await provider.save(currentNotulenId.value, {
        'title': meetingTitle.value,
        'meeting_date': DateTime.now().toIso8601String(),
        'transcript': transcriptionText.value,
      });
      fetchNotulen();
    } catch (e) {
      print('❌ Update error: $e');
      Get.snackbar('❌ Gagal', 'Gagal memperbarui notulen.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  void toggleEditDetailTranscription() {
    if (detailIsEditing.value) {
      detailTranscript.value = detailTranscriptionController.text;
      detailTitle.value = detailTitleController.text;
      if (detailNotulenId.value.isNotEmpty) {
        updateDetailNotulen();
      }
    } else {
      detailTranscriptionController.text = detailTranscript.value;
      detailTitleController.text = detailTitle.value;
    }
    detailIsEditing.value = !detailIsEditing.value;
  }

  Future<void> updateDetailNotulen() async {
    if (detailNotulenId.value.isEmpty) return;

    try {
      isProcessing.value = true;
      processingStatusText.value = 'Menyimpan perubahan...';
      
      await provider.save(detailNotulenId.value, {
        'title': detailTitle.value,
        'meeting_date': DateTime.now().toIso8601String(),
        'transcript': detailTranscript.value,
      });
      fetchNotulen();
    } catch (e) {
      print('❌ Update error: $e');
      Get.snackbar('❌ Gagal', 'Gagal memperbarui notulen.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }



  Future<void> analyzeDetailTranscription() async {
    if (detailNotulenId.value.isEmpty) return;

    try {
      detailIsAnalyzing.value = true;
      final res = await provider.generateSummary(detailNotulenId.value);
      final data = res.data;
      final summaryRaw = data['summary'] as String? ?? '';
      final actionRaw = data['action_items'];

      detailInsights.value = summaryRaw.isNotEmpty
          ? summaryRaw
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .map((l) => KeyInsight(l.trim()))
              .toList()
          : [];

      if (actionRaw is List) {
        detailActionItems.value = actionRaw.map((a) {
          if (a is Map) {
            return ActionItem(
              title: (a['task'] ?? a['title'] ?? '').toString(),
              description: (a['description'] ?? a['desc'] ?? a['assignee'] ?? '-').toString(),
              dueDate: (a['due_date'] ?? '-').toString(),
            );
          } else {
            String title = a.toString();
            String description = '-';
            String dueDate = '-';

            // Extract PJ (old version)
            final pjRegExp = RegExp(r'\[PJ:\s*([^\]]+)\]');
            final pjMatch = pjRegExp.firstMatch(title);
            if (pjMatch != null) {
              description = pjMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(pjRegExp, '').trim();
            }

            // Extract Desc (new version)
            final descRegExp = RegExp(r'\[Desc:\s*([^\]]+)\]');
            final descMatch = descRegExp.firstMatch(title);
            if (descMatch != null) {
              description = descMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(descRegExp, '').trim();
            }

            // Extract Due
            final dueRegExp = RegExp(r'\[Due:\s*([^\]]+)\]');
            final dueMatch = dueRegExp.firstMatch(title);
            if (dueMatch != null) {
              dueDate = dueMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(dueRegExp, '').trim();
            }

            return ActionItem(
              title: title,
              description: description,
              dueDate: dueDate,
            );
          }
        }).toList();
      }

      detailShowAiSummary.value = true;
    } catch (e) {
      print('❌ Analyze error: $e');
      Get.snackbar('❌ Gagal', 'Gagal membuat ringkasan AI.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      detailIsAnalyzing.value = false;
    }
  }

  void updateActionItem(int index, String title, String description, String dueDate) {
    if (index >= 0 && index < actionItems.length) {
      actionItems[index] = ActionItem(title: title, description: description, dueDate: dueDate);
      actionItems.refresh();
    }
  }

  void updateDetailActionItem(int index, String title, String description, String dueDate) {
    if (index >= 0 && index < detailActionItems.length) {
      detailActionItems[index] = ActionItem(title: title, description: description, dueDate: dueDate);
      detailActionItems.refresh();
    }
  }



  Future<void> analyzeTranscription() async {
    final uploaded = await _ensureUploaded();
    if (!uploaded) return;

    try {
      isAnalyzing.value = true;
      final res = await provider.generateSummary(currentNotulenId.value);
      final data = res.data;
      final summaryRaw = data['summary'] as String? ?? '';
      final actionRaw = data['action_items'];

      keyInsights.value = summaryRaw.isNotEmpty
          ? summaryRaw
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .map((l) => KeyInsight(l.trim()))
              .toList()
          : [];

      if (actionRaw is List) {
        actionItems.value = actionRaw.map((a) {
          if (a is Map) {
            return ActionItem(
              title: (a['task'] ?? a['title'] ?? '').toString(),
              description: (a['description'] ?? a['desc'] ?? a['assignee'] ?? '-').toString(),
              dueDate: (a['due_date'] ?? '-').toString(),
            );
          } else {
            String title = a.toString();
            String description = '-';
            String dueDate = '-';

            // Extract PJ
            final pjRegExp = RegExp(r'\[PJ:\s*([^\]]+)\]');
            final pjMatch = pjRegExp.firstMatch(title);
            if (pjMatch != null) {
              description = pjMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(pjRegExp, '').trim();
            }

            // Extract Desc
            final descRegExp = RegExp(r'\[Desc:\s*([^\]]+)\]');
            final descMatch = descRegExp.firstMatch(title);
            if (descMatch != null) {
              description = descMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(descRegExp, '').trim();
            }

            // Extract Due
            final dueRegExp = RegExp(r'\[Due:\s*([^\]]+)\]');
            final dueMatch = dueRegExp.firstMatch(title);
            if (dueMatch != null) {
              dueDate = dueMatch.group(1)?.trim() ?? '-';
              title = title.replaceAll(dueRegExp, '').trim();
            }

            return ActionItem(
              title: title,
              description: description,
              dueDate: dueDate,
            );
          }
        }).toList();
      }

      showAiSummary.value = true;
      hasStopped.value = false;
    } catch (e) {
      print('❌ Analyze error: $e');
      Get.snackbar('❌ Gagal', 'Gagal membuat ringkasan AI.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> saveNotulen() async {
    final uploaded = await _ensureUploaded();
    if (!uploaded) return;

    try {
      final title = meetingTitle.value.isNotEmpty
          ? meetingTitle.value
          : '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
      await provider.save(currentNotulenId.value, {
        'title': title,
        'meeting_date': DateTime.now().toIso8601String(),
        'transcript': transcriptionText.value,
      });
      Get.snackbar('✅ Tersimpan', 'Notulen berhasil disimpan ke arsip!');
      _resetState();
      fetchNotulen();
    } catch (e) {
      print('❌ Save error: $e');
      Get.snackbar('❌ Gagal', 'Gagal menyimpan notulen.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> discardNotulen() async {
    try {
      isProcessing.value = true;
      processingStatusText.value = 'Membatalkan dan menghapus draft...';
      
      if (currentNotulenId.value.isNotEmpty) {
        await provider.delete(currentNotulenId.value);
      }
      
      _resetState();
      Get.snackbar('🗑️ Dibatalkan', 'Draft rekaman berhasil dibatalkan dan dihapus.',
          backgroundColor: Colors.blueGrey, colorText: Colors.white);
    } catch (e) {
      print('❌ Discard error: $e');
      _resetState();
      Get.snackbar('⚠️ Info', 'Draft dibersihkan dari layar.',
          backgroundColor: Colors.orange, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  void _resetState() {
    currentNotulenId.value = '';
    transcriptionText.value = '';
    liveText.value = '';
    meetingTitle.value = '';
    showAiSummary.value = false;
    isAnalyzing.value = false;
    isProcessing.value = false;
    isEditingTranscription.value = false;
    transcriptionController.clear();
    keyInsights.clear();
    actionItems.clear();
    isRecording.value = false;
    hasStopped.value = false;
    formattedDuration.value = '00:00';
    _recordDuration = 0;
    _recordingPath = null;
    _committedText = '';
    _liveWords = '';
    _previousTranscript = '';

    // Stop timer and cancel active speech listening session
    _timer?.cancel();
    try {
      if (_speechToText.isListening) {
        _speechToText.cancel();
      }
    } catch (e) {
      print('Error cancelling speech listener: $e');
    }
  }

  Future<void> fetchNotulen() async {
    try {
      final res = await provider.getList();
      final list = res.data as List? ?? [];
      archivedMeetings.value = list.map((item) {
        final dur = item['duration_seconds'] as int? ?? 0;
        final min = dur ~/ 60;
        final sec = dur % 60;
        return ArchivedMeeting(
          id: item['id']?.toString() ?? '',
          title: item['title'] ?? 'Tanpa Judul',
          date: item['meeting_date'] != null
              ? _formatDate(item['meeting_date'])
              : _formatDate(item['created_at']),
          duration:
              '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}',
          preview: item['has_summary'] == true ? '✓ Sudah dianalisis' : 'Draft',
        );
      }).toList();
    } catch (e) {
      print('❌ Fetch notulen error: $e');
    }
  }

  Future<void> loadArchive(String id) async {
    try {
      isProcessing.value = true;
      processingStatusText.value = 'Memuat notulen...';
      
      final res = await provider.getDetail(id);
      final data = res.data;
      
      detailNotulenId.value = id;
      detailTitle.value = data['title'] ?? 'Tanpa Judul';
      detailTitleController.text = detailTitle.value;
      detailTranscript.value = data['transcript'] ?? '';
      
      final dur = data['duration_seconds'] as int? ?? 0;
      final minutes = dur ~/ 60;
      final seconds = dur % 60;
      detailDuration.value =
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      
      // Load AI Summary if available
      final summaryRaw = data['summary'] as String? ?? '';
      final actionRaw = data['action_items'];
      
      detailInsights.value = summaryRaw.isNotEmpty
          ? summaryRaw
              .split('\n')
              .where((l) => l.trim().isNotEmpty)
              .map((l) => KeyInsight(l.trim()))
              .toList()
          : [];
      
      if (actionRaw is List) {
        detailActionItems.value = actionRaw.map((a) {
          if (a is Map) {
            return ActionItem(
              title: (a['task'] ?? a['title'] ?? '').toString(),
              description: (a['description'] ?? a['desc'] ?? a['assignee'] ?? '-').toString(),
              dueDate: (a['due_date'] ?? '-').toString(),
            );
          } else {
            return ActionItem(
              title: a.toString(),
              description: '-',
              dueDate: '-',
            );
          }
        }).toList();
      } else {
        detailActionItems.clear();
      }
      
      detailShowAiSummary.value = data['summary'] != null && (data['summary'] as String).isNotEmpty;
      detailIsEditing.value = false;
      
      // Get.snackbar('✅ Berhasil', 'Notulen "${detailTitle.value}" berhasil dimuat.',
      //     backgroundColor: const Color(0xFF005AB4), colorText: Colors.white);
    } catch (e) {
      print('❌ Load archive error: $e');
      Get.snackbar('❌ Gagal', 'Gagal memuat notulen.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isProcessing.value = false;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Future<void> deleteNotulen(String id) async {
    try {
      await provider.delete(id);
      archivedMeetings.removeWhere((m) => m.id == id);
      selectedIds.remove(id);
      Get.snackbar('✅ Dihapus', 'Notulen berhasil dihapus.');
    } catch (e) {
      Get.snackbar('❌ Gagal', 'Gagal menghapus notulen.');
    }
  }

  void enterSelectionMode(String id) {
    isSelectionMode.value = true;
    selectedIds.add(id);
  }

  void exitSelectionMode() {
    isSelectionMode.value = false;
    selectedIds.clear();
  }

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
      if (selectedIds.isEmpty) exitSelectionMode();
    } else {
      selectedIds.add(id);
    }
  }

  Future<void> deleteSelected() async {
    if (selectedIds.isEmpty) return;
    try {
      final ids = selectedIds.toList();
      await provider.bulkDelete(ids: ids);
      archivedMeetings.removeWhere((m) => ids.contains(m.id));
      exitSelectionMode();
      Get.snackbar('✅ Dihapus', '${ids.length} notulen berhasil dihapus.');
    } catch (e) {
      Get.snackbar('❌ Gagal', 'Gagal menghapus notulen yang dipilih.');
    }
  }

  Future<void> deleteAll() async {
    try {
      await provider.bulkDelete(deleteAll: true);
      archivedMeetings.clear();
      exitSelectionMode();
      Get.snackbar('✅ Semua Dihapus', 'Semua notulen berhasil dihapus.');
    } catch (e) {
      Get.snackbar('❌ Gagal', 'Gagal menghapus semua notulen.');
    }
  }
}