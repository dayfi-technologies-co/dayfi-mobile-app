import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import '../../common/app_scaffold.dart';
import '../blog/blog_viewmodel.dart';
import 'blog_detail_viewmodel.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailView extends StackedView<BlogDetailViewModel> {
  final Article blog;
  const BlogDetailView({
    super.key,
    required this.blog,
  });

  @override
  Widget builder(
    BuildContext context,
    BlogDetailViewModel viewModel,
    Widget? child,
  ) {
    return AppScaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xffF6F5FE),
        leading: IconButton(
          onPressed: () => viewModel.navigationService.back(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff5645F5), // innit
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 18),
                  Text(
                    "${blog.title}.",
                    style: const TextStyle(
                      fontFamily: 'Boldonse',
                      fontSize: 27.5,
                      height: 1.2,
                      letterSpacing: 0.00,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff2A0079),
                      // color: Color( 0xff5645F5), // innit
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${DateFormat.yMMMEd().format(DateTime.parse(blog.publishedAt))}  .  ${blog.content.toString().contains('[') ? calculateMinReads(500, targetWords: int.parse(blog.content.toString().split('[')[1].split(' chars')[0].split('+')[1])) : "5"} min read",
                    style: TextStyle(
                      fontFamily: 'Karla',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.450,
                      color: Color(0xFF302D53),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${blog.author!}  .  ${blog.source.name}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.450,
                      fontFamily: 'Karla',
                      letterSpacing: .1,
                      color: Color(0xff304463),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    height: 198,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        18.0,
                      ),
                    ),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          18.0,
                        ),
                        child: Hero(
                          tag: 'image_',
                          child: CachedNetworkImage(
                            imageUrl: blog.urlToImage.toString() == "null"
                                ? ""
                                : blog.urlToImage!,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                  const SizedBox(height: 24),
                  HtmlWidget(
                    blog.content.toString(),
                    textStyle: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      fontFamily: 'Karla',
                      letterSpacing: .1,
                      color: Color(0xff304463),
                    ),
                  ),
                  const SizedBox(height: 245),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(
    BuildContext context,
    BlogDetailViewModel viewModel,
  ) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: IconButton(
          icon: SvgPicture.asset("assets/arrow-left.svg"),
          onPressed: () => {viewModel.navigationService.back()},
        ),
      ),
    );
  }

  @override
  BlogDetailViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      BlogDetailViewModel();
}
