import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/calc_button.dart';
import '../widgets/display.dart';
import '../widgets/history_panel.dart';
import '../services/history_service.dart';
import '../services/haptic_service.dart';
import '../models/history_item.dart';
import '../theme/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';
  bool _scientific = false;
  bool _showHistory = false;
  List<HistoryItem> _history = [];
  Color _accent = AppTheme.accents[0];
  int _accentIndex = 0;

  final _scientificButtons = [
    ['sin', 'cos', 'tan', 'π'],
    ['log', 'ln', '√', 'e'],
    ['^', '!', '(', ')'],
  ];

  final _mainButtons = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '−'],
    ['1', '2', '3', '+'],
    ['±', '0', '.', '='],
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await HapticService.init();
    final prefs = await SharedPreferences.getInstance();
    _accentIndex = prefs.getInt('accent') ?? 0;
    _accent = AppTheme.accents[_accentIndex];
    _history = await HistoryService.load();
    if (mounted) setState(() {});
  }

  void _cycleAccent() async {
    setState(() {
      _accentIndex = (_accentIndex + 1) % AppTheme.accents.length;
      _accent = AppTheme.accents[_accentIndex];
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('accent', _accentIndex);
    HapticService.tap();
  }

  void _onPressed(String value) {
    HapticService.tap();
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (value == '=') {
        _calculate();
      } else if (value == '±') {
        if (_input.startsWith('-')) {
          _input = _input.substring(1);
        } else if (_input.isNotEmpty) {
          _input = '-$_input';
        }
      } else if (['sin', 'cos', 'tan', 'log', 'ln', '√'].contains(value)) {
        _input += '$value(';
      } else if (value == 'π') {
        _input += '3.14159265';
      } else if (value == 'e') {
        _input += '2.71828182';
      } else {
        _input += value;
      }
    });
  }

  void _calculate() {
    try {
      String expr = _input
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('−', '-')
          .replaceAll('π', '3.14159265')
          .replaceAll('e', '2.71828182')
          .replaceAll('√', 'sqrt')
          .replaceAll('^', '^')
          .replaceAll('!', '!');

      Parser p = Parser();
      Expression exp = p.parse(expr);
      ContextModel cm = ContextModel();
      double eval = exp.evaluate(EvaluationType.REAL, cm);

      if (eval.isNaN || eval.isInfinite) throw Exception();

      _result = eval.truncateToDouble() == eval
          ? eval.toInt().toString()
          : eval
              .toStringAsFixed(6)
              .replaceAll(RegExp(r'0+$'), '')
              .replaceAll(RegExp(r'\.$'), '');

      final item = HistoryItem(
        expression: _input,
        result: _result,
        time: DateTime.now(),
      );
      HistoryService.add(item);
      setState(() => _history.insert(0, item));
      HapticService.equals();
    } catch (e) {
      _result = 'Error';
      HapticService.error();
    }
  }

  Widget _buildButton(String label) {
    return CalcButton(
      label: label,
      accent: _accent,
      small: _scientific,
      active: ['÷', '×', '−', '+'].contains(label),
      onTap: () => _onPressed(label),
    );
  }

   @override
  Widget build(BuildContext context) {
    // Get the system navigation bar height
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _cycleAccent,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _accent.withOpacity(0.6),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        HapticService.tap();
                        setState(() => _scientific = !_scientific);
                      },
                      icon: Icon(
                        _scientific ? Icons.calculate : Icons.functions,
                        color: _scientific ? _accent : Colors.white54,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        HapticService.tap();
                        setState(() => _showHistory = !_showHistory);
                      },
                      icon: Icon(
                        Icons.history,
                        color: _showHistory ? _accent : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),

              // Display
              Expanded(
                flex: 3,
                child: Display(
                  input: _input,
                  result: _result,
                  accent: _accent,
                  onTap: () {},
                ),
              ),

              // Scientific pad
              if (_scientific)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _scientificButtons.map((row) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: row.map((label) {
                            return Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: AspectRatio(
                                  aspectRatio: 1.6,
                                  child: _buildButton(label),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Main pad
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate button size to fit available space
                      const spacing = 10.0;
                      final availableHeight = constraints.maxHeight;
                      final availableWidth = constraints.maxWidth;

                      // 4 columns, 5 rows
                      final btnWidth = (availableWidth - spacing * 3) / 4;
                      final btnHeight = (availableHeight - spacing * 4) / 5;

                      // Use the smaller dimension to keep buttons square-ish
                      final btnSize =
                          btnWidth < btnHeight ? btnWidth : btnHeight;

                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: spacing,
                          crossAxisSpacing: spacing,
                          childAspectRatio: btnWidth / btnSize,
                        ),
                        itemCount: 20,
                        itemBuilder: (context, i) {
                          final label = _mainButtons[i ~/ 4][i % 4];
                          return _buildButton(label)
                              .animate(delay: (i * 20).ms)
                              .fadeIn(duration: 350.ms)
                              .scale(begin: const Offset(0.7, 0.7));
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // History Panel
      bottomSheet: _showHistory
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: HistoryPanel(
                items: _history,
                accent: _accent,
                onSelect: (item) {
                  HapticService.tap();
                  setState(() {
                    _input = item.result;
                    _result = item.result;
                    _showHistory = false;
                  });
                },
                onClear: () async {
                  await HistoryService.clear();
                  setState(() => _history = []);
                  HapticService.tap();
                },
              ),
            )
          : null,
    );
  }
}