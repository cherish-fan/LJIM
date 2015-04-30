//
//  MessageViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "MessageViewController.h"
#import "LoginViewController.h"
#import "XMPPUtils.h"
#import "MessageViewCell.h"

#import "ChatMessageController.h"
@interface MessageViewController ()<xmppConnectDelegate>
@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@property(nonatomic,strong) NSMutableArray *chatArray;
@property (nonatomic,strong) NSString *chatUserName;
@property int msgNum;

@end

@implementation MessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
      self.title=@"消息";
         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    return self;
}

#pragma mark-View

-(void)loadView
{
    [super loadView];
    UIView *view=[[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.view=view;
    [self loadTableView];
    
}

- (void)viewDidLoad {
    _chatArray = [NSMutableArray arrayWithCapacity:20];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.connectDelegate = self;
    [super viewDidLoad];
    [self setupLogin];
    [self addNotify];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    [self.parentViewController.tabBarItem setBadgeValue:nil];
    _msgNum = 0;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_chatRecord",userName]];
    [_chatArray removeAllObjects];
    _chatArray = [NSMutableArray arrayWithArray:array];
#warning 在这里刷新数据
    [tableView1 reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"");
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
        //[self removeNotify];
}

-(void)loadTableView
{
    tableView1=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-28) style:UITableViewStylePlain];
    tableView1.delegate=self;
    tableView1.dataSource=self;
    //tableView1.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView1.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:tableView1];
    
}
- (void)setupLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:XMPP_USER_NAME];
    NSString *pass = [userDefaults objectForKey:XMPP_USER_PASS];
    if(userName && pass)
    {
        [_sharedXMPP connect];
        
        
    }
    else{
        
        LoginViewController *loginVC=[[LoginViewController alloc]init];
        [self presentViewController:loginVC animated:NO completion:^{
            
        }];
        
        
        
    }
}
/**
 *  添加接收到好友消息,和好友邀请的通知
 */
- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatNotify:) name:NOTIFY_CHAT_MSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsRequestNotify:) name:NOTIFY_Friends_Request object:nil];
     
}

/**
 *  移除通知
 */
- (void)removeNotify
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_CHAT_MSG object:nil];
}

/**
 *  接收到新消息的通知
 *
 *  @param noti 通知对象
 */
- (void)chatNotify:(NSNotification *)noti
{
    NSMutableDictionary *chatDict = [noti object];
    BOOL isOutgoing = [[chatDict objectForKey:@"isOutgoing"] boolValue];
    BOOL isExist = NO;
    NSUInteger index = 0;
    if (_chatArray) {
        for (NSMutableDictionary *obj in _chatArray) {
            if ([self isGroupChatType:chatDict])
            {
                if ([obj[@"chatType"] isEqualToString:@"groupchat"] && [obj[@"roomJID"] isEqualToString: chatDict[@"roomJID"]])
                {
                    isExist = YES;
                    index = [_chatArray indexOfObject:obj];
                    break;
                }
            }
            else
            {
                if ([[obj objectForKey:@"chatwith"] isEqualToString:chatDict[@"chatwith"]])
                {
                    isExist = YES;
                    index = [_chatArray indexOfObject:obj];
                    break;
                }
            }
            
        }
        if (isExist) {
            [_chatArray removeObjectAtIndex:index];
            [_chatArray insertObject:chatDict atIndex:0];
        }
        else{
            [_chatArray insertObject:chatDict atIndex:0];
        }
    }
    else{
        [_chatArray insertObject:chatDict atIndex:0];
    }
    
    NSUInteger selectedIndex = [(UITabBarController *)self.parentViewController.parentViewController selectedIndex];
    if (!isOutgoing && (selectedIndex != 0)) {
        [self.parentViewController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",++_msgNum]];
    }
    
#warning 在这里刷新TableView的数据
    [tableView1 reloadData];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_chatArray forKey:[NSString stringWithFormat:@"%@_chatRecord",userName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
/**
 *  接收到好友消息的通知
 *
 *  @param noti 通知对象
 */
- (void)friendsRequestNotify:(NSNotification *)noti
{
    NSString *requestType = [noti object];
    if ([requestType isEqualToString:@"friendsInvite"]) {
        [[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:@"New"];
    }
}



#pragma mark - Intermediate Methods
/**
 *  判断是否是群聊类型
 *
 *  @param dict 判断是否是群聊类型传入的字典
 *
 *  @return 返回值Yes表示是群聊,返回No表示不是群聊
 */
- (BOOL)isGroupChatType:(NSDictionary *)dict
{
    if (dict[@"chatType"] && [dict[@"chatType"] isEqualToString:@"groupchat"]) {
        return YES;
    }
    return NO;
}

/**
 *  接收到内存警告
 */
- (void)didReceiveMemoryWarning
{
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

/**
 *  设置状态栏颜色
 *
 *  @return 状态栏颜色
 */
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark-xmppConnectDelegate


- (void)didAuthenticate
{
    MyLog(@"验证通过");
    
}

- (void)didNotAuthenticate:(NSXMLElement *)error
{
    //[self performSegueWithIdentifier:SEGUE_CHAT_LOGIN sender:self];
}


#pragma mark-TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_chatArray count] == 0){
        tableView1.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView1.scrollEnabled = YES;
        tableView1.userInteractionEnabled = YES;
        return 1;
    }
    else{
        tableView1.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView1.scrollEnabled = YES;
        tableView1.userInteractionEnabled = YES;
        return [_chatArray count];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if([_chatArray count] == 0){
        return ScreenHeight-20-28;
    }
    else{
        return 60.0;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if([_chatArray count] == 0){
        static NSString *NoChatCellIdentifier = @"No Chat Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoChatCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoChatCellIdentifier];
        }
        UIImageView *imageV=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"NoChat"]];
        imageV.frame=CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-28);
    
        
        [cell.contentView addSubview:imageV];
      
        
     
        return cell;
    }
    
    
    
    
    
    
    
    
    static NSString *cellIdentifier=@"cell";
    MessageViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"MessageViewCell" owner:self options:nil]lastObject];
        
    }
    
    NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
    NSString *body = [chatDict objectForKey:@"body"];
    NSMutableString *bodyString = [NSMutableString stringWithCapacity:40];
    if ([body hasPrefix:@"voiceBase64"]) {
        [bodyString appendString:@"[语音]"];
    }
    else if ([body hasPrefix:@"photoBase64"]){
        [bodyString appendString:@"[图片]"];
        
    }
    else if ([body hasPrefix:@"locationBase64"]){
        [bodyString appendString:@"[位置]"];
    }
    else
        [bodyString appendString:body];
    
    
    NSDate *timestamp = [chatDict objectForKey:@"timestamp"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd hh:mm"];
    NSString *sendDate = [dateFormatter stringFromDate:timestamp];
    
    if ([self isGroupChatType:chatDict])
    {
        cell.avatar.image = [UIImage imageNamed:@"groupContact.png"];
        cell.chatWithName.text = [[XMPPJID jidWithString:chatDict[@"roomJID"]] user] ;
        cell.chatMessage.text = [NSString stringWithFormat:@"%@:%@",chatDict[@"from"],bodyString];
    }
    else
    {
        cell.avatar.image = [chatDict objectForKey:@"chatWithAvatar"] ? [UIImage imageWithData:[chatDict objectForKey:@"chatWithAvatar"]] : [UIImage imageNamed:@"avatar_default.png"];
        cell.chatWithName.text = chatDict[@"chatwith"];
        cell.chatMessage.text = bodyString;
        
    }
    
    
    cell.chatDate.text = sendDate;

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
    
    
        _chatUserName = (NSString *)[[_chatArray objectAtIndex:[indexPath row]] objectForKey:@"chatwith"];
        
        //[self performSegueWithIdentifier:@"Chat2Chat" sender:self];
        ChatMessageController *messageVC=[[ChatMessageController alloc]init];
        messageVC.chatName=_chatUserName;
        NSData *data=[chatDict objectForKey:@"chatWithAvatar"];
        if (data) {
            messageVC.chatWithAvatar=data;
        }
        [self.navigationController pushViewController:messageVC animated:YES];
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}



/**
 *  当视图销毁是,移除通知
 */
-(void)dealloc
{
    [self removeNotify];
    
}

-(void)pushToChat
{
    
    ChatMessageController *chat=[[ChatMessageController alloc]init];
    [self.navigationController pushViewController:chat animated:YES];
    
}

@end
