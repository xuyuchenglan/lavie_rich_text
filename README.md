
## Features

* 富文本展示组件，支持各种文字富文本，不支持图片。

* 使用LVRichText，你不需要去手动拆分字符串。一开始你就可以输入完整字符串，然后哪些子字符串需要设置成富文本就单独设置这些子字符串即可。

* LVRichTextConfig类定义了你想格式化的字符串以及配置信息

* 一定要注意，LVRichTextConfig类中的targetString既可以是单个字符串String，也可以是一个字符串数组List<String>

* 该组件内部有一些小bug，就是当一个targetString被另外一个targetString包含的时候，两者的富文本设置就会冲突，不会叠加

## Usage

```dart
          LVRichText(
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
        )
```