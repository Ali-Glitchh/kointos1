import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';

class EnhancedCryptoBotWidget extends StatefulWidget {
  const EnhancedCryptoBotWidget({super.key});

  @override
  State<EnhancedCryptoBotWidget> createState() =>
      _EnhancedCryptoBotWidgetState();
}

class _EnhancedCryptoBotWidgetState extends State<EnhancedCryptoBotWidget>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  // Sample bot responses - In real implementation, this would connect to an AI service
  final Map<String, String> _botResponses = {
    'bitcoin':
        'Bitcoin (BTC) is currently trading at \$67,234. It\'s up 2.3% in the last 24 hours! 📈\n\nHere are some trending articles about Bitcoin:\n• "Bitcoin Reaches New Resistance Level"\n• "BTC Technical Analysis Q2 2025"',
    'ethereum':
        'Ethereum (ETH) is trading at \$3,456. The recent upgrade has improved gas fees significantly! ⛽\n\nRecommended reading:\n• "Ethereum Post-Merge Analysis"\n• "DeFi on Ethereum: Future Prospects"',
    'market':
        'The crypto market cap is \$2.3T today. Bitcoin dominance is at 42.1%. Most altcoins are showing bullish signals! 🚀\n\nTrending topics:\n• Market analysis and predictions\n• Altcoin season preparation',
    'defi':
        'DeFi Total Value Locked (TVL) is at \$89.4B. New protocols are emerging with innovative yield farming strategies! 🌾\n\nSuggested articles:\n• "DeFi 3.0: What\'s Next?"\n• "Yield Farming Strategies for 2025"',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Add welcome message
    _addBotMessage(
        'Hi! I\'m your crypto assistant 🤖\n\nAsk me about:\n• Any cryptocurrency prices\n• Market trends\n• DeFi protocols\n• Investment insights\n\nI can also suggest relevant articles from our community!');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isBot: true,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isBot: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim().toLowerCase();
    if (message.isEmpty) return;

    _addUserMessage(_messageController.text);
    _messageController.clear();

    // Simulate typing delay
    Future.delayed(const Duration(milliseconds: 800), () {
      String response =
          'I\'m still learning about that topic! 🤔\n\nTry asking me about:\n• Bitcoin, Ethereum, or other cryptocurrencies\n• Market trends\n• DeFi protocols\n\nOr check out our trending articles in the Articles tab!';

      // Simple keyword matching - In real implementation, use proper NLP/AI
      for (final keyword in _botResponses.keys) {
        if (message.contains(keyword)) {
          response = _botResponses[keyword]!;
          break;
        }
      }

      _addBotMessage(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expanded chat interface
          if (_isExpanded)
            Container(
              width: 320,
              height: 400,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardBlack,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.pureWhite.withValues(alpha: 0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryBlack,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.cryptoGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: AppTheme.pureWhite,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crypto Assistant',
                                style: AppTheme.body1.copyWith(
                                  color: AppTheme.pureWhite,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Online • Real-time data',
                                style: AppTheme.caption.copyWith(
                                  color: AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Messages
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ),

                  // Input area
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryBlack,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            onSubmitted: (_) => _sendMessage(),
                            style: AppTheme.body2.copyWith(
                              color: AppTheme.pureWhite,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Ask about crypto...',
                              hintStyle: AppTheme.body2.copyWith(
                                color: AppTheme.greyText,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.1),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.pureWhite.withValues(alpha: 0.1),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppTheme.pureWhite,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _sendMessage,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppTheme.cryptoGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: AppTheme.pureWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().scale().fadeIn(),

          // Floating action button
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _bounceController.forward().then((_) {
                  _bounceController.reverse();
                });
              }
            },
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale:
                      _isExpanded ? 1.0 : 1.0 + (_pulseController.value * 0.1),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: AppTheme.cryptoGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cryptoGold.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _isExpanded
                                ? Icons.smart_toy_rounded
                                : Icons.smart_toy_outlined,
                            color: AppTheme.pureWhite,
                            size: 32,
                          ),
                        ),
                        // Online indicator
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.pureWhite,
                                width: 2,
                              ),
                            ),
                          )
                              .animate()
                              .scale(delay: 1000.ms)
                              .then()
                              .fadeOut(duration: 500.ms)
                              .then()
                              .fadeIn(duration: 500.ms),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ).animate().scale(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.isBot) ...[
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppTheme.cryptoGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.pureWhite,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isBot
                    ? AppTheme.secondaryBlack
                    : AppTheme.pureWhite.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.message,
                style: AppTheme.body2.copyWith(
                  color: AppTheme.pureWhite,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (!message.isBot) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.cryptoGold,
              child: Text(
                'U',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideX(begin: message.isBot ? -0.3 : 0.3);
  }
}

class ChatMessage {
  final String message;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isBot,
    required this.timestamp,
  });
}
