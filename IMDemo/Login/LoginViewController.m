//
//  LoginViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/4.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "LoginViewController.h"
#import "XMPPUtils.h"
#import "QSUtils.h"
#import "BaseNavigationController.h"
@interface LoginViewController ()<xmppConnectDelegate>
@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@end

@implementation LoginViewController

#pragma mark-View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.connectDelegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark-Action

- (IBAction)LoginAction:(id)sender {
    MyLog(@"登录");
    [self.passWord resignFirstResponder];
    [self.userName resignFirstResponder];
    NSString *userName = [_userName text];
    NSString *pass = [_passWord text];
    if ([QSUtils isEmpty:userName] || [QSUtils isEmpty:pass])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名和密码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userName forKey:XMPP_USER_NAME];
        [userDefaults setObject:pass forKey:XMPP_USER_PASS];
        [userDefaults synchronize];
        
        [_sharedXMPP connect];
    }

}

- (IBAction)registerAction:(id)sender {
    MyLog(@"注册");
    EnrollVC *enrollvc=[[EnrollVC alloc]init];
    enrollvc.isFromME = _isFromME;
    BaseNavigationController *nav=[[BaseNavigationController alloc]initWithRootViewController:enrollvc];
    
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (IBAction)Longinquestion:(id)sender {
    MyLog(@"登录遇到问题");
}


#pragma mark-UITextFieldelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
   
    return YES;
}

/**
 *  触摸背景让键盘落下
 *
 *  @param touches <#touches description#>
 *  @param event   <#event description#>
 */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.passWord resignFirstResponder];
    [self.userName resignFirstResponder];
    
}

#pragma mark-XmppConnectDelegate


- (void)didAuthenticate
{
    if(_isFromME)
    {
        [_backToChatDelegate backToChatTab];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didNotAuthenticate:(NSXMLElement *)error
{
    [self clearUserDefaults];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名或密码不正确" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}






/**
 *   清除保存的用户信息
 */
- (void)clearUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:XMPP_USER_NAME];
    [userDefaults removeObjectForKey:XMPP_USER_PASS];
    [userDefaults synchronize];
}

@end
