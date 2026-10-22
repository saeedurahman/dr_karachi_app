import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class OtpBoxesWidget extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool shouldShake;
  final VoidCallback? onShakeCompleted;

  const OtpBoxesWidget({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.shouldShake = false,
    this.onShakeCompleted,
  });

  @override
  State<OtpBoxesWidget> createState() => OtpBoxesWidgetState();
}

class OtpBoxesWidgetState extends State<OtpBoxesWidget>
    with SingleTickerProviderStateMixin {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    // Autofocus first box after frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant OtpBoxesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldShake && !oldWidget.shouldShake) {
      _triggerClearAndShake();
    }
  }

  void _triggerClearAndShake() {
    // Clear all boxes
    for (final controller in _controllers) {
      controller.clear();
    }
    widget.onChanged?.call('');

    // Refocus box 0
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }

    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      _shakeController.forward(from: 0.0).then((_) {
        if (mounted) {
          widget.onShakeCompleted?.call();
        }
      });
    } else {
      widget.onShakeCompleted?.call();
    }
  }

  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    widget.onChanged?.call('');
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  String get currentCode {
    return _controllers.map((c) => c.text).join();
  }

  void _notifyCode() {
    final code = currentCode;
    widget.onChanged?.call(code);
    if (code.length == 6) {
      widget.onCompleted(code);
    }
  }

  void _onFieldChanged(int index, String value) {
    // Handle paste of full or partial code
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        for (int i = 0; i < 6; i++) {
          if (i < digits.length) {
            _controllers[i].text = digits[i];
          } else {
            _controllers[i].clear();
          }
        }
        final nextFocus = digits.length < 6 ? digits.length : 5;
        _focusNodes[nextFocus].requestFocus();
        _notifyCode();
      }
      return;
    }

    // Single digit input
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _notifyCode();
  }

  KeyEventResult _handleKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notifyCode();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        // Smooth damped harmonic shake
        final double progress = _shakeController.value;
        final double offset =
            progress > 0 ? sin(progress * 4 * pi) * 9.0 * (1.0 - progress) : 0.0;

        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          const double spacing = 6.0;
          final double maxAllowedWidth =
              ((constraints.maxWidth - (spacing * 5)) / 6).clamp(36.0, 44.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: maxAllowedWidth,
                height: 52,
                child: Focus(
                  onKeyEvent: (node, event) => _handleKeyEvent(index, event),
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.structuralNavy,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (val) => _onFieldChanged(index, val),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primaryAccent,
                          width: 1.8,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
