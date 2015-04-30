//
//  EnrollVC.m
//  IMDemo
//
//  Created by 梁建 on 14/12/9.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "EnrollVC.h"
#import "QSUtils.h"
#import "XMPPUtils.h"
@interface EnrollVC ()<xmppConnectDelegate,UIAlertViewDelegate>

@end

@implementation EnrollVC

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *btn =[UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame=CGRectMake(0, 5, 25, 25);
        [btn setBackgroundImage:[UIImage imageNamed:@"back2"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"back2_highlighted"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(goBackAction)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back=[[UIBarButtonItem alloc]initWithCustomView:btn];
        self.navigationItem.leftBarButtonItem=back;
    }
    return self;
}



- (void)viewDidLoad {
    self.title=@"注册新用户";
    [super viewDidLoad];
    XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
    sharedXMPP.connectDelegate = self;
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)enroll:(id)sender {
    
    NSString *userName = [_userName text];
    NSString *pass = [_password text];
    if([QSUtils isEmpty:userName] || [QSUtils isEmpty:pass])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名和密码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
        [sharedXMPP anonymousConnect];
    }

    
    
}

-(void)goBackAction
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

/**
 *  复写settitle方法设置title颜色
 *
 *  @param title 导航栏文字
 */
-(void)setTitle:(NSString *)title
{
    [super setTitle:title];
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.textColor=[UIColor whiteColor];
    titleLabel.font=[UIFont boldSystemFontOfSize:18.0f];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.text=title;
    [titleLabel sizeToFit];
    self.navigationItem.titleView=titleLabel;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.view endEditing:YES];
}


#pragma mark-XmppConnectDelegate

- (void)registerSuccess
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册帐号成功"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    alertView.tag = 11;
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11) {
        NSString *userName = [_userName text];
        NSString *pass = [_password text];
        
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        [userDefaults setObject:userName forKey:XMPP_USER_NAME];
//        [userDefaults setObject:pass forKey:XMPP_USER_PASS];
//        [userDefaults synchronize];
        XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
        [sharedXMPP disconnect];
        
        [self dismissViewControllerAnimated:YES completion:nil];
      
        
    }
}

- (void)registerFailed:(NSXMLElement *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册帐号失败"
                                                        message:@"用户名冲突"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)anonymousConnected
{
    NSString *userName = [_userName text];
    NSString *pass = [_password text];
    XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
    [sharedXMPP enrollWithUserName:userName andPassword:pass];
}

- (void)didAuthenticate
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (_isFromME) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BACK_CHAT object:self];
    }
    
    
}

- (void)didNotAuthenticate:(NSXMLElement *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名或密码不正确" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}







@end
