import 'package:dayfi/features/dayx_v2/constants/dayx_v2_voices.dart';
import 'package:dayfi/features/dayx_v2/services/dayx_v2_prefs.dart';
import 'package:flutter/material.dart';

/// ChatGPT-style voice carousel before first DayX v2 session.
class DayxV2VoicePicker extends StatefulWidget {
  final VoidCallback onDone;

  const DayxV2VoicePicker({super.key, required this.onDone});

  @override
  State<DayxV2VoicePicker> createState() => _DayxV2VoicePickerState();
}

class _DayxV2VoicePickerState extends State<DayxV2VoicePicker> {
  final _page = PageController();
  int _index = 0;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final voice = DayxV2Voices.profiles[_index];
    await DayxV2Prefs.setSelectedVoice(voice.id);
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final profile = DayxV2Voices.profiles[_index];
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Choose a voice',
              style: TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 220,
              child: PageView.builder(
                controller: _page,
                itemCount: DayxV2Voices.profiles.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final p = DayxV2Voices.profiles[i];
                  return Center(
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(p.gradient[0]),
                            Color(p.gradient[1]),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(p.gradient[0]).withValues(alpha: 0.35),
                            blurRadius: 32,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            Text(
              profile.label,
              style: const TextStyle(
                fontFamily: 'FunnelDisplay',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.tagline,
              style: TextStyle(
                fontFamily: 'Chirp',
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                DayxV2Voices.profiles.length,
                (i) => Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontFamily: 'Chirp',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
