//
//  DatabaseTool.m
//  Diancai1
//
//  Created by user on 14-3-11.
//  Copyright (c) 2014年 user. All rights reserved.
//

#import "DatabaseTool.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

//下载
#import "FileModel.h"
#import "CommonHelper.h"
#import "ContentModel.h"

static FMDatabase *_db;
//order by id desc:降序 asc：升序
@implementation DatabaseTool

+ (void)initialize
{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask , YES) firstObject];
    NSString* sqlPath = [NSString stringWithFormat:@"%@/tfdownload.sqlite",cachesPath];
    NSLog(@"--sqlPath:%@",sqlPath);
    _db = [[FMDatabase alloc] initWithPath:sqlPath];
    
    if (![_db open]) {
        [_db close];
        NSLog(@"打开数据库失败");
    }
    
    [_db setShouldCacheStatements:YES];
 
    //1：新下载  fileName 主键
    if (![_db tableExists:@"fileModel"]) {
        [_db executeUpdate:@"CREATE TABLE if not exists fileModel (id integer primary key autoincrement,fileName TEXT,title TEXT,fileURL TEXT,iconUrl TEXT,filesize TEXT,filerecievesize TEXT,isHadDown integer,urlType integer)"];
    }
      
    [_db close];
}

#pragma mark - 下载2.0
/*******************************5 -- 新 - 下载2.0****************************************/
+(BOOL)addFileModelWithModel:(FileModel *)model
{
    if (model == nil || model.fileName == nil || model.fileName.length == 0) {
        NSLog(@"加入下载列表失败-ID为空");
        return NO;
    }
    
    if (![_db open]) {
        [_db close];
        NSAssert(NO, @"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    
    //1:判断是否已经加入到数据库中
    int count = [_db intForQuery:@"SELECT COUNT(fileName) FROM fileModel where fileName = ?;",model.fileName];
    
    if (count >= 1) {
        NSLog(@"-已经在下载列表中--");
        return NO;
    }
    //2:存储
//    fileName title TEXT,fileURL TEXT,iconUrl TEXT,filesize TEXT,filerecievesize TEXT,isHadDown integer,urlType integer
    BOOL result = [_db executeUpdate:@"insert into fileModel (fileName,title,fileURL,iconUrl,filesize,filerecievesize,isHadDown,urlType) values (?,?,?,?,?,?,?,?);",model.fileName,model.title,model.fileURL,model.iconUrl,model.fileSize,model.fileReceivedSize,@(model.isHadDown),@(model.urlType)];
    
    [_db close];
    if (result) {

    }else{
        NSLog(@"加入下载列表失败");
    }
    return result;
}

/**
 *  根据是否下载完毕取出所有的数据
 *
 *  @param isDowned YES：已经下载，NO：未下载
 *
 *  @return 装有FileModel的模型
 */
+(NSArray *)getFileModeArray:(BOOL)isHadDown
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_db setShouldCacheStatements:YES];
     
    FMResultSet *rs = [_db executeQuery:@"SELECT * FROM fileModel where isHadDown = ? order by id asc;",@(isHadDown)];
    NSMutableArray * array = [NSMutableArray array];
    while (rs.next) {
        FileModel *file = [[FileModel alloc]init];
        file.fileName = [rs stringForColumn:@"fileName"];
        file.fileURL = [rs stringForColumn:@"fileURL"];
        file.fileSize = [rs stringForColumn:@"filesize"];
        file.fileReceivedSize = [rs stringForColumn:@"filerecievesize"];
        file.iconUrl = [rs stringForColumn:@"iconUrl"];
        file.isHadDown  = [rs boolForColumn:@"isHadDown"];
        file.title = [rs stringForColumn:@"title"];
        file.urlType = [rs intForColumn:@"urlType"];
        
        file.isDownloading=NO;
        file.isDownloading = NO;
        file.willDownloading = NO;
        // file.isFirstReceived = YES;
        file.error = NO;

        [array addObject:file];
    }
    [rs close];
    [_db close];
    return array;
}

+(void)updateFilesModeWhenDownFinish:(NSArray *)array
{
    if (array == nil || array.count == 0) {
        return;
    }
    for (FileModel *model in array) {
        [self updateFileModeWhenDownFinish:model];
    }
}


/**
 *  针对获取到真正的文件总大小的时候，更新文件的总大小
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeTotalSize:(FileModel *)model
{
    if (model.fileName == nil || model.fileName.length == 0) {
        NSLog(@"fileName为空，跟新下载完毕列表失败");
        return NO;
    }
    
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
 
    int count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where isHadDown = ? and fileName = ?;",@(NO),model.fileName];
    if (count == 0) {
        NSLog(@"没有剧集记录，无法更新");
        return NO;
    }
    
    BOOL result = false ;
    if (model.fileSize != nil || model.fileSize.length != 0 || [model.fileSize longLongValue] != 0) {
        result = [_db executeUpdate:@"update fileModel set filesize =? where fileName = ?;",model.fileSize,model.fileName];
    }
    [_db close];
    if (!result) {
        NSLog(@"---更改数据库信息失败---");
    }
    
    return result;
}

/**
 *  下载完毕更新数据库
 *
 *  @param model FileModel模型
 *
 *  @return 是否更新成功
 */
+(BOOL)updateFileModeWhenDownFinish:(FileModel *)model
{
    if (model.fileName == nil || model.fileName.length == 0) {
        NSLog(@"fileName为空，跟新下载完毕列表失败");
        return NO;
    }
    
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    int count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where isHadDown = ? and fileName = ?;",@(NO),model.fileName];
    if (count == 0) {
        NSLog(@"没有剧集记录，无法更新");
        return NO;
    }
    BOOL result = false ;
    if (model.fileSize != nil || model.fileSize.length != 0 || [model.fileSize longLongValue] != 0) {
        result = [_db executeUpdate:@"update fileModel set filesize =? ,isHadDown=? where fileName = ?;",model.fileSize,@(YES),model.fileName];
    }
    [_db close];
    if (!result) {
        NSLog(@"---更改数据库信息失败---");
    }
    return result;
}

/**
 *  这个剧是否在下载列表
 *
 *  @param fileName fileName 
 *
 *  @return YES：存在 ； NO：不存在
 */
+(BOOL)isFileModelInDB:(NSString *)fileName
{
    if (fileName == nil || fileName.length == 0) {
        NSLog(@"剧集id为空，跟新下载完毕列表失败");
        return NO;
    }
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    [_db setShouldCacheStatements:YES];
    int count = [_db intForQuery:@"SELECT COUNT(fileName) FROM fileModel where fileName = ?;",fileName];
    [_db close];
    if (count == 0) {
        return NO;
    }else{
        return YES;
    }
}

/**
 *  读取那些剧被下载 -- 不包括详细信息（只取到那些剧集被下载即可）
 *
 *  @return 下载完毕的剧集Array
 */
+(NSArray *)getFileModelsHadDownLoad
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return nil;
    }
    
    [_db setShouldCacheStatements:YES];
    FMResultSet *rs = [_db executeQuery:@"SELECT DISTINCT title,fileName,iconUrl from fileModel where isHadDown = ? order by id desc;",@(YES)];
    NSMutableArray * array = [NSMutableArray array];
    while (rs.next) {
//fileName TEXT,title TEXT,fileURL TEXT,iconUrl TEXT,filesize TEXT,filerecievesize TEXT,isHadDown integer,urlType integer)
        ContentModel *model = [[ContentModel alloc]init];
        model.title = [rs stringForColumn:@"title"] ;
        model.uniquenName = [rs stringForColumn:@"fileName"];
        model.iconUrl = [rs stringForColumn:@"iconUrl"];
        [array addObject:model];
    }
    [rs close];
    [_db close];
    return array;
}


 
/**
 *  是否这部剧已经下载完毕
 *
 *  @param fileName 剧集Id
 *
 *  @return YES:下载完毕 ； NO：没有下载完毕
 */
+(BOOL)isThisHadLoaded:(NSString *)fileName
{
    if (fileName ==  nil || fileName.length == 0) {
        return NO;
    }
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败");
        return NO;
    }
    
    NSUInteger count = [_db intForQuery:@"SELECT COUNT(1) FROM fileModel where fileName = ? ;",fileName];
    [_db close];
    
    if (count  == 0) {
        return NO;
    }else{
        return YES;
    }
}

/**
 *  根据fileName删除已经下载的剧 -- 只会删除一个
 *
 *  @param fileName
 *
 *  @return YES:成功；NO：失败
 */
+(BOOL)delFileModelWithfileName:(NSString *)fileName
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败！");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    BOOL result = [_db executeUpdate:@"DELETE FROM fileModel where fileName = ?",fileName];
    [_db close];
    return result;
}

/**
 *  根据uniquenName删除已经下载的剧 -- 只会删除一个
 *
 *  @param uniquenName MovieId+eposide
 *
 *  @return YES:成功；NO：失败
 */
+(BOOL)delFileModelWithUniquenName:(NSString *)uniquenName
{
    if (![_db open]) {
        [_db close];
        NSLog(@"数据库打开失败！");
        return NO;
    }
    [_db setShouldCacheStatements:YES];
    BOOL result = [_db executeUpdate:@"DELETE FROM fileModel where uniquenName = ?",uniquenName];
    [_db close];
    return result;
}
/*******************************5 -- 新 - 下载****************************************/


 
@end



