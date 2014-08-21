//
//  QYViewController.m
//  MapViewSample
//
//  Created by QingYun on 14-7-15.
//  Copyright (c) 2014年 河南青云信息技术有限公司. All rights reserved.
//

#import "QYViewController.h"
#import <MapKit/MapKit.h>
#import "QYMKAboutMeAnnotationView.h"


@interface QYViewController () <CLLocationManagerDelegate,MKMapViewDelegate>

@property (nonatomic, retain)  CLLocationManager *locationMgr;
@end

@implementation QYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    MKMapView *mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    mapView.tag = 1000;
    
//    span 指的是显示地图精确度，值越小显示的地图数据越精确，越详细，如果值越大， 则显示的区域越大
    MKCoordinateSpan span = {10,10};
//    结构体的第二种赋值方法
//    MKCoordinateSpan span2;
//    span2.latitudeDelta = 100;
//    span2.longitudeDelta = 100;
    
//    采用C函数来创建结构体的具体数据
//    MKCoordinateSpan span3;
//    span3 = MKCoordinateSpanMake(100, 100);
    
    /*
     *在OC环境下 对于结构体变量的赋值，有三种方式：
     1､初始化的时候， 直接采用花括号语法， 在花括里，按结构体声明的顺序依次赋值
     2､先声明结构体变量，可以使用点语法，来指定相对应的成员变量的值
     3､采用SDK的C 函数直接完成设置
     */
    
    
//    是地图当前显示位置的地理坐标
//    CLLocationCoordinate2D coordinate = {34,113};
    CLLocationCoordinate2D coordinate;
    coordinate = CLLocationCoordinate2DMake(34.7568711, 113.663221);
    
//    地理位置反编码类， 如果想要反编码， 需要实例这个对象
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
//    具体需要反编码的位置对象， 主要包含的是地理坐标
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
//    执行反编码动作， 这个动作是异步执行的， 当执行反编码完成之后， 会调用block
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error != nil) {
            NSLog(@"Erro:%@",error);
            return;
        }
        
//          CLPlacemark对象，主要描述的是具体的行政区域详细描述， 目前只需要掌握如何解出国家， 省份， 城市，街道即可。
        for (CLPlacemark *placeMark in placemarks) {
            NSLog(@"=======%@,%@,%@,%@,%@",placeMark.country,placeMark.administrativeArea,placeMark.locality,placeMark.thoroughfare,placeMark.subAdministrativeArea);
        }
    }];
    
//    地图上的显示区域
    MKCoordinateRegion region = {coordinate,span};
    
    mapView.region = region;
    mapView.showsUserLocation = YES;
//    mapView.zoomEnabled = NO;
//    mapView.scrollEnabled = NO;
//    显示卫星地图
//    mapView.mapType = MKMapTypeSatellite;
//    显示卫星地图和标准地图的混合
//    mapView.mapType = MKMapTypeHybrid;
//    显示标准也就是普通地图，这是默认地图类型
    mapView.mapType = MKMapTypeStandard;
    mapView.delegate = self;
    [self.view addSubview:mapView];
    
    self.locationMgr = [[CLLocationManager alloc] init];
//    当设备移动每超过100米，才会更新一次位置信息。
    self.locationMgr.distanceFilter = 1;
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationMgr.delegate = self;
    
    [self.locationMgr startUpdatingLocation];
    
//    注解类，用于提供注解数据，真正用于显示注解视图，需要在委托方法去创建
    MKPointAnnotation *pointAnnotaion = [[MKPointAnnotation alloc] init];
    pointAnnotaion.title = @"河南省";
    pointAnnotaion.subtitle = @"郑州市";
    pointAnnotaion.coordinate = CLLocationCoordinate2DMake(34.7568711, 113.663221);
    
    [mapView addAnnotation:pointAnnotaion];

}

#pragma mark -
#pragma mark CLLocationManagerDelegate
//第二个参数， 表示当位置更新的时候， 新位置信息。
//第三个参数，表示位置更新时， 老的位置信息。

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"newLocation's lat:%f,long:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    NSLog(@"oldLocation's lat:%f,long:%f",oldLocation.coordinate.latitude,oldLocation.coordinate.longitude);
    
    //    CLLocationCoordinate2D coordinate2;
    //    coordinate2 = CLLocationCoordinate2DMake(34.7568711, 113.663221);
    
    MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
    //    地图上的显示区域
    MKCoordinateRegion region = {newLocation.coordinate,span};
    
    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:1000];
    [mapView setRegion:region animated:YES];

//    计算两个位置的相隔距离， 单位是米
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    NSLog(@"郑州距苹果总部的距离是:%f",distance/1000);
    
//    调用此方法， 是终止位置管理器更新位置信息，在实际应用中， 一定调用这个方法， 解决设备耗电量问题。
//    [self.locationMgr stopUpdatingLocation];
}

//- (void)locationManager:(CLLocationManager *)manager
//	 didUpdateLocations:(NSArray *)locations
//{
//    NSLog(@"%@",NSStringFromSelector(_cmd));
////    数组locations的最后一个元素， 是最新的位置信息
//    CLLocation *newLocation = locations[0];
//    MKCoordinateSpan span = MKCoordinateSpanMake(1, 1);
//    //    地图上的显示区域
//    MKCoordinateRegion region = {newLocation.coordinate,span};
//    
//    MKMapView *mapView = (MKMapView*)[self.view viewWithTag:1000];
//    [mapView setRegion:region animated:YES];
//}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
    
    NSLog(@"%@",error);
}


#pragma mark -
#pragma mark MKMapViewDelegate

//当MKMapView的实例， 调用addAnnotation的时候 ，这个方法会被调用
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    /*
    static NSString *pinViewIndentifier = @"pinViwe";
    MKPinAnnotationView *pinView =(MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pinViewIndentifier];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinViewIndentifier];
    }
    //        修改大头针的显示颜色
    pinView.pinColor = MKPinAnnotationColorPurple;
    //        让大头针出现的时候， 展现从天而降的效果
    pinView.animatesDrop = YES;
    //        如果想要展示上述效果， 需要设置canShowCallout为yes
    pinView.canShowCallout = YES;
     */
    
    static NSString *customViewIndentifier = @"CustomMKAnnotaitonView";
    QYMKAboutMeAnnotationView *customAnnotationView =(QYMKAboutMeAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:customViewIndentifier];
    if (nil == customAnnotationView) {
        customAnnotationView = [[QYMKAboutMeAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customViewIndentifier];
    }
    
//   在这里可以绘制， 注解视图上显示的内容
//    也可以直接封装到自定义的注解视图中

    
    return customAnnotationView;
}


- (void)onButton
{
    UIAlertView *alertView =[ [UIAlertView alloc] initWithTitle:@"Test" message:@"customAnnotation" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil , nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
