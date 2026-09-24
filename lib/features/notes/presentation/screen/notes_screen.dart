import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/screen/notes_details_screen.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';
import 'package:well_trust_mobile_app/shared/widgets/input.dart';

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen>
    with TickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  String searchText = '';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {});

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 250) {}
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      searchText = query;
    });

    // ref.read(logisticsControllerProvider.notifier).onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    //  final asyncState = ref.watch(packageOrderControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,

      body: Column(
        children: [
          const WellTrustAppBar(title: 'Notes'),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    addVerticalSpacing(3),
                    SearchWidget(
                      text: searchText,
                      onChanged: _filterItems,
                      hintText: "Search Clients",
                    ),
                    addVerticalSpacing(4),
                    RichText(
                      text: TextSpan(
                        style: AppTextType.bodyMedium.style(
                          context,
                          color: AppColors.muted,
                          fontSize: 13,
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: "Showing 6 clients on your rota. ",
                            style: AppTextType.bodyMedium.style(
                              context,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          TextSpan(
                            text: "Tap a name to open their profile and notes.",
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: AppColors.surface,
                        child: ListView(
                          children: [
                            ClientNoteListTile(
                              initials: "AP",
                              name: "Anita Patel",
                              info:
                                  "📍 14 Linden Avenue · 84 yrs · 14h/week · 4 calls/day",
                              note:
                                  "Vascular dementia, lives alone. Daughter visits weekends...",
                              tags: ["FALLS RISK", "ALLERGY: PENICILLIN"],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  ResidentProfileScreen(),
                                );
                              },
                            ),
                            ClientNoteListTile(
                              initials: "GD",
                              name: "George Davies",
                              info:
                                  "📍 52 Beech Drive · 78 yrs · 7h/week · 3 calls/day",
                              note:
                                  "Heart failure, stable. Lives with wife (84) who does most...",
                              tags: [],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  ResidentProfileScreen(),
                                );
                              },
                            ),
                            ClientNoteListTile(
                              initials: "EH",
                              name: "Edna Henderson",
                              info:
                                  "📍 8 Mill Cottages · 91 yrs · 21h/week · 4 calls/day incl. bath visit",
                              note:
                                  "Alzheimer's, advanced. Needs full personal care. DNAR in...",
                              tags: ["DEMENTIA", "FALLS RISK", "DNAR"],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  ResidentProfileScreen(),
                                );
                              },
                            ),
                            ClientNoteListTile(
                              initials: "OA",
                              name: "Oluwaseun Akinola",
                              info:
                                  "📍 Flat 4 · 72 yrs · 3.5h/week · 2 short calls/day",
                              note: "",
                              tags: [],
                              onTap: () {
                                navigateToRoute(
                                  context,
                                  ResidentProfileScreen(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClientNoteListTile extends StatelessWidget {
  final String initials;
  final String name;
  final String info;
  final String note;
  final List<String> tags;
  final VoidCallback? onTap;

  const ClientNoteListTile({
    super.key,
    required this.initials,
    required this.name,
    required this.info,
    required this.note,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.line, width: 1.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.gold,
              child: AppText(
                text: initials,
                textAlign: TextAlign.center,
                color: Colors.white,
                type: AppTextType.labelSmall,
                fontWeight: FontWeight.w800,
              ),
            ),

            addHorizontalSpacing(3),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: name,
                    textAlign: TextAlign.start,
                    color: AppColors.black,
                    type: AppTextType.bodyLarge,
                    fontWeight: FontWeight.w800,
                  ),
                  addVerticalSpacing(1),
                  AppText(
                    text: info,
                    textAlign: TextAlign.start,
                    color: AppColors.muted,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w400,
                  ),
                  if (note.isNotEmpty) ...[
                    addVerticalSpacing(1),
                    AppText(
                      text: note,
                      textAlign: TextAlign.start,
                      color: AppColors.ink,
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                  if (tags.isNotEmpty) ...[
                    addVerticalSpacing(1),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: tags
                          .map((tag) => ClientNoteFlagChip(tag))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            addHorizontalSpacing(1),

            Icon(Icons.chevron_right, color: AppColors.muted, size: 34),
          ],
        ),
      ),
    );
  }
}

class ClientNoteFlagChip extends StatelessWidget {
  final String label;

  const ClientNoteFlagChip(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.roseBg;
    Color fg = AppColors.amber;

    if (label == "DEMENTIA") {
      bg = AppColors.bg;
      fg = AppColors.black;
    }

    if (label == "DNAR") {
      bg = AppColors.roseBg;
      fg = AppColors.rose;
    }

    if (label.contains("ALLERGY")) {
      bg = AppColors.bg;
      fg = AppColors.goldDeep;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: AppText(
        text: label,
        textAlign: TextAlign.center,
        color: fg,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
