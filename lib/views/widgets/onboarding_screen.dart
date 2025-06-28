import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../utils/helper.dart' as helper;
import '../../routes/route_name.dart';

// Model data disederhanakan, warna tidak lagi per halaman
class OnboardingPageUIData {
  final String backgroundImagePath;
  final String? foregroundImagePath;
  final String title;
  final String description;

  OnboardingPageUIData({
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingController with ChangeNotifier {
  final PageController pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPageUIData> _pages = [
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/oren.jpg',
      foregroundImagePath: 'assets/images/img intro 1.png',
      title: 'Hi-Tech',
      description:
          'Explore the latest advancements and technological breakthroughs shaping our future.',
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/biru.jpg',
      foregroundImagePath: 'assets/images/img intro 2.png',
      title: 'Personality',
      description:
          'Understand diverse personalities and enhance your interpersonal skills effectively.',
    ),
    OnboardingPageUIData(
      backgroundImagePath: 'assets/images/hejo.jpg',
      foregroundImagePath: 'assets/images/img intro 3.png',
      title: 'Global Mind',
      description:
          'Develop a global mindset to navigate and succeed in an interconnected world.',
    ),
  ];

  List<OnboardingPageUIData> get pages => _pages;
  int get totalPages => _pages.length;
  int get currentPage => _currentPage;

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void nextPageOrFinish(BuildContext context) {
    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteName.login);
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color elegantBlack = Color(0xFF1A1B20);
    const Color elegantWhite = Colors.white;

    return ChangeNotifierProvider(
      create: (_) => OnboardingController(),
      child: Consumer<OnboardingController>(
        builder: (context, controller, child) {
          final bool isLastPage =
              controller.currentPage == controller.totalPages - 1;

          return Scaffold(
            backgroundColor: elegantBlack,
            body: Stack(
              children: [
                PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.totalPages,
                  itemBuilder: (context, index) {
                    final pageData = controller.pages[index];
                    return _OnboardingPageContentWidget(
                      key: ValueKey('onboarding_page_$index'),
                      backgroundImagePath: pageData.backgroundImagePath,
                      foregroundImagePath: pageData.foregroundImagePath,
                      title: pageData.title,
                      description: pageData.description,
                    );
                  },
                ),
                // Kontrol navigasi di bagian bawah
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: MediaQuery.of(context).padding.bottom + 24.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPageIndicator(controller, elegantWhite),
                        const SizedBox(height: 30.0),
                        _buildNavigationButton(
                          context,
                          controller,
                          elegantWhite,
                        ),
                      ],
                    ),
                  ),
                ),
                // Tombol Skip di bagian atas
                if (!isLastPage)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: TextButton(
                      onPressed: () {
                        context.goNamed(RouteName.login);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageIndicator(
    OnboardingController controller,
    Color activeColor,
  ) {
    if (controller.totalPages <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        controller.totalPages,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: controller.currentPage == index ? 24.0 : 8.0,
          decoration: BoxDecoration(
            color: controller.currentPage == index
                ? activeColor
                : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    OnboardingController controller,
    Color buttonColor,
  ) {
    final bool isLastPage = controller.currentPage == controller.totalPages - 1;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => controller.nextPageOrFinish(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          ),
        ),
        child: Text(
          isLastPage ? 'Mulai' : 'Selanjutnya',
          style: helper.subtitle1.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _OnboardingPageContentWidget extends StatelessWidget {
  final String backgroundImagePath;
  final String? foregroundImagePath;
  final String title;
  final String description;

  const _OnboardingPageContentWidget({
    super.key,
    required this.backgroundImagePath,
    this.foregroundImagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gambar latar belakang
        Image.asset(
          backgroundImagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              Container(color: Colors.black),
        ),
        // Lapisan gelap untuk membuat teks lebih mudah dibaca
        Container(color: Colors.black.withOpacity(0.5)),

        // Konten utama
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (foregroundImagePath != null)
              Image.asset(
                foregroundImagePath!,
                height: screenHeight * 0.4,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            SizedBox(height: screenHeight * 0.05),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: helper.headline2.copyWith(
                      color: Colors.white,
                      fontWeight: helper.bold,
                    ),
                  ),
                  helper.vsMedium,
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: helper.subtitle1.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
