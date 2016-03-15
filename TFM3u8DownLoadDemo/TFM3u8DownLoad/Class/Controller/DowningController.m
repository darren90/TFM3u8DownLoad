//
//  DowningController.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/14.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "DowningController.h"
#import "FilesDownManage.h"
#import "DowningCell.h"
#import "WdCleanCaches.h"
#import "ASIHTTPRequest.h"
#import "DowningController.h"

@interface DowningController ()<DownloadDelegate>
@property(nonatomic,strong)NSMutableArray *downingList;
@end

@implementation DowningController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 100;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [FilesDownManage sharedFilesDownManage].downloadDelegate = self;
    
    //开启下载
    FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
    self.downingList = filedownmanage.downinglist;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downingList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DowningCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Downing"];
    if(cell == nil){
        cell = [[[NSBundle mainBundle]loadNibNamed:@"DowningCell" owner:nil options:nil]lastObject];
    }
    cell.cDelegate = self;
    ASIHTTPRequest *theRequest = self.downingList[indexPath.row];
    if (theRequest == nil) {
        return cell = Nil;
    }
    cell.request = theRequest;
    return cell;
}

#pragma - mark  删除操作
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {//删除操作
        ASIHTTPRequest *theRequest = self.downingList[indexPath.row];
        FilesDownManage *filedownmanage = [FilesDownManage sharedFilesDownManage];
        FileModel *model=[theRequest.userInfo objectForKey:@"File"];
        
        //1：停止下载 (包含的有删除数据库的操作)
        [filedownmanage deleteRequest:theRequest];
        
        //2：局部删除一行的刷新
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        
        //3：删除本地
        NSString *fileName = model.fileName;
        [WdCleanCaches deleteFileModelWithPath:fileName isDowned:NO];
    }
}


#pragma mark - 时时更新进度等信息
-(void)updateCellOnMainThread:(FileModel *)fileInfo
{
    NSArray* cellArr = [self.tableView visibleCells];
    for(id obj in cellArr)  {
        if([obj isKindOfClass:[DowningCell class]])  {
            DowningCell *cell = (DowningCell *)obj;
            
            if([cell.fileInfo.fileURL isEqualToString: fileInfo.fileURL])  {
                [cell updateContentCPS:fileInfo];
            }
        }
    }
}

#pragma mark FilesDownManage代理 - 更新进度
#pragma mark --- updateUI delegate ---
-(void)startDownload:(ASIHTTPRequest *)request;
{
    NSLog(@"-----IsDownloadingViewController--开始下载!");
}

#pragma mark - 下载进度
-(void)updateCellProgress:(ASIHTTPRequest *)request;
{
    FileModel *fileInfo=[request.userInfo objectForKey:@"File"];
    
    [self performSelectorOnMainThread:@selector(updateCellOnMainThread:) withObject:fileInfo waitUntilDone:YES];
}

#pragma mark - 下载完毕
-(void)finishedDownload:(ASIHTTPRequest *)request;
{
    [self.downingList removeObject:request];
    [self.tableView reloadData];
}
#pragma mark - tableview对于cell的代理，执行方法
-(void)ReloadDownLoadingTable
{
    //    self.downingList =[FilesDownManage sharedFilesDownManage].downinglist;
    [self.tableView reloadData];
}
-(void)allowNextRequest
{
    
}


-(NSMutableArray *)downingList
{
    if (_downingList == nil) {
        _downingList = [NSMutableArray array];
    }
    return _downingList;
}


@end
