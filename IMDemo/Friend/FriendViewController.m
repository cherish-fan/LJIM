//
//  FriendViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "FriendViewController.h"
#import "XMPPUtils.h"
#import "XMPPvCardTemp.h"
#import "ChatMessageController.h"
#define USERNAME @"username"
#define AVATARDATA @"avatardata"
@interface FriendViewController ()<xmppFriendsDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@property (nonatomic,strong) NSString *chatUserName;

@end

@implementation FriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.title=@"联系人";
    }
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTableView];
    _friendsArray = [NSMutableArray array];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.friendsDelegate = self;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [_sharedXMPP queryRoster];
}

-(void)loadTableView
{
    tableView1=[[UITableView alloc]initWithFrame:[UIScreen mainScreen].applicationFrame  style:UITableViewStylePlain];
    tableView1.delegate=self;
    tableView1.dataSource=self;
    //tableView1.separatorStyle=UITableViewCellSeparatorStyleNone;
    tableView1.indicatorStyle=UIScrollViewIndicatorStyleBlack;
    [self.view addSubview:tableView1];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friendsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendCell";
    MyFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell=[[[NSBundle mainBundle]loadNibNamed:@"MyFriendCell" owner:self options:nil] lastObject];
    }
   
    
   
        cell.name.text = [[_friendsArray objectAtIndex:[indexPath row]] objectForKey:USERNAME];
        NSData *data = [[_friendsArray objectAtIndex:[indexPath row]] objectForKey:AVATARDATA];
        if (data) {
            cell.avatar.image = [UIImage imageWithData:data];
        }
        
    
    
    //标记
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _chatUserName = (NSString *)[[_friendsArray objectAtIndex:[indexPath row]] objectForKey:USERNAME];
    MyLog(@"%@",_chatUserName);
    ChatMessageController *chatMessage=[[ChatMessageController alloc]init];
    chatMessage.chatName=_chatUserName;
    NSData *chatWithdata = [[_friendsArray objectAtIndex:[indexPath row]]
                            objectForKey:AVATARDATA];
    if (chatWithdata) {
        chatMessage.chatWithAvatar = chatWithdata;
        
        
    }

    [self.navigationController pushViewController:chatMessage animated:YES];
    [tableView1 deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
  
        return 60.0;
   
    
}






#pragma mark xmppFriendsDelegate implement

-(void)removeFriens
{
    if(_friendsArray)
        [_friendsArray removeAllObjects];
    [tableView1 reloadData];
    
}

- (void)friendsList:(NSDictionary *)dict
{
    NSMutableDictionary *_friendDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [_friendDict setObject:dict[@"name"] forKey:USERNAME];
    if ([dict objectForKey:@"avatar"]) {
        [_friendDict setObject:dict[@"avatar"] forKey:AVATARDATA];
    }
    [_friendsArray addObject:_friendDict];
  
    [tableView1 reloadData];
}


@end
