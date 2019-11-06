# 相机

[原文连接](https://learn.unity.com/tutorial/optimizing-graphics-in-unity#)

作者翻译水平有限，如有错误，请指出，谢谢。

相机是核心组件，每一个unity应用都严重的依赖相机。

这就以为着相机有很多选项。

如果管理的不合适，可以导致劣质的表现，比如clear，culling，和skybox选项。

## Clear

在基于tile-based渲染的移动设备上，clear指令的非常重要。在移动设备上Unity处理好了各种细节问题，所以你只要把相机的clear flag设置一下，避免使用dont clear就行了。 clear指令底层的行为依赖平台和显卡驱动程序，但是基于clear flag的选择，可以显著的影响性能。因为Unity要不就是清理上一次的内容，设置igore标签，要不就是从缓冲读取上一次内容。但是，**不要**在流式GPU上会执行不必要的clear指令，也就是说，这种行为通常在桌面或着终端设备中经常出现。

## Clear flags

在移动设备上要避免使用默认的天空盒，（大概名称是Default-Skybox），这个计算是昂贵的并且当创建新场景的时候默认开启。为了完全关闭天空盒，可以设置相机的clearFlags为SolidColor。然后打开LightingSetings窗口，删除天空盒材质球，并且把环境光设置成颜色。

## Discard and Restore buffer
当使用在Adreno GPUs 上使用OpenGLES  API时，Unity只是丢弃帧缓冲来避免帧缓冲恢复。在PVR和Mail GPU上，unity 却使用清除指令来避免帧缓冲恢复。

在移动设备上在显卡内存移进或着移出是非常资源密集型的，因为这种设备使用共享内存架构，意味着 GPU和GPU共享一块物理内存。在像Adreno,PowerVR或者苹果芯片那种Tile-based的GPU上，在逻辑缓冲上加载和存储数据要花费重要的系统时间和电量。对于每一个tile从共享内存转移内容到一部分的帧缓冲上（或者反过来）来说是资源密集型活动的主要来源。

## Tile-based Rendering
tile-based rendering 把视口分成特定的32 * 32 px 大小的格子，并把这些格子存储在离GPU更近的快速内存区域，在这个小内存和真的帧缓冲之间的拷贝操作要花费一些时间，因为内存拷贝比算术运算操作要慢一些。

这些缓慢的内存操作是主要原因，在tile-based GPU上，你应该避免在每一个新的帧上，加载前一个帧缓冲，并调用 glClear（OpenGLES）。通过发出glClear指令，你在告诉硬件你不想使用上一次的缓存内容，所以它没有必要从帧缓冲中拷贝颜色缓冲，深度缓冲和模板缓冲到小的格子内存中。
