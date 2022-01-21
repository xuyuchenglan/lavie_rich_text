import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum LVRichTextMatchOption {
  all, // 匹配所有
  first, // 只匹配第一个
  last, // 只匹配最后一个
  specifiedIndexs, // 匹配指定的下标。该情况下需要配置matchSpecifiedIndexs
}

typedef LVRichTextMatchBuilder = InlineSpan Function(
    BuildContext context, RegExpMatch? match);

class LVRichTextConfig {
  final dynamic targetString; // 待格式化的数据，可以是单个字符串String，也可以是一个字符串数组List<String>
  final String stringBeforeTarget; // 待格式数据前面的字符串
  final String stringAfterTarget; // 待格式数据后面的字符串

  /*
  * 如果以下三者均设为true，则优先级为matchLeftWordBoundary > matchRightWordBoundary > matchWordBoundaries
  * 当matchWordBoundaries设置为true的时候，matchLeftWordBoundary将被设置为false
  * 当matchWordBoundaries或者matchLeftWordBoundary设置为true的时候，matchRightWordBoundary将被设置为false
  * */
  final bool matchWordBoundaries; // 是否在正则表达式中应用单词边界，默认为true
  final bool matchLeftWordBoundary; // 是否在正则中仅应用左字边界，默认为false
  final bool matchRightWordBoundary; // 是否在正则中仅应用右字边界，默认为false

  /*
  * 优先级：superScript > subScript
  * */
  final bool superScript; // 将targetString转换为上标
  final bool subScript; // 将targetString转换为下标

  final TextStyle? style;
  final GestureRecognizer? recognizer;

  final bool
      hasSpecialCharacters; // 如果targetString里面包含如下特殊字符——\~[]{}#%^*+=_|<>£€•.,!’()?-$，则需要将该属性设置为true

  final LVRichTextMatchOption matchOption; // 默认匹配全部
  final List<int>? matchSpecifiedIndexs; // matchOption为specifiedIndexs时，必须配置该值

  final LVRichTextMatchBuilder? matchBuilder;

  LVRichTextConfig({
    Key? key,
    required this.targetString,
    this.stringBeforeTarget = '',
    this.stringAfterTarget = '',
    this.matchWordBoundaries = true,
    this.matchLeftWordBoundary = true,
    this.matchRightWordBoundary = true,
    this.superScript = false,
    this.subScript = false,
    this.style,
    this.recognizer,
    this.hasSpecialCharacters = false,
    this.matchOption = LVRichTextMatchOption.all,
    this.matchSpecifiedIndexs,
    this.matchBuilder,
  });

  LVRichTextConfig copyWith({
    targetString,
    stringBeforeTarget,
    stringAfterTarget,
    matchWordBoundaries,
    matchLeftWordBoundary,
    matchRightWordBoundary,
    superScript,
    subScript,
    style,
    urlType,
    recognizer,
    hasSpecialCharacters,
    matchOption,
    matchSpecifiedIndexs,
  }) {
    return LVRichTextConfig(
      targetString: targetString ?? this.targetString,
      stringBeforeTarget: stringBeforeTarget ?? this.stringBeforeTarget,
      stringAfterTarget: stringAfterTarget ?? this.stringAfterTarget,
      matchWordBoundaries: matchWordBoundaries ?? this.matchWordBoundaries,
      matchLeftWordBoundary:
          matchLeftWordBoundary ?? this.matchLeftWordBoundary,
      matchRightWordBoundary:
          matchRightWordBoundary ?? this.matchRightWordBoundary,
      superScript: superScript ?? this.superScript,
      subScript: subScript ?? this.subScript,
      style: style ?? this.style,
      recognizer: recognizer ?? this.recognizer,
      hasSpecialCharacters: hasSpecialCharacters ?? this.hasSpecialCharacters,
      matchOption: matchOption ?? this.matchOption,
      matchSpecifiedIndexs: matchSpecifiedIndexs ?? this.matchSpecifiedIndexs,
    );
  }
}
