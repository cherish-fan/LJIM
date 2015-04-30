//
//  MessageViewCell.h
//  IMDemo
//
//  Created by 梁建 on 14/12/5.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *chatWithName;
@property (weak, nonatomic) IBOutlet UILabel *chatMessage;
@property (weak, nonatomic) IBOutlet UILabel *chatDate;

@end
