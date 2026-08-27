/// YarnGPT voice profiles for DayX v2 voice picker.
class DayxV2VoiceProfile {
  final String id;
  final String label;
  final String tagline;
  final List<int> gradient;

  const DayxV2VoiceProfile({
    required this.id,
    required this.label,
    required this.tagline,
    required this.gradient,
  });
}

abstract final class DayxV2Voices {
  DayxV2Voices._();

  static const profiles = <DayxV2VoiceProfile>[
    DayxV2VoiceProfile(
      id: 'Idera',
      label: 'Idera',
      tagline: 'Warm and clear',
      gradient: [0xFF7DD3FC, 0xFFE0F2FE],
    ),
    DayxV2VoiceProfile(
      id: 'Tayo',
      label: 'Tayo',
      tagline: 'Friendly Lagos vibe',
      gradient: [0xFF86EFAC, 0xFFDCFCE7],
    ),
    DayxV2VoiceProfile(
      id: 'Nonso',
      label: 'Nonso',
      tagline: 'Calm and steady',
      gradient: [0xFFA78BFA, 0xFFEDE9FE],
    ),
    DayxV2VoiceProfile(
      id: 'Emma',
      label: 'Emma',
      tagline: 'Bright and upbeat',
      gradient: [0xFFFDE68A, 0xFFFEF9C3],
    ),
    DayxV2VoiceProfile(
      id: 'Zainab',
      label: 'Zainab',
      tagline: 'Soft and reassuring',
      gradient: [0xFFF9A8D4, 0xFFFCE7F3],
    ),
    DayxV2VoiceProfile(
      id: 'Femi',
      label: 'Femi',
      tagline: 'Confident and direct',
      gradient: [0xFF93C5FD, 0xFFDBEAFE],
    ),
    DayxV2VoiceProfile(
      id: 'Chinenye',
      label: 'Chinenye',
      tagline: 'Gentle and patient',
      gradient: [0xFFFCA5A5, 0xFFFEE2E2],
    ),
    DayxV2VoiceProfile(
      id: 'Adaora',
      label: 'Adaora',
      tagline: 'Polished and warm',
      gradient: [0xFF6EE7B7, 0xFFD1FAE5],
    ),
  ];

  static DayxV2VoiceProfile byId(String id) {
    return profiles.firstWhere(
      (p) => p.id.toLowerCase() == id.toLowerCase(),
      orElse: () => profiles.first,
    );
  }
}
