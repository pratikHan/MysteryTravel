import 'package:flutter/material.dart';

import '../theme/themes.dart';
import '../theme/tokens.dart';

/// Text that only speaks in tokens: `AppText('Hi', AppType.body)`.
class AppText extends StatelessWidget {
  const AppText(
    this.text,
    this.type, {
    super.key,
    this.color,
    this.align,
    this.maxLines,
    this.overflow,
  });

  final String text;
  final TypeStyle type;
  final Color? color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: type.style(color ?? context.colors.ink),
    );
  }
}
