//
//  LoginViewController.h
//  IMDemo
//
//  Created by 梁建 on 14/12/4.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EnrollVC.h"
@protocol BackToChatTabDelegate <NSObject>

@optional
-(void)backToChatTab;

@end

@interface LoginViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;
@property (weak,nonatomic) id<BackToChatTabDelegate> backToChatDelegate;
@property (nonatomic) BOOL isFromME;
/**
 *  用户登录
 *
 *  @param sender <#sender description#>
 */
- (IBAction)LoginAction:(id)sender;
/**
 *  用户注册
 *
 *  @param sender <#sender description#>
 */
- (IBAction)registerAction:(id)sender;
/**
 *  用户登录遇到问题,如忘记密码
 *
 *  @param sender <#sender description#>
 */
- (IBAction)Longinquestion:(id)sender;
@end
