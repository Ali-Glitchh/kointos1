import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeTutorial extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const FirstTimeTutorial({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<FirstTimeTutorial> createState() => _FirstTimeTutorialState();
}

class _FirstTimeTutorialState extends State<FirstTimeTutorial>
    with TickerProviderStateMixin {
  bool _showTutorial = false;
  int _currentStep = 0;
  late PageController _pageController;
  late AnimationController _pulseController;

  final List<TutorialStep> _steps = [
    TutorialStep(
      title: 'Welcome to Kointos!',
      description:
          'Your gateway to the crypto community. Share insights, learn from experts, and earn rewards for quality content.',
      icon: Icons.rocket_launch_rounded,
      gradient: AppTheme.cryptoGradient,
      features: [
        'Social crypto discussions',
        'Real-time market insights',
        'Gamified reward system',
      ],
    ),
    TutorialStep(
      title: 'Social Feed',
      description:
          'Connect with crypto enthusiasts worldwide. Share quick thoughts, market predictions, and engage with the community.',
      icon: Icons.dynamic_feed_rounded,
      gradient: const LinearGradient(
        colors: [AppTheme.successGreen, Color(0xFF4CAF50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        'Share crypto insights',
        'Follow expert traders',
        'Real-time discussions',
      ],
    ),
    TutorialStep(
      title: 'Write Articles',
      description:
          'Create in-depth analysis and tutorials. Quality articles earn higher rewards and establish your expertise.',
      icon: Icons.article_rounded,
      gradient: const LinearGradient(
        colors: [AppTheme.warningAmber, Color(0xFFFF9800)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        'In-depth market analysis',
        'Educational content',
        'Higher point rewards',
      ],
    ),
    TutorialStep(
      title: 'AI Crypto Assistant',
      description:
          'Your personal crypto advisor. Get real-time market data, price analysis, and personalized article recommendations.',
      icon: Icons.smart_toy_rounded,
      gradient: const LinearGradient(
        colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      features: [
        'Real-time crypto data',
        'Smart recommendations',
        'Market analysis',
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _checkFirstTime();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time_tutorial') ?? true;

    if (isFirstTime && mounted) {
      setState(() {
        _showTutorial = true;
      });
    }
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_time_tutorial', false);

    setState(() {
      _showTutorial = false;
    });

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showTutorial) _buildTutorialOverlay(),
      ],
    );
  }

  Widget _buildTutorialOverlay() {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton.icon(
                  onPressed: _completeTutorial,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Skip'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.greyText,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            // Tutorial content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialStep(_steps[index], index);
                },
              ),
            ),

            // Bottom navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(TutorialStep step, int index) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Animated icon with pulsing effect
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: step.gradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: step.gradient.colors.first.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    size: 70,
                    color: AppTheme.pureWhite,
                  ),
                ),
              );
            },
          ).animate().scale(delay: 200.ms, duration: 800.ms),

          const SizedBox(height: 48),

          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.cardBlack.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.pureWhite.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              step.title,
              textAlign: TextAlign.center,
              style: AppTheme.h1.copyWith(
                color: AppTheme.pureWhite,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

          const SizedBox(height: 24),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: AppTheme.body1.copyWith(
              color: AppTheme.accentWhite,
              height: 1.6,
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

          const SizedBox(height: 32),

          // Features list
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBlack.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.pureWhite.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: step.features.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: step.gradient,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: AppTheme.pureWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_steps.length, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isCompleted || isActive
                            ? AppTheme.pureWhite
                            : AppTheme.greyText.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${index + 1}',
                      style: AppTheme.caption.copyWith(
                        color: isCompleted || isActive
                            ? AppTheme.pureWhite
                            : AppTheme.greyText,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: AppTheme.normalAnimation,
                        curve: Curves.easeInOut,
                      );
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.pureWhite,
                      side: const BorderSide(color: AppTheme.pureWhite),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                )
              else
                const Expanded(child: SizedBox()),

              const SizedBox(width: 16),

              // Next/Get Started button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_currentStep < _steps.length - 1) {
                      _pageController.nextPage(
                        duration: AppTheme.normalAnimation,
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _completeTutorial();
                    }
                  },
                  icon: Icon(
                    _currentStep < _steps.length - 1
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                  ),
                  label: Text(
                    _currentStep < _steps.length - 1 ? 'Next' : 'Get Started',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pureWhite,
                    foregroundColor: AppTheme.primaryBlack,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 1.0, delay: 200.ms);
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final List<String> features;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.features,
  });
}
