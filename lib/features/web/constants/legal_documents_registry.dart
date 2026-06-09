import 'package:dayfi/features/web/constants/about_legal_content.dart';
import 'package:dayfi/features/web/constants/government_legal_content.dart';
import 'package:dayfi/features/web/constants/privacy_legal_content.dart';
import 'package:dayfi/features/web/constants/security_legal_content.dart';
import 'package:dayfi/features/web/constants/terms_legal_content.dart';
import 'package:dayfi/features/web/models/legal_document.dart';

class LegalDocuments {
  LegalDocuments._();

  static const LegalDocument terms = termsLegalDocument;
  static const LegalDocument privacy = privacyLegalDocument;
  static const LegalDocument about = aboutLegalDocument;
  static const LegalDocument security = securityLegalDocument;
  static const LegalDocument government = governmentLegalDocument;

  static LegalDocument forId(LegalDocumentId id) {
    switch (id) {
      case LegalDocumentId.terms:
        return terms;
      case LegalDocumentId.privacy:
        return privacy;
      case LegalDocumentId.about:
        return about;
      case LegalDocumentId.security:
        return security;
      case LegalDocumentId.government:
        return government;
    }
  }
}
