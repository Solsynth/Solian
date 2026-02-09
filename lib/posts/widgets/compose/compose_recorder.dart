import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/services/time.dart';
import 'package:island/talker.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/core/widgets/content/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart' hide Amplitude;
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:waveform_flutter/waveform_flutter.dart';

class ComposeRecorder extends HookConsumerWidget {
  const ComposeRecorder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recording = useState(false);
    final recordingStartAt = useState<DateTime?>(null);
    final recordingDuration = useState<Duration>(Duration(seconds: 0));

    StreamSubscription? originalAmplitude;
    StreamController<Amplitude> amplitudeStream = StreamController();
    var record = AudioRecorder();

    final resultPath = useState<String?>(null);

    Future<void> startRecord() async {
      recording.value = true;

      // Check and request permission if needed
      final tempPath = !kIsWeb ? (await getTemporaryDirectory()).path : 'temp';
      final uuid = const Uuid().v4().substring(0, 8);
      if (!await record.hasPermission()) return;

      const recordConfig = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      );
      resultPath.value = '$tempPath/solar-network-record-$uuid.m4a';
      await record.start(recordConfig, path: resultPath.value!);

      recordingStartAt.value = DateTime.now();
      originalAmplitude = record
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((value) async {
            amplitudeStream.add(
              Amplitude(current: value.current, max: value.max),
            );
            recordingDuration.value = DateTime.now().difference(
              recordingStartAt.value!,
            );
          });
    }

    useEffect(() {
      return () {
        // Called when widget is unmounted
        talker.info('[Recorder] Clean up!');
        originalAmplitude?.cancel();
        amplitudeStream.close();
        record.dispose();
      };
    }, []);

    Future<void> stopRecord() async {
      recording.value = false;
      await record.pause();
      final newResult = await record.stop();
      await record.cancel();
      if (newResult != null) resultPath.value = newResult;

      if (context.mounted) Navigator.of(context).pop(resultPath.value);
    }

    Future<void> addExistingAudio() async {
      var result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'm4a', 'wav', 'aac', 'flac', 'ogg', 'opus'],
        onFileLoading: (status) {
          if (!context.mounted) return;
          if (status == FilePickerStatus.picking) {
            showLoadingModal(context);
          } else {
            hideLoadingModal(context);
          }
        },
      );
      if (result == null || result.count == 0) return;
      if (context.mounted) Navigator.of(context).pop(result.files.first.path);
    }

    return SheetScaffold(
      titleText: "recordAudio".tr(),
      actions: [
        IconButton(
          onPressed: addExistingAudio,
          icon: const Icon(Symbols.upload),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Gap(32),
          Text(
            recordingDuration.value.formatShortDuration(),
          ).fontSize(20).bold().padding(bottom: 8),
          SizedBox(
            height: 120,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: AnimatedWaveList(stream: amplitudeStream.stream),
                ),
              ),
            ),
          ).padding(horizontal: 24),
          const Gap(12),
          IconButton.filled(
            onPressed: recording.value ? stopRecord : startRecord,
            iconSize: 32,
            icon: recording.value
                ? const Icon(Symbols.stop, fill: 1, color: Colors.white)
                : const Icon(Symbols.play_arrow, fill: 1, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
