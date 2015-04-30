//
//  MyFriendCell.m
//  IMDemo
//
//  Created by 梁建 on 14/12/8.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "MyFriendCell.h"

@implementation MyFriendCell

- (void)awakeFromNib {
    // Initialization code
    self.avatar.layer.cornerRadius=25.0;
    self.avatar.layer.masksToBounds=YES;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
