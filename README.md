# Fumofumo_Windows

> 本仓库原名 `WINobj`，现已重命名为 `Fumofumo_Windows`。
> 程序本身、可执行文件名与配置目录仍叫 **WINobj**（`WINobj.exe`、`%APPDATA%\WINobj`），没有改动。

一个用 Python 编写的 3D 桌面宠物程序。支持加载 `.obj`、`.glb`、`.gltf`、`.usdz`（以及解压后的 `.usdc`/`.usda`）模型，也可以直接丢进 Sketchfab 下载的 `.zip` 包；并具备物理碰撞、重力下落、鼠标拖拽和键盘翻转功能。

## 来源与致谢

本仓库基于 **[CaxyLZ/WINobj](https://github.com/CaxyLZ/WINobj)** 开发，感谢原作者。

| | |
| --- | --- |
| 上游仓库 | https://github.com/CaxyLZ/WINobj |
| 原作者 | CaxyLZ |
| 许可 | MIT（保留原始版权声明，见 [LICENSE](LICENSE)） |

本仓库在上游基础上的改动：

- **多格式支持**：`.glb` / `.gltf` / `.usdz` / `.usdc` / `.usda` / `.obj` / `.zip`（上游只支持 `.obj`）
- **格式嗅探**：按文件头判断真实格式，扩展名被改过（`.circ`、`.bin`、无扩展名）也能读
- **场景扁平化**：自己实现，避免 `Scene.to_mesh()` 在多材质时烘焙出全透明贴图导致模型消失
- **贴图提取**：兼容 trimesh 5.x 的 `baseColorTexture` / `emissiveTexture`（不再依赖已移除的 `.image`）
- **性能**：没装 scipy 时用 numpy 面积加权法线，十万面模型从 ~25 秒降到 ~0.1 秒
- **显存**：顶点数变化时重建 VBO/VAO（moderngl 的 buffer 不会自动扩容）

## 功能特性

- 自定义模型：支持 `.obj`（含 `.mtl` 贴图）、`.glb`、`.gltf`、`.usdz`、解压后的 `.usdc`/`.usda`，以及装着这些文件的 `.zip` 压缩包；贴图自动读取，没有时就提示你手动选图。
- 物理引擎：基于模型网格的边界碰撞，包含重力、弹性、摩擦力。
- 键盘控制：按住鼠标时，可用键盘精准控制 3D 模型的旋转。
- 热重载：在配置面板修改参数或更换模型，保存后即刻生效，无需重启（换更大的模型也行）。
- 自定义音效：可分别设置“按下”和“松开”时的音效。
- 数据集中：所有配置和数据统一保存在系统的 `%APPDATA%\WINobj` 文件夹。

## 支持的模型格式

| 格式 | 说明 | 额外依赖 |
| --- | --- | --- |
| `.obj` | Wavefront OBJ，建议和 `.mtl`、贴图放在一起 | 无 |
| `.glb` | glTF 二进制单文件，贴图内嵌，**最推荐** | 无 |
| `.gltf` | 需要同目录的 `.bin` 与贴图文件；建议直接选装它们的 `.zip` | 无 |
| `.usdz` | Pixar USDZ（Apple AR 常用格式） | `pip install usd-core` |
| `.usdc` / `.usda` / `.usd` | USDZ 解压出来的散文件，贴图放在它旁边（子目录也行） | `pip install usd-core` |
| `.zip` | 自动解包并挑出里面的模型文件 | 无 |

**扩展名不对也能读。** 程序是看文件内容（文件头）认格式的，不是看扩展名——下载工具把 `model.glb` 改成 `.circ`、`.bin` 或者干脆没扩展名，照样能打开。在文件对话框里选「所有文件（扩展名被改过也能读）」即可。压缩包里文件被改过名也能认出来。

**Sketchfab 怎么用**：在模型页面点 *Download 3D Model*，下载 **GLB**（单文件、贴图内嵌，最省事）、**glTF**（建议下载后直接选那个 `.zip`）或 **USDZ** 都行——程序现在都能直接打开，不需要额外转换工具。下载的是“原始格式”压缩包（比如 obj+贴图）时，直接选 `.zip` 也能读。USDZ 你也可以解压成 `scene.usdc` + 贴图目录再丢进来，效果完全一样。

> USD 系（`.usdz` / `.usdc` / `.usda`）需要一个可选的解析库：`pip install usd-core`（Pixar 官方 OpenUSD，Windows 上约 13 MB）。没装的时候程序会提示你怎么装，其它格式照常使用。
> 打包 exe 时需要一起带上它，PyInstaller 用 `--collect-all pxr`，否则 exe 里读不了 USD 模型。

## 操作说明

- 鼠标左键按住：拖拽移动模型。
- 按住模型时按键：W/S（横向旋转）、A/D（纵向旋转）、Q/E（平面旋转）。
- 鼠标左键松开：根据鼠标挥动速度和键盘旋转速度甩出模型。
- ESC 键：直接退出程序。
- 系统托盘：右键点击图标可打开 **控制台**、配置面板，或退出。

## 控制台

托盘右键 → **控制台**，会打开一个深色等宽日志窗口，实时显示运行情况：

```
[23:44:03] INFO ========================================================
[23:44:03] INFO WINobj 启动  Python 3.13.5  2026-11-08 23:44:03
[23:44:03] INFO trimesh 5.2.0  数据目录 C:\Users\...\AppData\Roaming\WINobj
[23:44:03] INFO scipy 未安装（使用内置 numpy 法线实现）
[23:44:04] INFO 读取模型：project-reimu-fumo-3d-scan.glb  →  识别为 .glb（4.4 MB）
[23:44:04] INFO 模型读取完成：11736 顶点 / 9999 面，贴图 1024×1024，耗时 0.12s
[23:44:04] INFO 模型不是封闭网格，用包围盒估算 Iz=3861
[23:44:04] INFO 屏幕 800×800，网格 29997 个顶点（9999 个三角面）
[23:44:04] INFO OpenGL 3.3.0 NVIDIA 616.64 / NVIDIA GeForce RTX 5060 Laptop GPU
```

能看到的包括：

- **模型加载全过程**：识别出的格式、文件大小、顶点/面数、贴图尺寸、耗时、缓存命中
- **几何与渲染**：屏幕尺寸、顶点数、OpenGL 版本与显卡型号、贴图上传结果
- **物理**：转动惯量是怎么算的（封闭网格用真实值，否则用包围盒估算）
- **报错与警告**：模型加载失败、贴图上传失败，以及 Python 的 `print` / `traceback` / 第三方库的警告（打包成 exe 后这些原本完全看不到）

窗口里有「复制全部」「清空」「关闭」三个按钮，方便把日志贴出来反馈问题。

日志同时**追加写入** `%APPDATA%\WINobj\console.log`，重启后不会丢；程序内的内存缓冲保留最近 2000 行。

## 下载与使用

1. 在仓库右侧的 Releases 页面下载最新的 `WINobj.exe`。
2. 双击运行，首次启动会提示选择模型文件。
3. 程序无需安装 Python 环境。

### 从源码运行

```bash
pip install PySide6 moderngl trimesh pillow numpy
pip install usd-core   # 可选，只为了打开 .usdz / .usdc
python WINobj.py
```

（`scipy` 可选，装上会让 trimesh 用更快的法线算法；不装也很快，程序内置了 numpy 版本的快速顶点法线。）

## 图标

应用图标是仓库根目录的 `Fumofumo_icon.png`（1254×1254，四角透明），托盘、窗口和 exe 都用它。

- 源码运行时从脚本同级目录查找；打包成 exe 后从 `sys._MEIPASS` 找，所以 PyInstaller 要把它一起带上：

  ```
  pyinstaller --onefile --windowed --icon=Fumofumo_icon.png --add-data "Fumofumo_icon.png;." WINobj.py
  ```

- 文件缺失时会退回原来手绘的圆形图标，托盘不会变成空白。

## 相关仓库

| 仓库 | 说明 |
| --- | --- |
| **[Fumofumo_Windows](https://github.com/FunnyArchbishop/Fumofumo_Windows)** | ← 你在这里：Windows 桌面版（Python + Qt + moderngl） |
| [Fumofumo_Mobile](https://github.com/FunnyArchbishop/Fumofumo_Mobile) | 同一只桌宠的 Android 版（Kotlin + OpenGL ES 3.0，悬浮在其他应用之上） |
| [Fumofumo_Models](https://github.com/FunnyArchbishop/Fumofumo_Models) | 20 个 fumo 3D 扫描模型（CC BY 4.0，含完整署名），两个版本都能直接导入 |
| [CaxyLZ/WINobj](https://github.com/CaxyLZ/WINobj) | 上游原始项目（本仓库的起点） |

## 开源协议

MIT License。本仓库保留上游 CaxyLZ 的原始版权声明，并补充本仓库修改部分的版权声明，详见 [LICENSE](LICENSE)。
