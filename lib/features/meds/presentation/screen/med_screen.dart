import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/meds/presentation/state/provider/package_provider.dart';
import 'package:well_trust_mobile_app/features/meds/presentation/widget/medication_resident_card.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/list_tile_widget.dart';

class MedScreen extends ConsumerStatefulWidget {
  const MedScreen({super.key});

  @override
  ConsumerState<MedScreen> createState() => _MedScreenState();
}

class _MedScreenState extends ConsumerState<MedScreen>
    with TickerProviderStateMixin {
  late final TabController tabController;
  final ScrollController scrollController = ScrollController();

  String userPhone = "";

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    Future.microtask(() async {});

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref
          .read(packageOrderControllerProvider.notifier)
          .loadMoreListPackageOrder();
    }
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();

    tabController.dispose();

    super.dispose();
  }

  void selectTab(int index) {
    tabController.animateTo(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: "Medication Round",
                          textAlign: TextAlign.start,
                          color: AppColors.muted,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w500,
                        ),

                        AppText(
                          text: greetingWithTime(),
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          type: AppTextType.bodyMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.navy, AppColors.navyDeep],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      color: AppColors.primaryDark,
                    ),
                    alignment: Alignment.center,
                    child: const AppText(
                      text: "CN",
                      textAlign: TextAlign.start,
                      color: AppColors.black,
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      addVerticalSpacing(3),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE2D9C9),
                            width: 1.4,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppText(
                              text: "💊",
                              textAlign: TextAlign.start,
                              color: AppColors.black,
                              type: AppTextType.headlineSmall,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: AppTextType.bodySmall.style(
                                    context,
                                    color: AppColors.black,
                                    fontSize: 15,
                                    height: 1.45,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "2-stage sign-off: ",
                                      style: AppTextType.titleMedium.style(
                                        context,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          "Tap a medication to view dose and confirm. Witness sign required for controlled drugs.",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      addVerticalSpacing(3),
                      SectionHead("Medication Due"),
                      MedicationResidentCard(
                        initials: 'AP',
                        name: 'Anita Patel',
                        address: '14 Linden Avenue',
                        medsToday: 4,
                        given: 2,
                        due: 2,
                        onView: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
