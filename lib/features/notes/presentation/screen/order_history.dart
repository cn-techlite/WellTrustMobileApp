import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/states/account_provider.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/provider/package_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class VisitsScreen extends ConsumerStatefulWidget {
  const VisitsScreen({super.key});

  @override
  ConsumerState<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends ConsumerState<VisitsScreen>
    with TickerProviderStateMixin {
  late final TabController tabController;
  final ScrollController scrollController = ScrollController();

  String userPhone = "";

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 4, vsync: this);

    Future.microtask(() async {
      await ref.read(accountProvider.notifier).getAccount();

      final user = ref.read(accountProvider).value?.userData;
      userPhone = user?.phoneNo ?? "";

      await ref
          .read(packageOrderControllerProvider.notifier)
          .getAllPackageOrderData();

      final userId = globals.userId;

      if (userId.isNotEmpty) {
        await ref
            .read(packageOrderControllerProvider.notifier)
            .connectAndJoinOrder(orderId: userId, isSingle: false);
      }

      if (mounted) setState(() {});
    });

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
    ref.read(packageOrderControllerProvider.notifier).disconnect();

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
    //  final asyncState = ref.watch(packageOrderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        showBackButton: false,
        title: const AppText(
          text: "My Orders",
          textAlign: TextAlign.start,

          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(child: Container()),
    );
  }
}
