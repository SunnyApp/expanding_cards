import 'package:expanding_cards/expanding_card.dart';
import 'package:expanding_cards/hero_hints.dart';
import 'package:flutter/cupertino.dart';

typedef TextBuilder = Text Function(TextStyle? style);

class HeroText extends StatelessWidget
    with HeroHintsProviderMixin
    implements HeroHints {
  final Text noStyle;
  final Text startText;
  final Text endText;
  final TextStyle startStyle;
  final TextStyle endStyle;

  HeroText(TextBuilder builder,
      {Key? key, required this.startStyle, required this.endStyle})
      : startText = builder(startStyle),
        endText = builder(endStyle),
        noStyle = builder(null),
        super(key: key);

  @override
  Widget buildCard(BuildContext context, HeroAnimation heroInfo) {
    final animation = heroInfo.animation;
    final state = heroInfo.state;
    if (animation == null) {
      return state == ExpandingCardState.collapsed ? startText : endText;
    } else {
      final tween = TextStyleTween(begin: startStyle, end: endStyle);

      return DefaultTextStyleTransition(
        style: animation.drive(tween),
        child: noStyle,
      );
    }
  }
}
