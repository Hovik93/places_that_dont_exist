// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/data/tips_data.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/pages/tips/tip_favorite.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';

import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';

// ignore: must_be_immutable
class TipsDetailsScreen extends StatefulWidget {
  String? title;
  TipsDetailsScreen({
    super.key,
    this.title,
  });

  @override
  State<TipsDetailsScreen> createState() => _TipsDetailsScreenState();
}

class _TipsDetailsScreenState extends State<TipsDetailsScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> filteredTips = [];
  List<Map<String, dynamic>> currentCategoryTips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterTips);
  }

  Future<void> _loadData() async {
    final storedTips = await DataStorage.getTips();
    if (storedTips.isEmpty) {
      // Если данные отсутствуют, сохраняем начальные данные
      await DataStorage.saveTips(tipsData);
      tipsData = List.from(tipsData);
    } else {
      tipsData = storedTips;
    }

    // Получаем данные текущей категории
    final selectedCategory =
        tipsData.firstWhere((category) => category['category'] == widget.title);
    filteredTips = List.from(selectedCategory['tips']);
    currentCategoryTips = List.from(selectedCategory['tips']);
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterTips);
    _searchController.dispose();
    super.dispose();
  }

  void _filterTips() {
    setState(() {
      filteredTips = currentCategoryTips
          .where((tip) => tip['title']
              .toString()
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void toggleFavorite(int index) async {
    setState(() {
      filteredTips[index]['favorite'] = !filteredTips[index]['favorite'];
    });

    // Обновление данных в основном списке
    for (var category in tipsData) {
      if (category['category'] == widget.title) {
        category['tips'] = currentCategoryTips;
        break;
      }
    }

    // Сохранение изменений в SharedPreferences
    await DataStorage.saveTips(tipsData);
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize:
                  MainAxisSize.min, // Ограничение по минимальной ширине
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 200.w), // Ограничиваем ширину текста
                  child: Text(
                    widget.title ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: theme?.bodySmall?.copyWith(
                      fontSize: 17,
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ],
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) {
                      return TipFavoriteScreen(
                        title: 'Favorite tips',
                      );
                    }),
                  ).then((onValue) {
                    _loadData();
                  });
                },
                child: Image.asset(AppImages.star)),
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
            height: 10.w,
          ),
          tipsBlock(theme: theme, customTheme: customTheme),
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
    );
  }

  Widget tipsBlock({required TextTheme theme, required customTheme}) {
    return filteredTips.isEmpty
        ? Center(
            child: Text(
              "No tips found",
              style: theme.bodySmall?.copyWith(color: AppColors.grey),
            ),
          )
        : ListView.builder(
            itemCount: filteredTips.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10.w),
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppColors.darkGrey,
                  borderRadius: BorderRadius.circular(20.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          filteredTips[index]['title'],
                          style: theme.bodySmall?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => toggleFavorite(index),
                          child: filteredTips[index]['favorite']
                              ? Image.asset(AppImages.star)
                              : Image.asset(
                                  AppImages.star,
                                  color: AppColors.grey,
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.w),
                    Text(
                      filteredTips[index]['description'],
                      style: theme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          );
  }
}
