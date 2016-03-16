# TFM3u8DownLoad


---
### Some

1. [流媒体开发之–HLS–M3U8解析](http://mobile1.riaos.com/?p=2026287) - 关于m3u8文件的一些分析认识
2. [m3u8文件信息总结](http://blog.csdn.net/blueboyhi/article/details/40107683) - 全面的m3u8的介绍
3. [wiki上m3u8的解释](https://zh.wikipedia.org/wiki/M3U) - 需要科学上网才可打开
4. [linux下搭建生成HLS所需的.ts和.m3u8文件](http://www.cnblogs.com/mystory/archive/2013/04/07/3006200.html) - 从m3u8文件的生成来了解其机制
5. [Apple的介绍](https://developer.apple.com/streaming/) - 苹果的官网对已这种HTTP Live Streaming 的介绍 //key word `apple m3u8`
  感谢[XB2](https://github.com/luoxubin/XB2)-里面提供的m3u8文件的下载私聊

 
---

### TOTO

1. 项目的是OC版本的，基于Swift版本在开发计划中，等待更新
2. 下载引擎使用的是早已经不再更新的ASI，急需要基于新的请求框架进行重新的改写
3. 计算下载进度使用的是：已下载的片段数 / 总的片段数 ； 不知有没有更好的意见。

---

### warning

经过测试发现m3u8地址会失效，如果下载此Demo后，下载进度没有变化，则应该是地址已经失效了，请更换为有效的m3u8地址进行测试

----


### 2015年12月16日更新 逻辑存在一些问题，暂停更新，年后有时间接着更新