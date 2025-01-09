import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:places_that_dont_exist/base/images.dart';
import 'package:places_that_dont_exist/ui/data_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:places_that_dont_exist/base/colors.dart';
import 'package:places_that_dont_exist/theme/theme.dart';
import 'package:places_that_dont_exist/ui/widgets/buttom_border.dart';
import 'package:places_that_dont_exist/data/tips_data.dart';

class TipFavoriteScreen extends StatefulWidget {
  final String? title;

  const TipFavoriteScreen({
    super.key,
    this.title,
  });

  @override
  State<TipFavoriteScreen> createState() => _TipFavoriteScreenState();
}

class _TipFavoriteScreenState extends State<TipFavoriteScreen> {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> favoriteTips = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_updateSearchResults);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final storedTips =
        await DataStorage.getTips(); // Загружаем из SharedPreferences
    if (storedTips.isEmpty) {
      await DataStorage.saveTips(
          tipsData); // Если данных нет, сохраняем начальные
      tipsData = List.from(tipsData);
    } else {
      tipsData = storedTips; // Обновляем локальные данные
    }

    // Обновляем список избранного после загрузки данных
    _filterFavoriteTips();
    setState(() {});
  }

  Future<void> _loadTipsFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTips = prefs.getString('tipsData');

    if (savedTips != null) {
      final List<dynamic> decodedTips = jsonDecode(savedTips);
      setState(() {
        tipsData = List<Map<String, dynamic>>.from(decodedTips);
      });
    }

    // Обновляем список избранного
    _filterFavoriteTips();
  }

  Future<void> _saveTipsToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTips = jsonEncode(tipsData);

    // Сохраняем данные в SharedPreferences
    await prefs.setString('tipsData', encodedTips);
  }

  void _filterFavoriteTips() {
    setState(() {
      favoriteTips = tipsData
          .where((category) =>
              (category['tips'] as List<dynamic>).any((tip) => tip['favorite']))
          .map((category) {
        final filteredTips = (category['tips'] as List<dynamic>)
            .where((tip) => tip['favorite'])
            .toList();
        return {
          'category': category['category'],
          'tips': filteredTips,
        };
      }).toList();
    });
  }

  void _toggleFavorite(Map<String, dynamic> tip) async {
    setState(() {
      tip['favorite'] = !tip['favorite']; // Переключение статуса
    });

    // Поиск элемента по id и обновление данных
    for (var category in tipsData) {
      for (var item in category['tips']) {
        if (item['id'] == tip['id']) {
          // Сравнение по id
          item['favorite'] = tip['favorite'];
          break;
        }
      }
    }

    // Сохранение изменений в SharedPreferences
    await DataStorage.saveTips(tipsData);

    // Обновление списка избранных
    _filterFavoriteTips();
  }

  void _updateSearchResults() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      favoriteTips = tipsData.where((category) {
        final filteredTips = (category['tips'] as List<dynamic>)
            .where((tip) =>
                tip['favorite'] && tip['title'].toLowerCase().contains(query))
            .toList();
        return filteredTips.isNotEmpty;
      }).map((category) {
        final filteredTips = (category['tips'] as List<dynamic>)
            .where((tip) =>
                tip['favorite'] && tip['title'].toLowerCase().contains(query))
            .toList();
        return {
          'category': category['category'],
          'tips': filteredTips,
        };
      }).toList();
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey),
                ),
                const SizedBox(width: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 200.w),
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
          ],
        ),
      ),
    );
  }

  Widget bodyBlock({required TextTheme theme, required customTheme}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
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
          favoriteTipsBlock(theme: theme, customTheme: customTheme),
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
        onChanged: (value) {
          _updateSearchResults();
        },
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

  Widget favoriteTipsBlock({required TextTheme theme, required customTheme}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: favoriteTips.map((category) {
        final tips = category['tips'] as List<dynamic>;
        return Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: AppColors.darkGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category['category'],
                style: theme.titleMedium?.copyWith(
                  color: AppColors.white,
                  fontSize: 18.sp,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.w),
                child: Divider(
                  color: AppColors.grey,
                  height: 0.3,
                  thickness: 0.3,
                ),
              ),
              ...tips.map((tip) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.w),
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(width: 1, color: AppColors.grey))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            tip['title'],
                            style: theme.bodySmall?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleFavorite(tip),
                            child: tip['favorite']
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
                        tip['description'],
                        style: theme.bodySmall?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }).toList(),
    );
  }
}
