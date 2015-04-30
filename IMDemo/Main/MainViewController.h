//
//  MainViewController.h
//  IMDemo
//
//  Created by 梁建 on 14/12/2.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
@interface MainViewController : UITabBarController<UINavigationControllerDelegate>
{
 @private
    
    UIView *_tabarbg;
    UIImageView *_selectView;
    NSArray *_titles;
    NSArray *imgs2;
    UIImageView *item;
    
}

/**
 *  标记选择的button
 */
@property(nonatomic,retain)UIButton *selectedBtn;
/**
 *  是否显示Tabbar
 *
 *  @param isShow 是否显示Tabbar
 */
-(void)showTabbar:(BOOL)isShow;
@end
