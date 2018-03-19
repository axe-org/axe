# Axe

Axe is all the reinforcement this army needs.

## 进度

#### 初步完成

* Router 
* Event
* Data 
* TarbarController
* JavascriptSupport
* Html
* React
* [axe-react](https://github.com/CodingForMoney/axe-react)
* [axe-js](https://github.com/CodingForMoney/axe-js)
* [offline-pack-server](https://github.com/CodingForMoney/offline-pack-server)
* [OfflinePackage](https://github.com/CodingForMoney/offline-pack-ios)

#### 尚未完成

* OfflineHtml
* OfflineReact
* DynamicModular 动态路由
* APP 开发平台
* 完整 Demo
* 代码检视 、 异常处理 、 异常日志。

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