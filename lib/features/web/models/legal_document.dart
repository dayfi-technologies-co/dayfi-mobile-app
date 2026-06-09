enum LegalDocumentId {
  terms,
  privacy,
  about,
  security,
  government,
}

class LegalSection {
  const LegalSection({
    required this.number,
    required this.title,
    required this.paragraphs,
  });

  final String number;
  final String title;
  final List<String> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.pageTitle,
    required this.subtitle,
    required this.effectiveDate,
    required this.sections,
  });

  final LegalDocumentId id;
  final String pageTitle;
  final String subtitle;
  final String effectiveDate;
  final List<LegalSection> sections;
}
