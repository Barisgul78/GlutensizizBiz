import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/screens/sign_screen.dart';

const Color _kDarkGreen = Color(0xFF2D4A2D);

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
      MaterialPageRoute(builder: (_) => const SignScreen()),
    );
  }

  Future<void> _skipToSign() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignScreen()),
    );
  }

  Color get _bgColor => _currentPage == 2 ? _kDarkGreen : kBackground;

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
              onSkip: _skipToSign,
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
              onSkip: _skipToSign,
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
        _BubbleBackground(isDark: isDark),
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
// Arka plan kabarcıkları
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleBackground extends StatelessWidget {
  const _BubbleBackground({this.isDark = false});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Açık tema renkleri
    const sageColor = kPrimary;
    const peachColor = kSecondary;
    const grayColor = kOutlineVariant;

    // Koyu tema için beyaz kabarcıklar
    final darkAlpha = isDark ? 0.08 : 0.0;
    final sageAlpha = isDark ? darkAlpha : 0.12;
    final peachAlpha = isDark ? darkAlpha : 0.10;
    final grayAlpha = isDark ? darkAlpha : 0.16;

    Color bubble(Color c, double alpha) =>
        isDark ? Colors.white.withValues(alpha: alpha + 0.06) : c.withValues(alpha: alpha);

    return SizedBox.expand(
      child: Stack(
        children: [
          // Sağ üst — büyük
          Positioned(
            top: -size.height * 0.06,
            right: -size.width * 0.12,
            child: _Bubble(size: size.width * 0.38,
                color: bubble(grayColor, grayAlpha)),
          ),
          // Sağ üst — orta
          Positioned(
            top: size.height * 0.08,
            right: size.width * 0.02,
            child: _Bubble(size: size.width * 0.18,
                color: bubble(peachColor, peachAlpha + 0.04)),
          ),
          // Orta sol — küçük
          Positioned(
            top: size.height * 0.20,
            left: size.width * 0.05,
            child: _Bubble(size: size.width * 0.10,
                color: bubble(sageColor, sageAlpha)),
          ),
          // Orta sağ — küçük
          Positioned(
            top: size.height * 0.48,
            right: size.width * 0.08,
            child: _Bubble(size: size.width * 0.08,
                color: bubble(peachColor, peachAlpha)),
          ),
          // Sol alt — büyük
          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.10,
            child: _Bubble(size: size.width * 0.42,
                color: bubble(sageColor, sageAlpha - 0.03)),
          ),
          // Sağ alt — orta
          Positioned(
            bottom: size.height * 0.08,
            right: size.width * 0.04,
            child: _Bubble(size: size.width * 0.16,
                color: bubble(grayColor, grayAlpha - 0.05)),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
