# Axe

Axe is all the reinforcement this army needs.

要用一句话，最简洁明了的表示自己的思路 ：

面向大前端开发的iOS业务组件化框架， 即这个框架无视开发语言，通过一套标准的业务组件通信方式，来组织与管理 iOS组件、android组件、h5组件和 react-native组件。

## 主要内容

通过三大基础组件，来规定所有业务组件之间的交互方式， 三大基础组件即 ： 

* Router : 路由模块，根据URL获取界面或者进行跳转
* Event : 事件通知， 是业务组件之间的主要交互方式
* Data :  公共数据，以及业务组件之前传递数据的媒介

三大基础组件，更重要的意义是能够跨越不同语言 ， 即对于 APP中的`h5`或者`react-native`等内容， 也可以基于这三大组件，来实现业务组件之间的交互与合作。 这样就是跨语言的业务开发模式的统一成为了可能 ， 更高程度地管理和控制APP上所有业务组件的开发。

## 进度

#### 初步完成

* Router
* Event 
* Data 
* TabbarController ： 提供基础功能的 TabbarController 
* JavascriptSupport : 三大基础组件为支持js调用，所做的简单封装
* Html ：提供webview支持
* React ： 提供react-native支持
* [axe-react](https://github.com/CodingForMoney/axe-react) ： js端的接口封装
* [axe-js](https://github.com/CodingForMoney/axe-js) ：  js端的接口封装
* [offline-pack-server](https://github.com/CodingForMoney/offline-pack-server) ： 离线包管理平台
* [OfflinePackage](https://github.com/CodingForMoney/offline-pack-ios) ： 离线包基础
* OfflineHtml ： h5离线包支持
* OfflineReact : react-native 离线包支持
* DynamicRouter ： 动态路由，实现完全脱离实现细节的 路由控制。
* [dynamic-router-server](https://github.com/axe-org/dynamic-router-server) : 动态路由后台

#### 尚未完成

* MockTest ： 模拟测试，可以简单定义一些接口、事件和数据，以实现单独地测试，以及在依赖工程同步开发时的单独测试。
* APP 开发管理平台 ： 为优化业务模块开发流程，开发的简单的管理平台， 提供依赖图、发布构建、开发时间线、接口文档等等有用的功能
* 完整 Demo
* 代码检视 、 异常处理 、 异常日志。

## Axe 想要解决以下问题

* 统一的业务组件之间的交互方式
* 一个可用的离线包系统
* rn和js的支持
* 模块动态切换
* 模块单独测试
* 一个可用的开发管理平台
* 一个可用的开发框架、模式与系统

## 思路阐述

> 这个地方， 对于平台化的定义，还是要继续斟酌。

`axe`是什么， 是一个 iOS的`平台化框架` 。 一个业务组件化的基础开发平台。

`平台化` : 将APP底层和公共的内容整合成一个完整而高效的平台， 使业务开发者能够更高效地在这个平台上开发功能， 由于是一个平台，功能可以随意的新增、删除与切换， 且这个平台是对所有在APP上的内容。 即 APP、h5、rn等内容，都能使用同样的一套业务交互的逻辑来进行开发与管理。

平台化的主要思想是 `基础平台化，业务组件化`

具体实现，将一个APP的公共业务和基础组件整合起来做为一个底层的平台，向业务开发者提供的一套高效严谨的业务组件开发方案。 即 `axe`使一个APP形成一个平台， 而APP的业务在平台上开发， 使代码分离，使跨模块、跨团队的合作开发成为可能。

`axe`的目标是 ：

* 业务组件化， 实现真正的代码分离，支持单独编译、单独测试
* 形成一套跨平台的 `业务模块开发` 模式, 在这个平台上，开发 `APP`，与开发`H5`，开发`React-Native`， 都是一样的模式，一样的沟通方式。 扩展开发者的视野与能力。
* 搭建一个APP模块开发管理平台， 为开发者提供便捷好用的功能，降低沟通成本，提高开发效率。

### License

Axe is licensed under [The MIT License](LICENSE).