import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lavie_rich_text/src/rich_text.dart';
import 'package:lavie_rich_text/src/rich_text_config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Rich Text Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: LVRichText(
          "啦啦啦蓝色加粗italic上标下标蓝色红色1红色12红色123红色红色green哈啊哈Green点击这里响应事件电话+86 18868876045网址http://www.baidu.com",
          // 设置文本的默认展示样式
          defaultTextStyle: const TextStyle(
            color: Colors.orange,
          ),
          // 不区分大小写
          caseSensitive: false,
          // 是否可以长按选中，true可以
          selectable: false,
          configList: [
            LVRichTextConfig(
              targetString: "蓝色",
              // 设置目标字符串的前后字符串，以限制匹配到指定的字符串
              stringBeforeTarget: "啦啦啦",
              stringAfterTarget: "加粗",
              style: const TextStyle(
                color: Colors.blue,
              ),
            ),
            LVRichTextConfig(
              targetString: "加粗",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            LVRichTextConfig(
              targetString: "italic",
              style: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
            LVRichTextConfig(
              // 设置上下标与selectable: true冲突
              targetString: "上标",
              superScript: true,
            ),
            LVRichTextConfig(
              targetString: "下标",
              subScript: true,
            ),
            LVRichTextConfig(
              targetString: "红色",
              // 只修改匹配到的指定位置的字符串
              matchOption: LVRichTextMatchOption.specifiedIndexs,
              matchSpecifiedIndexs: [3, 4],
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
            LVRichTextConfig(
              targetString: "green",
              style: const TextStyle(
                color: Colors.green,
              ),
            ),
            LVRichTextConfig(
              targetString: "点击这里响应事件",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print("点击邮箱");
                },
            ),
            // LVRichTextConfig(
            //   // 根据正则表达式去匹配字符串
            //   // 注意，直接根据正则表达式去匹配字符串的话，很容易与其他的冲突，所以尽可能避免正则与其他匹配方式一起使用
            //   targetString: "[0-9]*",
            //   style: const TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 30,
            //   ),
            // ),
            LVRichTextConfig(
                targetString: "+86 18868876045",
                // 如果targetString中包含特殊字符，则需要设置hasSpecialCharacters: true
                hasSpecialCharacters: true,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                )),
          ],
        ),
      ),
    );
  }
}
