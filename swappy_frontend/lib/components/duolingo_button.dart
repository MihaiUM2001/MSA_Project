import 'package:flutter/material.dart';

class DuolingoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? startColor;
  final Color? endColor;
  final bool isSolidColor;

  const DuolingoButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.startColor,
    this.endColor,
    this.isSolidColor = false,
  }) : super(key: key);

  @override
  _DuolingoButtonState createState() => _DuolingoButtonState();
}

class _DuolingoButtonState extends State<DuolingoButton> {
  bool _isPressed = false;

  /// **Function to Darken Color Automatically for the Border**
  Color _darkenColor(Color color, {double factor = 0.2}) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).clamp(0, 255).toInt(),
      (color.green * (1 - factor)).clamp(0, 255).toInt(),
      (color.blue * (1 - factor)).clamp(0, 255).toInt(),
    );
  }

  /// **Handle button press animation**
  void _handlePress() async {
    if (widget.onPressed == null || widget.isDisabled) return;

    setState(() {
      _isPressed = true; // Start press effect
    });

    await Future.delayed(const Duration(milliseconds: 150)); // Hold animation for 150ms

    setState(() {
      _isPressed = false; // Release effect
    });

    widget.onPressed!(); // Execute button action
  }

  @override
  Widget build(BuildContext context) {
    bool disable = widget.onPressed == null || widget.isDisabled;
    Color mainColor = widget.startColor ?? const Color(0xFF58CC02); // Default Duolingo Green
    Color borderColor = _darkenColor(mainColor, factor: 0.3); // Automatically darken border

    return GestureDetector(
      onTap: _handlePress, // Now handles animation regardless of tap duration
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: _isPressed ? 53 : 55, // Shrink when pressed
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), // Smooth pill shape
          color: widget.isSolidColor
              ? (disable ? Colors.grey[400] : mainColor) // Solid color version
              : null,
          gradient: !widget.isSolidColor && !disable && widget.startColor != null && widget.endColor != null
              ? LinearGradient(colors: [widget.startColor!, widget.endColor!]) // Gradient version
              : null,
          border: widget.isSolidColor && !disable && !_isPressed
              ? Border(
            bottom: BorderSide(
              color: borderColor, // Auto-darkened color
              width: 5, // More visible bottom border
            ),
          )
              : null,
          boxShadow: disable
              ? []
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: _isPressed ? 3 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: widget.isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
          widget.text.toUpperCase(),
          style: TextStyle(
            color: disable ? Colors.white70 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16, // Slightly larger text
            letterSpacing: 1.5, // More visible letter spacing
          ),
        ),
      ),
    );
  }
}
