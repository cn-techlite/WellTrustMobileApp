// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/logistic_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/region_search_widget.dart';

import '../../../../core/utils/colors.dart';
import '../../../../core/utils/package_export.dart';

class CompanySelectPage extends ConsumerStatefulWidget {
  final String isSelectionType;

  const CompanySelectPage({super.key, required this.isSelectionType});

  @override
  ConsumerState<CompanySelectPage> createState() => _CompanySelectPageState();
}

class _CompanySelectPageState extends ConsumerState<CompanySelectPage> {
  final ScrollController _scrollController = ScrollController();

  String searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      await ref
          .read(logisticsControllerProvider.notifier)
          .setFilterTypes(widget.isSelectionType);
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      ref.read(logisticsControllerProvider.notifier).loadMoreListLogistic();
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchText = query;
    });

    ref.read(logisticsControllerProvider.notifier).onSearchChanged(query);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(logisticsControllerProvider);
    final notifier = ref.read(logisticsControllerProvider.notifier);

    final data = asyncState.value ?? const LogisticState();
    final logistics = data.listLogistic;

    final isFirstLoading = asyncState.isLoading && !data.hasLoadedInitially;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        elevation: 0,
        title: SearchWidget(
          text: searchText,
          onChanged: _filterItems,
          hintText: 'Search Company',
        ),
      ),
      body: SafeArea(
        child: isFirstLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              )
            : RefreshIndicator(
                onRefresh: notifier.refreshList,
                child: logistics.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          Center(
                            child: AppText(
                              text: "No company found",
                              textAlign: TextAlign.center,

                              color: AppColors.black,

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount:
                            logistics.length + (data.isLoadingMore ? 1 : 0),
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          if (index >= logistics.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final logistic = logistics[index];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.grey,
                              backgroundImage:
                                  logistic.companyLogo == null ||
                                      logistic.companyLogo!.isEmpty
                                  ? null
                                  : NetworkImage(logistic.companyLogo!),
                              child:
                                  logistic.companyLogo == null ||
                                      logistic.companyLogo!.isEmpty
                                  ? const Icon(Icons.business)
                                  : null,
                            ),
                            title: AppText(
                              text: logistic.companyName ?? "",
                              textAlign: TextAlign.start,

                              color: AppColors.black.withAlpha(162),

                              fontWeight: FontWeight.w800,
                            ),
                            subtitle: AppText(
                              text: logistic.companyInfo ?? "",
                              textAlign: TextAlign.start,

                              overflow: TextOverflow.ellipsis,
                              maxLines: 3,
                              color: AppColors.black.withValues(alpha: 0.4),

                              fontWeight: FontWeight.w500,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 18,
                            ),
                            onTap: () {
                              Navigator.pop(context, logistic);
                            },
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
