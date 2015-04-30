//
//  ChoseMapViewController.m
//  IMDemo
//
//  Created by 梁建 on 14/12/22.
//  Copyright (c) 2014年 梁建. All rights reserved.
//

#import "ChoseMapViewController.h"

@interface ChoseMapViewController ()
- (void)backToUserLocation;
@property (strong, nonatomic) MKMapView *mapView;
@property (nonatomic , strong) CLLocationManager *mgr;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic,copy)NSString *nameString;
@property (nonatomic,copy)NSString *thoroughfareString;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@implementation ChoseMapViewController

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
        
        UIButton *btn2 =[UIButton buttonWithType:UIButtonTypeSystem];
        btn2.frame=CGRectMake(0, 5, 60, 30);
        btn2.titleLabel.font=[UIFont boldSystemFontOfSize:18.0f];
        [btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn2 setTitle:@"确定" forState:UIControlStateNormal];
        [btn2 addTarget:self action:@selector(sendLocation)forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *back2=[[UIBarButtonItem alloc]initWithCustomView:btn2];
        self.navigationItem.rightBarButtonItem=back2;
        
        
    }
    return self;
}

-(void)goBackAction
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)sendLocation
{
    NSLog(@"发送位置");
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_delegate sendLocationImage:image andLongitude:_longitude andLatitude:_latitude];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (CLGeocoder *)geocoder
{
    if (!_geocoder) {
        self.geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}


-(void)loadView
{
    [super loadView];
    self.title=@"发送位置";
    UIView *view=[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.view=view;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadMapView];
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // iOS8
        CLLocationManager *mgr = [[CLLocationManager alloc] init];
        mgr.delegate = self;
        self.mgr = mgr;
        //[self.mgr requestWhenInUseAuthorization];
        [self.mgr requestAlwaysAuthorization];
        [self.mgr startUpdatingLocation];
    }
    
    // iOS7
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    self.mapView.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)loadMapView
{
    self.mapView=[[MKMapView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:self.mapView];
    UIButton *btn=[[UIButton alloc]initWithFrame:CGRectMake(50, 489, 59, 59)];
    [btn addTarget:self action:@selector(backToUserLocation) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"btn_map_locate"] forState:UIControlStateNormal];
    [self.view addSubview:btn];
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

#pragma mark - MKMapViewDelegate
/**
 *  当用户的位置更新，就会调用（不断地监控用户的位置，调用频率特别高）
 *
 *  @param userLocation 表示地图上蓝色那颗大头针的数据
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    
    
    userLocation.title =self.nameString;
    
    userLocation.subtitle = self.thoroughfareString;
    
    CLLocationCoordinate2D center = userLocation.location.coordinate;
    NSLog(@"%f %f", center.latitude, center.longitude);
    
   
    _longitude = center.longitude;
    _latitude = center.latitude;
    // 设置地图的中心点（以用户所在的位置为中心点）
    //    [mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    // 设置地图的显示范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.021321, 0.019366);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [mapView setRegion:region animated:YES];
}



-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MKPinAnnotationView * piview = (MKPinAnnotationView *)[views objectAtIndex:0];
    [self.mapView selectAnnotation:piview.annotation animated:YES];
}



- (void)backToUserLocation {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied :
        {
            // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
            UIAlertView *tempA = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"请在设置-隐私-定位服务中开启定位功能！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [tempA show];
        }
            break;
        case kCLAuthorizationStatusNotDetermined :
            // Note: Xcode6才有的方法，所以会有警告
            if ([self.mgr respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                NSLog(@"调用");
                [self.mgr respondsToSelector:@selector(requestAlwaysAuthorization)];
            }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
            UIAlertView *tempA = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"定位服务无法使用！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [tempA show];
            
        }
        default:
            
            break;
    }
}

#pragma mark - CLLocationManagerDelegate
/**
 *  只要定位到用户的位置，就会调用（调用频率特别高）
 *  @param locations : 装着CLLocation对象
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
//    NSLog(@"%@",[locations firstObject]);
    
    // 1.取出位置对象
    CLLocation *loc = [locations firstObject];
    
    // 2.取出经纬度
    CLLocationCoordinate2D coordinate = loc.coordinate;
    
    // 3.打印经纬度
    NSLog(@"didUpdateLocations------%f %f", coordinate.latitude, coordinate.longitude);
    
    
    
    // 2.反地理编码
    [self.geocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) { // 有错误（地址乱输入）
            //self.reverseDetailAddressLabel.text = @"你找的地址可能只在火星有！！！";
        } else { // 编码成功
            // 取出最前面的地址
            CLPlacemark *pm = [placemarks firstObject];
            
            // 设置具体地址
            self.nameString=pm.name;
            self.thoroughfareString=[NSString stringWithFormat:@"%@%@%@%@%@",pm.administrativeArea,pm.locality,pm.subLocality,pm.thoroughfare,pm.subThoroughfare];
//            NSLog(@"pm.name%@",pm.name);
//            NSLog(@"pm.thoroughfare%@",pm.thoroughfare);
//            NSLog(@"pm.subThoroughfare%@",pm.subThoroughfare);
//            NSLog(@"pm.locality%@",pm.locality);
//            NSLog(@"pm.subLocality%@",pm.subLocality);
//            NSLog(@"pm.administrativeArea%@",pm.administrativeArea);
            
            
            
        }
    }];
    
    
    
    
    
    
    
    
    
    
    
    
    
}

@end
