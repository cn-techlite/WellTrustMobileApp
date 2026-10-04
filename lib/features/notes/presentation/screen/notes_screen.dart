import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/screen/new_care_note_page.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/providers/care_note_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(careNotesProvider).notes;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Notes'),
          Expanded(
            child: SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                children: [
                  AppText(
                    text:
                        'Care notes you have written. Notes from a visit are added when you finish it.',
                    type: AppTextType.bodySmall,
                    color: AppColors.muted,
                  ),
                  addVerticalSpacing(2.13),
                  DesignButton(
                    'Add a care note',
                    onPressed: () =>
                        navigateToRoute(context, const NewCareNotePage()),
                  ),
                  addVerticalSpacing(2.13),
                  if (notes.isEmpty)
                    const _EmptyNotes()
                  else
                    ...notes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CareNoteRecord(note: note),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          AppText(
            text: 'No care notes yet',
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.59),
          AppText(
            text: 'Finish a visit or add a note and it appears here.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CareNoteRecord extends StatelessWidget {
  final CareNoteEntry note;

  const _CareNoteRecord({required this.note});

  Widget _statusPill(CareNoteEntry note) {
    if (note.flagged) return Pill.bad('Flagged');
    if (note.outcome != null) {
      return note.outcome == 'concern'
          ? Pill.bad('Concern raised')
          : Pill.ok('No concerns');
    }
    if (note.mood.isNotEmpty) {
      return note.mood == 'Settled'
          ? Pill.ok(note.mood)
          : Pill.warn(note.mood);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final preferred = note.clientName.isNotEmpty
        ? note.clientName
        : 'Person supported';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            iconColor: AppColors.muted,
            collapsedIconColor: AppColors.muted,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: preferred,
                        type: AppTextType.bodySmall,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                      addVerticalSpacing(0.24),
                      AppText(
                        text: DateFormat('d MMM, HH:mm').format(note.at),
                        type: AppTextType.labelLarge,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                ),
                addHorizontalSpacing(2.05),
                _statusPill(note),
              ],
            ),
            children: [
              Divider(height: 1, color: AppColors.line),
              addVerticalSpacing(1.66),
              if (note.visitDate != null) ...[
                _NoteValue(
                  label: 'Visit date',
                  value: DateFormat('d MMM yyyy').format(note.visitDate!),
                ),
                addVerticalSpacing(1.42),
              ],
              if (note.startTime != null || note.endTime != null) ...[
                _NoteValue(
                  label: 'Visit time',
                  value: '${note.startTime ?? '-'} – ${note.endTime ?? '-'}',
                ),
                addVerticalSpacing(1.42),
              ],
              if (note.supportType != null) ...[
                _NoteValue(label: 'Support type', value: note.supportType!),
                addVerticalSpacing(1.42),
              ],
              if (note.mood.isNotEmpty) ...[
                _NoteValue(label: 'How they were', value: note.mood),
                addVerticalSpacing(1.42),
              ],
              if (note.intake.isNotEmpty) ...[
                _NoteValue(label: 'Food and drink', value: note.intake),
                addVerticalSpacing(1.42),
              ],
              if (note.skin.isNotEmpty) ...[
                _NoteValue(label: 'Skin and comfort', value: note.skin),
                addVerticalSpacing(1.42),
              ],
              _NoteValue(label: 'Note', value: note.text),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteValue extends StatelessWidget {
  final String label;
  final String value;

  const _NoteValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 126,
          child: AppText(
            text: label,
            type: AppTextType.labelLarge,
            color: AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: AppText(
            text: value,
            type: AppTextType.bodySmall,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}
