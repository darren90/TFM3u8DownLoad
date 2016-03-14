//
//  M3u8DownManage.m
//  MovieBinge
//
//  Created by Fengtf on 16/2/29.
//  Copyright © 2016年 ftf. All rights reserved.
//

#import "M3u8DownManage.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"
#import "DownLoadModel.h"
#import "CommonHelper.h"
#import "M3u8PartInfo.h"
#import "FileModel.h"
#import "PartDownloader.h"


#define TEMPPATH [CommonHelper getTempFolderPathWithBasepath:_basepath]

@interface M3u8DownManage ()<SegmentDownloadDelegate>

@property (nonatomic,strong) ASIHTTPRequest *request;

@property(nonatomic,copy)NSString *basepath;

@property(nonatomic,copy)NSString *TargetSubPath;

@property(nonatomic,strong)NSMutableArray *targetPathArray;

@property (nonatomic,copy)void(^onePartDownFinished)();
@end

@implementation M3u8DownManage

static   M3u8DownManage *sharedFilesDownManage = nil;

+(M3u8DownManage *) sharedFilesDownManage{
    @synchronized(self){
        if (sharedFilesDownManage == nil) {
            sharedFilesDownManage = [[self alloc] init];
        }
    }
    return  sharedFilesDownManage;
}

//重新下载
-(void)resumeDownload:(ASIHTTPRequest *)request{
    
}
//删除下载
-(void)deleteDownload:(ASIHTTPRequest *)request{
    [[PartDownloader sharedPartDownloader] deleteDownLoad];
}
//停止下载
-(void)stopDownload:(ASIHTTPRequest *)request{
    [[PartDownloader sharedPartDownloader] stopDownLoad];
}


#pragma mark - 外界调用的下载入口
-(void)downFileUrl:(DownLoadModel *)downLoadModel{
    
    //如果是重新下载，则说明肯定该文件已经被下载完，或者有临时文件正在留着，所以检查一下这两个地方，存在则删除掉
    NSString *path = @"Video";
    NSString *name = [NSString stringWithFormat:@"%@",downLoadModel.uniquenName];//存储硬盘上的的文件夹
    
    self.TargetSubPath = path;
    if (_fileInfo!=nil) {
        _fileInfo = nil;
    }
    _fileInfo = [[FileModel alloc]init];
    _fileInfo.fileName = name;
    _fileInfo.fileURL = downLoadModel.downUrl;
    _fileInfo.webPlayUrl = downLoadModel.webPlayUrl;
    _fileInfo.movieId = downLoadModel.movieId;
    _fileInfo.uniquenName = [NSString stringWithFormat:@"%@%d",downLoadModel.movieId,downLoadModel.episode];
    _fileInfo.iconUrl = downLoadModel.iconUrl;
    _fileInfo.episode = downLoadModel.episode;
    _fileInfo.quality = downLoadModel.quality;
    _fileInfo.title = [downLoadModel.title stringByReplacingOccurrencesOfString:@" " withString:@""];//替换空格
    _fileInfo.episodeSid = downLoadModel.episodeSid;
    
    if ([_fileInfo.fileURL rangeOfString:@"m3u8"].location != NSNotFound || [_fileInfo.fileURL rangeOfString:@"tss=ios"].location != NSNotFound) {
        _fileInfo.urlType = UrlM3u8;
    }else{
        _fileInfo.urlType = UrlHttp;
    }
    
    NSDate *myDate = [NSDate date];
    _fileInfo.time = [CommonHelper dateToString:myDate];
    
    path= [CommonHelper getTargetPathWithBasepath:_basepath subpath:path];//--/DownLoad/video
    
    path = [path stringByAppendingPathComponent:name];//--/DownLoad/video/4646
    _fileInfo.targetPath = path ;
    
    _fileInfo.isDownloading=YES;
    _fileInfo.willDownloading = YES;
    _fileInfo.error = NO;
    _fileInfo.isFirstReceived = YES;
    
    NSString *tempfilePath= [TEMPPATH stringByAppendingPathComponent: _fileInfo.fileName];
    _fileInfo.tempPath = tempfilePath;
    
    BOOL result = [DatabaseTool isFileModelInDB:downLoadModel.uniquenName];
    if(result){//已经下载过一次该音乐
        NSLog(@"-----------该文件已下载---------------");
        return;
    }
    
    //若不存在文件和临时文件，则是新的下载
    [self.filelist addObject:_fileInfo];
    
    [self startLoad];
    
    return;
}

-(void)beginRequest:(FileModel *)fileInfo isBeginDown:(BOOL)isBeginDown
{
    if (isBeginDown) {//要进行下载的
        [PartDownloader sharedPartDownloader].fileInfo = self.fileInfo;
        [PartDownloader sharedPartDownloader].uniquenName = self.fileInfo.uniquenName;
        [PartDownloader sharedPartDownloader].partDownloadDelegate = self;
        [[PartDownloader sharedPartDownloader] startDownLoad];
        
    }else{
        [[PartDownloader sharedPartDownloader] stopDownLoad];
    }
}




#pragma mark - 重新进行下载
-(void)resumeRequest:(ASIHTTPRequest *)request{
    if(self.request){
        [self.request cancel];
        self.request = nil;
    }
    
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
 
    //中止一个进程使其进入等待
    for (FileModel *file in self.downinglist) {
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
    
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    for (FileModel *file in self.downinglist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            break;
        }
    }

    [self startLoad];
}


#pragma mark - 开始下载
-(void)startLoad{
    NSInteger num = 0;
    NSInteger max = 1;
    for (FileModel *file in _filelist) {
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
        for (FileModel *file in _filelist) {
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
    
    for (FileModel *file in self.filelist) {
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
    FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
    NSString *path=fileInfo.tempPath;
    
    [DatabaseTool delFileModelWithUniquenName:fileInfo.uniquenName];//删除数据库记录
    [fileManager removeItemAtPath:path error:&error]; //删除临时文件
    
    if(!error)  {
        NSLog(@"%@",[error description]);
    }
    
    NSInteger delindex =-1;
    for (FileModel *file in self.downinglist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            delindex = [self.downinglist indexOfObject:file];
            break;
        }
    }
    if (delindex!=NSNotFound)
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
        FileModel *fileInfo=(FileModel*)[request.userInfo objectForKey:@"File"];
        NSString *path=fileInfo.tempPath;;
        [DatabaseTool delFileModelWithUniquenName:fileInfo.uniquenName];//删除数据库记录
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
    NSArray *array = [DatabaseTool getFileModeArray:NO];//拿到未下载的数据
    [self.downinglist addObjectsFromArray:array];
    [self startLoad];
}
/**
 *  加载所有的已经下载完毕的文件
 */
-(void)loadFinishedfiles
{
    NSArray *array = [DatabaseTool getFileModeArray:YES];//拿到未下载的数据
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
    [DatabaseTool updateFilesModeWhenDownFinish:_finishedlist];
    
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
    NSLog(@"ASIHttpRequest出错了!%@",error);
    if (error.code==4) {
        return;
    }
    if ([request isExecuting]) {
        [request cancel];
    }
    FileModel *fileInfo =  [request.userInfo objectForKey:@"File"];
    fileInfo.isDownloading = NO;
    fileInfo.willDownloading = NO;
    fileInfo.error = YES;
    for (FileModel *file in self.downinglist) {
        if ([file.fileName isEqualToString:fileInfo.fileName]) {
            file.isDownloading = NO;
            file.willDownloading = NO;
            file.error = YES;
        }
    }
    [self.m3u8DownloadDelegate updateM3u8Progress:request];
}

-(void)requestStarted:(ASIHTTPRequest *)request
{
    NSLog(@"http--下载，开始啦!");
    //    NSLog(@"0---requestHeaders:%@",[request requestHeaders]);
}

#pragma mark - 下载收到数据
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    NSLog(@"http--下载，收到回复啦!");
    NSLog(@"code2:%d",[request responseStatusCode]);
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    int httpCode = [request responseStatusCode];
    if (httpCode == 424 || httpCode == 403 ) {//403:forbiden
        fileInfo.error = YES;
        fileInfo.isDownloading = NO;
        if([self.m3u8DownloadDelegate respondsToSelector:@selector(updateM3u8Progress:)]){
            [self.m3u8DownloadDelegate updateM3u8Progress:request];
        }
        return;
    }
    
    long long totalSize = [[responseHeaders objectForKey:@"Content-Length"] longLongValue];
    NSLog(@"-:%@%d--totalSize:%lld-url:%@-ourl-:%@-responseHeaders:%@",fileInfo.title,fileInfo.episode,totalSize,request.url.absoluteString,request.originalURL.absoluteString,responseHeaders);
    //    NSLog(@"--totalSize:%lld",totalSize);
    
    NSString *len = [responseHeaders objectForKey:@"Content-Length"];
    NSLog(@"http--didReceiveResponseHeaders--：%@,%@,%@",fileInfo.fileSize,fileInfo.fileReceivedSize,len);
    //这个信息头，首次收到的为总大小，那么后来续传时收到的大小为肯定小于或等于首次的值，则忽略
    if ([len longLongValue] == 0 || [fileInfo.fileSize longLongValue]> [len longLongValue]){
        return;
    }else {
        fileInfo.fileSize = [NSString stringWithFormat:@"%lld",  [len longLongValue]];
        [DatabaseTool updateFileModeTotalSize:fileInfo];
    }
    
    [self saveDownloadFile:fileInfo];
}

-(void)setProgress:(float)newProgress
{
    //    NSLog(@"--http--deleg--progress-%f",newProgress);
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    //    NSLog(@"-http--didReceiveBytes：%@,%lld",fileInfo.fileReceivedSize,bytes);
    if (fileInfo.isFirstReceived) {
        fileInfo.isFirstReceived=NO;
        fileInfo.fileReceivedSize =[NSString stringWithFormat:@"%lld",bytes];
    }else if(!fileInfo.isFirstReceived) {
        fileInfo.fileReceivedSize=[NSString stringWithFormat:@"%lld",[fileInfo.fileReceivedSize longLongValue]+bytes];
    }
    float progress = [CommonHelper getProgress:[fileInfo.fileSize longLongValue] currentSize:[fileInfo.fileReceivedSize longLongValue]];
    NSLog(@"--http--progress--:%@-%d:%f",fileInfo.title,fileInfo.episode,progress);
    if([self.m3u8DownloadDelegate respondsToSelector:@selector(updateM3u8Progress:)]){
        [self.m3u8DownloadDelegate updateM3u8Progress:request];
    }
}
#pragma mark - 下载完毕
//将正在下载的文件请求ASIHttpRequest从队列里移除，并将其配置文件删除掉,然后向已下载列表里添加该文件对象
-(void)requestFinished:(ASIHTTPRequest *)request
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    if (fileInfo.error) {

        return;
    }
    
    NSLog(@"---：%@%d下载结束---error:%@",fileInfo.title,fileInfo.episode,request.error);
  
    [self.finishedlist addObject:fileInfo];
    
    [self.downinglist removeObject:fileInfo];
    [self.downinglist removeObject:request];
    
    if([request isExecuting]) {
        [request cancel];
    }
    self.request = nil;
    
    [self saveFinishedFile];
    [self startLoad];
    
    if([self.m3u8DownloadDelegate respondsToSelector:@selector(finishedDownloadM3u8:)])  {
        [self.m3u8DownloadDelegate finishedDownloadM3u8:request];
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
-(void)saveDownloadFile:(FileModel*)fileinfo{
    BOOL result = [DatabaseTool addFileModelWithModel:fileinfo];
    NSLog(@"-save result--:%d",result);
}


-(NSMutableArray *)filelist
{
    if (!_filelist) {
        _filelist = [NSMutableArray array];
    }
    return _filelist;
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





#pragma mark - m3u8的小文件下载的一些代理
-(void)partDownloadFinished:(ASIHTTPRequest *)request{
    NSLog(@"---m3u8的文件下载完成----");
}
#warning mark - 小文件的下载失败，怎么搞？？？？
-(void)partDownloadFailed:(ASIHTTPRequest *)request{
    NSLog(@"---m3u8的文件下载失败----");
}
-(void)partDownloadProgress:(float)progress{
    NSLog(@"mmmm--progress:%f",progress);
}

@end







































































