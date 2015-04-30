//
//  MessageFrame.m
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//


#import "MessageFrame.h"
#import "MessageModel.h"
#import "NSString+Extension.h"
#import "UIImage+Extension.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

@implementation MessageFrame

-(void)setMessage:(MessageModel *)message
{
    _message = message;
    // 间距
    CGFloat padding = 10;
    // 屏幕的宽度
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    // 1.时间
    if (message.hideTime == NO) { // 显示时间
        CGFloat timeX = 0;
        CGFloat timeY = 0;
        CGFloat timeW = screenW;
        CGFloat timeH = 40;
        _timeF = CGRectMake(timeX, timeY, timeW, timeH);
    }
    
    // 2.头像
    CGFloat iconY = CGRectGetMaxY(_timeF) + padding;
    CGFloat iconW = 40;
    CGFloat iconH = 40;
    CGFloat iconX;
    if (message.type == MessageModelTypeOther) {// 别人发的
        iconX = padding;
    } else { // 自己的发的
        iconX = screenW - padding - iconW;
    }
    _iconF = CGRectMake(iconX, iconY, iconW, iconH);
    
    // 3.正文
    CGFloat textY = iconY;
    
    if (message.contentType==MessageModelContentTypeText)
    {
        //返回文本内容的尺寸
    }
    if (message.contentType==MessageModelContentTypePicture) {
        //返回图片内容的尺寸
        NSString *photoBase64Str = [message.text substringFromIndex:11];
        NSData *data = [photoBase64Str base64DecodedData];
        UIImage *image = [UIImage imageWithData:data];
        CGSize size = image.size;
        if (size.width > 80)
        {
            size.height /= (size.width / 80);
            size.width = 80;
        }
        

        CGSize textBtnSize = CGSizeMake(size.width + MJTextPadding * 2, size.height + MJTextPadding * 2);
        CGFloat textX;
        if (message.type == MessageModelTypeOther) {// 别人发的
            textX = CGRectGetMaxX(_iconF) + padding;
        } else {// 自己的发的
            textX = iconX - padding - textBtnSize.width;
        }
        
        _textF = (CGRect){{textX, textY}, textBtnSize};
        
        // 4.cell的高度
        CGFloat textMaxY = CGRectGetMaxY(_textF);
        CGFloat iconMaxY = CGRectGetMaxY(_iconF);
        _cellHeight = MAX(textMaxY, iconMaxY) + padding;
        
        
        return;
        
    }
    if (message.contentType==MessageModelContentTypeVoice)
    {
        //返回录音的尺寸
        NSString *voiceBase64Str=[message.text substringWithRange:NSMakeRange(11, 1)];
        //获得声音的时间长度
        int length=[voiceBase64Str intValue];
        NSLog(@"%d",length);
        //设置视图的长和宽
        
        CGFloat viewLength;
        
        if (length*20>250) {
            viewLength=250;
        }else{
            viewLength=length*20;
        }
        
        
        CGSize size=CGSizeMake(viewLength, 0);
        CGSize textBtnSize = CGSizeMake(size.width + MJTextPadding * 2, size.height + MJTextPadding * 2);
        CGFloat textX;
        if (message.type == MessageModelTypeOther) {// 别人发的
            textX = CGRectGetMaxX(_iconF) + padding;
        } else {// 自己的发的
            textX = iconX - padding - textBtnSize.width;
        }
        
        _textF = (CGRect){{textX, textY}, textBtnSize};
        
        // 4.cell的高度
        CGFloat textMaxY = CGRectGetMaxY(_textF);
        CGFloat iconMaxY = CGRectGetMaxY(_iconF);
        _cellHeight = MAX(textMaxY, iconMaxY) + padding;
        
        
        return;

        
        
    }
    if (message.contentType==MessageModelContentTypePicture) {
        //返回位置截图的尺寸
    }
    // 文字计算的最大尺寸
    CGSize textMaxSize = CGSizeMake(200, MAXFLOAT);
    // 文字计算出来的真实尺寸(按钮内部label的尺寸)
    CGSize textRealSize = [message.text sizeWithFont:MJTextFont maxSize:textMaxSize];
    // 按钮最终的真实尺寸
    CGSize textBtnSize = CGSizeMake(textRealSize.width + MJTextPadding * 2, textRealSize.height + MJTextPadding * 2);
    CGFloat textX;
    if (message.type == MessageModelTypeOther) {// 别人发的
        textX = CGRectGetMaxX(_iconF) + padding;
    } else {// 自己的发的
        textX = iconX - padding - textBtnSize.width;
    }
    
    _textF = (CGRect){{textX, textY}, textBtnSize};
    
    // 4.cell的高度
    CGFloat textMaxY = CGRectGetMaxY(_textF);
    CGFloat iconMaxY = CGRectGetMaxY(_iconF);
    _cellHeight = MAX(textMaxY, iconMaxY) + padding;
    
    
    
    
    
}
@end
