import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/web/constants/legal_documents_registry.dart';
import 'package:dayfi/features/web/models/legal_document.dart';
import 'package:dayfi/features/web/utils/web_layout.dart';
import 'package:dayfi/features/web/widgets/web_landing_shell.dart';
import 'package:dayfi/routes/route.dart';
import 'package:flutter/material.dart';

class LegalDocumentView extends StatelessWidget {
  const LegalDocumentView({
    super.key,
    required this.documentId,
  });

  final LegalDocumentId documentId;

  LegalDocument get _document => LegalDocuments.forId(documentId);

  String get _activeRoute {
    switch (documentId) {
      case LegalDocumentId.terms:
        return AppRoute.webTermsPath;
      case LegalDocumentId.privacy:
        return AppRoute.webPrivacyPath;
      case LegalDocumentId.about:
        return AppRoute.webAboutPath;
      case LegalDocumentId.security:
        return AppRoute.webSecurityPath;
      case LegalDocumentId.government:
        return AppRoute.webGovernmentPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _document;
    final body = _LegalDocumentBody(document: doc);

    if (isDayfiWeb) {
      return WebLandingShell(
        activeRoute: _activeRoute,
        child: body,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).textTheme.headlineLarge?.color,
          ),
        ),
        title: Text(
          doc.pageTitle,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'FunnelDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: body,
    );
  }
}

class _LegalDocumentBody extends StatelessWidget {
  const _LegalDocumentBody({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = WebLayout.isMobile(constraints.maxWidth);

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            0,
            isDayfiWeb ? 24 : 16,
            0,
            48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isDayfiWeb) ...[
                Text(
                  document.pageTitle,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(
                document.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 16 : 18,
                  height: 1.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                document.effectiveDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              ...document.sections.map(
                (section) => _LegalSectionBlock(section: section),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalSectionBlock extends StatelessWidget {
  const _LegalSectionBlock({required this.section});

  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orange500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  section.number,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  section.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                paragraph,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: 15,
                  height: 1.55,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
