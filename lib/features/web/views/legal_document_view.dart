import 'package:dayfi/common/utils/dayfi_platform.dart';
import 'package:dayfi/core/theme/app_colors.dart';
import 'package:dayfi/features/web/constants/legal_documents_registry.dart';
import 'package:dayfi/features/web/models/legal_document.dart';
import 'package:dayfi/features/web/utils/web_layout.dart';
import 'package:dayfi/features/web/widgets/landing/landing_copyable_text.dart';
import 'package:dayfi/features/web/widgets/landing/landing_sections.dart';
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

    if (isDayfiWeb) {
      return WebLandingShell(
        activeRoute: _activeRoute,
        fullWidthChild: true,
        child: _LegalDocumentWebBody(document: doc),
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
      body: _LegalDocumentBody(document: doc),
    );
  }
}

class _LegalDocumentWebBody extends StatelessWidget {
  const _LegalDocumentWebBody({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final isMobile = WebLayout.isMobile(viewportWidth);
    final topPad = WebLayout.sectionVerticalGap(viewportWidth) * 2;
    final heroTopPad = topPad * .5;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.hero,
          padding: EdgeInsets.fromLTRB(0, heroTopPad, 0, topPad * .75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LandingCopyableText(
                document.pageTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'FunnelDisplay',
                  fontSize: isMobile ? 68 : 112,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  letterSpacing: -2,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 32),
              LandingCopyableText(
                document.subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  letterSpacing: 0.2,
                  color: AppColors.neutral800,
                ),
              ),
              const SizedBox(height: 16),
              LandingCopyableText(
                document.effectiveDate,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Chirp',
                  fontSize: isMobile ? 14 : 16,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
        LandingFullBleedSection(
          backgroundColor: LandingSectionColors.hero,
          padding: EdgeInsets.only(bottom: topPad * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...document.sections.map(
                (section) => _LegalSectionBlock(
                  section: section,
                  isWeb: true,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ),
      ],
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
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                (section) => _LegalSectionBlock(
                  section: section,
                  isWeb: false,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalSectionBlock extends StatelessWidget {
  const _LegalSectionBlock({
    required this.section,
    required this.isWeb,
    required this.isMobile,
  });

  final LegalSection section;
  final bool isWeb;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      fontFamily: 'FunnelDisplay',
      fontSize: isWeb ? (isMobile ? 28 : 36) : 22,
      fontWeight: isWeb ? FontWeight.w500 : FontWeight.w600,
      height: isWeb ? 1.1 : null,
      letterSpacing: isWeb ? -1 : -0.3,
      color: isWeb ? AppColors.neutral900 : null,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'Chirp',
      fontSize: isWeb ? (isMobile ? 16 : 18) : 15,
      height: 1.55,
      letterSpacing: isWeb ? 0.2 : -0.2,
      color: isWeb ? AppColors.neutral800 : null,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: isWeb ? 48 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: isWeb ? 44 : 36,
                height: isWeb ? 44 : 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.orange500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(isWeb ? 12 : 8),
                ),
                child: Text(
                  section.number,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: 'FunnelDisplay',
                    fontSize: isWeb ? 16 : null,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isWeb
                    ? LandingCopyableText(section.title, style: titleStyle)
                    : Text(section.title, style: titleStyle),
              ),
            ],
          ),
          SizedBox(height: isWeb ? 20 : 12),
          ...section.paragraphs.map(
            (paragraph) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isWeb
                  ? LandingCopyableText(paragraph, style: bodyStyle)
                  : Text(paragraph, style: bodyStyle),
            ),
          ),
        ],
      ),
    );
  }
}
