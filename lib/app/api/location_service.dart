import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://wft-geo-db.p.rapidapi.com/v1/geo/',
      headers: {
        'X-RapidAPI-Key': '09aea564c6mshfa59376d1053c42p1e18d9jsnc53a973d895e',
        'X-RapidAPI-Host': 'wft-geo-db.p.rapidapi.com',
      },
    ),
  );

  Future<List<String>> fetchCities(String query) async {
    if (query.isEmpty) return [];

    final response = await _dio.get(
      'cities',
      queryParameters: {
        'countryIds': 'US',
        'namePrefix': query,
        'limit': 10,
        'sort': '-population',
      },
    );

    final List data = response.data['data'];
    return data.map((city) {
      final cityName = city['city'] ?? '';
      final state = city['region'] ?? '';

      String zip = '';
      if (city['postalCodes'] != null &&
          city['postalCodes'] is List &&
          (city['postalCodes'] as List).isNotEmpty) {
        zip = city['postalCodes'][0]['postalCode'] ?? '';
      }
      return "$cityName, $state $zip"; // return string
    }).toList();
  }
}

class SchoolAddressAutoComplete extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChangedValue;
  final IconData? frontIcon;
  const SchoolAddressAutoComplete({
    super.key,
    required this.controller,
    required this.onChangedValue,
    this.frontIcon,
  });

  @override
  State<SchoolAddressAutoComplete> createState() =>
      _SchoolAddressAutoCompleteState();
}

class _SchoolAddressAutoCompleteState extends State<SchoolAddressAutoComplete> {
  final LocationService locationService = LocationService();
  List<String> options = [];

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        options = await locationService.fetchCities(textEditingValue.text);
        return options;
      },
      displayStringForOption: (option) => option,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // if (controller.text.isEmpty && widget.controller.text.isNotEmpty) {
        //   controller.text = widget.controller.text;
        // }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topLeft,
              child: Text(
                " School Address",
                style: t3White().copyWith(fontSize: 20.sp),
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: controller,
              focusNode: focusNode,
              cursorColor: Colors.blue,

              style: t3White(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 17.h,
                ).copyWith(right: 10.w),
                filled: true,
                fillColor: AppColor.secondary.withAlpha(10),
                prefixIcon: widget.frontIcon != null
                    ? Padding(
                        padding: EdgeInsets.only(left: 10.w, right: 3.w),
                        child: Icon(
                          widget.frontIcon,
                          color: AppColor.secondary,
                        ),
                      )
                    : SizedBox(width: 10.w),

                prefixIconConstraints: BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                hintText: "Kent, Ohio",
                hintStyle: hintTextStyle().copyWith(fontSize: 20.sp),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColor.secondary),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              onChanged: (value) {
                widget.onChangedValue(value);
              },
            ),
          ],
        );
      },
      onSelected: (selection) {
        widget.controller.text =
            selection; // update the controller with selected option
        widget.onChangedValue(selection); // notify parent widget of selection
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Material(
          color: AppColor.dropDownColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12.sp),
          ),

          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: options
                .map(
                  (option) => ListTile(
                    title: Text(option, style: t3White()),
                    onTap: () => onSelected(option),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
