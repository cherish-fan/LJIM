//
//  ChatMessageController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/6.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "ChatMessageController.h"
#import "RecordUtils.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "UIViewExt.h"
#import "QBImagePickerController.h"
#import "BaseNavigationController.h"
#import "ChoseMapViewController.h"
@interface ChatMessageController ()<QBImagePickerControllerDelegate,UIImagePickerControllerDelegate,MyLocationDelegate>
/**
 *  录音部分
 */
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) RecordUtils *record;

/**
 *  用int类型来标示录音的长度
 */
@property(assign,nonatomic)int voiceTime;

@end

@implementation ChatMessageController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self=[super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        
        [self.navigationItem setHidesBackButton:YES];
        
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

-(void)goBackAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)loadListView
{
    MyLog(@"%f",self.navigationController.navigationBar.height);
    MyLog(@"%f",[UIScreen mainScreen].applicationFrame.size.height);
    MyLog(@"%f",[UIScreen mainScreen].bounds.size.height);
    MyLog(@"%@",NSStringFromCGRect(self.view.frame));
    MyLog(@"%@",NSStringFromCGRect(self.view.bounds));
   
    self.listView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-44-44-20) style:UITableViewStylePlain];
    self.listView.backgroundColor=[UIColor whiteColor];
    self.listView.separatorStyle=UITableViewCellSeparatorStyleNone;
    self.listView.delegate=self;
    self.listView.dataSource=self;
    [self.view addSubview:self.listView];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=_chatName;
    _isVocie=NO;
    _isKey=NO;
    _isFace=NO;
    _isAdd=NO;
    self.voiceTime=0;
    [self loadListView];
    [self setupToolViews];
    [self setupVoiceView];
    
    
    
    [self setup];
    [self.listView reloadData];
    //self.navigationController.tabBarController.tabBar.hidden=YES;
    MyLog(@"%@",self.navigationController.tabBarController);
    if (self.listView.contentSize.height > self.listView.bounds.size.height)
        [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.frame.size.height)];
}

-(void)viewWillAppear:(BOOL)animated
{
    
     [self.videoView setHidden:YES];
//       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardShown:) name:UIKeyboardWillShowNotification object:nil];
}


/**
 *  setup
 */
-(void)setup
{
    
    [XMPPUtils sharedInstance].messageDelegate = self;
    _shareXMPP = [XMPPUtils sharedInstance];
    //self.messageFrames=[NSMutableArray array];
    self.messageArray= [NSMutableArray array];
    [self getMessageData];
    [self  setupMyAvatar];
    /**
     录音部分
     */
    _record = [[RecordUtils alloc]init];
    [_record setupRecordSetting];
    
    
}

-(void)setupToolViews
{
    
    
    
    /**
     初始化键盘上的工具条
     */
    self.toolView=[[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight-44-44-20, ScreenWidth, 44)];
    /**
     为键盘上的工具条添加背景
     */
    self.toolViewbg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.toolView.userInteractionEnabled=YES;
    [self.toolViewbg setImage:[UIImage imageNamed:@"chat_bottom_bg"]];
    self.toolViewbg.userInteractionEnabled=YES;
    [self.toolView addSubview:self.toolViewbg];
    /**
     *  在工具栏的输入框的左边添加一个录音按钮
     */
    self.btnVideo=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnVideo setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
    self.btnVideo.frame=CGRectMake(7, 7, 30, 30);
    [self.btnVideo addTarget:self action:@selector(btnVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:self.btnVideo];
    /**
     *  为输入框的右边添加一个表情按钮
     */
    self.btnFace=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnFace setBackgroundImage:[UIImage imageNamed:@"chat_bottom_smile_nor.png"] forState:UIControlStateNormal];
    self.btnFace.frame=CGRectMake(294, 7, 30, 30);
    [self.btnFace addTarget:self action:@selector(btn_faceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.toolView addSubview:self.btnFace];
    /**
     *在表情按钮的右边添加一个add按钮
     */
    self.btnAdd=[UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnAdd setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
    [self.btnAdd addTarget:self action:@selector(btnAddAction) forControlEvents:UIControlEventTouchUpInside];
    self.btnAdd.frame=CGRectMake(331, 7, 30, 30);
    [self.toolView addSubview:self.btnAdd];
    

    
    self.messageField=[[UITextField alloc]initWithFrame:CGRectMake(44, 7, 243, 30)];
    self.messageField.backgroundColor=[UIColor whiteColor];
    self.messageField.delegate=self;
    self.messageField.borderStyle=UITextBorderStyleRoundedRect;
    [self.toolView addSubview:self.messageField];
    
    self.faceView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 40, ScreenWidth, 200)];
    [self.toolView addSubview:self.faceView];
    [self.view addSubview:self.toolView];
    
    
    
    
    
    
    
    
    
    
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


-(void)setupVoiceView
{
    
    CGFloat W=50.0;
    CGFloat P=(ScreenWidth-3*W)/4;
   
    self.videoView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.bottom-258, ScreenWidth, 258)];
    self.videoView.backgroundColor=[UIColor whiteColor];
    self.btn_voice=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_voice.frame=CGRectMake(ScreenWidth/2-75, 258/2-75, 150, 150);
    [self.btn_voice setBackgroundImage:[UIImage imageNamed:@"voiceBtn"] forState:UIControlStateNormal];
    [self.btn_voice addTarget:self action:@selector(beginRcord) forControlEvents:UIControlEventTouchDown];
    [self.btn_voice addTarget:self action:@selector(endRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.videoView addSubview:self.btn_voice];
    
    self.btn_place=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_place.frame=CGRectMake(P, 20, W, W);
    [self.btn_place setBackgroundImage:[UIImage imageNamed:@"grk"] forState:UIControlStateNormal];
    [self.btn_place addTarget:self action:@selector(sendPlace) forControlEvents:UIControlEventTouchUpInside];
    [self.videoView addSubview:self.btn_place];
    
    self.btn_picture=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_picture.frame=CGRectMake(self.btn_place.right+P, 20, W, W);
    [self.btn_picture setBackgroundImage:[UIImage imageNamed:@"grg"] forState:UIControlStateNormal];
    [self.btn_picture addTarget:self action:@selector(sendPic) forControlEvents:UIControlEventTouchUpInside];
    [self.videoView addSubview:self.btn_picture];
    
    self.btn_takephoto=[UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_takephoto.frame=CGRectMake(self.btn_picture.right+P, 20, W, W);
    [self.btn_takephoto setBackgroundImage:[UIImage imageNamed:@"grn"] forState:UIControlStateNormal];
    [self.btn_takephoto addTarget:self
                           action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.videoView addSubview:self.btn_takephoto];
    
    
    [self.view addSubview:self.videoView];
   
}

-(void)sendPic
{
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    UINavigationController *navigationController = [[BaseNavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];
}

-(void)takePhoto
{
    
[self pushImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];

}

-(void)sendPlace
{
   
    ChoseMapViewController *chooseMapView=[[ChoseMapViewController alloc]init];
    chooseMapView.delegate=self;
    BaseNavigationController *nav=[[BaseNavigationController alloc]initWithRootViewController:chooseMapView];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
    
    
}

#pragma mark-Action

-(void)btnVideoAction
{
    
    MyLog(@"点击了声音按钮");
    if (_isVocie==YES) {
        
        [self.messageField becomeFirstResponder];
        [_btnVideo setBackgroundImage:[UIImage imageNamed:@"chat_bottom_voice_nor.png"] forState:UIControlStateNormal];
       [self.videoView setHidden:YES];
        _isVocie = NO;
        
    }else{
        
        
        [self.view endEditing:YES];
        [self.videoView setHidden:NO];
        [self.btn_voice setHidden:NO];
        [self.btn_place setHidden:YES];
        [self.btn_picture setHidden:YES];
        [self.btn_takephoto setHidden:YES];
        CGRect rectTool = self.toolView.frame;
        rectTool.origin.y = self.videoView.top-44;
        [self.toolView setFrame:rectTool];
        [_btnVideo setBackgroundImage:[UIImage imageNamed:@"skin_aio_keyboard_nor"] forState:UIControlStateNormal];
        _isVocie = YES;
        
    }
    
    
}

-(void)btn_faceAction
{
    MyLog(@"点击了表情按钮");
}

-(void)btnAddAction
{
    MyLog(@"点击了加号按钮");
    if (_isVocie==YES) {
        
        [self.messageField becomeFirstResponder];
        [_btnAdd setBackgroundImage:[UIImage imageNamed:@"chat_bottom_up_nor.png"] forState:UIControlStateNormal];
        [self.videoView setHidden:YES];
        _isVocie = NO;
        
    }else{
        
        
        [self.view endEditing:YES];
        [self.videoView setHidden:NO];
        [self.btn_voice setHidden:YES];
        [self.btn_place setHidden:NO];
        [self.btn_picture setHidden:NO];
        [self.btn_takephoto setHidden:NO];
        CGRect rectTool = self.toolView.frame;
        rectTool.origin.y = self.videoView.top-44;
        [self.toolView setFrame:rectTool];
        [_btnAdd setBackgroundImage:[UIImage imageNamed:@"skin_aio_keyboard_nor"] forState:UIControlStateNormal];
        _isVocie = YES;
        
    }

    
    
    
    
    
    
    
    
    
}
/**
 *  设置头像
 */
- (void)setupMyAvatar
{
    XMPPJID *myJid = _shareXMPP.xmppStream.myJID;
    XMPPvCardTempModule *vCardModule = _shareXMPP.xmppvCardTempModule;
    XMPPvCardTemp *myCard = [vCardModule vCardTempForJID:myJid shouldFetch:YES];
    NSData *avatarData = myCard.photo;
    if (avatarData) {
        _myAvatar = avatarData;
    }
}

/**
 *  获得聊天的历史纪录
 */
- (void)getMessageData
{
    NSManagedObjectContext *context = [[XMPPUtils sharedInstance].xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
    NSLog(@"%lu",(unsigned long)[dataArray count]);
    NSString *chatwith = [NSString stringWithFormat:@"%@@%@",_chatName,XMPP_HOST_NAME];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    NSString *userJIDStr = [NSString stringWithFormat:@"%@@%@",userName,XMPP_HOST_NAME];
    
    
    for (XMPPMessageArchiving_Message_CoreDataObject *messageObject in dataArray) {
        if (([[messageObject bareJidStr] isEqualToString:chatwith]) && ([[messageObject streamBareJidStr] isEqualToString:userJIDStr])) {
            
            
            
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
            [messageDict setObject:_chatName forKey:@"chatwith"];
            [messageDict setObject:messageObject.body forKey:@"text"];
            [messageDict setObject:@(!messageObject.isOutgoing) forKey:@"type"];
            NSDate *timestamp=messageObject.timestamp;
            
            
            NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
            fmt.dateFormat = @"MM月dd日 hh:mm";
            
            [messageDict setObject:[fmt stringFromDate:timestamp] forKey:@"time"];
            if ([messageObject.body hasPrefix:@"photoBase64"])
            {
                [messageDict setObject:@(1) forKey:@"contentType"];
            }
            else if ([messageObject.body hasPrefix:@"voiceBase64"])
            {
                [messageDict setObject:@(2) forKey:@"contentType"];
            }
            else if ([messageObject.body hasPrefix:@"locationBase64"])
            {
                [messageDict setObject:@(3) forKey:@"contentType"];
            }
            else
            {
                [messageDict setObject:@(0) forKey:@"contentType"];
            }
           // NSLog(@"nnumber:%@",[messageDict objectForKey:@"type"]);
            [self.messageArray addObject:messageDict];
        }
        
    }
    
    
}

-(void)scrollToBottom
{
    
    
    
    NSInteger count=[self.messageFrames count];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count-1) inSection:0];
    // 3. 选中并滚动到末尾
    [self.listView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-get
-(NSMutableArray *)messageFrames
{
    
    if (_messageFrames==nil) {
        
        
        NSMutableArray *mfArray=[NSMutableArray array];
        for (NSDictionary *dict in self.messageArray)
        {
            //NSLog(@"%@",self.messageArray);
            MessageModel *msg=[MessageModel messageWithDict:dict];
            MessageFrame *lastMf=[mfArray lastObject];
            MessageModel *lastMsg=lastMf.message;
            msg.hideTime=[msg.time isEqualToString:lastMsg.time];
            MessageFrame *mf=[[MessageFrame alloc]init];
            mf.message=msg;
            [mfArray addObject:mf];
            
        }
        _messageFrames=mfArray;
    }
    //[self.tableView reloadData];
    return _messageFrames;
}


/**
 *  当键盘改变了frame(位置和尺寸)的时候调用
 */
- (void)keyboardWillChangeFrame:(NSNotification *)note
{
    // 设置窗口的颜色
    self.view.window.backgroundColor = self.listView.backgroundColor;
    
    // 0.取出键盘动画的时间
    CGFloat duration =300.0; //[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 1.取得键盘最后的frame
    CGRect keyboardFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // 2.计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - self.view.frame.size.height;
    
    // 3.执行动画
    if (1)
    {
        //self.listView.contentSize.height>self.listView.bounds.size.height
        [UIView animateWithDuration:duration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, transformY-44-20);
        }];
    }else{
        [UIView animateWithDuration:duration animations:^{
            
#warning 键盘升起的通知
             self.toolView.transform = CGAffineTransformMakeTranslation(0, transformY-44-20+80);
        }];
    }
}

- (void)onKeyboardShown:(NSNotification *)notify
{
    //通知显示键盘
    CGFloat keyboardHeight = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    NSLog(@"%ff",keyboardHeight);
    NSTimeInterval duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self handleView:keyboardHeight setAnimationDuration:duration];
    //[self.listView scrollBubbleViewToBottomAnimated:YES];
    
    
    CGRect viewFrame = CGRectMake(0.0, 0.0, self.listView.frame.size.width, self.listView.frame.size.height);
    
    
    if (self.messageFrames.count>3) {
        
        
        
        [UIView animateWithDuration:0 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.listView.frame = CGRectOffset(viewFrame, 0, -keyboardHeight+20);
            //        self.toolView.frame=CGRectOffset(toolViewFrame,0, keyboardHeight+44);
        } completion:nil];

    }
    
    
    
    
    
    
    //
    //    CGSize keyboardSize = [[[notify userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    //    CGFloat keyboardHeight = keyboardSize.height;
    //    [self animateTextField:_messageField up:YES moveDistance:keyboardHeight];
    
    
    
    
    
    
}

//关闭键盘
-(void)hideKeyBoard
{
    [self.view endEditing:YES];
}



- (void)handleView:(CGFloat)height setAnimationDuration:(NSTimeInterval)duration {
    CGFloat selfHeight = self.view.frame.size.height;
    CGRect sendRect = self.toolView.frame;
    sendRect.origin.y = selfHeight - height - 44;
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:duration];
//    [UIView animateWithDuration:duration animations:^{
//        self.view.transform = CGAffineTransformMakeTranslation(0, -height-44-20);
//    }];
    
    
    [self.toolView setFrame:sendRect];
    [UIView commitAnimations];
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)dir moveDistance:(CGFloat)distance
{
    
    CGFloat movementDistance = distance;
    CGFloat movementDuration = 0;
    CGRect viewFrame = CGRectMake(0.0, 0.0, self.listView.frame.size.width, self.listView.frame.size.height);
    
    int movement = (dir ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:movementDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.listView.frame = CGRectOffset(viewFrame, 0, movement);
    } completion:nil];
}



- (void)showKeyboard
{
    [_messageField becomeFirstResponder];
}


- (void)hidenKeyboard {
    [_messageField resignFirstResponder];
    [self handleView:0 setAnimationDuration:0.3];
    
    [self animateTextField:_messageField up:NO moveDistance:0];
    
    
    
    
    
    
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    MyLog(@"%lu",(unsigned long)self.messageFrames.count);
    return self.messageFrames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"message";
    MessageCell *cell =(MessageCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    cell.myAvatar=self.myAvatar;
#warning 当发送的信息是图片时候设置的代理方法
    //cell.seePictureDelegate=self;
    cell.chatWithAvatar=self.chatWithAvatar;
    // 2.给cell传递模型
    cell.selectionStyle= UITableViewCellSelectionStyleNone;
    cell.messageFrame = self.messageFrames[indexPath.row];
    
    
    // 3.返回cell
    return cell;
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 */

#pragma mark - 代理方法
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageFrame *mf = self.messageFrames[indexPath.row];
    return mf.cellHeight;
}

/**
 *  当开始拖拽表格的时候就会调用
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 退出键盘
    MyLog(@"开始拖拽");
    [self.videoView setHidden:YES];
    [_messageField resignFirstResponder];
    [self hidenKeyboard];
    
}

/**
 *  所有的发送消息都要调用这个方法
 *
 *  @param type    消息的类型
 *  @param bodyObj 消息体
 */
- (void)sendWithType:(NSString *)type andBody:(id)bodyObj
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *chatWithUser = [NSString stringWithFormat:@"%@@%@",_chatName,XMPP_HOST_NAME];
    NSString *chatFrom =  [NSString stringWithFormat:@"%@@%@",[[NSUserDefaults standardUserDefaults] stringForKey:XMPP_USER_NAME],XMPP_HOST_NAME];
    
    [mes addAttributeWithName:@"to" stringValue:chatWithUser];
    [mes addAttributeWithName:@"from" stringValue:chatFrom];
    
    NSMutableString *sendString = [NSMutableString stringWithCapacity:40];
    
    if ([type isEqualToString:@"text"]) {
        [sendString appendString:(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"voice"]){
        [sendString appendFormat:@"%@%d%@",@"voiceBase64",self.voiceTime,(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"photo"]){
        [sendString appendFormat:@"%@%@",@"photoBase64",(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"location"]){
        [sendString appendString:(NSString *)bodyObj];
    }
    
    
    [body setStringValue:sendString];
    [mes addChild:body];
    
    [[[XMPPUtils sharedInstance] xmppStream] sendElement:mes];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setObject:_chatName forKey:@"chatwith"];
    [messageDict setObject:sendString forKey:@"body"];
    [messageDict setObject:@(YES) forKey:@"isOutgoing"];
    [messageDict setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"timestamp"];
    
    NSMutableDictionary *notifiMessage = [messageDict mutableCopy];
    
    if (_chatWithAvatar) {
        [notifiMessage setObject:_chatWithAvatar forKey:@"chatWithAvatar"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_MSG object:notifiMessage];
    
    
    NSMutableDictionary *messageDict2 = [NSMutableDictionary dictionary];
    [messageDict2 setObject:_chatName forKey:@"chatwith"];
    [messageDict2 setObject:sendString forKey:@"text"];
    [messageDict2 setObject:@(0) forKey:@"type"];
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"MM月dd日 hh:mm";;
    
    
    
    [messageDict2 setObject:[fmt stringFromDate:now] forKey:@"time"];
    if ([sendString hasPrefix:@"photoBase64"])
    {
        [messageDict2 setObject:@(1) forKey:@"contentType"];
    }
    else if ([sendString hasPrefix:@"voiceBase64"])
    {
        [messageDict2 setObject:@(2) forKey:@"contentType"];
    }
    else if ([sendString hasPrefix:@"locationBase64"])
    {
        [messageDict2 setObject:@(3) forKey:@"contentType"];
    }
    else
    {
        [messageDict2 setObject:@(0) forKey:@"contentType"];
    }
    MyLog(@"nnumber:%@",[messageDict2 objectForKey:@"type"]);
    MessageModel *model=[[MessageModel alloc]initWithDict:messageDict2];
    MessageFrame  *frame=[[MessageFrame alloc]init];
    frame.message=model;
    [self.messageFrames addObject:frame];
    [self.messageArray addObject:messageDict2];
    
    
    
    
    [self.listView reloadData];
    
//    [self.listView setContentOffset:CGPointMake(0, self.listView.contentSize.height - self.listView.frame.size.height)];
    [self scrollToBottom];
    
    
    
}
#pragma mark-UITextFiledDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    //本地输入框中的信息
    NSString *message = textField.text;
    
    if (message.length > 0) {
        
        [self sendWithType:@"text" andBody:message];
    }
    
    self.messageField.text = @"";
    
    return YES;
}



#pragma mark - xmppMessageDelegate

-(void)newMessageReceived:(NSDictionary *)messageCotent
{
    
    if ([[messageCotent objectForKey:@"chatwith"] isEqualToString:_chatName])
    {
        /**
         *NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
         [messageDict setObject:_chatName forKey:@"chatwith"];
         [messageDict setObject:sendString forKey:@"body"];
         [messageDict setObject:@(YES) forKey:@"isOutgoing"];
         [messageDict setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"timestamp"];
         
         NSMutableDictionary *notifiMessage = [messageDict mutableCopy];
         
         if (_chatWithAvatar) {
         [notifiMessage setObject:_chatWithAvatar forKey:@"chatWithAvatar"];
         }
         
         [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_MSG object:notifiMessage];

         *
         *
         */
        
        NSMutableDictionary *messageDict2 = [NSMutableDictionary dictionary];
        [messageDict2 setObject:_chatName forKey:@"chatwith"];
        [messageDict2 setObject:[messageCotent objectForKey:@"body"] forKey:@"text"];
        [messageDict2 setObject:@(1) forKey:@"type"];
        NSDate *now = [messageCotent objectForKey:@"timestamp"];
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"MM月dd日 hh:mm";;
        
        
        
        [messageDict2 setObject:[fmt stringFromDate:now] forKey:@"time"];
        if ([[messageCotent objectForKey:@"body"] hasPrefix:@"photoBase64"])
        {
            [messageDict2 setObject:@(1) forKey:@"contentType"];
        }
        else if ([[messageCotent objectForKey:@"body"] hasPrefix:@"voiceBase64"])
        {
            [messageDict2 setObject:@(2) forKey:@"contentType"];
        }
        else if ([[messageCotent objectForKey:@"body"] hasPrefix:@"locationBase64"])
        {
            [messageDict2 setObject:@(3) forKey:@"contentType"];
        }
        else
        {
            [messageDict2 setObject:@(0) forKey:@"contentType"];
        }
        MyLog(@"nnumber:%@",[messageDict2 objectForKey:@"type"]);
        MessageModel *model=[[MessageModel alloc]initWithDict:messageDict2];
        MessageFrame  *frame=[[MessageFrame alloc]init];
        frame.message=model;
        [self.messageFrames addObject:frame];
        [self.messageArray addObject:messageDict2];
        
        
        
        
        [self.listView reloadData];

        [self scrollToBottom];
        
        
        
        
        
    }
    
    
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)beginRcord
{
    
    [_record beginRecord];
    //启动定时器
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(levelTimer) userInfo:nil repeats:YES];
}

-(void)endRecord
{
    
    [_record endRecord];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"voice.aac"];
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *voiceBase64 = [data base64EncodedString];
        [self sendWithType:@"voice" andBody:voiceBase64];
    }
    [timer invalidate];
    timer = nil;
    self.voiceTime=0;
}

-(void)levelTimer
{
    
    self.voiceTime++;
    //NSLog(@"%d",self.voiceTime);
    
    
    
}
- (void)dismissImagePickerController
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark-QBImagePickerDelegate
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    MyLog(@"*** imagePickerController:didSelectAsset:");
    MyLog(@"%@", asset);
    [self dismissImagePickerController];
}
- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    for (ALAsset *asset in assets) {
        CGImageRef imageRef = [[asset defaultRepresentation]fullResolutionImage];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        NSString *imageBase64Str = [data base64EncodedString];
        [self sendWithType:@"photo" andBody:imageBase64Str];
    }
    [self dismissImagePickerController];

}
- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
     [self dismissImagePickerController];
}

- (void)pushImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        
        [picker.navigationBar setBarStyle:UIBarStyleBlack];
        [picker setSourceType:sourceType];
        
        [picker setAllowsEditing:YES];
        //picker.showsCameraControls=YES;
        [picker setDelegate:self];
        [self.navigationController presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark-UIImagePickerControlDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    NSData *data = UIImageJPEGRepresentation(image, 0.2f);
    NSString *imageBase64Str = [data base64EncodedString];
    [self sendWithType:@"photo" andBody:imageBase64Str];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
        
        
    }];

}

#pragma mark-MyLocationDelegate

-(void)sendLocationImage:(UIImage *)image andLongitude:(double)longitude andLatitude:(double)latitude
{
    
    NSData *data = UIImageJPEGRepresentation(image, 0.2f);
    NSString *imageBase64Str = [data base64EncodedString];

    [self sendWithType:@"photo" andBody:imageBase64Str];


    
    
    
}
@end
