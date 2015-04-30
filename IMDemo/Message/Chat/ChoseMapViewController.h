//
//  ChoseMapViewController.h
//  IMDemo
//
//  Created by 梁建 on 14/12/22.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol MyLocationDelegate <NSObject>

-(void)sendLocationImage:(UIImage *)image andLongitude:(double)longitude andLatitude:(double)latitude;

@end

@interface ChoseMapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>

@property (nonatomic,weak) id<MyLocationDelegate> delegate;

@end
