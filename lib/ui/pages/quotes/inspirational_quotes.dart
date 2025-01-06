// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/data/quotes_data.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/pages/quotes/quotes.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';

// ignore: must_be_immutable
class InspirationalQuotesScreen extends StatefulWidget {
  String? title;
  String? quoteOfTheDay;
  String? quoteAuthor;
  bool? favorite;
  InspirationalQuotesScreen({
    super.key,
    this.title,
    this.quoteOfTheDay,
    this.quoteAuthor,
    this.favorite,
  });

  @override
  State<InspirationalQuotesScreen> createState() =>
      _InspirationalQuotesScreenState();
}

class _InspirationalQuotesScreenState extends State<InspirationalQuotesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredQuotesList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // По умолчанию отфильтрованный список такой же, как оригинальный
    filteredQuotesList = quotesList;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredQuotesList = quotesList
            .where((item) => item['type']
                .toString()
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme theme = Theme.of(context).textTheme;
    final customTheme = Theme.of(context).extension<CustomTheme>();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Снимает фокус с любого TextField
      },
      child: Scaffold(
        body: body(theme: theme, customTheme: customTheme),
      ),
    );
  }

  Widget body({required TextTheme theme, required customTheme}) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: customTheme?.gradientBackground,
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 10.w,
              ),
              child: appBar(theme: theme, customTheme: customTheme),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: bodyBlock(theme: theme, customTheme: customTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget appBar({required TextTheme? theme, required customTheme}) {
    return BottomBorderContainer(
      child: Padding(
        padding: EdgeInsets.only(top: 20, left: 26.w, bottom: 15, right: 26.w),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
            ),
            const SizedBox(width: 10),
            Text(
              widget.title ?? '',
              style: theme?.bodySmall
                  ?.copyWith(fontSize: 17, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget bodyBlock({required TextTheme theme, required customTheme}) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 15.w,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.w,
          ),
          quoteOfTheDay(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 20.w,
          ),
          searchBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 20.w,
          ),
          ...List.generate(
            filteredQuotesList.length,
            (index) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) {
                    return QuotesScreen(
                      title: filteredQuotesList[index]['type'],
                      data: filteredQuotesList[index],
                    );
                  }),
                );
              },
              child: Container(
                padding: EdgeInsets.all(14.w),
                margin: EdgeInsets.only(bottom: 15.w),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        filteredQuotesList[index]['type'],
                        style: theme.bodySmall?.copyWith(fontSize: 16.sp),
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) {
                        return customTheme?.secondaryGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ) ??
                            const LinearGradient(
                                    colors: [Colors.white, Colors.white])
                                .createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                      },
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget quoteOfTheDay({required TextTheme theme, required customTheme}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quote of the day",
            style: theme.bodySmall?.copyWith(
              color: AppColors.grey,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.grey,
            ),
          ),
          SizedBox(
            height: 10.w,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: widget.favorite == true
                    ? Image.asset(AppImages.star)
                    : Image.asset(
                        AppImages.star,
                        color: AppColors.grey,
                      ),
              ),
              SizedBox(
                width: 15.w,
              ),
              Expanded(
                child: Text(
                  widget.quoteOfTheDay ?? '',
                  style: theme.titleMedium?.copyWith(
                    fontSize: 20,
                  ),
                ),
              ),
              Image.asset(AppImages.forward)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.quoteAuthor ?? '',
                style: theme.bodySmall?.copyWith(color: AppColors.grey),
              ),
              SizedBox(
                width: 40.w,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget searchBlock({required TextTheme theme, required customTheme}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            style: theme.bodySmall?.copyWith(
              color: AppColors.white,
            ),
            // onChanged: updateSearch,
            cursorColor: AppColors.white,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkGrey,
              suffixIcon: Icon(Icons.search, color: AppColors.white),
              hintText: "Search",
              hintStyle: theme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15.w, horizontal: 15.w),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.w),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        ShaderMask(
          shaderCallback: (bounds) {
            return customTheme?.secondaryGradient.createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ) ??
                const LinearGradient(colors: [Colors.white, Colors.white])
                    .createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                );
          },
          child: Container(
            width: 52.w,
            height: 52.w,
            margin: EdgeInsets.only(left: 15.w),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: AppColors.white),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Image.asset(AppImages.star),
            ),
          ),
        )
      ],
    );
  }
}
