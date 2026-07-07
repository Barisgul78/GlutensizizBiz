import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/utils/date_utils.dart' as du;
import '../../../../../core/widgets/bubble_background.dart';
import '../../data/models/tip.dart';
import '../widgets/category_badge.dart';
import '../widgets/tip_image.dart';
import '../../../auth/data/services/auth_service.dart';
import '../../../favorites/data/services/favorites_service.dart';
import '../../../profile/data/services/stats_service.dart';

class TipDetailScreen extends StatefulWidget {
  final Tip tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

enum _Reaction { none, liked, disliked }

class _TipDetailScreenState extends State<TipDetailScreen> {
  _Reaction _reaction = _Reaction.none;
  bool _saved = false;
  bool _readRegistered = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkIfSaved();
    _scrollController.addListener(_maybeRegisterRead);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeRegisterRead());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Kısa makalede scroll hiç mümkün değilse direkt okundu say; değilse
  // like/dislike/kaydet satırına (son gerçek içerik) yaklaşınca say.
  void _maybeRegisterRead() {
    if (_readRegistered) return;
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final scrollable = position.maxScrollExtent > 0;
    if (!scrollable || position.pixels >= position.maxScrollExtent - 24) {
      _readRegistered = true;
      final userId = AuthService.currentUserId;
      if (userId != null) {
        StatsService.registerArticleRead(userId, widget.tip.id);
      }
    }
  }

  Future<void> _checkIfSaved() async {
    final saved = await FavoritesService.isArticleFavorite(widget.tip.id);
    if (mounted) setState(() => _saved = saved);
  }

  Future<void> _toggleSaved() async {
    if (AuthService.currentUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kaydetmek için giriş yapmanız gerekiyor.')),
        );
      }
      return;
    }
    await FavoritesService.toggleArticleFavorite(widget.tip.id, isFavorite: _saved);
    if (mounted) setState(() => _saved = !_saved);
  }

  void _setReaction(_Reaction r) {
    setState(() => _reaction = _reaction == r ? _Reaction.none : r);
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: kOnSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Günün Bilgisi',
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.push('/tips'),
            style: TextButton.styleFrom(
              foregroundColor: kPrimary,
              padding: const EdgeInsets.only(right: AppSizes.md),
            ),
            child: Text(
              'Tümü',
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const BubbleBackground(),
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingH,
              vertical: AppSizes.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroImage(tip),
                const SizedBox(height: AppSizes.lg),
                _buildTitle(tip),
                const SizedBox(height: AppSizes.lg),
                ..._buildSections(tip),
                const SizedBox(height: AppSizes.md),
                _buildAuthorRow(tip),
                const Divider(height: AppSizes.xl, color: kOutlineVariant),
                _buildInteractionRow(tip),
                const SizedBox(height: AppSizes.xxl + AppSizes.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Tip tip) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: TipImage(asset: tip.imageAsset, iconSize: 40),
          ),
        ),
        Positioned(
          top: AppSizes.sm + 4,
          left: AppSizes.sm + 4,
          child: CategoryBadge(label: tip.category),
        ),
      ],
    );
  }

  Widget _buildTitle(Tip tip) {
    return Text(
      tip.title,
      style: GoogleFonts.plusJakartaSans(
        color: kOnSurface,
        fontSize: AppSizes.fontXxl - 2,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: -0.3,
      ),
    );
  }

  List<Widget> _buildSections(Tip tip) {
    final widgets = <Widget>[];

    // Özet paragraf
    widgets.add(
      Text(
        tip.summary,
        style: GoogleFonts.sourceSans3(
          color: kOnSurfaceVariant,
          fontSize: AppSizes.fontLg - 1,
          fontWeight: FontWeight.w500,
          height: 1.6,
        ),
      ),
    );
    widgets.add(const SizedBox(height: AppSizes.lg));

    for (final section in tip.sections) {
      widgets.add(
        Text(
          section.heading,
          style: GoogleFonts.plusJakartaSans(
            color: kOnSurface,
            fontSize: AppSizes.fontXl - 1,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      widgets.add(const SizedBox(height: AppSizes.xs + 2));
      widgets.add(
        Text(
          section.body,
          style: GoogleFonts.sourceSans3(
            color: kOnSurfaceVariant,
            fontSize: AppSizes.fontLg - 1,
            fontWeight: FontWeight.w500,
            height: 1.6,
          ),
        ),
      );
      widgets.add(const SizedBox(height: AppSizes.lg));
    }

    return widgets;
  }

  Widget _buildAuthorRow(Tip tip) {
    return Text(
      '${tip.author}  |  ${du.formatDate(tip.date)}',
      style: GoogleFonts.sourceSans3(
        color: kOnSurfaceVariant,
        fontSize: AppSizes.fontSm + 1,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInteractionRow(Tip tip) {
    final liked = _reaction == _Reaction.liked;
    final disliked = _reaction == _Reaction.disliked;
    final likeCount = tip.likes + (liked ? 1 : 0);
    final dislikeCount = tip.dislikes + (disliked ? 1 : 0);

    return Row(
      children: [
        _InteractionButton(
          icon: Icons.thumb_up_outlined,
          activeIcon: Icons.thumb_up_rounded,
          count: likeCount,
          activeColor: Colors.amber.shade600,
          borderColor: kPrimary,
          isActive: liked,
          onTap: () => _setReaction(_Reaction.liked),
        ),
        const SizedBox(width: AppSizes.sm + 4),
        _InteractionButton(
          icon: Icons.thumb_down_outlined,
          activeIcon: Icons.thumb_down_rounded,
          count: dislikeCount,
          activeColor: kError,
          borderColor: kError,
          isActive: disliked,
          onTap: () => _setReaction(_Reaction.disliked),
        ),
        const SizedBox(width: AppSizes.sm + 4),
        _InteractionButton(
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          count: tip.commentCount,
          activeColor: kPrimary,
          borderColor: kPrimary,
          isActive: false,
          onTap: () {},
        ),
        const Spacer(),
        GestureDetector(
          onTap: _toggleSaved,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary, width: 1.5),
            ),
            child: Icon(
              _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _saved ? kSecondary : kOnSurfaceVariant,
              size: AppSizes.iconSm + 4,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Etkileşim butonu (like / dislike / yorum)
// ─────────────────────────────────────────────────────────────────────────────
class _InteractionButton extends StatelessWidget {
  const _InteractionButton({
    required this.icon,
    required this.activeIcon,
    required this.count,
    required this.activeColor,
    required this.borderColor,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final int count;
  final Color activeColor;
  final Color borderColor;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? activeColor : kOutlineVariant,
                width: 1.5,
              ),
            ),
            child: Icon(
              isActive ? activeIcon : icon,
              size: AppSizes.iconSm + 4,
              color: isActive ? activeColor : kOnSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          Text(
            '$count',
            style: GoogleFonts.sourceSans3(
              color: kOnSurfaceVariant,
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

