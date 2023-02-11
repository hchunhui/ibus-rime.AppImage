# ibus-rime.AppImage

本项目提供 AppImage 格式的中州韵输入法（ibus-rime）的打包方案。

## 特性
  - 打包最新版本的中州韵输入法，支持 Lua 插件和语言模型插件；
  - 一键安装，免编译代码，免使用管理员权限，免安装依赖；
  - 支持各种 Linux 发行版。

## 系统要求
  - fuse2/3
  - glibc >= 2.23
  - ibus 1.5

  2016 年之后的发行版在默认情况下应该能自动满足上述条件。

## 获取
  免责声明：下述二进制文件是使用 Travis CI，引用公开获取的源代码和二进制程序自动生成的，仅供参考。
  请了解运行未知来源二进制文件的风险。使用下述文件造成的后果请您自行承担，制作者不承担任何责任。

  [GitHub Release](https://github.com/hchunhui/ibus-rime.AppImage/releases)

  您也可以从( https://github.com/hchunhui/ibus-rime.AppImage )获取编译脚本，从源码编译生成 AppImage。

## 安装
  1. 获取 `ibus-rime.AppImage`，加上可执行权限，双击执行；
  2. 看见安装成功提示后，重启 ibus；
  3. 在 ibus 的设置界面中添加 rime 输入法。

  注意：
  - 安装后不要删除和移动 `ibus-rime.AppImage`。
  - 部分发行版（如 Fedora）在安装时需要输入管理员密码。

## 更新
  1. 获取并执行新的 `ibus-rime.AppImage`；
  2. 看见安装成功提示后，重启 ibus。

## 卸载
  1. 在 ibus 设置界面中删除 rime 输入法；
  2. 删除 `ibus-rime.AppImage`；
  3. 删除 `$HOME/.config/ibus/rime/appimage` 和 `$HOME/.config/ibus/rime/build`。

## 内置工具
  除 ibus-rime 本身外，AppImage 文件中还打包了一些相关工具，如：
  - 东风破配置管理工具：`rime-install`
  - 开放中文转换：`opencc` `opencc_dict` `opencc_phrase_extract`
  - librime 工具：`rime_deployer` `rime_dict_manager` `rime_patch`

  可以用两种方法来运行他们：
  - 直接运行：
    ```
    ./ibus-rime-x86_64.AppImage command [options...]
    ```
    如：
    ```
    ./ibus-rime-x86_64.AppImage rime-install wubi   # 安装五笔方案
    ```

  - 符号链接：
    ```
    ln -s ibus-rime-x86_64.AppImage command
    ./command [options...]
    ```
    如：
    ```
    ln -s ibus-rime-x86_64.AppImage rime-install
    ./rime-install wubi
    ```

  其他可用工具如下查看：
  ```
  ./ibus-rime-x86_64.AppImage help
  ```

## 插件
  预编译 `librime-charcode`、`librime-lua` 和 `librime-octagram` 插件，默认均为加载。

## 相关项目
  - [ibus-rime](https://github.com/rime/ibus-rime)
  - [plum](https://github.com/rime/plum)
  - [librime](https://github.com/rime/librime)
  - [librime-charcode](https://github.com/rime/librime-charcode)
  - [librime-octagram](https://github.com/lotem/librime-octagram)
  - [librime-lua](https://github.com/hchunhui/librime-lua)
  - [AppImageKit](https://github.com/AppImage/AppImageKit)
