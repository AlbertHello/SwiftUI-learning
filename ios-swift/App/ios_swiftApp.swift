import SwiftUI

/// SwiftUI 工程的应用入口。
///
/// 如果你是 OC 背景，可以把它粗略理解成：
/// - 以前 UIKit + AppDelegate/SceneDelegate 里负责创建根控制器
/// - 现在改成用 `@main` + `Scene` 来描述应用启动后的第一个界面
///
/// 这里最容易误会的点有两个：
/// 1. `struct IOSSwiftApp: App`
///    - `IOSSwiftApp` 是一个结构体类型
///    - `App` 不是父类，而是一个协议 (protocol)
///    - 这里的 `:` 表示“遵守协议”，不是“继承类”
///    - 如果类比到 OC，可以先理解成 `@interface Xxx : NSObject <SomeProtocol>`
///      里的 `<SomeProtocol>` 那部分语义
/// 2. `var body: some Scene`
///    - `body` 是一个计算属性，不是方法
///    - 返回值写成 `some Scene`，意思是“返回某个具体的 Scene 类型”
///    - 具体类型由编译器推断，这里实际返回的是 `WindowGroup`
///    - 这样写的好处是：既保留强类型，又不用把复杂的真实类型名字写出来
@main
/// 这里的 `:` 要读成“遵守协议”。
///
/// `struct IOSSwiftApp: App` 不是说 `IOSSwiftApp` 继承了某个父类，
/// 而是说它这个类型遵守了 `App` 协议。
///
/// 同一个 `:` 在 Swift 里会根据位置有不同含义：
/// - 放在 `struct/class/enum` 名字后面：表示继承或遵守协议
/// - 放在 `var body: some Scene` 这种属性名后面：表示“这个属性的类型是什么”
struct IOSSwiftApp: App {
    /// App 协议要求提供一个 `body`。
    ///
    /// 你可以把它理解成：
    /// - UIKit 时代：告诉系统“启动后把哪个控制器塞进 window 里”
    /// - SwiftUI 时代：告诉系统“启动后创建哪个 Scene，Scene 里放什么 View”
    /// 这里的 `:` 就不是“遵守协议”了，而是“类型标注”。
    ///
    /// `var body: some Scene` 的意思是：
    /// - 定义一个叫 `body` 的属性
    /// - 这个属性的类型是 `some Scene`
    ///
    /// 因为 `body` 是计算属性，所以访问它时会计算出一个值并返回。
    /// 因此你也可以把它理解成：
    /// “这个属性会返回某个具体的 Scene 类型，只是具体类型名被隐藏了”
    var body: some Scene {
        /// `WindowGroup` 可以理解成“应用的一个窗口场景”。
        ///
        /// 后面的大括号是一个闭包，用来描述这个窗口里显示什么根视图。
        /// 现在这里放的是 `DemoHomeView()`，所以应用启动后会先看到 demo 列表首页。
        ///
        /// 粗略类比 UIKit：
        /// `window.rootViewController = UIHostingController(rootView: DemoHomeView())`
        ///
        /// 这段的完整写法可以写成：
        /// `WindowGroup(content: { DemoHomeView() })`
        ///
        /// 现在这种写法只是 Swift 的“尾随闭包”语法糖：
        /// - `content:` 参数省略到后面的大括号里
        /// - 大括号里的内容就是“返回根 View 的闭包”
        WindowGroup {
            DemoHomeView()
        }
    }
}
