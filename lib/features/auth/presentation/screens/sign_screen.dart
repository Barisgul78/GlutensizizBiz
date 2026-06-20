import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../core/routing/main_shell.dart';
import '../../data/services/auth_service.dart';
import 'login_screen.dart';
import 'register_screen.dart';

// _BubbleBackground onboarding_screen.dart içindeki ile aynı mantık;
// sign ekranı kendi kopyasını barındırır (ileride core/widgets'a taşınabilir).

class SignScreen extends StatefulWidget {
  const SignScreen({super.key});

  @override
  State<SignScreen> createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> {
  bool _guestLoading = false;

  Future<void> _continueAsGuest() async {
    setState(() => _guestLoading = true);
    try {
      await AuthService.signInAnonymously();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Misafir giriş hatası — kod: ${e.code}, mesaj: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AuthService.errorMessage(e.code),
              style: GoogleFonts.plusJakartaSans()),
          backgroundColor: kError,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    } finally {
      if (mounted) setState(() => _guestLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          const _SignBubbleBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 52),

                  // ── İki renkli başlık ─────────────────────────────────
                  Text(
                    'Gluten-Free',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: kPrimary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Haven',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: kSecondary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Glutensiz yaşamın en kolay yolu.\nÜrünleri keşfedin, restoranları bulun ve\nkendi listenizi oluşturun.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: kOnSurfaceVariant,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Görsel kart ──────────────────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/images/sign.icon.jpg',
                      width: double.infinity,
                      height: 210,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: double.infinity,
                        height: 210,
                        color: kSurfaceContainerHigh,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grain,
                                size: 52,
                                color: kSecondary.withValues(alpha: 0.4)),
                            const SizedBox(height: 8),
                            Text(
                              'Glutensiz Ürünler',
                              style: GoogleFonts.plusJakartaSans(
                                  color: kOnSurfaceVariant, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Giriş Yap butonu ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Giriş Yap',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Kayıt Ol butonu ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPrimary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Kayıt Ol',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Alt linkler ──────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _guestLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: kPrimary),
                            )
                          : TextButton(
                              onPressed: _continueAsGuest,
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Hesap oluşturmadan devam et',
                                style: GoogleFonts.plusJakartaSans(
                                    color: kOnSurfaceVariant, fontSize: 13),
                              ),
                            ),
                      Text(
                        '  |  ',
                        style: TextStyle(
                            color: kOutlineVariant.withValues(alpha: 0.7),
                            fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Gizlilik politikası sayfası
                        },
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Gizlilik',
                          style: GoogleFonts.plusJakartaSans(
                              color: kOnSurfaceVariant, fontSize: 13),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sign ekranı arka plan kabarcıkları
// ─────────────────────────────────────────────────────────────────────────────

class _SignBubbleBackground extends StatelessWidget {
  const _SignBubbleBackground();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: -size.height * 0.05,
            right: -size.width * 0.10,
            child: _Bubble(
                size: size.width * 0.36,
                color: kOutlineVariant.withValues(alpha: 0.16)),
          ),
          Positioned(
            top: size.height * 0.07,
            right: size.width * 0.03,
            child: _Bubble(
                size: size.width * 0.17,
                color: kSecondary.withValues(alpha: 0.09)),
          ),
          Positioned(
            top: size.height * 0.18,
            left: size.width * 0.04,
            child: _Bubble(
                size: size.width * 0.09,
                color: kPrimary.withValues(alpha: 0.11)),
          ),
          Positioned(
            top: size.height * 0.52,
            right: size.width * 0.07,
            child: _Bubble(
                size: size.width * 0.07,
                color: kSecondary.withValues(alpha: 0.08)),
          ),
          Positioned(
            bottom: -size.height * 0.04,
            left: -size.width * 0.09,
            child: _Bubble(
                size: size.width * 0.44,
                color: kPrimary.withValues(alpha: 0.09)),
          ),
          Positioned(
            bottom: size.height * 0.10,
            right: size.width * 0.05,
            child: _Bubble(
                size: size.width * 0.14,
                color: kOutlineVariant.withValues(alpha: 0.12)),
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
