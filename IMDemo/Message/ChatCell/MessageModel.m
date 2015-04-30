//
//  MessageModel.m
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

+ (instancetype)messageWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.text=[dict objectForKey:@"text"];
        self.time=[dict objectForKey:@"time"];
        self.type=[[dict objectForKey:@"type"] intValue];
        self.contentType=[[dict objectForKey:@"contentType"] intValue];
        
    }
    return self;
}
@end
