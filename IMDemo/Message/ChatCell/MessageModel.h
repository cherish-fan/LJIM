//
//  MessageModel.h
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    
    MessageModelTypeMe = 0,//自己发的
    MessageModelTypeOther
    
} MessageModelType;

typedef enum{
    
    MessageModelContentTypeText = 0,
    MessageModelContentTypePicture,
    MessageModelContentTypeVoice,
    MessageModelContentTypeLocation
    
} MessageModelContentType;
@interface MessageModel : NSObject
/**
 *  聊天内容
 */
@property (nonatomic, copy) NSString *text;
/**
 *  发送时间
 */
@property (nonatomic, copy) NSString *time;
/**
 *  信息的类型
 */
@property (nonatomic, assign) MessageModelType type;

/**
 *  是否隐藏时间
 */
@property (nonatomic, assign) BOOL hideTime;
/**
 *   消息的内容类型
 */
@property (nonatomic, assign) MessageModelContentType contentType;

+ (instancetype)messageWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
