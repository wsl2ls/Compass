
简书地址：http://www.jianshu.com/p/9d9718876663

>高仿系统指南针，方向数据是地磁航向数据，有定位地理位置信息和地磁方向信息，可以和系统的指南针对比看一看。

## 一、运行效果

![总效果](/总效果.gif)
![效果](/效果.jpg)


## 二、实现过程
#### 1.继承于UIView创建一个带刻度标注的视图ScaleView，利用UIBezierPath和CAShapeLayer、UILabel，默认0刻度(北)在最上方。
```
//化刻度表
- (void)paintingScale{
    
    CGFloat perAngle = M_PI/(90);
    NSArray *array = @[@"北",@"东",@"南",@"西"];
     //画圆环，每隔2°画一个弧线，总共180条
    for (int i = 0; i < 180; i++) {
        CGFloat startAngle = (-(M_PI_2+M_PI/180/2)+perAngle*i);
        CGFloat endAngle = startAngle+perAngle/2;
        UIBezierPath *bezPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                               radius:(self.frame.size.width/2 - 50)
                                                           startAngle:startAngle
                                                             endAngle:endAngle
                                                            clockwise:YES];
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
     //每隔30°画一个白条刻度
        if (i%15 == 0) {
            shapeLayer.strokeColor = [[UIColor whiteColor] CGColor];
            shapeLayer.lineWidth = 20;
        }else{
            shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
            shapeLayer.lineWidth = 10;
        }
        shapeLayer.path = bezPath.CGPath;
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [_backgroundView.layer addSublayer:shapeLayer];

        //每隔30°画一个刻度的标注 0 30 60...
        if (i % 15 == 0){
            NSString *tickText = [NSString stringWithFormat:@"%d",i * 2];
            CGFloat textAngel = startAngle+(endAngle-startAngle)/2;
            CGPoint point = [self calculateTextPositonWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                              Angle:textAngel andScale:1.2];
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 30, 15)];
            label.center = point;
            label.text = tickText;
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont systemFontOfSize:15];
            label.textAlignment = NSTextAlignmentCenter;
            [_backgroundView addSubview:label];
            
           //标注 北 东 南 西
            if (i%45 == 0){
                tickText = array[i/45];
                CGPoint point2 = [self calculateTextPositonWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                                   Angle:textAngel andScale:0.8];
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point2.x, point2.y, 30, 20)];
                label.center = point2;
                label.text = tickText;
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont systemFontOfSize:20];
                label.textAlignment = NSTextAlignmentCenter;
                if ([tickText isEqualToString:@"北"]) {
                    UILabel * markLabel = [[UILabel alloc]initWithFrame:CGRectMake(point.x, point.y, 8, 8)];
                    markLabel.center = CGPointMake(point.x, point.y + 12);
                    markLabel.clipsToBounds = YES;
                    markLabel.layer.cornerRadius = 4;
                    markLabel.backgroundColor = [UIColor redColor];
                    [_backgroundView addSubview:markLabel];   
                }
                [_backgroundView addSubview:label];
            }
        }
    } 

     //画十字线，参照线
    UIView *  levelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width/2/2, 1)];
    levelView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    levelView.backgroundColor = [UIColor whiteColor];
    [self addSubview:levelView];
    
    UIView *  verticalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, self.frame.size.width/2/2)];
    verticalView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    verticalView.backgroundColor = [UIColor whiteColor];
    [self addSubview:verticalView];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2 -1.5, self.frame.size.height/2 - (self.frame.size.width/2 - 50) - 50, 3, 30 + 30)];
    lineView.backgroundColor = [UIColor whiteColor];
    [self addSubview:lineView];
}

```
#### 2、利用CLLocationManager初始化定位装置，并设置代理 ，记得在info.plist中加入隐私定位权限关键字 Privacy - Location When In Use Usage Description
```
  // 注意开启手机的定位服务，隐私那里的
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate=self;
    //  定位频率,每隔多少米定位一次
    // 距离过滤器，移动了几米之后，才会触发定位的代理函数
    self.locationManager.distanceFilter = 0;
    // 定位的精度，越精确，耗电量越高
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//导航

    //请求允许在前台获取用户位置的授权
    [self.locationManager requestWhenInUseAuthorization];
    
    //允许后台定位更新,进入后台后有蓝条闪动
    self.locationManager.allowsBackgroundLocationUpdates = YES;
    //判断定位设备是否能用和能否获得导航数据
    if ([CLLocationManager locationServicesEnabled]&&[CLLocationManager headingAvailable]){
        [self.locationManager startUpdatingLocation];//开启定位服务
        [self.locationManager startUpdatingHeading];//开始获得航向数据
    }
    else{
        NSLog(@"不能获得航向数据");
    }
```
> 通过实现定位装置的代理方法：
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading 来获得地理和地磁航向数据，从而转动地理刻度表以及表上的文字标注；
方法-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager返回Yes是为了受到外来磁场干扰时，设备会自动进行校验。

```
#pragma mark - CLLocationManagerDelegate
//获得地理和地磁航向数据，从而转动地理刻度表
-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading{
    //获得当前设备
    UIDevice *device =[UIDevice currentDevice];
    //   判断磁力计是否有效,负数时为无效，越小越精确
    if (newHeading.headingAccuracy>0)
    {
        //地磁航向数据-》magneticHeading
        float magneticHeading =[self heading:newHeading.magneticHeading fromOrirntation:device.orientation];
        //地理航向数据-》trueHeading
        float trueHeading =[self heading:newHeading.trueHeading fromOrirntation:device.orientation];
        //地磁北方向
        float heading = -1.0f *M_PI *newHeading.magneticHeading /180.0f;
        _angleLabel.text = [NSString stringWithFormat:@"%3.1f°",magneticHeading];
        //旋转变换
        [_scaView resetDirection:heading]; 
       //返回当前手机（摄像头)朝向方向
        [self updateHeading:newHeading]; 
    }
}
//判断设备是否需要校验，受到外来磁场干扰时
-(BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return YES;
}
//旋转重置刻度标志的方向
- (void)resetDirection:(CGFloat)heading{
    _backgroundView.transform = CGAffineTransformMakeRotation(heading);
    for (UILabel * label in _backgroundView.subviews) {
        label.transform = CGAffineTransformMakeRotation(-heading);
    }
}
```
#### 3、通过代理方法获得经纬度以及海拔数据，然后利用经纬度进行地理反编码获得地理位置信息。
```
// 定位成功之后的回调方法，只要位置改变，就会调用这个方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    
    self.currLocation = [locations lastObject];
    
    //维纬度
    NSString * latitudeStr = [NSString stringWithFormat:@"%3.2f",
                              _currLocation.coordinate.latitude];
    //经度
    NSString * longitudeStr  = [NSString stringWithFormat:@"%3.2f",
                                _currLocation.coordinate.longitude];
    //高度
    NSString * altitudeStr  = [NSString stringWithFormat:@"%3.2f",
                               _currLocation.altitude];
    
    NSLog(@"纬度 %@  经度 %@  高度 %@", latitudeStr, longitudeStr, altitudeStr);
    
    _latitudlongitudeLabel.text = [NSString stringWithFormat:@"纬度：%@  经度：%@  海拔：%@", latitudeStr, longitudeStr, altitudeStr];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.currLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if ([placemarks count] > 0) {
                           
                           CLPlacemark *placemark = placemarks[0];
                           
                           NSDictionary *addressDictionary =  placemark.addressDictionary;
                           
                           NSString *street = [addressDictionary
                                               objectForKey:(NSString *)kABPersonAddressStreetKey];
                           street = street == nil ? @"": street;
                           
                           NSString *country = placemark.country;
                           
                           NSString * subLocality = placemark.subLocality;
                           
                           NSString *city = [addressDictionary
                                             objectForKey:(NSString *)kABPersonAddressCityKey];
                           city = city == nil ? @"": city;
                           
                           NSLog(@"%@",[NSString stringWithFormat:@"%@ \n%@ \n%@  %@ ",country, city,subLocality ,street]);
                           
                           _positionLabel.text = [NSString stringWithFormat:@" %@\n %@ %@%@ " ,country, city,subLocality ,street];
                           
                       }
                       
                   }];
}
```
![本汪.gif](http://upload-images.jianshu.io/upload_images/1708447-2383c9334e5b5884.gif?imageMogr2/auto-orient/strip)


![点个赞吧.jpg](http://upload-images.jianshu.io/upload_images/1708447-f388dca829704b5d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
