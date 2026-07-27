//
//  form.swift
//  ios-swift
//
//  Created by 隔壁老王 on 2026/7/27.
//

import SwiftUI

//Form    📑    表单容器，自动适配平台样式，对控件进行分组和布局。    .formStyle(), Section
//TextField    ✏️    单行文本输入框，用于输入用户名、搜索词等。    text:, placeholder:, .textFieldStyle()
//SecureField    🔒    安全文本输入框，用于输入密码等敏感信息，内容隐藏。    同 TextField，但内容掩码显示。
//TextEditor    📄    多行文本编辑区域，用于输入长文本、备注等。    text:, .frame(minHeight:)
//Toggle    🔘    开关控件，用于布尔值选择（开/关）。    isOn:, .toggleStyle()
//Picker    📌    选择器，用于从一组选项中选择一个值。    selection:, .pickerStyle()
//Slider    🎚️    滑块，用于在一个范围内选择连续数值。    value:in:, step:
//Stepper    🔢    步进器，用于以固定步长增加或减少数值。    value:in:step:, onIncrement/decrement:

//关键知识点：
//@State：用于声明视图内部的可变状态，当状态改变时，视图会自动更新。
//$（美元符号）：前缀用于创建与状态变量的双向绑定（Binding），将控件与数据源连接起来。
//Form 和 Section：用于逻辑分组，提升表单的可读性和可访问性。
//每个控件都有丰富的修饰符（如 .pickerStyle()）用于自定义外观和行为。


struct RegistrationFormView: View {
    /// 用枚举描述“当前哪个输入控件拿着键盘焦点”。
    ///
    /// 这和 UIKit 里“当前 first responder 是谁”是一个概念：
    /// - `.username` 表示用户名输入框正在编辑
    /// - `.password` 表示密码输入框正在编辑
    /// - `.bio` 表示多行简介输入框正在编辑
    /// - `nil` 表示没有任何输入控件拿着焦点，键盘就会收起
    private enum Field: Hashable {
        case username
        case password
        case bio
    }

    // 1. 使用 @State 管理表单数据
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var bio: String = "请输入个人简介..."
    @State private var receiveNotifications: Bool = true
    @State private var selectedColorIndex: Int = 0
    @State private var brightness: Double = 0.5
    @State private var age: Int = 18

    /// `@FocusState` 专门用来管理输入焦点。
    ///
    /// 你可以把它类比成“SwiftUI 帮你声明式管理 first responder”：
    /// - 给输入框绑定 `.focused(...)`
    /// - 然后把 `focusedField = nil`
    /// - 键盘就会自动回收
    @FocusState private var focusedField: Field?

    let colorOptions = ["红色", "蓝色", "绿色", "黄色"]

    var body: some View {
        // 2. Form 作为容器
        Form {
            Section(header: Text("账户信息").font(.headline)) {
                // 3. TextField 输入用户名
                TextField("请输入用户名", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .focused($focusedField, equals: .username)

                // 4. SecureField 输入密码
                SecureField("请输入密码", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($focusedField, equals: .password)

                // 5. Toggle 开关
                Toggle("接收通知", isOn: $receiveNotifications)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }

            Section(header: Text("个人资料").font(.headline)) {
                // 6. Picker 选择颜色
                Picker("最喜欢的颜色", selection: $selectedColorIndex) {
                    ForEach(0 ..< colorOptions.count, id: \.self) { index in
                        Text(colorOptions[index]).tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                // 7. Slider 调整亮度
                HStack {
                    Text("界面亮度")
                    Slider(value: $brightness, in: 0...1, step: 0.1)
                    Text("\(brightness, specifier: "%.1f")")
                }

                // 8. Stepper 选择年龄
                Stepper(value: $age, in: 0...120, step: 1) {
                    Text("年龄: \(age)")
                }

                // 9. TextEditor 输入简介
                Text("个人简介")
                    .font(.headline)
                TextEditor(text: $bio)
                    .focused($focusedField, equals: .bio)
                    .frame(minHeight: 100)
                    .border(Color.gray.opacity(0.3), width: 1)
                    .cornerRadius(5)
            }

            Section {
                Button(action: submitForm) {
                    HStack {
                        Image(systemName: "paperplane.fill")
                        Text("提交注册")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(username.isEmpty || password.isEmpty) // 简单验证
            }
        }
        .navigationTitle("用户注册")
        .padding()
        /// 允许在滚动表单时顺手把键盘收起来。
        /// `Form` 本质上是滚动容器，这个 modifier 很适合表单页。
        .scrollDismissesKeyboard(.interactively)
        /// 点屏幕空白处时，把焦点清空，键盘就会回收。
        ///
        /// 这就是 SwiftUI 里最常见的“点击空白收键盘”写法之一：
        /// - UIKit 思路：让当前 first responder resign
        /// - SwiftUI 思路：把 `@FocusState` 置成 `nil`
        .simultaneousGesture(
            TapGesture().onEnded {
                focusedField = nil
            }
        )
    }

    func submitForm() {
        print("提交数据：")
        print("用户名: \(username)")
        print("密码长度: \(password.count)")
        print("颜色: \(colorOptions[selectedColorIndex])")
        print("年龄: \(age)")
        // 实际开发中，这里会发送网络请求
    }
}
