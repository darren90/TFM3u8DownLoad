//
//  TFM3u8Downloader.m
//  TFM3u8DownLoad
//
//  Created by Fengtf on 16/3/15.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import "TFM3u8Downloader.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "WdCleanCaches.h"
#import "TFDownLoadTools.h"
#import "RegexKitLite.h"

@interface TFM3u8Downloader ()

@property (nonatomic,strong) ASIHTTPRequest *request;

@property(nonatomic,copy)NSString *basepath;

@property(nonatomic,copy)NSString *TargetSubPath;

@property(nonatomic,strong)NSMutableArray *targetPathArray;

@property(nonatomic,strong)NSMutableArray *downinglist;//正在下载的文件列表(储存:ASIHttpRequest)
@property(nonatomic,strong)NSMutableArray *finishedlist;//已下载完成的文件列表（存储:FileModel）

//片段新加代码

/** m3u8的总片段数 */
@property (nonatomic,strong)NSMutableArray * m3u8PartList;//已下载完成的文件列表（存储:M3u8PartInfo）

@property (nonatomic,copy)void(^onePartDownFinished)();

///总的片段数
@property (nonatomic,assign)int partCont;

@end

@implementation TFM3u8Downloader

static   TFM3u8Downloader *sharedFilesDownManage = nil;

+(TFM3u8Downloader *) sharedM3u8Downloader{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}


-(void)startDownLoad{
    [self stopDownLoad];
    [self startDownloadInGroup];
}

//重新下载
-(void)resumeRequest{
    //    [self resumeRequest:self.request];
    [self startDownloadInGroup];
}

-(void)stopDownLoad{
    [self stopRequest:self.request];
}
-(void)cleanDownLoad{
    
}
-(void)deleteDownLoad{
    [self deleteRequest:self.request];
}


#pragma mark - 放到组中依次进行下载
- (void)startDownloadInGroup {
    
    [self praseUrl:self.fileInfo.fileURL withStableName:self.fileInfo.uniquenName];
    
    if(self.m3u8PartList != nil && self.m3u8PartList.count != 0)  {
#pragma - mark  到数据库中查找是否有片段没有下载完毕
        int segmentHadDown = [DatabaseTool getMovieHadDownSegment:self.fileInfo.uniquenName];
        
        if (segmentHadDown != 0 && (segmentHadDown < self.m3u8PartList.count)) {   //存在有片段 没有下载完毕的,则去除已经下载的m3u8PartList数组里的片段，重新装载未下载的数据
            NSRange range = NSMakeRange(0, segmentHadDown);
            [self.m3u8PartList removeObjectsInRange:range];
        }
    }
    
    [self startLoad];
    
    NSLog(@"--全部加入下载队列--OK--");
}

-(void)startDownPart:(M3u8PartInfo *)part  finish:(void (^)())finish{
    
    finish();
}

-(void)beginRequest:(TFM3u8FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    [self saveDownloadFile:fileInfo];
    
    //NSLog(@"targetPath %@",fileInfo.targetPath);
    //按照获取的文件名获取临时文件的大小，即已下载的大小
    
     NSFileManager *fileManager=[NSFileManager defaultManager];
    NSData *fileData=[fileManager contentsAtPath:fileInfo.tempPath];
    NSInteger receivedDataLength=[fileData length];
  
#pragma mark - 启用ASIHTTPRequest进行下载请求
    ASIHTTPRequest *request=[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:fileInfo.fileURL]];
    request.delegate=self;
    [request setDownloadDestinationPath:[fileInfo targetPath]];
    [request setTemporaryFileDownloadPath:fileInfo.tempPath];
    [request setDownloadProgressDelegate:self];
    [request setNumberOfTimesToRetryOnTimeout:2];
    [request setAllowResumeForFileDownloads:YES];//支持断点续传
    
    [request setUserInfo:[NSDictionary dictionaryWithObject:fileInfo forKey:@"File"]];//设置上下文的文件基本信息
    [request setTimeOutSeconds:30.0f];
    if (isBeginDown) {
        if (self.request == nil) {
            self.request = request;
            [request startAsynchronous];
        }else{
            fileInfo.isDownloading = NO;
            fileInfo.willDownloading = YES;
        }
    }
    
    //如果文件重复下载或暂停、继续，则把队列中的请求删除，重新添加
    BOOL exit = NO;
    for(ASIHTTPRequest *tempRequest in self.downinglist)  {
        TFM3u8FileModel *tempInfo =  [tempRequest.userInfo objectForKey:@"File"];
        //地址存在重定向问题，ASIHTTPRequest 中有一个url和originalURL 连个不同
        if([[[self getRequestUrlStr:tempRequest] lastPathComponent] isEqualToString:[fileInfo.fileURL lastPathComponent]]) {
            [self.downinglist replaceObjectAtIndex:[_downinglist indexOfObject:tempRequest] withObject:request];
            exit = YES;
            break;
        }
    }
    
    if (!exit) {
        [self.downinglist addObject:request];
    }
}


#pragma mark - 重新进行下载
-(void)resumeRequest:(ASIHTTPRequest *)request{
    if(self.request){
        [self.request cancel];
        self.request = nil;
    }
    
    TFM3u8FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    
    //中止一个进程使其进入等待
    for (TFM3u8FileModel *file in self.downinglist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = YES;
            file.willDownloading = NO;
            file.error = NO;
        }
    }
    //重新开始此下载
    [self startLoad];
}

#pragma mark - 停止下载
-(void)stopRequest:(ASIHTTPRequest *)request{
    if (self.request) {
        [self.request cancel];
        self.request = nil;
    }
    if (request == nil) return;
    
    if([request isExecuting]) {
        [request cancel];
    }
    
    TFM3u8FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    
#pragma mark- 保存片段到数据库
    float progress = 1 - [TFDownLoadTools getProgress:self.partCont currentSize:self.m3u8PartList.count];
    fileInfo.progress = progress;
    NSLog(@"stop-m3u8--progress:%f",progress);
    [DatabaseTool updatePartWhenDownStoWithPprogress:progress segmentHadDown:(int)(self.partCont- self.m3u8PartList.count) uniqueName:fileInfo.uniquenName];
    
    for (TFM3u8FileModel *file in self.m3u8PartList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            break;
        }
    }
    
    //    [self startLoad];
}


#pragma mark - 开始下载
-(void)startLoad{
    NSInteger num = 0;
    NSInteger max = 1;
    for (TFM3u8FileModel *file in self.m3u8PartList) {
        if (!file.error) {
            if (file.isDownloading==YES) {
                file.willDownloading = NO;
                
                if (num>max) {
                    file.isDownloading = NO;
                    file.willDownloading = YES;
                }else
                    num++;
            }
        }
    }
    if (num<max) {
        for (TFM3u8FileModel *file in self.m3u8PartList) {
            if (!file.error) {
                if (!file.isDownloading&&file.willDownloading) {
                    num++;
                    if (num>max) {
                        break;
                    }
                    file.isDownloading = YES;
                    file.willDownloading = NO;
                }
            }
        }
        
    }
    
    for (TFM3u8FileModel *file in self.m3u8PartList) {
        if (!file.error) {
            if (file.isDownloading == YES) {
                [self beginRequest:file isBeginDown:YES];
            }else
                [self beginRequest:file isBeginDown:NO];//暂定下载
        }
    }
}

#pragma mark - 删除下载的操作
-(void)deleteRequest:(ASIHTTPRequest *)request{
    bool isexecuting = NO;
    if([request isExecuting])  {
        [request cancel];
        isexecuting = YES;
    }
    if(self.request){
        [self.request cancel];
        self.request = nil;
    }
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    TFM3u8FileModel *fileInfo=(TFM3u8FileModel *)[request.userInfo objectForKey:@"File"];
    NSString *path=fileInfo.tempPath;
    
    //    [DatabaseTool delFileModelWithUniquenName:fileInfo.uniquenName];//删除数据库记录
    [fileManager removeItemAtPath:path error:&error]; //删除临时文件
    
    if(!error)  {
        NSLog(@"%@",[error description]);
    }
    
    NSInteger delindex =-1;
    for (TFM3u8FileModel *file in self.m3u8PartList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [self.downinglist indexOfObject:file];
            break;
        }
    }
    if (delindex!=NSNotFound && delindex > -1)
        [self.downinglist removeObjectAtIndex:delindex];
    
    [self.downinglist removeObject:request];
    
    if (isexecuting) {
        
        [self startLoad];
    }
}

-(void)clearAllFinished{
    [self.finishedlist removeAllObjects];
}

-(void)clearAllRquests{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    NSError *error;
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
        TFM3u8FileModel *fileInfo=(TFM3u8FileModel *)[request.userInfo objectForKey:@"File"];
        NSString *path=fileInfo.tempPath;;
        //        [DatabaseTool delFileModelWithUniquenName:fileInfo.uniquenName];//删除数据库记录
        [fileManager removeItemAtPath:path error:&error];
        
        if(!error)  {
            NSLog(@"%@",[error description]);
        }
        
    }
    [self.downinglist removeAllObjects];
    [self.downinglist removeAllObjects];
}

/**
 *  加载所有的未下载的文件
 */
#pragma mark - 加载未下载的文件文件
-(void)loadTempfiles
{
    self.basepath = kDownDomanPath ;
    self.TargetSubPath = @"Video";
    NSArray *array = [NSArray array];//[DatabaseTool getFileModeArray:NO];//拿到未下载的数据
    [self.downinglist addObjectsFromArray:array];
    [self startLoad];
}
/**
 *  加载所有的已经下载完毕的文件
 */
-(void)loadFinishedfiles
{
    NSArray *array = [NSArray array];//[DatabaseTool getFileModeArray:YES];//拿到未下载的数据
    [self.finishedlist addObjectsFromArray:array];
}
/**
 *  下载完毕 写文件
 */
-(void)saveFinishedFile{
    //[_finishedList addObject:file];
    if (_finishedlist==nil || _finishedlist.count == 0) {
        return;
    }
    //    [DatabaseTool updateFilesModeWhenDownFinish:_finishedlist];
    
}
-(void)deleteFinishFile:(FileModel *)selectFile{
    [_finishedlist removeObject:selectFile];
}

#pragma mark -- ASIHttpRequest 代理
#pragma mark -- ASIHttpRequest回调委托 --

//出错了，如果是等待超时，则继续下载
-(void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error=[request error];
    NSLog(@"%@",request.url);
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    TFM3u8FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.isDownloading = NO;
    fileInfo.willDownloading = NO;
    fileInfo.error = YES;
    for (TFM3u8FileModel *file in self.m3u8PartList) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            file.error = YES;
        }
    }
    [self startLoad];
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    //    DLog(@"http--下载，开始啦!");
    //    NSLog(@"0---requestHeaders:%@",[request requestHeaders]);
}

#pragma mark - 下载收到数据
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"http--下载，收到回复啦!--code2:%d",[request responseStatusCode]);
    TFM3u8FileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    int httpCode = [request responseStatusCode];
    if (httpCode == 424 || httpCode == 403 ) {//403:forbiden
        fileInfo.error = YES;
        fileInfo.isDownloading = NO;
        
        return;
    }
    
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];
    //    NSLog(@"http--didReceiveResponseHeaders--：%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
 
    
    [self saveDownloadFile:fileInfo];
}

-(void)setProgress:(float)newProgress
{
    //        NSLog(@"--http--deleg--progress-%f",newProgress);
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
 
}
#pragma mark - 下载完毕
//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    TFM3u8FileModel *fileInfo = [request.userInfo objectForKey:@"File"];
    if (fileInfo.error) {
        
        return;
    }
    
    [self.finishedlist addObject:fileInfo];
    
    [self.m3u8PartList removeObject:fileInfo];
    [self.downinglist removeObject:request];
    
    if([request isExecuting]) {
        [request cancel];
    }
    self.request = nil;
    
    [self saveFinishedFile];
    
    [self startLoad];
    
    if (self.partCont != 0) {
        float progress = 1 - [TFDownLoadTools getProgress:self.partCont currentSize:self.m3u8PartList.count];
        
        NSLog(@"-m3u8-part:%@,-progress:%f",self.fileInfo.uniquenName,progress);
#pragma mark - 下载进度的代理
        if ([self.m3u8DownloadDelegate respondsToSelector:@selector(m3u8DownloaderProgress:)]) {
            self.fileInfo.progress = progress;
            [self.tranferReques setUserInfo:[NSDictionary dictionaryWithObject:self.fileInfo forKey:@"File"]];//设置上下文的文件基本信息
            [self.m3u8DownloadDelegate m3u8DownloaderProgress:self.tranferReques];
        }
    }
    if (self.m3u8PartList.count == 0) {//全部片段已经下载完毕
        [self.downinglist removeAllObjects];
        [self createLocalM3U8file];
    }
}

-(void)restartAllRquests{
    for (ASIHTTPRequest *request in _downinglist) {
        if([request isExecuting])
            [request cancel];
    }
    [self startLoad];
}



-(NSString *)getRequestUrlStr:(ASIHTTPRequest *)tempRequest {
    NSString *judgeUrl = @"";
    if (tempRequest.originalURL.absoluteString != nil || tempRequest.originalURL.absoluteString.length != 0) {
        judgeUrl = tempRequest.originalURL.absoluteString;
    }else{
        judgeUrl = tempRequest.url.absoluteString;
    }
    
    return judgeUrl;
}


#pragma mark - 存储数据
-(void)saveDownloadFile:(TFM3u8FileModel *)fileinfo{
#pragma TODO - 下载 待做
    //    BOOL result = [DatabaseTool addFileModelWithModel:fileinfo];
    //    NSLog(@"-save result--:%d",result);
}


-(NSMutableArray *)m3u8PartList
{
    if (_m3u8PartList == nil) {
        _m3u8PartList = [NSMutableArray array];
    }
    return _m3u8PartList;
}


//解析m3u8的内容
-(void)praseUrl:(NSString *)urlstr withStableName:(NSString *)stableName
{
    if (urlstr == nil || urlstr.length == 0) return;
    
    NSURL *url = [[NSURL alloc] initWithString:urlstr];
    NSError *error = nil;
    NSStringEncoding encoding;
    NSString *data = [[NSString alloc] initWithContentsOfURL:url
                                                usedEncoding:&encoding
                                                       error:&error];
    if(data == nil)   {
        if([self.m3u8DownloadDelegate respondsToSelector:@selector(m3u8DownloaderFailed:)])  {
            [self.m3u8DownloadDelegate m3u8DownloaderFailed:self.tranferReques];
        }
        
        return;
    }
    //写m3u8文件   不能手动更改本地m3u8文件格式，以原来的文件为基础进行替换，否则下载好，无法读取
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    //    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:kPathDownload] stringByAppendingPathComponent:stableName];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Video"] stringByAppendingPathComponent:stableName];
    NSString *tempTo = [[pathPrefix stringByAppendingPathComponent:@"Temp"] stringByAppendingPathComponent:stableName];
    
    NSString *fullpath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
    //    NSString *tempTopath = [tempTo stringByAppendingPathComponent:@"movie.m3u8"];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if(!([fm fileExistsAtPath:saveTo isDirectory:&isDir] && isDir))  {
        [fm createDirectoryAtPath:saveTo withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL isDir2 = NO;
    if(!([fm fileExistsAtPath:tempTo isDirectory:&isDir2] && isDir2))  {
        [fm createDirectoryAtPath:tempTo withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSError *werror = nil;
    BOOL bSucc =[data writeToFile:fullpath atomically:YES encoding:NSUTF8StringEncoding error:&werror];
    //                [data writeToFile:tempTopath atomically:YES encoding:NSUTF8StringEncoding error:&werror];
    
    if(bSucc) {
        NSLog(@"create original m3u8file succeed; fullpath:%@, content:",fullpath);
    } else  {
        NSLog(@"create original m3u8file failed:%@",werror);
    }
    
    NSMutableArray *segments = [[NSMutableArray alloc] init];
    NSString* remainData =data;
    NSRange segmentRange = [remainData rangeOfString:@"#EXTINF:"];
    NSInteger length = 0; //视频总时长
    int i = 0;
    while (segmentRange.location != NSNotFound){
        M3u8PartInfo * segment = [[M3u8PartInfo alloc]init];
        // 读取片段时长
        NSRange commaRange = [remainData rangeOfString:@","];
        NSString* value = [remainData substringWithRange:NSMakeRange(segmentRange.location + [@"#EXTINF:" length], commaRange.location -(segmentRange.location + [@"#EXTINF:" length]))];
        length += [value floatValue];
        segment.duration = [value floatValue];
        
        remainData = [remainData substringFromIndex:commaRange.location];
        // 读取片段url
        NSRange linkRangeBegin = [remainData rangeOfString:@"http"];
        NSRange linkRangeEnd = [remainData rangeOfString:@"#"];
        NSString* linkurl = [remainData substringWithRange:NSMakeRange(linkRangeBegin.location, linkRangeEnd.location - linkRangeBegin.location)];
        segment.locationUrl = linkurl;
        
        //        [segments addObject:segment];
        
        remainData = [remainData substringFromIndex:linkRangeEnd.location];
        segmentRange = [remainData rangeOfString:@"#EXTINF:"];
        
        NSString* tsName = [NSString stringWithFormat:@"id%d.ts",i];
        
        TFM3u8FileModel *m = [[TFM3u8FileModel alloc]init];
        m.uniquenName = self.fileInfo.uniquenName;
     
        m.title = self.fileInfo.title;
        m.iconUrl = self.fileInfo.iconUrl;
        m.isHadDown = self.fileInfo.isHadDown;
        m.urlType = self.fileInfo.urlType;
        m.progress = self.fileInfo.progress;
        m.fileName = tsName;//self.fileInfo.fileName;//
        m.progress = self.fileInfo.progress;
        m.segmentHadDown = self.fileInfo.segmentHadDown;
        
        NSString *urlStr = [linkurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//url进行转义，不转义的话，
        
        m.fileURL = urlStr;//把地址换成小段的地址啊
        m.isDownloading = self.fileInfo.isDownloading;
        m.willDownloading = self.fileInfo.willDownloading;
        m.error = self.fileInfo.error;
        m.targetPath = [NSString stringWithFormat:@"%@/%@",self.fileInfo.targetPath,tsName] ;;
        m.tempPath =[NSString stringWithFormat:@"%@/%@",self.fileInfo.tempPath,tsName] ; ;
        m.m3u8Info = segment;
        [segments addObject:m];
        
        i++;
    }
    NSLog(@"总时长：%ld:%ld (分:秒)",length / 60,length % 60);
    if (segments.count == 0) {//没有片段，m3u8文件列表出错，
        if([self.m3u8DownloadDelegate respondsToSelector:@selector(m3u8DownloaderFailed:)])  {
            [self.m3u8DownloadDelegate m3u8DownloaderFailed:self.tranferReques];
        }
    }else{
        [self.m3u8PartList removeAllObjects];
        self.m3u8PartList = segments;
        self.partCont = (int)self.m3u8PartList.count;
    }
}


#pragma mark - 修改已经下载好的m3u8文件
-(NSString *)createLocalM3U8file
{
    NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *saveTo = [[pathPrefix stringByAppendingPathComponent:@"Video"] stringByAppendingPathComponent:self.fileInfo.uniquenName];
    
    NSString *fullpath = [saveTo stringByAppendingPathComponent:@"movie.m3u8"];
    //UTF-8编码
    __block NSString *str = [NSString stringWithContentsOfFile:fullpath encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *httpArray = [NSMutableArray array];
    NSString* segmentPrefix = [NSString stringWithFormat:@"%@/%@/",KLocaPlaylUrl,self.fileInfo.uniquenName];
    //填充片段数据
    for(int i = 0;i< self.m3u8PartList.count;i++) {
        NSString* filename = [NSString stringWithFormat:@"id%d.ts",i];
        NSString* url = [segmentPrefix stringByAppendingString:filename];
        [httpArray addObject:url];
    }
    
    NSString *httpPattern = @"[a-zA-z]+://[^\\s]*";//匹配http地址
    // 遍历所有的匹配结果
    __block int index = 0;
    [str enumerateStringsMatchedByRegex:httpPattern usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
        NSString* segmentPrefix = [NSString stringWithFormat:@"%@/%@/%@/",KLocaPlaylUrl,kDownTargetPath,self.fileInfo.uniquenName];
        NSString* filename = [segmentPrefix stringByAppendingPathComponent:[NSString stringWithFormat:@"id%d.ts",index]];
        str = [str stringByReplacingOccurrencesOfString:*capturedStrings withString:filename];
        index ++;
    }];
    BOOL bSucc =[str writeToFile:fullpath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if(bSucc) {
        NSLog(@"chang local movie.m3u8 file succeed; fullpath:%@;",fullpath);
        
        //替换m3u8文件成功后，删除Temp目录下的临时文件夹
        //        NSString *tempTo = [[pathPrefix stringByAppendingPathComponent:@"Temp"] stringByAppendingPathComponent:self.fileInfo.uniquenName];
        NSString *tempp = [TFDownLoadTools getTempPath:self.fileInfo.uniquenName];
        [[NSFileManager defaultManager] removeItemAtPath:tempp error:nil];
    }
    else  {
        NSLog(@"chang local m3u8file failed");
    }
#pragma mark - 下载完成的代理
    self.fileInfo.progress = 1.0;
    self.fileInfo.segmentHadDown = self.partCont;
    double downedSize = 0.0;//[WdCleanCaches biteSizeWithPaht:[TFDownLoadTools getHttpDowningSize:self.fileInfo.uniquenName urlType:self.fileInfo.urlType]];
    
    self.fileInfo.fileSize = [NSString stringWithFormat:@"%f",downedSize];
    [_tranferReques setUserInfo:[NSDictionary dictionaryWithObject:self.fileInfo forKey:@"File"]];//设置上下文的文件基本信息
    
    if ([self.m3u8DownloadDelegate respondsToSelector:@selector(m3u8DownloaderFinished:)]) {
        [self.m3u8DownloadDelegate m3u8DownloaderFinished:self.tranferReques];
    }
    
    return @"m3u8-----";
}


-(NSMutableArray *)downinglist
{
    if (!_downinglist) {
        _downinglist = [NSMutableArray array];
    }
    return _downinglist;
}


-(NSMutableArray *)finishedlist
{
    if (!_finishedlist) {
        _finishedlist = [NSMutableArray array];
    }
    return _finishedlist;
}


-(ASIHTTPRequest *)tranferReques{
    if (_tranferReques == nil) {
        _tranferReques = [[ASIHTTPRequest alloc] initWithURL:nil];
        //设置用于传递的参数，用于更新进度等信息，
        if (self.fileInfo) {
            [_tranferReques setUserInfo:[NSDictionary dictionaryWithObject:self.fileInfo forKey:@"File"]];//设置上下文的文件基本信息
        }
    }
    return _tranferReques;
}


@end


/**
 --------------------m3u8的格式1：--------------------
 #EXTM3U
 #EXT-X-TARGETDURATION:30
 #EXTINF:10,
 http://data.vod.itc.cn/ipad?file=/73/49/TQoVLi2yiG7CEzUT4jGpI6.mp4&ysig=2inV-7ooRXzTqNfpVGmyu58U7aFZ0sP_&ch=17173&prod=17173&start=0&end=10
 
 --------------------m3u8的格式2：--------------------
 #EXTM3U
 #EXT-X-TARGETDURATION:10
 #EXT-X-MEDIA-SEQUENCE:0
 #EXTINF:10, no desc
 fileSequence0.ts
 #EXTINF:10, no desc
 
 */
