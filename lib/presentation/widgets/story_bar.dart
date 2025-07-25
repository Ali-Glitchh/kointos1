import 'package:flutter/material.dart';
import 'package:kointos/core/theme/modern_theme.dart';

class StoryBar extends StatelessWidget {
  const StoryBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildAddStoryItem();
          }
          return _buildStoryItem(index);
        },
      ),
    );
  }

  Widget _buildAddStoryItem() {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.cardBlack,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.pureWhite.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppTheme.pureWhite,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your Story',
            style: AppTheme.caption.copyWith(
              color: AppTheme.greyText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(int index) {
    final List<String> users = [
      'CryptoGuru',
      'BitcoinFan',
      'DeFiExpert',
      'ETHTrader',
      'AltcoinPro',
    ];

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              gradient: AppTheme.cryptoGradient,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlack,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: CircleAvatar(
                backgroundColor: AppTheme.cryptoGold,
                child: Text(
                  users[index - 1][0],
                  style: AppTheme.body1.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            users[index - 1],
            style: AppTheme.caption.copyWith(
              color: AppTheme.greyText,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
