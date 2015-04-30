//
//  MessageCell.h
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol seePictureDelegate<NSObject>

@optional

-(void)seePictureWithPictureData:(NSData *)data;


@end


@class MessageFrame;
@interface MessageCell : UITableViewCell


+ (instancetype)cellWithTableView:(UITableView *)tableView;
/**
 *  message frame模型
 */
@property (nonatomic, strong) MessageFrame *messageFrame;
/**
 *  好友的头像数据
 */
@property (nonatomic,strong) NSData *chatWithAvatar;
/**
 *  自己的头像数据
 */
@property (nonatomic,strong) NSData *myAvatar;
/**
 *  显示录音时间长度的label
 */
@property (nonatomic,strong) UILabel *timeLabel;
/**
 *  正文
 */
@property (nonatomic, weak) UIButton *textView;
/**
 *  查看图片的代理方法
 */

@property (nonatomic,weak) id<seePictureDelegate> seePictureDelegate;
@end
