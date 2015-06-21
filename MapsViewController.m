//
//  MapsViewController.m
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-20.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import "MapsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "dropPin.h"


@interface MapsViewController ()<CLLocationManagerDelegate>
{
   MKMapView *mapView;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLPlacemark *placeMark;

@end

@implementation MapsViewController
@synthesize mapView;
@synthesize manager;
@synthesize geoCoder;
@synthesize placeMark;

- (void)viewDidLoad {
   [super viewDidLoad];
   if(manager == nil){
      manager = [CLLocationManager new];
   }
   manager.delegate = self;
   manager.desiredAccuracy = kCLLocationAccuracyBest;
   [manager requestWhenInUseAuthorization];
   [manager startUpdatingLocation];
   
   geoCoder = [[CLGeocoder alloc]init];
}

-(void)viewDidAppear:(BOOL)animated{
   [super viewDidAppear:animated];
   
   UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
   [self.mapView addGestureRecognizer:longPressGesture];
   
}


#pragma mark - CLLocation Manager
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
   NSLog(@"location manager failed: %@", error);
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

   [self.manager stopUpdatingLocation];
   
   CLLocation *currentLocation = locations.lastObject;
   
   mapView.showsUserLocation=YES;
   
   MKCoordinateRegion myRegion = {{0.0,0.0},{0.0,0.0}};
   myRegion.center.latitude = currentLocation.coordinate.latitude;
   myRegion.center.longitude = currentLocation.coordinate.longitude;
   myRegion.span.longitudeDelta = 0.05f;
   myRegion.span.latitudeDelta = 0.05f;
   [mapView setRegion:myRegion animated:YES];
   
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
   
   // remove the previous pin to replace
  if(sender.state == UIGestureRecognizerStateBegan)
      [mapView removeAnnotations:[mapView annotations]];

   // This is important if you only want to receive one tap and hold event
   if (sender.state == UIGestureRecognizerStateEnded)
   {
      

   }
   else
   {
      // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
      CGPoint point = [sender locationInView:self.mapView];
      CLLocationCoordinate2D locCoord = [mapView convertPoint:point toCoordinateFromView:mapView];
      // Then all you have to do is create the annotation and add it to the map
      dropPin *ann = [[dropPin alloc]init];
      ann.title = @"Restuarant";
      ann.subTitle = @"Subtitle";
      
      [ann setCoordinate:locCoord];
      
     CLLocation *thisLocation = [[CLLocation alloc] initWithLatitude:locCoord.latitude longitude:locCoord.longitude];
  
      [self.mapView addAnnotation:ann];
      
      [geoCoder reverseGeocodeLocation:thisLocation completionHandler:^(NSArray *placemarks, NSError *error) {
         if(error == nil && [placemarks count]>0){
            placeMark = [placemarks lastObject];
            
            NSLog(@"Lat: %f",locCoord.latitude);
            NSLog(@"Log: %f",locCoord.longitude);

            NSLog(@"%@ %@\n%@ %@\n%@ %@", placeMark.subThoroughfare,placeMark.thoroughfare, placeMark.locality
                  , placeMark.administrativeArea, placeMark.country, placeMark.postalCode);
            

         }
         else
            NSLog(@"error: %@,", error);
      }];

   }
}

- (void)removeAllPinsButUserLocation1
{
   id userLocation = [mapView userLocation];
   [mapView removeAnnotations:[mapView annotations]];
   
   if ( userLocation != nil ) {
      [mapView addAnnotation:userLocation]; // will cause user location pin to blink
   }
}




@end
