//
//  MainViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "MainViewController.h"
#import "MessageViewController.h"
#import "MeViewController.h"
#import "FriendViewController.h"
#import "UIViewExt.h"
#import "BaseNavigationController.h"


@interface MainViewController ()

@end

@implementation MainViewController





- (void)viewDidLoad {
    
 
    
        [super viewDidLoad];
    
        [self initChildViewController];
        self.tabBar.backgroundColor=[UIColor clearColor];
        [self reloadImage];
    
    
    
        
 
    

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}


/**
 *  初始化TabbarViewController的子视图控制器
 */
-(void)initChildViewController
{
    MessageViewController *messageVC =[[MessageViewController alloc]init];
    FriendViewController  *friendVC  =[[FriendViewController alloc]init];
    /**
     *  通过storyboard加载视图控制器
     */
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"IMDemo" bundle:nil];
    MeViewController      *meVC      =[[MeViewController alloc]init];
    NSArray *views=@[messageVC,friendVC,meVC];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:3];
    for (UIViewController *viewController in views)
    {
        BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:viewController];
        [viewControllers addObject:nav];
        nav.delegate=self;
        
    }
    
    self.viewControllers=viewControllers;

}
/**
 *  初始化自定义的TabbarView
 */
-(void)initTabarView
{
    _tabarbg=[[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-49,ScreenWidth ,49 )];
    _tabarbg.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_bg"]];
    
    [self.view addSubview:_tabarbg];
    NSArray *imgs=@[@"tab_recent_nor",@"tab_buddy_nor",@"tab_qworld_nor"];
    NSArray *heightimgs=@[@"tab_recent_press",@"tab_buddy_press",@"tab_qworld_press"];
    _titles=@[@"消息",@"联系人",@"动态"];
    
    
    
    int y=0;
    UIButton *button=nil;
    for (int i=0; i<imgs.count; i++) {
        NSString *backImage = imgs[i];
        NSString *heightImage = heightimgs[i];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(y, 0, ScreenWidth/3, 49);
        button.tag = i;
        [button setImage:[UIImage imageNamed:backImage] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:heightImage] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectedTab:) forControlEvents:UIControlEventTouchUpInside];
        [_tabarbg addSubview:button];
        y+=ScreenWidth/3;
        //设置刚进入时,第一个按钮为选中状态
        if (0 == i) {
            button.selected = YES;
            self.selectedBtn = button;  //设置该按钮为选中的按钮
        }
        
        
        
        
        
    }
    
}

/**
 *  是否显示或者隐藏Tabbar
 */

-(void)showTabbar:(BOOL)isShow
{
    [UIView animateWithDuration:0.2 animations:^{
        if (isShow) {
            self.tabBar.left=0;
        }else{
            self.tabBar.left=-ScreenWidth;
        }
    }];
    
}
/**
 *
 */
- (void)reloadImage
{
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"tabbar_bg_ios7.png"]];
    NSArray *ar = self.viewControllers;
    NSMutableArray *arD = [NSMutableArray new];
    [ar enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop)
     {
         //        UITabBarItem *item = viewController.tabBarItem;
         UITabBarItem *item2 = nil;
         switch (idx)
         {
             case 0:
             {
                 item2 = [[UITabBarItem alloc] initWithTitle:@"消息" image:[[UIImage imageNamed:@"tab_recent_nor.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:[[UIImage imageNamed:@"tab_recent_press.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                 break;
             }
             case 1:
             {
                 item2 = [[UITabBarItem alloc] initWithTitle:@"联系人" image:nil tag:1];
                 [item2 setImage:[[UIImage imageNamed:@"tab_buddy_nor.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                 [item2 setSelectedImage:[[UIImage imageNamed:@"tab_buddy_press.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                 break;
             }
             case 2:
             {
                 item2 = [[UITabBarItem alloc]initWithTitle:@"动态" image:nil tag:1];
                 [item2 setImage:[[UIImage imageNamed:@"tab_qworld_nor.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                 [item2 setSelectedImage:[[UIImage imageNamed:@"tab_qworld_press.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
                 break;
             }
         }
         viewController.tabBarItem = item2;
         [arD addObject:viewController];
     }];
    self.viewControllers = arD;
    
    
    
}



/**
 *
 */

- (void)selectedTab:(UIButton *)button {
    
    self.selectedBtn.selected=NO;
    button.selected=YES;
    self.selectedBtn=button;
    
    self.selectedIndex = button.tag;
    
}




#pragma mark-UInavigationControllerdelgate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    //导航控制器的字控制器的个数
    NSUInteger conunt=navigationController.viewControllers.count;
    if (conunt==2)
    {
    [self showTabbar:NO];
    }else if(conunt==1)
    {
    [self showTabbar:YES];
    }
    
    
}
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    
    
    
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

@end
