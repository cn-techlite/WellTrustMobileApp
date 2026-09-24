import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';

/// "5 Mar 2026", or null when there is no date.
String? fmtDate(DateTime? d) =>
    d == null ? null : DateFormat('d MMM yyyy').format(d.toLocal());

/// Text from the API, or null when it is empty or an "N/A - reason" sentence,
/// which the API uses for fields that do not apply.
String? applicable(String? v) {
  final t = v?.trim() ?? '';
  return t.isEmpty || t.toUpperCase().startsWith('N/A') ? null : t;
}

/// £12.75 style money, or null.
String? fmtMoney(num? v, String? currency) {
  if (v == null) return null;
  final symbol = switch (currency) {
    'GBP' || null || '' => '£',
    'EUR' => '€',
    'USD' => r'$',
    final c => '$c ',
  };
  return '$symbol${NumberFormat('#,##0.00').format(v)}';
}

/// Where an expiry date stands. A record with no expiry never expires.
enum ExpiryState { none, valid, soon, expired }

ExpiryState expiryStateOf(DateTime? expiry, {int soonDays = 30}) {
  if (expiry == null) return ExpiryState.none;
  final now = DateTime.now();
  if (expiry.isBefore(now)) return ExpiryState.expired;
  if (expiry.difference(now).inDays <= soonDays) return ExpiryState.soon;
  return ExpiryState.valid;
}

Pill? expiryPill(DateTime? expiry) => switch (expiryStateOf(expiry)) {
  ExpiryState.expired => Pill.bad('Expired'),
  ExpiryState.soon => Pill.warn('Expires soon'),
  ExpiryState.valid || ExpiryState.none => null,
};

/// How many certificates, qualifications and checks need the carer's
/// attention: expired, or expiring in the next 30 days.
int staffAttentionCount(RegisterResponseModel? user) {
  if (user == null) return 0;
  bool needs(DateTime? d) {
    final s = expiryStateOf(d);
    return s == ExpiryState.expired || s == ExpiryState.soon;
  }

  var n = 0;
  n += user.certificates.where((c) => needs(c.expiryDate)).length;
  n += user.qualifications.where((q) => needs(q.expiryDate)).length;
  final c = user.compliance;
  if (c != null) {
    if (needs(c.dbsExpiryDate)) n++;
    if (needs(c.rightToWorkExpiryDate)) n++;
    if (needs(c.passportExpiryDate)) n++;
    if (needs(c.visaExpiryDate)) n++;
    if (needs(c.registrationExpiryDate)) n++;
  }
  return n;
}

/// "PartTime" as "Part time".
String employmentTypeLabel(String v) => switch (v) {
  'FullTime' => 'Full time',
  'PartTime' => 'Part time',
  _ => v,
};

/// "PreferNotToSay" as "Prefer not to say".
String genderLabel(String v) => v == 'PreferNotToSay' ? 'Prefer not to say' : v;

/// "CanViewOwnProfile" as "Can view own profile", "OneToOne" as "One to one".
String humanize(String v) {
  final words = v
      .replaceAllMapped(RegExp(r'(?<=[a-z0-9])(?=[A-Z])'), (_) => ' ')
      .trim();
  if (words.isEmpty) return words;
  return words[0].toUpperCase() + words.substring(1).toLowerCase();
}

/// A coloured pill for an API status such as Active, Requested or Passed.
Pill statusPill(String? status) {
  final s = status ?? '';
  final label = humanize(s);
  return switch (s) {
    'Active' ||
    'Compliant' ||
    'Clear' ||
    'Verified' ||
    'Issued' ||
    'Competent' ||
    'Passed' ||
    'Completed' ||
    'Confirmed' ||
    'Received' => Pill.ok(label),
    'Pending' ||
    'OnLeave' ||
    'Draft' ||
    'In Progress' ||
    'InProgress' ||
    'Requested' ||
    'Scheduled' ||
    'Extended' ||
    'RequiresReview' => Pill.warn(label),
    'Expired' ||
    'Barred' ||
    'Refused' ||
    'NotVerified' ||
    'Not Yet Competent' ||
    'Failed' ||
    'Declined' ||
    'Overdue' ||
    'Cancelled' => Pill.bad(label),
    _ => Pill.neutral(label),
  };
}

/// A label and its value. Shows [empty] ("Not set") when there is no value.
/// [valueWidget] replaces the text, for a pill in the value's place.
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final Widget? trailing;
  final String empty;

  const InfoRow(
    this.label,
    this.value, {
    super.key,
    this.valueWidget,
    this.trailing,
    this.empty = 'Not set',
  });

  @override
  Widget build(BuildContext context) {
    final has = value != null && value!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                if (valueWidget != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: valueWidget!,
                  )
                else
                  Text(
                    has ? value! : empty,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: has ? FontWeight.w600 : FontWeight.w400,
                      color: has ? AppColors.ink : AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A design card with a heading and an optional action button.
class SectionCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget> children;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.ink,
                  ),
                ),
              ),
              if (actionLabel != null)
                DesignButton(
                  actionLabel!,
                  small: true,
                  secondary: true,
                  onPressed: onAction,
                ),
            ],
          ),
          ...children,
        ],
      ),
    );
  }
}

/// Explains an empty list or a section nothing has been recorded for.
class EmptyBox extends StatelessWidget {
  final String title;
  final String? body;

  const EmptyBox(this.title, {super.key, this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line2, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          if (body != null) ...[
            const SizedBox(height: 4),
            Text(
              body!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}
