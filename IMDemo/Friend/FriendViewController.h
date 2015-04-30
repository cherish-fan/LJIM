//
//  FriendViewController.h
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyFriendCell.h"
@interface FriendViewController : UIViewController
{
    UITableView *tableView1;
}

@property (nonatomic,strong) NSMutableArray *friendsArray;

@end
