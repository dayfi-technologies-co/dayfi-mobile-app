import 'package:dayfi/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'blog_viewmodel.dart';
import 'package:dayfi/ui/common/app_scaffold.dart';
import 'package:dayfi/ui/common/ui_helpers.dart';
import 'package:dayfi/ui/components/buttons/filled_btn.dart' show FilledBtn;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class BlogView extends StackedView<BlogViewModel> {
  const BlogView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BlogViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      backgroundColor: const Color(0xffF6F5FE),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              verticalSpace(10),
              Text(
                "Latest updates",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 27.5,
                  height: 1.2,
                  letterSpacing: 0.00,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff2A0079),
                  // color: Color( 0xff5645F5), // innit
                ),
                textAlign: TextAlign.start,
              ),
              verticalSpace(4),
              Text(
                "Stay informed with our news and blog",
                style: TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  height: 1.450,
                  color: Color(0xFF302D53),
                ),
                textAlign: TextAlign.start,
              ),
              verticalSpace(30),
              viewModel.isLoading
                  ? ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.only(bottom: 120.0),
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.w, 12, 0.h, 32.h),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () => viewModel.navigationService
                                      .navigateToBlogDetailView(
                                          blog: viewModel.articles[index]),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 275,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            6.0,
                                          ),
                                        ),
                                        child: Shimmer.fromColors(
                                          direction: ShimmerDirection.ltr,
                                          baseColor: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(.3),
                                          highlightColor:
                                              Colors.grey[500]!.withOpacity(.5),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[500]!
                                                  .withOpacity(.5),
                                              borderRadius:
                                                  BorderRadius.circular(6.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ))
                  : viewModel.articles.isEmpty
                      ? Center(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Empty",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.450,
                                    fontFamily: 'Karla',
                                    letterSpacing: .255,
                                    color: Color(0xff2A0079),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                verticalSpaceLarge,
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(bottom: 120.0),
                          itemCount: 4,
                          itemBuilder: (context, index) => viewModel
                                          .articles[index].title ==
                                      "[Removed]" ||
                                  viewModel.articles[index].author ==
                                      "Ben Janca" ||
                                  viewModel.articles[index].author ==
                                      "Adam Mason"
                              ? const SizedBox.shrink()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          0.w, 12, 0.h, 32.h),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () => viewModel.navigationService
                                            .navigateToBlogDetailView(
                                                blog:
                                                    viewModel.articles[index]),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // ignore: unnecessary_null_comparison

                                            viewModel.articles[index].urlToImage
                                                        .toString() ==
                                                    "null"
                                                ? const SizedBox.shrink()
                                                : Container(
                                                    height: 198,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        6.0,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        6.0,
                                                      ),
                                                      child: CachedNetworkImage(
                                                        imageUrl: viewModel
                                                            .articles[index]
                                                            .urlToImage!,
                                                        placeholder:
                                                            (context, url) =>
                                                                Center(
                                                          child: Container(
                                                            height: 198,
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                18.0,
                                                              ),
                                                            ),
                                                            child: Shimmer
                                                                .fromColors(
                                                              direction:
                                                                  ShimmerDirection
                                                                      .ltr,
                                                              baseColor: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .secondary
                                                                  .withOpacity(
                                                                      .3),
                                                              highlightColor:
                                                                  Colors.grey[
                                                                          500]!
                                                                      .withOpacity(
                                                                          .5),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey[
                                                                          500]!
                                                                      .withOpacity(
                                                                          .5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        errorWidget: (context,
                                                                url, error) =>
                                                            const Icon(
                                                                Icons.error),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                            SizedBox(
                                                height: viewModel
                                                            .articles[index]
                                                            .urlToImage
                                                            .toString() ==
                                                        "null"
                                                    ? 0
                                                    : 8),
                                            Text(
                                              viewModel.articles[index].title,
                                              style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .255,
                                                color: Color(0xff2A0079),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "${DateFormat.yMMMEd().format(DateTime.parse(viewModel.articles[index].publishedAt))}  .  ${viewModel.articles[index].content.toString().contains('[') ? calculateMinReads(500, targetWords: int.parse(viewModel.articles[index].content.toString().split('[')[1].split(' chars')[0].split('+')[1])) : "5"} min read",
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                                height: 1.450,
                                                fontFamily: 'Karla',
                                                letterSpacing: .1,
                                                color: Color(0xff304463),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
              verticalSpace(40),
            ],
          ),
        ),
      ),
    );
  }

  @override
  BlogViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      BlogViewModel();

  @override
  void onViewModelReady(BlogViewModel viewModel) {
    viewModel.fetchSubscriptionNews();
    super.onViewModelReady(viewModel);
  }
}
