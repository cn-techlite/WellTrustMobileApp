// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/state/providers/auth_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/custom_snackbar.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/help_support.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/more_screens.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/my_documents_screen.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/staff_record_widgets.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/settings_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/personal_detail.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/raise_cocerns_bottomshet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/report_incident_bottomsheet.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/package_export.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<AccountPage> {
  String selectedCarType = "";

  @override
  void initState() {
    super.initState();
    // Loads the staff record that the document counts below come from.
    Future.microtask(() {
      ref.read(accountControllerProvider.notifier).getAccount();
    });
  }

  Future<void> urlString(String? url) async {
    final link = Uri.parse(url!);
    if (await canLaunchUrl(link)) {
      await launchUrl(link);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final result = await ref.read(authControllerProvider.notifier).logout();
    if (!mounted) return;

    if (result.isSuccess) {
      navigateAndRemoveUntilRoute(context, const LoginScreens());
      return;
    }

    showCustomSnackbar(
      context,
      title: 'Sign out failed',
      content: result.message ?? 'Please try again.',
      type: SnackbarType.error,
      isTopPosition: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSigningOut = ref.watch(authControllerProvider).isLoading;
    final attention = staffAttentionCount(
      ref.watch(accountControllerProvider).value?.userData,
    );
    final name = globals.userName.trim().isEmpty
        ? 'Staff member'
        : globals.userName.trim();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'More'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Container(
                  color: AppColors.navy,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 64),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _initials(name),
                          style: TextStyle(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              globals.kioskDeviceName.trim().isEmpty
                                  ? 'Staff carer'
                                  : 'Staff carer, ${globals.kioskDeviceName.trim()}'
                                        '${globals.kioskDeviceReference.trim().isEmpty ? '' : ' (${globals.kioskDeviceReference.trim()})'}',
                              style: TextStyle(color: AppColors.brandMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.add_circle_outline,
                          title: 'Open shifts',
                          subtitle: '3 shifts you can ask for',
                          onTap: () => navigateToRoute(
                            context,
                            const OpenShiftsScreen(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.access_time,
                          title: 'My hours',
                          subtitle: 'Care time and travel from your clock-ins',
                          onTap: () =>
                              navigateToRoute(context, const MyHoursScreen()),
                        ),
                        _MenuTile(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'Assessments',
                          subtitle: '2 to complete',
                          onTap: () => navigateToRoute(
                            context,
                            const AssessmentsScreen(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.warning_amber_rounded,
                          title: 'Incident report',
                          subtitle: 'Report something that happened',
                          onTap: () => displayBottomSheet(
                            context,
                            ReportIncidentBottomSheet(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.description_outlined,
                          title: 'Complaints',
                          subtitle: 'Record a complaint or concern',
                          onTap: () => displayBottomSheet(
                            context,
                            RaiseConcernBottomSheet(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.folder_open_outlined,
                          title: 'My documents',
                          subtitle: attention > 0
                              ? '$attention need attention'
                              : 'Documents, certificates and qualifications',
                          badge: attention > 0 ? attention : null,
                          onTap: () =>
                              navigateToRoute(context, const DocumentsScreen()),
                        ),
                        _MenuTile(
                          icon: Icons.person_outline,
                          title: 'My details',
                          subtitle: 'Your details, job and emergency contact',
                          onTap: () => navigateToRoute(
                            context,
                            const AccountDetailsPage(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.settings_outlined,
                          title: 'Settings',
                          subtitle: 'Text size and appearance',
                          onTap: () => displayBottomSheet(
                            context,
                            const SettingsSheet(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.help_outline,
                          title: 'Help & support',
                          subtitle: 'Get help with the app',
                          onTap: () => navigateToRoute(
                            context,
                            const HelpAndSupportPage(),
                          ),
                        ),
                        _MenuTile(
                          icon: Icons.logout,
                          title: 'Sign out',
                          subtitle: 'Return to login',
                          danger: true,
                          onTap: isSigningOut ? null : _signOut,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) => name
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .take(2)
      .map((w) => w[0].toUpperCase())
      .join();
}

/// Menu row from the design's More page (gold icon tile, chevron).
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final int? badge;
  final bool danger;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.danger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 68),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: danger ? AppColors.roseBg : AppColors.goldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 22,
                    color: danger ? AppColors.rose : AppColors.goldDeep,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: danger ? AppColors.rose : AppColors.ink,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (badge != null) ...[
                  Pill.warn('$badge'),
                  const SizedBox(width: 4),
                ],
                Icon(Icons.chevron_right, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
