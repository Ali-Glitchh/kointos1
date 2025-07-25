import 'package:flutter/material.dart';
import 'package:kointos/core/theme/app_theme.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final double totalValue;
  final double profitLoss;
  final double profitLossPercentage;
  final bool isPrivateMode;
  final String timeFilter;
  final Function(String) onTimeFilterChanged;

  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.profitLoss,
    required this.profitLossPercentage,
    required this.isPrivateMode,
    required this.timeFilter,
    required this.onTimeFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = profitLoss >= 0;
    final timeFilters = ['24h', '7d', '30d', 'All'];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPrivateMode ? '••••••••' : '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppTheme.positiveChangeColor.withValues(alpha: 0.3)
                      : AppTheme.negativeChangeColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isPrivateMode
                    ? const Text(
                        '••••••••',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            size: 16,
                            color: isPositive
                                ? AppTheme.positiveChangeColor
                                : AppTheme.negativeChangeColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? '+' : ''}${profitLossPercentage.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPositive
                                  ? AppTheme.positiveChangeColor
                                  : AppTheme.negativeChangeColor,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 12),
              Text(
                isPrivateMode
                    ? '••••••••'
                    : '${isPositive ? '+' : ''}\$${profitLoss.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isPositive
                      ? AppTheme.positiveChangeColor
                      : AppTheme.negativeChangeColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Time filter pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: timeFilters.map((filter) {
              final isSelected = filter == timeFilter;
              return GestureDetector(
                onTap: () => onTimeFilterChanged(filter),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
