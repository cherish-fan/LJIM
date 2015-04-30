//
//  MessageViewCell.m
//  IMDemo
//
//  Created by 梁建 on 14/12/5.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "MessageViewCell.h"

@implementation MessageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        self.avatar.layer.cornerRadius=20.0;
        self.avatar.layer.masksToBounds=YES;
        
        
    }
    return self;
}





- (void)awakeFromNib {
    // Initialization code
    self.avatar.layer.cornerRadius=25.0;
    self.avatar.layer.masksToBounds=YES;
    MyLog(@"awakeFromNib");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
