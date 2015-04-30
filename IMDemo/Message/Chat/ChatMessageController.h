//
//  ChatMessageController.h
//  IMDemo
//
//  Created by 梁建 on 14/12/6.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUtils.h"
#import "MessageModel.h"
#import "MessageCell.h"
#import "MessageFrame.h"
#import "XMPPvCardTemp.h"
@interface ChatMessageController : UIViewController<UITextFieldDelegate,xmppMessageDelegate,UITableViewDelegate,UITableViewDataSource>
{
    /**
     *  计算声音长度的定时器
     */
    NSTimer *timer;
    
}
//这四个bool形的变量是干嘛的呢
@property (nonatomic) BOOL isKey;
@property (nonatomic) BOOL isAdd;


@property (nonatomic,assign) BOOL isVocie;
@property (nonatomic,assign) BOOL isFace;
/**
 *  XMPP工具对象
 */
@property(nonatomic,strong) XMPPUtils *shareXMPP;
/**
 *  存放信息字典的Array
 */
@property(nonatomic,strong) NSMutableArray *messageArray;
/**
 *  计算message frame的数组
 */
@property(nonatomic,strong)NSMutableArray *messageFrames;
/**
 *  好友昵称
 */
@property(nonatomic,strong)NSString *chatName;
/**
 *  好友头像数据
 */
@property(nonatomic,strong)NSData *chatWithAvatar;
/**
 *  我的头像数据
 */
@property(nonatomic,strong)NSData *myAvatar;
/**
 *  表视图
 */
@property(nonatomic,strong)UITableView *listView;

/**
 *文字输入的父视图
 */
@property(strong,nonatomic)UIView *toolView;
/**
 *  文字输入框的背景
 */
@property(strong,nonatomic) UIImageView *toolViewbg;
/**
 *  消息文本输入框
 */
@property(strong,nonatomic) UITextField *messageField;
/**
 *  表情父视图
 */
@property(strong,nonatomic) UIScrollView *faceView;

/**
 *  输入框右边声音录音按钮
 */
@property(strong,nonatomic) UIButton *btnVideo;
/**
 *  输入框右边加号按钮
 */
@property(strong,nonatomic) UIButton *btnAdd;
/**
 *  输入框右边表情按钮
 */
@property(strong,nonatomic) UIButton *btnFace;

/**
 *  发送位置,图片,等按钮的父视图
 */
@property(strong,nonatomic) UIView *videoView;
/**
 *  发送图片按钮
 */
@property(strong,nonatomic) UIButton *btn_picture;
/**
 *  拍照发送图片按钮
 */
@property(strong,nonatomic) UIButton *btn_takephoto;
/**
 *  发送位置按钮
 */
@property(strong,nonatomic) UIButton *btn_place;
/**
 *  发送作业按钮
 */
@property(strong,nonatomic) UIButton *btn_homework;

/**
 *  开始录音按钮
 */
@property(strong,nonatomic) UIButton *btn_voice;
/**
 *  发送按钮
 */
@property(strong,nonatomic) UIButton *btn_send;
/**
 *  取消按钮
 */
@property(strong,nonatomic) UIButton *btn_cancel;
@end
