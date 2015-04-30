//
//  MessageFrame.h
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//
// 正文的字体
#define MJTextFont [UIFont systemFontOfSize:15]

// 正文的内边距
#define MJTextPadding 20

#import "MessageFrame.h"

@class MessageModel;

@interface MessageFrame : NSObject

/**
 *  头像的frame
 */
@property (nonatomic, assign, readonly) CGRect iconF;
/**
 *  时间的frame
 */
@property (nonatomic, assign, readonly) CGRect timeF;
/**
 *  正文的frame
 */
@property (nonatomic, assign, readonly) CGRect textF;
/**
 *  cell的高度
 */
@property (nonatomic, assign, readonly) CGFloat cellHeight;

/**
 *  数据模型
 */
@property (nonatomic, strong) MessageModel *message;

@end
