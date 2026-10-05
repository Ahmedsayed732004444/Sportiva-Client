import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Six digit boxes backed by one hidden input, so typing, deleting, pasting and the keyboard's SMS / email suggestion all work.
class OtpField extends StatefulWidget {
  const OtpField({super.key, required this.controller, this.length = 6, this.onChanged, this.onCompleted});

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
    _focus.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  void _changed(String value) {
    widget.onChanged?.call(value);
    if (value.length == widget.length) widget.onCompleted?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.controller.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focus.requestFocus,
      // Digits read left to right in both languages.
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < widget.length; i++)
                  _Box(
                    digit: i < code.length ? code[i] : null,
                    isCurrent: _focus.hasFocus && i == code.length.clamp(0, widget.length - 1),
                  ),
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.length),
                  ],
                  enableInteractiveSelection: false,
                  showCursor: false,
                  onChanged: _changed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.isCurrent});

  final String? digit;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final filled = digit != null;
    return Container(
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent || filled ? AppColors.primary : AppColors.gray400,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Text(digit ?? '', style: AppTextStyles.title),
    );
  }
}
