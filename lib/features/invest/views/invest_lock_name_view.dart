import 'package:dayfi/common/widgets/text_fields/custom_text_field.dart';
import 'package:dayfi/features/invest/models/invest_lock_draft.dart';
import 'package:dayfi/features/invest/views/invest_lock_preview_view.dart';
import 'package:dayfi/features/invest/widgets/invest_lock_step_scaffold.dart';
import 'package:dayfi/services/remote/investment_service.dart';
import 'package:flutter/material.dart';

class InvestLockNameView extends StatefulWidget {
  final InvestLockDraft draft;
  final InvestmentSummary? summary;
  final VoidCallback? onSuccess;
  final bool showBackButton;

  const InvestLockNameView({
    super.key,
    required this.draft,
    this.summary,
    this.onSuccess,
    this.showBackButton = true,
  });

  @override
  State<InvestLockNameView> createState() => _InvestLockNameViewState();
}

class _InvestLockNameViewState extends State<InvestLockNameView> {
  final _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.draft.name != null) {
      _nameCtrl.text = widget.draft.name!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _canContinue => _nameCtrl.text.trim().isNotEmpty;

  void _continue() {
    widget.draft.name = _nameCtrl.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvestLockPreviewView(
          draft: widget.draft,
          summary: widget.summary,
          onSuccess: widget.onSuccess,
          showBackButton: widget.showBackButton,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InvestLockStepScaffold(
      showBackButton: widget.showBackButton,
      step: 2,
      totalSteps: 4,
      title: 'Name your lock',
      subtitle:
          'Give this lock a short name so you can find it later — e.g. Rent, Emergency, Trip.',
      bottomBar: InvestLockStepScaffold.primaryButton(
        context,
        text: 'Preview lock',
        enabled: _canContinue,
        onPressed: _continue,
      ),
      child: CustomTextField(
        controller: _nameCtrl,
        label: 'Lock name',
        hintText: 'My house rent',
        textCapitalization: TextCapitalization.words,
        maxLength: 120,
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
