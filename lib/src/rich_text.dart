import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'rich_text_config.dart';

class LVRichText extends StatelessWidget {
  LVRichText(
    this.originalText, {
    Key? key,
    this.configList,
    this.defaultTextStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.strutStyle,
    this.caseSensitive = true,
    this.selectable = false,
  });

  final String originalText;
  final List<LVRichTextConfig>? configList;
  final TextStyle? defaultTextStyle;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool softWrap; // 文本是否在软换行符处换行。如设为false，则代表水平方向有无限空间。
  final TextOverflow overflow;
  final int? maxLines;
  final StrutStyle? strutStyle;
  final bool caseSensitive; // 是否区分大小写，默认为true
  final bool selectable; // 是否可以长按选中

  @override
  Widget build(BuildContext context) {
    return _assembleRichText(context);
  }
}

extension LVRichTextExtensionForPrivateMethods on LVRichText {
  List<String> _specialCharacters() {
    return '\\~[]{}#%^*+=_|<>£€•.,!’()?-\$'.split('');
  }

  List<String> _processSpanTextList(
      List<LVRichTextConfig> configList, String originalText) {
    List<String> spanTextList = [];
    List<List<int>> positions = [];

    configList.asMap().forEach((index, configue) {
      String thisRegExPattern;
      String targetString = configue.targetString;
      String stringBeforeTarget = configue.stringBeforeTarget;
      String stringAfterTarget = configue.stringAfterTarget;

      bool matchLeftWordBoundary = configue.matchLeftWordBoundary;
      bool matchRightWordBoundary = configue.matchRightWordBoundary;
      bool matchWordBoundaries = configue.matchWordBoundaries;
      bool unicode = !configue.hasSpecialCharacters;

      String wordBoundaryStringBeforeTarget1 = "\\b";
      String wordBoundaryStringBeforeTarget2 = "\\s";
      String wordBoundaryStringAfterTarget1 = "\\s";
      String wordBoundaryStringAfterTarget2 = "\\b";

      String leftBoundary = "(?<!\\w)";
      String rightBoundary = "(?!\\w)";

      // matchWordBoundaries 或 matchLeftWordBoundary 中任一为 false 时，进行如下设置
      // leftBoundary = ""
      if (!matchWordBoundaries || !matchLeftWordBoundary) {
        leftBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringAfterTarget1 = "";
      }

      if (!matchWordBoundaries || !matchRightWordBoundary) {
        rightBoundary = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      bool isHan = RegExp(r"[\u4e00-\u9fa5]+",
              caseSensitive: caseSensitive, unicode: unicode)
          .hasMatch(targetString);

      bool isArabic = RegExp(r"[\u0621-\u064A]+",
              caseSensitive: caseSensitive, unicode: unicode)
          .hasMatch(targetString);

      /// 当目标字符串是汉字或者阿拉伯数字的时候，进行如下设置
      /// matchWordBoundaries = false
      /// wordBoundaryStringBeforeTarget = ""
      if (isHan || isArabic) {
        matchWordBoundaries = false;
        leftBoundary = "";
        rightBoundary = "";
        wordBoundaryStringBeforeTarget1 = "";
        wordBoundaryStringBeforeTarget2 = "";
        wordBoundaryStringAfterTarget1 = "";
        wordBoundaryStringAfterTarget2 = "";
      }

      String stringBeforeTargetRegex = "";
      if (stringBeforeTarget != "") {
        stringBeforeTargetRegex =
            "(?<=$wordBoundaryStringBeforeTarget1$stringBeforeTarget$wordBoundaryStringBeforeTarget2)";
      }
      String stringAfterTargetRegex = "";
      if (stringAfterTarget != "") {
        stringAfterTargetRegex =
            "(?=$wordBoundaryStringAfterTarget1$stringAfterTarget$wordBoundaryStringAfterTarget2)";
      }

      thisRegExPattern =
          '($stringBeforeTargetRegex$leftBoundary$targetString$rightBoundary$stringAfterTargetRegex)';
      RegExp exp = new RegExp(thisRegExPattern,
          caseSensitive: caseSensitive, unicode: unicode);
      var allMatches = exp.allMatches(originalText);

      int matchesLength = allMatches.length;
      List<int> matchIndexList = [];
      LVRichTextMatchOption matchOption = configue.matchOption;
      switch (matchOption) {
        case LVRichTextMatchOption.all:
          matchIndexList = List<int>.generate(matchesLength, (i) => i);
          break;
        case LVRichTextMatchOption.first:
          matchIndexList = [0];
          break;
        case LVRichTextMatchOption.last:
          matchIndexList = [matchesLength - 1];
          break;
        case LVRichTextMatchOption.specifiedIndexs:
          if (configue.matchSpecifiedIndexs != null) {
            configue.matchSpecifiedIndexs!.forEach((index) {
              matchIndexList.add(index);
            });
          }
          break;
      }

      // 例如：positions = [[7,11],[26,30],]
      allMatches.toList().asMap().forEach((index, match) {
        if (matchIndexList.indexOf(index) > -1) {
          positions.add([match.start, match.end]);
        }
      });
    });
    // 在某些情况下，排序结果仍然是无序的，因此需要重新排序一维列表
    positions.sort((a, b) => a[0].compareTo(b[0]));

    // 删除无效的位置
    List<List<int>> postionsToRemove = [];
    for (var i = 1; i < positions.length; i++) {
      if (positions[i][0] < positions[i - 1][1]) {
        postionsToRemove.add(positions[i]);
      }
    }
    postionsToRemove.forEach((position) {
      positions.remove(position);
    });

    //将 positions 转化成一维列表
    List<int> splitPositions = [0];
    positions.forEach((position) {
      splitPositions.add(position[0]);
      splitPositions.add(position[1]);
    });
    splitPositions.add(originalText.length);
    splitPositions.sort();

    splitPositions.asMap().forEach((index, splitPosition) {
      if (index != 0) {
        spanTextList.add(
            originalText.substring(splitPositions[index - 1], splitPosition));
      }
    });
    return spanTextList;
  }

  String _replaceSpecialCharacters(str) {
    String tempStr = str;
    //\[]()^*+?.$-{}|!
    _specialCharacters().forEach((chr) {
      tempStr = tempStr.replaceAll(chr, '\\$chr');
    });

    return tempStr;
  }

  Widget _assembleRichText(BuildContext context) {
    List<InlineSpan> textSpanList = _assembleTextSpanList(context);

    if (selectable) {
      return SelectableText.rich(
        TextSpan(
          style: defaultTextStyle ?? DefaultTextStyle.of(context).style,
          children: textSpanList,
        ),
        maxLines: maxLines,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    } else {
      return RichText(
        text: TextSpan(
          style: defaultTextStyle ?? DefaultTextStyle.of(context).style,
          children: textSpanList,
        ),
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
      );
    }
  }

  List<InlineSpan> _assembleTextSpanList(BuildContext context) {
    List<InlineSpan> textSpanList = [];

    _assembleSpanTextList((spanTextList, unicode, finalConfigList) {
      spanTextList.forEach((spanText) {
        var inlineSpan;
        int targetIndex = -1;
        RegExpMatch? match;
        if (configList != null) {
          finalConfigList.asMap().forEach((index, configue) {
            String targetString = configue.targetString;

            //\$, match end
            RegExp targetStringExp = RegExp(
              '^$targetString\$',
              caseSensitive: caseSensitive,
              unicode: unicode,
            );

            RegExpMatch? tempMatch = targetStringExp.firstMatch(spanText);
            if (tempMatch is RegExpMatch) {
              targetIndex = index;
              match = tempMatch;
            }
          });
        }

        // 如果当前字符串是目标字符串
        if (targetIndex > -1) {
          var configue = finalConfigList[targetIndex];

          if (null != configue.matchBuilder && match is RegExpMatch) {
            inlineSpan = configue.matchBuilder!(context, match);
          } else if (configue.superScript && !selectable) {
            // 将目标字符串改为上标
            inlineSpan = WidgetSpan(
              child: Transform.translate(
                offset: const Offset(0, -5),
                child: Text(
                  spanText,
                  textScaleFactor: 0.7,
                  style: configue.style ?? DefaultTextStyle.of(context).style,
                ),
              ),
            );
          } else if (configue.subScript && !selectable) {
            // 将目标字符串改为下标
            inlineSpan = WidgetSpan(
              child: Transform.translate(
                offset: const Offset(0, 1),
                child: Text(
                  spanText,
                  textScaleFactor: 0.7,
                  style: configue.style ?? DefaultTextStyle.of(context).style,
                ),
              ),
            );
          } else {
            inlineSpan = TextSpan(
              text: spanText,
              recognizer: configue.recognizer,
              style: configue.style ?? DefaultTextStyle.of(context).style,
            );
          }
        } else {
          inlineSpan = TextSpan(
            text: spanText,
          );
        }
        textSpanList.add(inlineSpan);
      });
    }, context);

    return textSpanList;
  }

  _assembleSpanTextList(
    void Function(
      List<String> spanTextList,
      bool unicode,
      List<LVRichTextConfig> finalConfigList,
    )
        resultClosure,
    BuildContext context,
  ) {
    List<LVRichTextConfig> tempConfigList = [];
    List<LVRichTextConfig> finalConfigList = [];
    List<String> spanTextList = [];
    bool unicode = true;

    if (configList == null) {
      spanTextList = [originalText];
    } else {
      configList!.asMap().forEach((index, configue) {
        if (configue.targetString is List<String>) {
          // 如果数据是字符串数组
          configue.targetString.asMap().forEach((index, eachTargetString) {
            tempConfigList
                .add(configue.copyWith(targetString: eachTargetString));
          });
        } else {
          tempConfigList.add(configue);
        }
      });

      tempConfigList.asMap().forEach((index, configure) {
        if (configure.hasSpecialCharacters) {
          unicode = false;
          String newTargetString =
              _replaceSpecialCharacters(configure.targetString);
          finalConfigList
              .add(configure.copyWith(targetString: newTargetString));
        } else {
          finalConfigList.add(configure);
        }
      });

      spanTextList = _processSpanTextList(finalConfigList, originalText);
    }

    resultClosure(spanTextList, unicode, finalConfigList);
  }
}
