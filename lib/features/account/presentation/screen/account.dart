// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:well_trust_mobile_app/core/utils/size_config.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/package_export.dart';
import '../../../../shared/widgets/app_text.dart';

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
    // final notifier = ref.read(accountControllerProvider.notifier);
    Future.microtask(() {
      //   notifier.getAccount();
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

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<ScaffoldMessengerState>();

    // final accountAsync = ref.watch(accountControllerProvider);
    // final account = accountAsync.value;
    // final user = account?.userData;
    // final hasLoadedInitially2 = account?.hasFetchedAccount ?? false;
    // final isLoading = accountAsync.isLoading && !hasLoadedInitially2;

    return Scaffold(
      key: key,
      backgroundColor: AppColors.navyDeepest,

      body: SafeArea(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StaffProfileHeaderUi(),

                AppMenuList(
                  items: [
                    AppMenuItemData(
                      icon: '📹',
                      title: 'Meetings',
                      subtitle:
                          'Handovers, supervisions, family meetings · 3 today',
                      badge: 3,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '💬',
                      title: 'Messages',
                      subtitle: 'Chat with co-ordinator and fellow carers',
                      badge: 2,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '⚠️',
                      title: 'Report an incident',
                      subtitle: 'Falls, medication errors, near-miss',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '🚩',
                      title: 'Raise a concern',
                      subtitle: 'Early warning to the co-ordinator',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '📋',
                      title: 'Competencies',
                      subtitle: '5 assigned · 3 pending',
                      badge: 3,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '📜',
                      title: 'Policies',
                      subtitle: '6 policies · 2 to read',
                      badge: 2,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '✍️',
                      title: 'Declarations',
                      subtitle: '4 on file · 3 to complete',
                      badge: 3,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '💡',
                      title: 'Suggestions & feedback',
                      subtitle: 'Help shape how the home runs',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '📄',
                      title: 'My documents',
                      subtitle: "Upload certificates, see what's expiring",
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '🎓',
                      title: 'Training',
                      subtitle: '3 modules · 2 expiring in 30 days',
                      badge: 2,
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '🗣',
                      title: 'Supervisions',
                      subtitle: 'Last 3 months ago · next due in 2 weeks',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '🏖',
                      title: 'Holidays',
                      subtitle: '14 days remaining this year',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '📊',
                      title: 'Pay & timesheets',
                      subtitle: 'Last paid: 28 May · next: 28 Jun',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '❓',
                      title: 'Help & support',
                      subtitle: 'Get help with the app',
                      onTap: () {},
                    ),
                    AppMenuItemData(
                      icon: '↩',
                      title: 'Sign out',
                      subtitle: 'Return to login',
                      isDanger: true,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class StaffProfileHeaderUi extends StatelessWidget {
  const StaffProfileHeaderUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.navyDeepest,
      padding: const EdgeInsets.fromLTRB(8, 10, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .20),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const AppText(
                  text: "SO",
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  type: AppTextType.headlineLarge,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 6,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.navy,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          addVerticalSpacing(3),

          const AppText(
            text: "Samir Okonjo",
            textAlign: TextAlign.start,
            color: Colors.white,
            type: AppTextType.headlineMedium,
            fontWeight: FontWeight.w600,
          ),

          addVerticalSpacing(.3),

          const AppText(
            text: "Senior Domiciliary Carer · Kettering area",
            textAlign: TextAlign.start,
            color: Color(0xFFD8DDEA),
            type: AppTextType.bodyLarge,
            fontWeight: FontWeight.w400,
          ),

          addVerticalSpacing(3),

          const Row(
            children: [
              Expanded(
                child: ProfileStatBox(value: "32h", label: "THIS WEEK"),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ProfileStatBox(value: "12", label: "NOTES"),
              ),
              SizedBox(width: 20),
              Expanded(
                child: ProfileStatBox(value: "100%", label: "COMPLIANCE"),
              ),
            ],
          ),

          addVerticalSpacing(1),

          Row(
            children: [
              Expanded(
                child: ProfileActionButton(
                  text: "🚨 Safeguarding",
                  backgroundColor: const Color(0xFFB44D45),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProfileActionButton(
                  text: "🚩 Concern",
                  backgroundColor: const Color(0xFFC97D37),
                  onTap: () {},
                ),
              ),
            ],
          ),

          addVerticalSpacing(1),

          const SafetyCheckInfoBox(),
        ],
      ),
    );
  }
}

class ProfileStatBox extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 11.heightAdjusted,
      decoration: BoxDecoration(
        color: const Color(0xFF2A3A5B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: value,
            textAlign: TextAlign.center,
            color: Colors.white,
            type: AppTextType.headlineSmall,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 8),
          AppText(
            text: label,
            textAlign: TextAlign.center,
            color: const Color(0xFFD8DDEA),
            type: AppTextType.labelSmall,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}

class ProfileActionButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const ProfileActionButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6.heightAdjusted,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: AppText(
          text: text,
          textAlign: TextAlign.center,
          color: AppColors.white,
          type: AppTextType.labelMedium,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class SafetyCheckInfoBox extends StatelessWidget {
  const SafetyCheckInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF233150),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF56627C), width: 1.5),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextType.bodySmall.style(
            context,
            color: AppColors.white,
            fontSize: 12,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: "🛡️ Safety check-in: ",
              style: AppTextType.bodySmall.style(
                context,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text:
                  "When you start a visit, the system watches the clock. If you go ",
            ),
            TextSpan(
              text: "15 min past scheduled end",
              style: AppTextType.bodySmall.style(
                context,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text:
                  ", you'll get an \"Are you OK?\" prompt. If you don't respond within ",
            ),
            TextSpan(
              text: "5 more min",
              style: AppTextType.bodySmall.style(
                context,
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: ", the on-call manager is alerted automatically.\n\n",
            ),
            TextSpan(
              text:
                  "Honest demo note: works while the app is open. In production this uses push notifications even when the phone is locked.",
              style: AppTextType.bodySmall.style(
                context,
                color: Color(0xFFD8DDEA),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//! LIST ITEMS ON ACCOUNT PAGE

class AppMenuList extends StatelessWidget {
  final List<AppMenuItemData> items;

  const AppMenuList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return AppMenuTile(item: item);
      }).toList(),
    );
  }
}

class AppMenuTile extends StatelessWidget {
  final AppMenuItemData item;

  const AppMenuTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 8, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE2D9C9), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2D9C9), width: 1.5),
              ),
              alignment: Alignment.center,
              child: AppText(
                text: item.icon,
                textAlign: TextAlign.center,
                color: AppColors.black,
                type: AppTextType.labelSmall,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(width: 6),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: item.title,
                    textAlign: TextAlign.start,
                    color: item.isDanger
                        ? const Color(0xFFB85048)
                        : Colors.black,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 5),
                  AppText(
                    text: item.subtitle,
                    textAlign: TextAlign.start,
                    color: AppColors.muted,
                    type: AppTextType.bodyMedium,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),

            if (item.badge != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFB85048),
                  shape: BoxShape.circle,
                ),
                child: AppText(
                  text: item.badge.toString(),
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 2),
            ],

            Icon(Icons.chevron_right, color: AppColors.muted, size: 32),
          ],
        ),
      ),
    );
  }
}

class AppMenuItemData {
  final String icon;
  final String title;
  final String subtitle;
  final int? badge;
  final bool isDanger;
  final VoidCallback? onTap;

  const AppMenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    this.isDanger = false,
    this.onTap,
  });
}
