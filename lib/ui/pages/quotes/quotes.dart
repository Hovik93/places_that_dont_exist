// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/data/quotes_data.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';
import 'package:share_plus/share_plus.dart';

// ignore: must_be_immutable
class QuotesScreen extends StatefulWidget {
  String? title;
  QuotesScreen({
    super.key,
    this.title,
  });

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  TextEditingController _searchController = TextEditingController();
  List<dynamic> quotesListForTitle = [];
  List<dynamic> filteredQuotesList = [];
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadQuotesForTitle();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadQuotesForTitle() async {
    final storedQuotes = await DataStorage.getQuotes();
    final allQuotes = storedQuotes.isNotEmpty ? storedQuotes : quotesList;

    final Map<String, dynamic>? matchingCategory =
        allQuotes.cast<Map<String, dynamic>?>().firstWhere(
              (category) => category?['type'] == widget.title,
              orElse: () => null,
            );

    if (matchingCategory != null) {
      setState(() {
        quotesListForTitle = matchingCategory['content'] ?? [];
        filteredQuotesList = List.from(quotesListForTitle);
      });
    } else {
      setState(() {
        quotesListForTitle = [];
        filteredQuotesList = [];
      });
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void toggleFavorite(String quoteText) async {
    final updatedQuotes = quotesListForTitle.map((quote) {
      if (quote['quote'] == quoteText) {
        return {
          ...quote,
          'favorite': !(quote['favorite'] ?? false),
        };
      }
      return quote;
    }).toList();

    setState(() {
      quotesListForTitle = updatedQuotes;
      filteredQuotesList = List.from(updatedQuotes);
    });

    quotesList = quotesList.map((category) {
      if (category['type'] == widget.title) {
        return {
          ...category,
          'content': updatedQuotes,
        };
      }
      return category;
    }).toList();

    await DataStorage.saveQuotes(quotesList);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        filteredQuotesList = quotesListForTitle
            .where((item) => item['quote']
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
        FocusScope.of(context).unfocus();
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
                Navigator.pop(
                  context,
                );
              },
              child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.title ?? '',
                overflow: TextOverflow.ellipsis,
                style: theme?.bodySmall
                    ?.copyWith(fontSize: 17, color: AppColors.grey),
              ),
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
          searchBlock(theme: theme, customTheme: customTheme),
          SizedBox(
            height: 20.w,
          ),
          ...List.generate(
              filteredQuotesList.length,
              (index) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    margin: EdgeInsets.only(bottom: 15.w),
                    decoration: BoxDecoration(
                      color: AppColors.darkGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                toggleFavorite(
                                    filteredQuotesList[index]['quote']);
                              },
                              child:
                                  filteredQuotesList[index]['favorite'] == true
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
                                '“${filteredQuotesList[index]['quote'] ?? ''}”',
                                style: theme.titleMedium?.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await Share.share(
                                    "“${filteredQuotesList[index]['quote'] ?? ''}”\n${filteredQuotesList[index]["author"] ?? ''}");
                              },
                              child: Image.asset(AppImages.forward),
                            )
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              filteredQuotesList[index]["author"] ?? '',
                              style: theme.bodySmall
                                  ?.copyWith(color: AppColors.grey),
                            ),
                            SizedBox(
                              width: 40.w,
                            )
                          ],
                        )
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget searchBlock({required TextTheme theme, required customTheme}) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: _searchController,
        style: theme.bodySmall?.copyWith(
          color: AppColors.white,
        ),
        cursorColor: AppColors.white,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.darkGrey,
          suffixIcon: Image.asset(AppImages.search),
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
    );
  }
}
