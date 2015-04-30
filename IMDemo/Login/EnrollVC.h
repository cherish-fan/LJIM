//
//  EnrollVC.h
//  IMDemo
//
//  Created by 梁建 on 14/12/9.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollVC : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userName;

@property (weak, nonatomic) IBOutlet UITextField *password;

@property (nonatomic) BOOL isFromME;

- (IBAction)enroll:(id)sender;

@end
