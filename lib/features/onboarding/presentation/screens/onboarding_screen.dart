import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/routing/main_shell.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/bubble_background.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../auth/presentation/screens/sign_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AuthService.currentUser != null
            ? const MainShell()
            : const SignScreen(),
      ),
    );
  }

  Color get _bgColor => _currentPage == 2 ? kOnboardingDarkGreen : kBackground;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      color: _bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView(
          controller: _controller,
          onPageChanged: (i) => setState(() => _currentPage = i),
          children: [
            _OnboardingPage(
              imagePath: 'assets/images/ob1.icon.jpg',
              title: 'Ürünleri Keşfet',
              subtitle:
                  'Glutensiz ürünleri kolayca keşfedin. Marketlerdeki glutensiz alternatifleri bulmanız artık çok kolay.',
              activeIndex: 0,
              isDark: false,
              onSkip: _completeOnboarding,
              buttons: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _PillButton(
                  text: 'Devam',
                  onTap: () => _goToPage(1),
                  color: kPrimary,
                ),
              ),
            ),
            _OnboardingPage(
              imagePath: 'assets/images/ob2.icon.jpg',
              title: 'Size Yakın Mekanlar',
              subtitle:
                  'Bulunduğunuz konuma yakın glutensiz menü sunan restoranları anında bulun. Sağlıklı ve lezzetli seçenekler sizi bekliyor.',
              activeIndex: 1,
              isDark: false,
              onSkip: _completeOnboarding,
              buttons: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: 'Geri',
                        onTap: () => _goToPage(0),
                        color: kPrimary,
                        filled: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillButton(
                        text: 'Devam',
                        onTap: () => _goToPage(2),
                        color: kPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _OnboardingPage(
              imagePath: 'assets/images/ob3.icon.jpg',
              title: 'Kendi Listeni Oluştur',
              subtitle:
                  'Favori glutensiz ürünlerinizi listeye ekleyin. Alışveriş yaparken veya dışarıda yerken listeniz her zaman yanınızda.',
              activeIndex: 2,
              isDark: true,
              onSkip: _completeOnboarding,
              buttons: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _PillButton(
                        text: 'Geri',
                        onTap: () => _goToPage(1),
                        color: Colors.white,
                        filled: false,
                        isDark: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PillButton(
                        text: 'İleri',
                        onTap: _completeOnboarding,
                        color: kSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tekil sayfa widget'ı
// ─────────────────────────────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.activeIndex,
    required this.isDark,
    required this.onSkip,
    required this.buttons,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final int activeIndex;
  final bool isDark;
  final VoidCallback onSkip;
  final Widget buttons;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : kOnSurface;
    final subColor =
        isDark ? Colors.white.withValues(alpha: 0.7) : kOnSurfaceVariant;

    return Stack(
      children: [
        BubbleBackground(isDark: isDark),
        SafeArea(
          child: Column(
            children: [
              // Atla
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 4),
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Atla',
                      style: GoogleFonts.plusJakartaSans(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.8)
                            : kOnSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),

              // Dairesel görsel
              Expanded(
                child: Center(
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: 240,
                      height: 240,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : kSurfaceContainerHigh,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.image_outlined,
                            size: 56,
                            color: isDark
                                ? Colors.white38
                                : kOnSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Başlık
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: textColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Alt başlık
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: subColor,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Nokta göstergesi
              _DotsIndicator(activeIndex: activeIndex, isDark: isDark),

              const SizedBox(height: 32),

              // Butonlar
              buttons,

              const SizedBox(height: 36),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nokta göstergesi
// ─────────────────────────────────────────────────────────────────────────────

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.activeIndex, this.isDark = false});
  final int activeIndex;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final isActive = i == activeIndex;
        final activeColor = isDark ? Colors.white : kPrimary;
        final inactiveColor = isDark
            ? Colors.white.withValues(alpha: 0.3)
            : kOutlineVariant;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill buton
// ─────────────────────────────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.text,
    required this.onTap,
    required this.color,
    this.filled = true,
    this.isDark = false,
  });

  final String text;
  final VoidCallback onTap;
  final Color color;
  final bool filled;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: filled ? null : Border.all(color: color, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            color: filled ? Colors.white : color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
