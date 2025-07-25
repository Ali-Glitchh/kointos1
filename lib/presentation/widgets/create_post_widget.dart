import 'package:flutter/material.dart';
import 'package:kointos/core/theme/modern_theme.dart';

class CreatePostWidget extends StatelessWidget {
  const CreatePostWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.pureWhite.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.cryptoGold,
            child: Text(
              'U',
              style: AppTheme.body1.copyWith(
                color: AppTheme.pureWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create post feature coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlack,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.pureWhite.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  'What\'s on your mind about crypto?',
                  style: AppTheme.body2.copyWith(
                    color: AppTheme.greyText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quick share feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(
              Icons.photo_camera_rounded,
              color: AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
