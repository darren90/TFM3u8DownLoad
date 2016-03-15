//
//  DownManagerViewController.m
//  TFDownLoad
//
//  Created by Fengtf on 15/11/11.
//  Copyright © 2015年 ftf. All rights reserved.
//

#import "DownManagerViewController.h"
#import "DownloadedCell.h"
#import "DowningController.h"

@interface DownManagerViewController ()
@property (nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation DownManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dataArray removeAllObjects];
    NSArray *array = [DatabaseTool getFileModelsHadDownLoad];
    [self.dataArray addObjectsFromArray:array];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.dataArray.count){
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.dataArray.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {//downingState
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"downingState"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }else{
        DownloadedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Downloaded"];
        if(cell == nil){
            cell = [[[NSBundle mainBundle]loadNibNamed:@"DownloadedCell" owner:nil options:nil]lastObject];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.dataArray[indexPath.row];
        return cell;
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {//downingVc
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DowningController *downingVc = [sb instantiateViewControllerWithIdentifier:@"downingVc"];
        [self.navigationController pushViewController:downingVc animated:YES];
    }
}



-(NSMutableArray *)dataArray
{
    if (!_dataArray ) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
