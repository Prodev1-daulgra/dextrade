import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/custom_toast.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../data/models/crypto_model.dart';
import '../../widgets/crypto_icon.dart';

// Candlestick model representing volatile price action
class CandleData {
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final String label;

  CandleData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.label,
  });
}

// Simulated active position in terminal
class ActivePosition {
  final String symbol;
  final String side; // "LONG" or "SHORT"
  final double entryPrice;
  double markPrice;
  final double margin;
  final double size;
  final int leverage;

  ActivePosition({
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.markPrice,
    required this.margin,
    required this.size,
    required this.leverage,
  });

  double get unrealizedPnL {
    if (side == "LONG") {
      return (markPrice - entryPrice) * size;
    } else {
      return (entryPrice - markPrice) * size;
    }
  }

  double get pnlPercent {
    return (unrealizedPnL / margin) * 100;
  }
}

class TradeScreen extends ConsumerStatefulWidget {
  const TradeScreen({super.key});

  @override
  ConsumerState<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends ConsumerState<TradeScreen>
    with TickerProviderStateMixin {
  // Tab controller for order forms
  int _orderTab = 0; // 0 = Market, 1 = Limit
  int _sideTab = 0; // 0 = Buy (Long), 1 = Sell (Short)
  int _bottomTab = 0; // 0 = Active Positions, 1 = Node Sync Logs

  // Form states
  final _priceCtrl = TextEditingController(text: "97240.00");
  final _amountCtrl = TextEditingController(text: "0.05");
  double _leverage = 5.0;
  bool _submitting = false;

  // Chart states
  String _timeframe = "15M";
  List<CandleData> _chartData = [];
  Offset _chartHoverOffset = Offset.zero;
  bool _isHoveringChart = false;

  // Live order book streams
  final List<Map<String, dynamic>> _asks = [];
  final List<Map<String, dynamic>> _bids = [];
  double _currentPrice = 97240.00;
  double _priceChangePercent = 2.45;
  CryptoModel? _selectedCrypto;
  bool _cryptoLoaded = false;

  // Active positions & logs
  final List<ActivePosition> _positions = [];
  final List<String> _activityLogs = [];
  final ScrollController _logScrollController = ScrollController();

  // Simulated live timers
  Timer? _tickerTimer;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generateMockChartData();
    _generateMockOrderBook();
    _seedInitialPositions();

    // Start live matching engine simulated ticking
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _tickEngine();
    });

    _priceCtrl.addListener(_updateTotalCost);
    _amountCtrl.addListener(_updateTotalCost);
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    _logScrollController.dispose();
    super.dispose();
  }

  void _generateMockChartData() {
    _chartData.clear();
    double startPrice = 96500.0;
    int count = 24;

    for (int i = 0; i < count; i++) {
      final double change = (_random.nextDouble() - 0.45) * 800;
      final double open = startPrice;
      final double close = startPrice + change;
      final double high = math.max(open, close) + _random.nextDouble() * 300;
      final double low = math.min(open, close) - _random.nextDouble() * 300;
      final double vol = 5 + _random.nextDouble() * 85;

      _chartData.add(
        CandleData(
          open: open,
          high: high,
          low: low,
          close: close,
          volume: vol,
          label: "${10 + i}:00",
        ),
      );
      startPrice = close;
    }
  }

  void _generateMockOrderBook() {
    _asks.clear();
    _bids.clear();

    double basePrice = _currentPrice;
    for (int i = 0; i < 8; i++) {
      basePrice += 12.0 + _random.nextDouble() * 15.0;
      _asks.add({
        'price': basePrice,
        'size': 0.02 + _random.nextDouble() * 1.8,
        'flash': false,
      });
    }

    basePrice = _currentPrice;
    for (int i = 0; i < 8; i++) {
      basePrice -= 12.0 + _random.nextDouble() * 15.0;
      _bids.add({
        'price': basePrice,
        'size': 0.02 + _random.nextDouble() * 1.8,
        'flash': false,
      });
    }
    // Reverse asks to render highest at the top
    _asks.sort((a, b) => b['price'].compareTo(a['price']));
  }

  void _seedInitialPositions() {
    _positions.add(
      ActivePosition(
        symbol: "BTC/USDT",
        side: "LONG",
        entryPrice: 96800.00,
        markPrice: _currentPrice,
        margin: 400.00,
        size: 0.15,
        leverage: 10,
      ),
    );

    _addLog("SYSTEM INIT: Matches aligned successfully.");
    _addLog("WEBSOCKET CONNECTED: Port 443 active.");
  }

  void _addLog(String msg) {
    if (mounted) {
      setState(() {
        final timestamp = DateTime.now().toLocal().toString().substring(11, 19);
        _activityLogs.add("[$timestamp] $msg");
        if (_activityLogs.length > 50) _activityLogs.removeAt(0);
      });
      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_logScrollController.hasClients) {
          _logScrollController.jumpTo(
            _logScrollController.position.maxScrollExtent,
          );
        }
      });
    }
  }

  double _totalCost = 0.0;
  void _updateTotalCost() {
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    setState(() {
      _totalCost = (price * amount) / _leverage;
    });
  }

  // Matching Engine Live Ticking Math
  void _tickEngine() {
    if (!mounted) return;

    setState(() {
      // 1. Tick Current Spot Price volatile fluctuations
      final double delta = (_random.nextDouble() - 0.49) * 18.0;
      _currentPrice += delta;
      _priceChangePercent += delta * 0.001;

      // Update spot inputs if in Market Mode
      if (_orderTab == 0) {
        _priceCtrl.text = _currentPrice.toStringAsFixed(2);
      }

      // 2. Fluctuating Positions Unrealized P&Ls
      for (var pos in _positions) {
        pos.markPrice = _currentPrice;
      }

      // 3. Fluctuating Order Book Sizes & flashing glows
      if (_random.nextDouble() > 0.4) {
        final bool isAsk = _random.nextBool();
        final int targetIdx = _random.nextInt(8);
        final Map<String, dynamic> row = isAsk
            ? _asks[targetIdx]
            : _bids[targetIdx];

        row['size'] = math.max(
          0.01,
          row['size'] + (_random.nextDouble() - 0.5) * 0.2,
        );
        row['flash'] = true;
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() {
              row['flash'] = false;
            });
          }
        });
      }

      // Add high-frequency simulated logs
      if (_random.nextDouble() > 0.7) {
        final double flowSize = 0.1 + _random.nextDouble() * 4.5;
        final String sym = _random.nextBool() ? "BTC/USDT" : "ETH/USDT";
        _addLog(
          "MATCHED FLOW: Order block synced size ${flowSize.toStringAsFixed(3)} on $sym.",
        );
      }
    });
  }

  Future<void> _submitOrder() async {
    final price = double.tryParse(_priceCtrl.text) ?? 0.0;
    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;

    if (amount <= 0) {
      DexToast.showPushNotification(
        context,
        title: 'Error',
        body: 'Invalid order size format.',
      );
      return;
    }

    setState(() => _submitting = true);
    _addLog("SUBMITTING ORDER: Dispatching credentials to matches cluster...");

    // Simulated network processing latency
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _submitting = false;
        final side = _sideTab == 0 ? "LONG" : "SHORT";
        _positions.add(
          ActivePosition(
            symbol: "${_selectedCrypto?.symbol ?? 'BTC'}/USDT",
            side: side,
            entryPrice: price,
            markPrice: _currentPrice,
            margin: _totalCost,
            size: amount,
            leverage: _leverage.toInt(),
          ),
        );
      });

      _addLog(
        "ORDER EXECUTED: Added new position side ${_sideTab == 0 ? 'LONG' : 'SHORT'} sizing $amount BTC.",
      );
      DexToast.showPushNotification(
        context,
        title: 'Order Executed',
        body: 'Order matching completed instantly!',
      );
    }
  }

  void _closePosition(int idx) {
    if (idx >= _positions.length) return;
    final pos = _positions[idx];
    setState(() {
      _positions.removeAt(idx);
    });
    _addLog(
      "POSITION RESOLVED: Closed ${pos.symbol} ${pos.side} sizing ${pos.size} with P&L: \$${pos.unrealizedPnL.toStringAsFixed(2)}",
    );
    DexToast.showPushNotification(
      context,
      title: 'Position Closed',
      body: 'Position cleared from terminal.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 900;

    final cryptosAsync = ref.watch(cryptosProvider);

    // Initial setup of real crypto data
    if (cryptosAsync.value != null &&
        cryptosAsync.value!.isNotEmpty &&
        !_cryptoLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedCrypto = cryptosAsync.value!.first;
          _currentPrice = _selectedCrypto!.price;
          _priceChangePercent = _selectedCrypto!.change24h;
          _priceCtrl.text = _currentPrice.toStringAsFixed(2);
          _cryptoLoaded = true;
          _generateMockChartData();
          _generateMockOrderBook();
        });
      });
    }

    return Scaffold(
      backgroundColor: Colors.black, // Dark obsidian canvas
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header: Real-Time Price Statistics Bar ───
              _buildTerminalHeader(isDesktop, cryptosAsync.value ?? []),
              const SizedBox(height: 16),

              // ─── Main Terminal Screen Layout ───
              Expanded(
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Panel (10): Custom Candlestick Chart & Position Manager
                          Expanded(
                            flex: 10,
                            child: Column(
                              children: [
                                // Interactive Candlestick Chart panel
                                Expanded(flex: 6, child: _buildChartPanel()),
                                const SizedBox(height: 16),
                                // Bottom Logs / Positions Panel
                                Expanded(
                                  flex: 4,
                                  child: _buildBottomTabPanel(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Panel (4): Live Order Book & BUY/SELL Form Console
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                // Buy/Sell forms
                                Expanded(
                                  flex: 5,
                                  child: _buildOrderFormConsole(),
                                ),
                                const SizedBox(height: 16),
                                // Live Order Book (Asks & Bids queues)
                                Expanded(
                                  flex: 5,
                                  child: _buildOrderBookPanel(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 350, child: _buildChartPanel()),
                            const SizedBox(height: 16),
                            _buildOrderFormConsole(),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: _buildOrderBookPanel(),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: _buildBottomTabPanel(),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Terminal Header Widget ───
  Widget _buildTerminalHeader(bool isDesktop, List<CryptoModel> cryptos) {
    final bool isUp = _priceChangePercent >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.015),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Flex(
        direction: isDesktop ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: isDesktop
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          PopupMenuButton<CryptoModel>(
            position: PopupMenuPosition.under,
            color: DexColors.surfaceLight,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (crypto) {
              setState(() {
                _selectedCrypto = crypto;
                _currentPrice = crypto.price;
                _priceChangePercent = crypto.change24h;
                if (_orderTab == 0) {
                  _priceCtrl.text = _currentPrice.toStringAsFixed(2);
                }
                _generateMockChartData();
                _generateMockOrderBook();
              });
              _addLog("MARKET SWITCHED: Connected to ${crypto.symbol} node.");
            },
            itemBuilder: (context) => cryptos
                .map(
                  (c) => PopupMenuItem(
                    value: c,
                    child: Row(
                      children: [
                        CryptoIcon(
                          symbol: c.symbol,
                          colorHex: c.iconColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          c.symbol,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
            child: Row(
              children: [
                if (_selectedCrypto != null)
                  CryptoIcon(
                    symbol: _selectedCrypto!.symbol,
                    colorHex: _selectedCrypto!.iconColor,
                    size: 32,
                  )
                else
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DexColors.primary.withOpacity(0.12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.flash_on_rounded,
                        color: DexColors.primary,
                        size: 16,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _selectedCrypto != null
                              ? '${_selectedCrypto!.symbol}/USDT'
                              : 'LOADING...',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ],
                    ),
                    Text(
                      'DEXTRADE NODE ACTIVE',
                      style: GoogleFonts.orbitron(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: DexColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop) const Spacer() else const SizedBox(height: 12),
          _buildHeaderStat(
            'SPOT PRICE',
            '\$${_currentPrice.toStringAsFixed(2)}',
            valueColor: isUp ? DexColors.successGlow : DexColors.errorGlow,
          ),
          const SizedBox(width: 24),
          _buildHeaderStat(
            '24H CHANGE',
            '${isUp ? "+" : ""}${_priceChangePercent.toStringAsFixed(2)}%',
            valueColor: isUp ? DexColors.successGlow : DexColors.errorGlow,
          ),
          const SizedBox(width: 24),
          _buildHeaderStat('24H HIGH', '\$98,421.12'),
          const SizedBox(width: 24),
          _buildHeaderStat('24H LOW', '\$95,190.50'),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: Colors.white30,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? Colors.white,
          ),
        ),
      ],
    );
  }

  // ─── Custom Candlestick & Volume Chart Panel ───
  Widget _buildChartPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.04),
      child: Column(
        children: [
          // Chart Controls Topbar
          Row(
            children: [
              Text(
                'CHARTS OVERVIEW',
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: DexColors.primaryGlow,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              // Timeframe selectors
              Row(
                children: ["1M", "5M", "15M", "1H", "4H", "1D"].map((tf) {
                  final active = _timeframe == tf;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _timeframe = tf;
                        _generateMockChartData();
                      });
                      _addLog(
                        "TIMEFRAME RECONFIGURED: Reloaded matching nodes to $tf interval.",
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? DexColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: active
                              ? DexColors.primary.withOpacity(0.25)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        tf,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: active ? Colors.white : Colors.white38,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Custom Candlestick Chart Area
          Expanded(
            child: MouseRegion(
              onHover: (event) {
                setState(() {
                  _chartHoverOffset = event.localPosition;
                  _isHoveringChart = true;
                });
              },
              onExit: (event) {
                setState(() {
                  _isHoveringChart = false;
                });
              },
              child: ClipRect(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _CandlestickPainter(
                    data: _chartData,
                    hoverOffset: _chartHoverOffset,
                    isHovering: _isHoveringChart,
                    spotPrice: _currentPrice,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BUY / SELL Order Form Console Panel ───
  Widget _buildOrderFormConsole() {
    final bool isBuy = _sideTab == 0;
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Buy / Sell Tabs
          Row(
            children: [
              Expanded(
                child: _buildFormToggleTab(
                  'BUY (LONG)',
                  _sideTab == 0,
                  DexColors.success,
                  () => setState(() => _sideTab = 0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFormToggleTab(
                  'SELL (SHORT)',
                  _sideTab == 1,
                  DexColors.error,
                  () => setState(() => _sideTab = 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Limit / Market selectors
          Row(
            children: [
              _buildLimitMarketButton('MARKET', _orderTab == 0, () {
                setState(() {
                  _orderTab = 0;
                  _priceCtrl.text = _currentPrice.toStringAsFixed(2);
                });
              }),
              const SizedBox(width: 8),
              _buildLimitMarketButton('LIMIT', _orderTab == 1, () {
                setState(() => _orderTab = 1);
              }),
            ],
          ),
          const SizedBox(height: 20),

          // Price field
          Text(
            'EXECUTION PRICE (USDT)',
            style: GoogleFonts.orbitron(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.white30,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextField(
              controller: _priceCtrl,
              enabled: _orderTab == 1, // Disable price editing in market mode
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.00",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount field
          Text(
            'ORDER SIZE (BTC)',
            style: GoogleFonts.orbitron(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: Colors.white30,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: TextField(
              controller: _amountCtrl,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white,
                fontSize: 14,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "0.00",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Glassmorphic Leverage Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NODE LEVERAGE',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Colors.white30,
                ),
              ),
              Text(
                '${_leverage.toInt()}x',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _leverage >= 25
                      ? DexColors.errorGlow
                      : DexColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isBuy ? DexColors.success : DexColors.error,
              inactiveTrackColor: Colors.white.withOpacity(0.08),
              thumbColor: Colors.white,
              overlayColor: isBuy
                  ? DexColors.success.withOpacity(0.2)
                  : DexColors.error.withOpacity(0.2),
            ),
            child: Slider(
              value: _leverage,
              min: 1.0,
              max: 100.0,
              divisions: 99,
              onChanged: (val) {
                setState(() {
                  _leverage = val;
                  _updateTotalCost();
                });
              },
            ),
          ),

          // High Leverage Warnings
          if (_leverage >= 25) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: DexColors.error.withOpacity(0.08),
                border: Border.all(color: DexColors.error.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: DexColors.error,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'HIGH RISK: Liquidation parameters elevated.',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: DexColors.errorGlow,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Margin Requirements cost calculator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'REQUIRED MARGIN',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white38,
                ),
              ),
              Text(
                '\$${_totalCost.toStringAsFixed(2)} USDT',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Execution submit button
          GlowButton(
            label: isBuy ? 'DISPATCH LONG NODE' : 'DISPATCH SHORT NODE',
            onPressed: _submitting ? null : _submitOrder,
            isLoading: _submitting,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildFormToggleTab(
    String label,
    bool active,
    Color activeColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? activeColor.withOpacity(0.12)
              : Colors.white.withOpacity(0.01),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? activeColor.withOpacity(0.3)
                : Colors.white.withOpacity(0.04),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLimitMarketButton(
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: active ? Colors.white : Colors.white38,
          ),
        ),
      ),
    );
  }

  // ─── Live Order Book (Asks/Bids Queues) Panel ───
  Widget _buildOrderBookPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MATCH QUEUE ORDER BOOK',
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: DexColors.primaryGlow,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          // Column Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRICE (USDT)',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  color: Colors.white30,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                'SIZE (BTC)',
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  color: Colors.white30,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Asks (Sells in Red)
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, idx) {
                final ask = _asks[idx + 4]; // Render lower asks closer to spot
                return _buildOrderBookRow(
                  ask,
                  DexColors.errorGlow,
                  isAsk: true,
                );
              },
            ),
          ),

          // Current spot center dividing line
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.white.withOpacity(0.05)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${_currentPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _priceChangePercent >= 0
                        ? DexColors.successGlow
                        : DexColors.errorGlow,
                  ),
                ),
                Text(
                  'MATCH SPOT',
                  style: GoogleFonts.orbitron(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),

          // Bids (Buys in Green)
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, idx) {
                final bid = _bids[idx];
                return _buildOrderBookRow(
                  bid,
                  DexColors.successGlow,
                  isAsk: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderBookRow(
    Map<String, dynamic> data,
    Color priceColor, {
    required bool isAsk,
  }) {
    final double size = data['size'];
    final double price = data['price'];
    final bool flash = data['flash'];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      decoration: BoxDecoration(
        color: flash
            ? (isAsk
                  ? DexColors.error.withOpacity(0.12)
                  : DexColors.success.withOpacity(0.12))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            price.toStringAsFixed(2),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: priceColor,
            ),
          ),
          Text(
            size.toStringAsFixed(4),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Position Tracker / Sync Logs Panel ───
  Widget _buildBottomTabPanel() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      borderColor: Colors.white.withOpacity(0.04),
      child: Column(
        children: [
          // Panel Navigation headers
          Row(
            children: [
              _buildBottomNavTab(
                'ACTIVE POSITIONS (${_positions.length})',
                _bottomTab == 0,
                () {
                  setState(() => _bottomTab = 0);
                },
              ),
              const SizedBox(width: 16),
              _buildBottomNavTab(
                'MATCH CODES SYNC RECORD',
                _bottomTab == 1,
                () {
                  setState(() => _bottomTab = 1);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _bottomTab == 0
                ? _buildPositionsTable()
                : _buildActivityLogsPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavTab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.orbitron(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: active ? Colors.white : Colors.white30,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            width: 40,
            color: active ? DexColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsTable() {
    if (_positions.isEmpty) {
      return Center(
        child: Text(
          'No active matching positions located in this node.',
          style: GoogleFonts.spaceGrotesk(color: Colors.white24, fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      itemCount: _positions.length,
      itemBuilder: (context, idx) {
        final pos = _positions[idx];
        final bool isLong = pos.side == "LONG";
        final double pnl = pos.unrealizedPnL;
        final double pnlPct = pos.pnlPercent;
        final bool posUp = pnl >= 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.01),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Side Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isLong
                          ? DexColors.success.withOpacity(0.08)
                          : DexColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isLong
                            ? DexColors.success.withOpacity(0.2)
                            : DexColors.error.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      pos.side,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isLong
                            ? DexColors.successGlow
                            : DexColors.errorGlow,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pos.symbol,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Size: ${pos.size} BTC (${pos.leverage}x)',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10.5,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Entry & Mark Prices
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Entry: \$${pos.entryPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                  Text(
                    'Mark: \$${pos.markPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),

              // P&L Tracker
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${posUp ? "+" : ""}\$${pnl.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: posUp
                          ? DexColors.successGlow
                          : DexColors.errorGlow,
                    ),
                  ),
                  Text(
                    '${posUp ? "+" : ""}${pnlPct.toStringAsFixed(2)}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: posUp
                          ? DexColors.successGlow
                          : DexColors.errorGlow,
                    ),
                  ),
                ],
              ),

              // Action buttons
              IconButton(
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.white38,
                  size: 20,
                ),
                onPressed: () => _closePosition(idx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityLogsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: ListView.builder(
        controller: _logScrollController,
        itemCount: _activityLogs.length,
        itemBuilder: (context, idx) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              _activityLogs[idx],
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white38,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Custom Candlestick Chart CustomPainter ───
class _CandlestickPainter extends CustomPainter {
  final List<CandleData> data;
  final Offset hoverOffset;
  final bool isHovering;
  final double spotPrice;

  _CandlestickPainter({
    required this.data,
    required this.hoverOffset,
    required this.isHovering,
    required this.spotPrice,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double width = size.width;
    final double height = size.height;

    // 1. Draw dashed grid index lines
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1.0;

    const double gridStep = 45.0;
    for (double y = 0; y < height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    final double candleWidth = (width * 0.85) / data.length;
    for (int i = 0; i < data.length; i++) {
      final double x = i * candleWidth + (candleWidth * 0.5);
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // 2. Map coordinates relative to price limits
    double minPrice = data.first.low;
    double maxPrice = data.first.high;

    for (var c in data) {
      minPrice = math.min(minPrice, c.low);
      maxPrice = math.max(maxPrice, c.high);
    }
    // Add margin buffer
    final double priceDiff = maxPrice - minPrice;
    minPrice -= priceDiff * 0.08;
    maxPrice += priceDiff * 0.08;

    double mapY(double price) {
      return height - ((price - minPrice) / (maxPrice - minPrice)) * height;
    }

    final Paint candlePaint = Paint()..style = PaintingStyle.fill;
    final Paint wickPaint = Paint()..strokeWidth = 1.2;

    // 3. Draw Candlesticks & Volume Bars
    for (int i = 0; i < data.length; i++) {
      final c = data[i];
      final double left = i * candleWidth + (candleWidth * 0.15);
      final double right = (i + 1) * candleWidth - (candleWidth * 0.15);
      final double x = (left + right) / 2;

      final bool isUp = c.close >= c.open;
      final Color color = isUp ? DexColors.successGlow : DexColors.errorGlow;

      candlePaint.color = color.withOpacity(0.85);
      wickPaint.color = color;

      // Draw high/low wicks
      canvas.drawLine(
        Offset(x, mapY(c.high)),
        Offset(x, mapY(c.low)),
        wickPaint,
      );

      // Draw body rect
      final double top = mapY(math.max(c.open, c.close));
      final double bottom = mapY(math.min(c.open, c.close));
      final Rect bodyRect = Rect.fromLTRB(left, top, right, bottom);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyRect, const Radius.circular(3)),
        candlePaint,
      );

      // Draw Volume Bar underneath (bottom 20% of canvas)
      final double volHeight = (c.volume / 100.0) * (height * 0.18);
      final Rect volRect = Rect.fromLTRB(
        left,
        height - volHeight,
        right,
        height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(volRect, const Radius.circular(2)),
        Paint()..color = color.withOpacity(0.12),
      );
    }

    // 4. Draw spot price horizontal neon threshold
    final double spotY = mapY(spotPrice);
    final Paint spotPaint = Paint()
      ..color = DexColors.primary.withOpacity(0.3)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, spotY), Offset(width, spotY), spotPaint);

    // Draw small spot pill on the right
    final Paint spotPillPaint = Paint()..color = DexColors.primary;
    final Rect spotPill = Rect.fromLTWH(width - 60, spotY - 8, 60, 16);
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotPill, const Radius.circular(4)),
      spotPillPaint,
    );

    final TextPainter spotTP = TextPainter(
      text: TextSpan(
        text: spotPrice.toStringAsFixed(1),
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    spotTP.paint(canvas, Offset(width - 55, spotY - 6.5));

    // 5. Draw mouse hover crosshair coordinates
    if (isHovering && hoverOffset.dx < width - 60) {
      final Paint crosshairPaint = Paint()
        ..color = Colors.white.withOpacity(0.18)
        ..strokeWidth = 1.0;

      // Draw horizontal crosshair
      canvas.drawLine(
        Offset(0, hoverOffset.dy),
        Offset(width, hoverOffset.dy),
        crosshairPaint,
      );
      // Draw vertical crosshair
      canvas.drawLine(
        Offset(hoverOffset.dx, 0),
        Offset(hoverOffset.dx, height),
        crosshairPaint,
      );

      // Resolve price coordinates
      final double pctY = 1.0 - (hoverOffset.dy / height);
      final double hoverPrice = minPrice + pctY * (maxPrice - minPrice);

      // Price indicator bubble
      final Paint bubblePaint = Paint()..color = Colors.white24;
      final Rect bubble = Rect.fromLTWH(width - 65, hoverOffset.dy - 8, 65, 16);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bubble, const Radius.circular(4)),
        bubblePaint,
      );

      final TextPainter priceTP = TextPainter(
        text: TextSpan(
          text: hoverPrice.toStringAsFixed(1),
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontSize: 8.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      priceTP.paint(canvas, Offset(width - 60, hoverOffset.dy - 6.5));
    }
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) => true;
}
