//
//  MessageCell.m
//  QShare
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MessageCell.h"
#import "MessageFrame.h"
#import "MessageModel.h"
#import "UIImage+Extension.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "UIViewExt.h"
#import "RecordUtils.h"

@interface MessageCell()
/**
 *  时间
 */
@property (nonatomic, weak) UILabel *timeView;
/**
 *  头像
 */
@property (nonatomic, weak) UIImageView *iconView;

/**
 *  播放录音
 */
@property (nonatomic,strong) AVAudioPlayer *player;

@end

@implementation MessageCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"message";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 子控件的创建和初始化
        // 1.时间
        UILabel *timeView = [[UILabel alloc] init];
        timeView.textAlignment = NSTextAlignmentCenter;
        timeView.textColor = [UIColor grayColor];
        timeView.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:timeView];
        self.timeView = timeView;
        
        // 2.头像
        UIImageView *iconView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconView];
        self.iconView = iconView;
        self.iconView.layer.cornerRadius=20.0;
        self.iconView.layer.masksToBounds=YES;
        
        // 3.正文
        UIButton *textView = [[UIButton alloc] init];
        textView.titleLabel.numberOfLines = 0; // 自动换行
        textView.titleLabel.font = MJTextFont;
       
        textView.contentEdgeInsets = UIEdgeInsetsMake(MJTextPadding, MJTextPadding, MJTextPadding, MJTextPadding);
        
      
        [textView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.contentView addSubview:textView];
        self.textView = textView;
        
        // 4.设置cell的背景色
        self.backgroundColor = [UIColor clearColor];
        //录音时间长度的label
        self.timeLabel=[[UILabel alloc]init];
        self.timeLabel.backgroundColor=[UIColor clearColor];
        self.timeLabel.font=[UIFont systemFontOfSize:14.0f];
        self.timeLabel.textColor=[UIColor colorWithRed:44.0/225.0 green:46.0/255.0 blue:47.0/255.0 alpha:0.7];
        //self.timeLabel.font=[UIFont boldSystemFontOfSize:13.0f];
        [self.contentView addSubview:self.timeLabel];
 
    }
    
    return self;
    
    
    
}

-(void)setMessageFrame:(MessageFrame *)messageFrame
{
    
    _messageFrame = messageFrame;
    
    MessageModel *message = messageFrame.message;
    
    // 1.时间
    self.timeView.text = message.time;
    self.timeView.frame = messageFrame.timeF;
    
    // 2.头像
    NSData *iconData = (message.type == MessageModelTypeMe) ? self.myAvatar : self.chatWithAvatar;
    self.iconView.image = [UIImage imageWithData:iconData];
    self.iconView.frame = messageFrame.iconF;
  
    
    // 3.正文
    if (_messageFrame.message.contentType==MessageModelContentTypeText) {
        
          [self.textView setTitle:message.text forState:UIControlStateNormal];
    }
    else if (_messageFrame.message.contentType==MessageModelContentTypePicture) {
        
        NSString *photoBase64Str = [message.text substringFromIndex:11];
        NSData *data = [photoBase64Str base64DecodedData];
        _textView.contentEdgeInsets = UIEdgeInsetsMake(13, 13, 13, 13);
        
        [self.textView setImage:[UIImage imageWithData:data] forState:UIControlStateNormal];
        [self.textView addTarget:self action:@selector(goToChatDetailVC) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    else if (_messageFrame.message.contentType==MessageModelContentTypeVoice)
    {
        [self.textView addTarget:self action:@selector(playRecord) forControlEvents:UIControlEventTouchUpInside];
    }
    self.textView.frame = messageFrame.textF;
    
    // 4.正文的背景
    if (message.type == MessageModelTypeMe)
    { // 自己发的,蓝色
        
        if (message.contentType==MessageModelContentTypeVoice) {
            [self.textView setBackgroundImage:[UIImage resizableImage:@"VOIPSenderVoiceNodeBkg"] forState:UIControlStateNormal];
            
            NSLog(@" self.textView %f",self.textView.right);
            UIImageView *voiceImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"image_right_2"]];
            voiceImage.size=CGSizeMake(15, 15);
            voiceImage.frame=CGRectMake(280-self.textView.left, 10, 15, 15);
            [self.textView addSubview:voiceImage];
            self.timeLabel.frame=CGRectMake(self.textView.left-12, self.textView.top+10, 15, 15);
            NSString *timeString=[messageFrame.message.text substringWithRange:NSMakeRange(11, 1)];
            NSString *disPlayString=[NSString stringWithFormat:@"%@%@",timeString,@"\""];
            self.timeLabel.text=disPlayString;
        }else{
        
        [self.textView setBackgroundImage:[UIImage resizableImage:@"chat_send_nor"] forState:UIControlStateNormal];
        }
        
         if (_messageFrame.message.contentType==MessageModelContentTypeText) {
             
             [self.textView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
             
         }
        
        
    } else { // 别人发的,白色
        
        if (message.contentType==MessageModelContentTypeVoice) {
            [self.textView setBackgroundImage:[UIImage resizableImage:@"VOIPReceiverVoiceNodeBkg"] forState:UIControlStateNormal];

            UIImageView *voiceImage=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"image_left_1"]];
            voiceImage.frame=CGRectMake(self.textView.left-35, 10, 15, 15);
            [self.textView addSubview:voiceImage];
            self.timeLabel.frame=CGRectMake(self.textView.right+4, self.textView.top+10, 15, 15);
            NSString *timeString=[messageFrame.message.text substringWithRange:NSMakeRange(11, 1)];
            NSString *disPlayString=[NSString stringWithFormat:@"%@%@",timeString,@"\""];
            self.timeLabel.text=disPlayString;


            
        }else{
            
            [self.textView setBackgroundImage:[UIImage resizableImage:@"chat_recive_press_pic"] forState:UIControlStateNormal];
        }
    }
 
    
    
    
    
    
}



-(void)playRecord
{
   
    NSLog(@"%@",[_messageFrame.message.text substringWithRange:NSMakeRange(11, 1)]);
    NSString *voiceBase64Str=[self.messageFrame.message.text substringFromIndex:12];
    NSData *data=[voiceBase64Str base64DecodedData];
    NSError *playerError;
    
    //播放
    
    _player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
    
    if (_player == nil)
    {
        NSLog(@"ERror creating player: %@", [playerError description]);
    }else{
        [_player play];
    }

    
}
-(void)goToChatDetailVC
{
    NSString *picBase64Str=[_messageFrame.message.text substringFromIndex:11];
    NSData *data=[picBase64Str base64DecodedData];
//    ChatDetailVC *chatDetail=[[ChatDetailVC alloc]init];
//    chatDetail.data=data;
//    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:chatDetail];
    
    [self.seePictureDelegate seePictureWithPictureData:data];
    
    
    
    
}
@end
