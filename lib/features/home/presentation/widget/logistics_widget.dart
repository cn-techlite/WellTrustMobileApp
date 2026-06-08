// ignore_for_file: library_private_types_in_public_api

import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/home/data/model/company_response_model.dart';

import '../../../../shared/widgets/app_text.dart';

class LogisticsWidget extends ConsumerStatefulWidget {
  const LogisticsWidget({super.key, required this.dataModel});

  final List<LogisticResponseModel> dataModel;
  @override
  _LogisticsWidgetState createState() => _LogisticsWidgetState();
}

class _LogisticsWidgetState extends ConsumerState<LogisticsWidget> {
  DeliveryAddress? country2;
  num distance = 10.1;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var post = widget.dataModel.toList();
    return Container(
      color: AppColors.white,
      child: post.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(
                    text: "Coming soon!",
                    textAlign: TextAlign.start,

                    color: AppColors.black,

                    fontWeight: FontWeight.bold,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: AppText(
                      text:
                          "There is no available Logistics Company in Your location",
                      textAlign: TextAlign.center,

                      color: AppColors.black,

                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: List.generate(post.length, (index) {
                final data3 = post[index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: [
                          addHorizontalSpacing(10),
                          Container(
                            margin: const EdgeInsets.all(5),
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.grey,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(50),
                              //set border radius to 50% of square height and width
                              image: DecorationImage(
                                image: NetworkImage(
                                  data3.companyLogo.toString(),
                                ),
                                fit: BoxFit.contain, //change image fill type
                              ),
                            ),
                          ),
                          addHorizontalSpacing(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  text: "${data3.companyName}",
                                  textAlign: TextAlign.start,

                                  color: AppColors.black,

                                  maxLines: 1,
                                  fontWeight: FontWeight.bold,
                                ),
                                AppText(
                                  text:
                                      "${data3.companyAddress}, ${data3.locality}, ${data3.state}",
                                  textAlign: TextAlign.start,

                                  color: AppColors.black,

                                  fontWeight: FontWeight.w500,
                                ),
                                const AppText(
                                  text: "",
                                  textAlign: TextAlign.start,

                                  color: AppColors.green,

                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(thickness: 0.7, color: AppColors.grey),
                  ],
                );
              }),
            ),
    );
  }
}
