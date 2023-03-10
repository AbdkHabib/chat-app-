import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:chat_sample_app/core/constants/colors_manager.dart';
import 'package:chat_sample_app/core/widgets/no_data_widget.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({
    required this.enabled,
    Key? key,
  }) : super(key: key);
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      enabled: enabled,
      baseColor: ColorsManager.shimmerBaseColor,
      highlightColor: ColorsManager.shimmerHighlightColor,
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(40.w, 30.h, 0, 30.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequent contacts',
              style: TextStyle(
                color: ColorsManager.hintColor,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 30.h),
            SizedBox(
              height: 150.r,
              child: enabled
                  ? ListView.separated(
                      padding: EdgeInsetsDirectional.only(end: 40.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundColor: ColorsManager.grey,
                            ),
                            Container(
                              height: 20.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: ColorsManager.grey,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 25.w),
                    )
                  : const NoDataWidget(message: 'No Contacts'),
            ),
            SizedBox(height: 50.h),
            Text(
              'Recent conversations',
              style: TextStyle(
                color: ColorsManager.hintColor,
                fontSize: 24.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: enabled
                  ? ListView.separated(
                      padding: EdgeInsets.fromLTRB(0, 10.h, 40.w, 0),
                      itemCount: 8,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ColorsManager.grey,
                              radius: 50.r,
                            ),
                            SizedBox(
                              width: 20.w,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 20.h,
                                        width: 150.w,
                                        decoration: BoxDecoration(
                                          color: ColorsManager.grey,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                      Container(
                                        height: 20.h,
                                        width: 100.w,
                                        decoration: BoxDecoration(
                                          color: ColorsManager.grey,
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Container(
                                    height: 50.h,
                                    width: Get.width,
                                    decoration: BoxDecoration(
                                      color: ColorsManager.grey,
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(
                        color: ColorsManager.dividerColor,
                        thickness: 2,
                      ),
                    )
                  : const NoDataWidget(message: 'No Chats'),
            ),
          ],
        ),
      ),
    );
  }
}
