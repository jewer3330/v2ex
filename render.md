# unity渲染优化
[原文连接](https://learn.unity.com/tutorial/optimizing-graphics-in-unity#)

作者翻译水平有限，如有错误，请指出，谢谢。

渲染在Unity内部是非常复杂的。在读这篇文章之前，如果想知道它是怎么工作的基础概念，请看点这里的[unity渲染管线的文章](https://docs.unity3d.comManualSL-RenderPipeline.html_ga=2.197607279.1598871684.1572854234-485071112.1572854234)

这份引导提供了一个更好的关于渲染相关的概念理解，并且提供了关于如何减轻GPU渲染工作量的最佳实践。

* 光照场景
* 相机
* 纹理
* 多线程渲染和Graphics Jobs
* 帧缓冲
* 着色器

为了更加高效的优化您的图形渲染，您需要清楚你硬件的极限和如何分析GPU。分析能帮助您检查和确认您做的优化是高效的。

# GPU benchmarks

当分析时，使用一个benchmark更加有用，当你的设备在最佳的运行状态时，一个benchmark告诉你从特定的GPU应该料到怎样的分析结果。

打开[网站](https://gfxbench.com/result.jsp)得倒一些benchmark

