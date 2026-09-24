import 'package:well_trust_mobile_app/core/services/upload_service.dart';
import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

/// Opens a form sheet. If the sheet closes with a message (it saved), the
/// message is shown as a success snackbar on the page underneath.
Future<void> openStaffSheet(BuildContext context, Widget sheet) async {
  final message = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) =>
        Padding(padding: MediaQuery.of(context).viewInsets, child: sheet),
  );
  if (message != null && context.mounted) {
    showCustomSnackbar(
      context,
      title: 'Saved',
      content: message,
      type: SnackbarType.success,
      isTopPosition: false,
    );
  }
}

/// Save handling for a form sheet: shows the spinner on the button, keeps the
/// sheet open with the error if the save fails, and closes it if it works.
mixin StaffSheetSaving<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool saving = false;
  String? saveError;

  Future<void> submit(Future<GeneralResultModel> Function() action) async {
    setState(() {
      saving = true;
      saveError = null;
    });
    final result = await action();
    if (!mounted) return;
    if (result.isSuccess) {
      Navigator.pop(context, result.message ?? 'Saved');
      return;
    }
    setState(() {
      saving = false;
      saveError = result.message ?? 'Could not save. Please try again.';
    });
  }
}

/// A form sheet: title, scrolling fields and a Save button.
class StaffSheet extends StatelessWidget {
  final String title;
  final String? intro;
  final List<Widget> children;
  final String saveLabel;
  final bool saving;
  final bool canSave;
  final String? error;
  final VoidCallback onSave;

  const StaffSheet({
    super.key,
    required this.title,
    required this.children,
    required this.onSave,
    this.intro,
    this.saveLabel = 'Save',
    this.saving = false,
    this.canSave = true,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: AppColors.ink,
                ),
              ),
              if (intro != null) ...[
                const SizedBox(height: 4),
                Text(intro!, style: TextStyle(color: AppColors.muted)),
              ],
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final c in children) ...[
                        c,
                        const SizedBox(height: 14),
                      ],
                    ],
                  ),
                ),
              ),
              if (error != null) ...[
                NoticeBox(
                  error!,
                  bg: AppColors.roseBg,
                  fg: AppColors.rose,
                  icon: Icons.error_outline,
                ),
                const SizedBox(height: 10),
              ],
              AppButton(
                text: saveLabel,
                onPressed: (saving || !canSave) ? null : onSave,
                isLoading: saving,
                fontSize: 16,
                heightPercent: 6.5,
                btnColor: AppColors.primary,
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _labelled(String label, Widget field, {bool required = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        required ? '$label *' : label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.ink,
        ),
      ),
      const SizedBox(height: 6),
      field,
    ],
  );
}

/// Label above a text box. Optional unless [required]. Spaces are allowed and
/// there is no digit or length rule beyond [maxLength], so it suits UK phone
/// numbers, addresses and notes.
class StaffTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final bool email;
  final bool name;
  final bool multiline;
  final int maxLength;
  final ValueChanged<String?>? onChanged;

  const StaffTextField({
    super.key,
    required this.label,
    required this.controller,
    this.required = false,
    this.email = false,
    this.name = false,
    this.multiline = false,
    this.maxLength = 80,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _labelled(
      label,
      GlobalTextField(
        fieldName: label,
        keyBoardType: email
            ? TextInputType.emailAddress
            : name
            ? TextInputType.name
            : TextInputType.text,
        textController: controller,
        removeSpace: false,
        isOptional: !required,
        isNotePad: multiline,
        maxLength: multiline ? 500 : maxLength,
        onChanged: onChanged,
      ),
      required: required,
    );
  }
}

/// A tappable date box with the app's date picker. Shows a clear button when
/// [allowClear] is set, for dates that can be left empty.
class StaffDateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final bool allowClear;
  final bool future;

  const StaffDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowClear = true,
    this.future = false,
  });

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: DateTime(1930),
      lastDate: DateTime(now.year + (future ? 15 : 1)),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return _labelled(
      label,
      InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.only(left: 14, right: 6),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.line2, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value == null
                      ? 'Choose a date'
                      : DateFormat('d MMM yyyy').format(value!),
                  style: TextStyle(
                    fontSize: 16,
                    color: value == null ? AppColors.muted : AppColors.ink,
                  ),
                ),
              ),
              if (allowClear && value != null)
                IconButton(
                  tooltip: 'Clear date',
                  onPressed: () => onChanged(null),
                  icon: Icon(Icons.close, size: 20, color: AppColors.muted),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A pick-one box. [value] must be one of [options] (or null for none yet).
class StaffDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String Function(String)? display;

  const StaffDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.display,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.line2, width: 1.5),
    );
    return _labelled(
      label,
      DropdownButtonFormField<String>(
        initialValue: options.contains(value) ? value : null,
        isExpanded: true,
        dropdownColor: AppColors.surface,
        hint: Text('Choose', style: TextStyle(color: AppColors.muted)),
        style: TextStyle(fontSize: 16, color: AppColors.ink),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
        ),
        items: [
          for (final o in options)
            DropdownMenuItem(value: o, child: Text(display?.call(o) ?? o)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

/// Attach a file to a record. The file goes through the app's upload service,
/// and the URL it returns is handed to [onUrl] to be saved with the record.
class StaffAttachment extends StatefulWidget {
  final String label;
  final String url;

  /// Which folder the server stores the file in.
  final UploadFolder folder;
  final ValueChanged<String> onUrl;
  final ValueChanged<bool> onBusy;

  const StaffAttachment({
    super.key,
    required this.label,
    required this.url,
    required this.folder,
    required this.onUrl,
    required this.onBusy,
  });

  @override
  State<StaffAttachment> createState() => _StaffAttachmentState();
}

class _StaffAttachmentState extends State<StaffAttachment> {
  bool _uploading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image == null) return;

      setState(() {
        _uploading = true;
        _error = null;
      });
      widget.onBusy(true);

      final url = await ApiService.upload(image.path, folder: widget.folder);
      if (!mounted) return;
      widget.onUrl(url);
    } on UploadException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The upload did not work. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
      widget.onBusy(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final has = widget.url.isNotEmpty;
    return _labelled(
      widget.label,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_uploading)
            Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text('Uploading...', style: TextStyle(color: AppColors.muted)),
              ],
            )
          else if (has)
            Row(
              children: [
                Pill.ok('File attached'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(widget.url),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text('View', style: TextStyle(color: AppColors.ink)),
                ),
              ],
            )
          else
            Text('No file yet', style: TextStyle(color: AppColors.muted)),
          if (_error != null) ...[
            const SizedBox(height: 4),
            Text(_error!, style: TextStyle(color: AppColors.rose)),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DesignButton(
                  has ? 'Replace photo' : 'Choose photo',
                  secondary: true,
                  small: true,
                  icon: Icons.photo_outlined,
                  onPressed: _uploading
                      ? null
                      : () => _pick(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DesignButton(
                  'Take photo',
                  secondary: true,
                  small: true,
                  icon: Icons.photo_camera_outlined,
                  onPressed: _uploading
                      ? null
                      : () => _pick(ImageSource.camera),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Text trimmed, or empty when null.
String clean(TextEditingController c) => c.text.trim();
