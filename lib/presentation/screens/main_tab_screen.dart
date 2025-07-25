import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/widgets/enhanced_crypto_bot_widget.dart';
import 'package:kointos/presentation/screens/social_feed_screen.dart';
import 'package:kointos/presentation/screens/articles_screen.dart';
import 'package:kointos/presentation/screens/profile_screen.dart';
import 'package:kointos/presentation/screens/leaderboard_screen.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;

  final List<Widget> _screens = [
    const SocialFeedScreen(),
    const ArticlesScreen(),
    const LeaderboardScreen(),
    const ProfileScreen(),
  ];

  final List<IconData> _icons = [
    Icons.dynamic_feed_rounded,
    Icons.article_rounded,
    Icons.leaderboard_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = [
    'Social',
    'Articles',
    'Leaderboard',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),

          // Floating Enhanced Crypto Bot
          const EnhancedCryptoBotWidget(),
        ],
      ),

      // Modern Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.secondaryBlack,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });

                // Haptic feedback
                // HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: AppTheme.normalAnimation,
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.pureWhite.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[index],
                      color:
                          isSelected ? AppTheme.pureWhite : AppTheme.greyText,
                      size: isSelected ? 28 : 24,
                    ).animate(target: isSelected ? 1 : 0).scale(
                          duration: AppTheme.fastAnimation,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[index],
                      style: TextStyle(
                        color:
                            isSelected ? AppTheme.pureWhite : AppTheme.greyText,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ).animate(target: isSelected ? 1 : 0).fadeIn(
                          duration: AppTheme.fastAnimation,
                        ),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: index * 100),
                  duration: AppTheme.normalAnimation,
                )
                .slideY(
                  begin: 0.3,
                  duration: AppTheme.normalAnimation,
                  curve: Curves.easeOutBack,
                );
          }),
        ),
      ),
    );
  }
}
