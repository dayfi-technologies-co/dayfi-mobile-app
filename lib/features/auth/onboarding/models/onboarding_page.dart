class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String illustrationPath;
  final List<String> decorativeElements;
  final Map<String, Map<String, double>> decorativeElementPositions;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.illustrationPath,
    this.decorativeElements = const [],
    this.decorativeElementPositions = const {},
  });
}
