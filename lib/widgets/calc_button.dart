import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalcButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final Color accent;
  final bool small;
  final bool active;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.accent,
    this.small = false,
    this.active = false,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _depth;
  late Animation<double> _rotation;

  bool get _isOperator =>
      ['÷', '×', '−', '+'].contains(widget.label);
  bool get _isEquals => widget.label == '=';
  bool get _isTop => ['C', '⌫', '%'].contains(widget.label);
  bool get _isScientific =>
      ['sin', 'cos', 'tan', 'log', 'ln', '√', 'π', 'e', '^', '!', '(', ')']
          .contains(widget.label);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _depth = Tween(begin: 0.0, end: 10.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _rotation = Tween(begin: 0.0, end: 0.03)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _baseColor {
    if (_isEquals) return widget.accent;
    if (_isOperator) return AppTheme.operatorBg;
    if (_isTop) return AppTheme.surfaceAlt;
    if (_isScientific) return const Color(0xFF121220);
    return AppTheme.surface;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..translate(
                _rotation.value * 20,
                _depth.value,
                _depth.value * -0.5,
              )
              ..rotateX(_rotation.value)
              ..rotateY(_rotation.value * 0.5)
              ..scale(_scale.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.small ? 16 : 22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(_baseColor, Colors.white, 0.1)!,
                    _baseColor,
                    Color.lerp(_baseColor, Colors.black, 0.15)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: Offset(0, 8 - _depth.value),
                    blurRadius: 14,
                  ),
                  if (_isEquals)
                    BoxShadow(
                      color: widget.accent.withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  if (!_isEquals && widget.active)
                    BoxShadow(
                      color: widget.accent.withOpacity(0.35),
                      blurRadius: 24,
                    ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.08),
                    offset: const Offset(0, -1),
                    blurRadius: 3,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.07),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: widget.small ? 18 : 26,
                  fontWeight: _isEquals ? FontWeight.w800 : FontWeight.w500,
                  color: _isEquals
                      ? Colors.white
                      : widget.active
                          ? widget.accent
                          : Colors.white.withOpacity(0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}