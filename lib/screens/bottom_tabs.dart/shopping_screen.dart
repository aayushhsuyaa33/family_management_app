import 'dart:async';
import 'package:family_management_app/app/app%20Color/app_color.dart';
import 'package:family_management_app/app/images/app_images.dart';
import 'package:family_management_app/app/textStyle/textstyles.dart';
import 'package:family_management_app/app/utils/custom_appbar.dart';
import 'package:family_management_app/app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  // Track expanded items
  Set<int> expandedIndexes = {};
  bool isExpanded = false;
  int selectedIndex = -1;
  Timer? _timer;

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(milliseconds: 3500), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % bannerImages.length;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  final categories = [
    "Kids & Baby",
    "HouseHold",
    "Caregiver Picks",
    "Mom's Corner",
  ];
  final List<Map<String, dynamic>> amazonProducts = [
    // ---------------- KIDS & BABY ----------------
    {
      "category": "Kids & Baby",
      "products": [
        {
          "name":
              "Evenflo Gold Revolve360 Extend All-in-One Rotational Car Seat with SensorSafe (Moonstone Gray)",
          "quantity": "152 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81liuxXsXHL._SX425_.jpg",
          "link": "https://amzn.to/3KgpMQi",
        },
        {
          "name":
              "LeIsfIt Toddler Shoes Boys Girls Barefoot Shoes Kids Breathable Sneakers Tennis Shoes Slip on Shoes",
          "quantity": "120 Pair",
          "imageUrl":
              "https://m.media-amazon.com/images/I/71yA8-Yu4CL._AC_SY575_.jpg",
          "link": "https://amzn.to/46wpmgo",
        },
        {
          "name":
              "Dr. Brown's Anti-Colic Options+ Narrow Glass Baby Bottle with Level 1 Slow Flow Nipple, BPA-Free, 4 oz/120mL, 2-Pack",
          "quantity": "50 Bottles",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81AQMaLmiTL._SX425_.jpg",
          "link": "https://amzn.to/3VX3JAL",
        },
        {
          "name":
              "2 Pcs U-Shaped Kids Toothbrush, Premium Soft Manual Training Toothbrush for Kids 2-6 Years Old (Pink)",
          "quantity": "45 Brushes",
          "imageUrl":
              "https://m.media-amazon.com/images/I/41+9Xe3ufQL._AC_SX569_.jpg",
          "link": "https://amzn.to/3K9AvMB",
        },
        {
          "name":
              "Enfamil NeuroPro Gentlease Baby Formula, Brain Building DHA, HuMO6 Immune Blend, 27.4 Oz",
          "quantity": "125 Can",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81FKd9IS10L._AC_SX569_.jpg",
          "link": "https://amzn.to/46JT16S",
        },
      ],
    },

    // ---------------- HOUSEHOLD ----------------
    {
      "category": "Household",
      "products": [
        {
          "name": "Baby Bath Pink Elephant thermometer for Infant Safety",
          "quantity": "725 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/51h2GK9Ec8L._SX466_.jpg",
          "link": "https://amzn.to/3IAfmup",
        },
        {
          "name":
              "Munchkin® Arm & Hammer Puck Baking Soda Cartridge, Lavender Scent, 3 Count",
          "quantity": "38 Cartridges",
          "imageUrl":
              "https://m.media-amazon.com/images/I/71XzlJvonKL._SX425_.jpg",
          "link": "https://amzn.to/3Vs6CcD",
        },
        {
          "name":
              "Biaungdo 24 Pcs Heavy Duty Stainless Steel Black Vinyl Siding Hooks",
          "quantity": "24 Hooks",
          "imageUrl":
              "https://m.media-amazon.com/images/I/61brbgKmM3L._AC_SX569_.jpg",
          "link": "https://amzn.to/46lpWNC",
        },
        {
          "name":
              "Lilly's Love Stuffed Animal Hammock | Corner Hanging Organizer, 2 Pack",
          "quantity": "52 Hammocks",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81-7+N8FJ-L._AC_SX679_.jpg",
          "link": "https://amzn.to/4mujo5s",
        },
        {
          "name": "Best Choice Products 8-Cube Storage Organizer, White",
          "quantity": "10 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81DpqnUAzdL._AC_SX679_.jpg",
          "link": "https://amzn.to/4na7r63",
        },
      ],
    },

    // ---------------- CAREGIVER PICKS ----------------
    {
      "category": "Caregiver Picks",
      "products": [
        {
          "name":
              "Baby's Brew Warmer 3.0 - Portable Formula Warmers for Travel",
          "quantity": "27 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/41Zb78NMVnL._SX425_.jpg",
          "link": "https://amzn.to/4nh3KvA",
        },
        {
          "name": "TUCKS Medicated Cooling Pads, 100 Count",
          "quantity": "100 Pads",
          "imageUrl":
              "https://m.media-amazon.com/images/I/411SFLVz85L._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/4pvmoRI",
        },
        {
          "name":
              "Accmor Universal Stroller Organizer with Insulated Cup Holder",
          "quantity": "125 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/41yIaHyHQ1L._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/3Kw2KVD",
        },
        {
          "name": "Thinkbaby SPF 50+ Baby Mineral Sunscreen, 6 Oz",
          "quantity": "36 Bottle",
          "imageUrl":
              "https://m.media-amazon.com/images/I/31LBDJ86O1L._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/4gBi27R",
        },
        {
          "name":
              "Evenflo Pivot Modular Travel System with LiteMax Infant Car Seat (Desert Tan)",
          "quantity": "10 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/61yT478X3cL._SX425_.jpg",
          "link": "https://amzn.to/3IlncYS",
        },
      ],
    },

    // ---------------- MOM'S CORNER ----------------
    {
      "category": "Mom's Corner",
      "products": [
        {
          "name": "LUXJA Breast Pump Bag Compatible with Spectra S1 and S2",
          "quantity": "48 Bag",
          "imageUrl":
              "https://m.media-amazon.com/images/I/41Bnfxe8WXL._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/3IuWMns",
        },
        {
          "name": "Elvie Pump - Breastmilk Storage Bottles - 3 Pack",
          "quantity": "34 Bottles",
          "imageUrl":
              "https://m.media-amazon.com/images/I/21iZmoB3TwL._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/421dPUN",
        },
        {
          "name": "Womens Maternity Nursing Tank Cami for Breastfeeding",
          "quantity": "136 Unit",
          "imageUrl":
              "https://m.media-amazon.com/images/I/61-kdjuWqXL._AC_SX425_.jpg",
          "link": "https://amzn.to/46LXbLx",
        },
        {
          "name":
              "Depend Fresh Protection Adult Incontinence & Postpartum Bladder Leak Underwear for Women, 22 Count",
          "quantity": "22 Units",
          "imageUrl":
              "https://m.media-amazon.com/images/I/81GnKopZTAL._AC_SX569_.jpg",
          "link": "https://amzn.to/4nEnQj1",
        },
        {
          "name": "Frida Mom Nursing Pads, Cooling Hydrogel Nipple Pads, 8ct",
          "quantity": "80 Pads",
          "imageUrl":
              "https://m.media-amazon.com/images/I/312nsJB9euL._SX300_SY300_QL70_FMwebp_.jpg",
          "link": "https://amzn.to/4pxG4o1",
        },
      ],
    },
  ];

  int _currentIndex = 0;

  final List<String> bannerImages = [
    AppImages.banner1,
    AppImages.banner2,
    AppImages.banner3,
    AppImages.banner4,
  ];

  void _onSwipe(DragEndDetails details) {
    // Detect swipe direction
    if (details.primaryVelocity! < 0) {
      // Swipe Left → next banner
      setState(() {
        _currentIndex = (_currentIndex + 1) % bannerImages.length;
      });
    } else if (details.primaryVelocity! > 0) {
      // Swipe Right → previous banner
      setState(() {
        _currentIndex =
            (_currentIndex - 1 + bannerImages.length) % bannerImages.length;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.background,
      appBar: MyCustomAppBar(
        heading: "Smart Shopping",
        subTitle: "Find everything you need in one place",
        isBack: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                myBannerHolder(),
                SizedBox(height: 20.h),
                ListView.builder(
                  itemCount: categories.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final isExpanded = selectedIndex == index;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.only(
                            left: 10.w,
                            bottom: 10.h,
                          ),
                          title: Row(
                            children: [
                              Text(
                                categories[index],
                                style: t3White().copyWith(
                                  color: AppColor.border,
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    if (isExpanded) {
                                      selectedIndex = -1;
                                    } else {
                                      selectedIndex = index;
                                    }
                                  });
                                },
                                iconSize: 25.sp,
                                color: AppColor.secondary,
                                icon: Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_outlined
                                      : Icons.keyboard_arrow_down_outlined,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Divider(color: AppColor.border),
                        ),

                        // Expanded content
                        AnimatedSize(
                          duration: Duration(
                            milliseconds: isExpanded ? 700 : 300,
                          ),
                          curve: Curves.easeInOut,
                          child: isExpanded
                              ? SizedBox(
                                  height: 180.h,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        amazonProducts[0]['products'].length,
                                    itemBuilder: (context, i) {
                                      final productDetails =
                                          amazonProducts[selectedIndex]['products'][i];
                                      return Padding(
                                        padding: EdgeInsets.only(left: 10.w),
                                        child: SizedBox(
                                          width: 295.w,
                                          child: myProductHolder(
                                            heading: productDetails['name'],
                                            subTitle:
                                                productDetails['quantity'],
                                            imageUrl:
                                                productDetails['imageUrl'],
                                            onButtonPressed: () {
                                              launchUrl(
                                                Uri.parse(
                                                  productDetails['link'],
                                                ),
                                                mode: LaunchMode
                                                    .externalApplication,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox.shrink(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget myBannerHolder() {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragEnd: _onSwipe,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              // key: ValueKey<int>(_currentIndex),
              height: 170.h,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Image.asset(
                // AppImages.bannerImg1,
                bannerImages[_currentIndex],
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerImages.length,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentIndex == index ? 12 : 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentIndex == index
                    ? Colors.blueAccent
                    : Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget myProductHolder({
    required String imageUrl,
    required String heading,
    required String subTitle,
    String? urlLink,
    required VoidCallback onButtonPressed,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(17.r),
        border: BoxBorder.all(color: AppColor.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
        child: Row(
          children: [
            Container(
              width: 120.w,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColor.secondary),
                borderRadius: BorderRadius.circular(15.r),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(imageUrl),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    heading,
                    style: t3White().copyWith(
                      color: AppColor.secondary,
                      fontSize: 18.sp,
                    ),
                  ),
                  Text(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    subTitle,
                    style: hintTextStyle(),
                  ),
                  SizedBox(height: 10.h),
                  MyShopButton(
                    text: "Buy",
                    onPressed: onButtonPressed,
                    isInfinte: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
