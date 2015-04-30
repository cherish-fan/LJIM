//
//  MeViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "MeViewController.h"
#import "LoginViewController.h"
#import "XMPPUtils.h"
@interface MeViewController ()<BackToChatTabDelegate>

@property (nonatomic,strong) XMPPUtils *sharedXMPP;

@end

@implementation MeViewController
/**
 *  @author liangjian, 14年12月19日 15:12
 *
 *  <#Description#>
 *
 *  @param nibNameOrNil   <#nibNameOrNil description#>
 *  @param nibBundleOrNil <#nibBundleOrNil description#>
 *
 *  @return <#return value description#>
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title=@"动态";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTableView];
    [self addNotify];
      _sharedXMPP = [XMPPUtils sharedInstance];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




-(void)loadTableView
{
    self.listView=[[UITableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame style:UITableViewStylePlain];
    self.listView.delegate=self;
    self.listView.dataSource=self;
    
    [self.view addSubview:self.listView];
    
    
    
}



#pragma mark-UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NoChatCellIdentifier = @"No Chat Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoChatCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoChatCellIdentifier];
    }
   
    cell.textLabel.text=@"退出登录";
    
    
    
    return cell;
    
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    return 80.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    
    [self.listView deselectRowAtIndexPath:indexPath animated:YES];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:XMPP_USER_PASS];
    [userDefaults synchronize];
    [_sharedXMPP disconnect];
    LoginViewController *loginVC=[[LoginViewController alloc]init];
    loginVC.isFromME=YES;
    loginVC.backToChatDelegate=self;
    [self presentViewController:loginVC animated:YES completion:^{
        
    }];

    
    
    
    
}

#pragma mark-backtochatdelegate
-(void)backToChatTab
{
    MyLog(@"%@",self.parentViewController.parentViewController );
    
    
    [(UITabBarController *)self.parentViewController.parentViewController setSelectedIndex:0];
}



-(void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backtochatNotify) name:NOTIFY_BACK_CHAT object:nil];
}

-(void)backtochatNotify
{
    [self backToChatTab];
    
}

-(void)removeNotify
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_BACK_CHAT object:nil];
}


-(void)dealloc{
    [self removeNotify];
}
@end
