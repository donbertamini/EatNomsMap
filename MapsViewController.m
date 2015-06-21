//
//  MapsViewController.m
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-20.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import "MapsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "MapListViewController.h"
#import "dropPin.h"


@interface MapsViewController ()<CLLocationManagerDelegate>
{
   MKMapView *mapView;
}

@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *manager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (strong, nonatomic) CLPlacemark *placeMark;
@property (weak, nonatomic) IBOutlet UIButton *listButton;

@property (strong, nonatomic) MKLocalSearchResponse *topTen;


@property (weak, nonatomic) IBOutlet UITextField *restNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *restTitleTextField;



@end

@implementation MapsViewController
@synthesize mapView;
@synthesize manager;
@synthesize geoCoder;
@synthesize placeMark;
@synthesize restNameTextField;
@synthesize restTitleTextField;
@synthesize topTen;
@synthesize listButton;


- (void)viewDidLoad {
   [super viewDidLoad];
   listButton.enabled=NO;
   
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

- (IBAction)listClick:(UIButton *)sender {
   
 //  [self.navigationController performSegueWithIdentifier:@"MapToList" sender:self];
   
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
   if ([segue.identifier isEqualToString:@"MapToList"])
   {
      MapListViewController *mapListVC = (MapListViewController *)[segue destinationViewController];
      mapListVC.restList = topTen;
   }
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
   
   // avoid a drag
   if(sender.state == UIGestureRecognizerStateChanged){
     
      return;
   }
   
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
            
//            NSLog(@"Lat: %f",locCoord.latitude);
//            NSLog(@"Log: %f",locCoord.longitude);
            
            [self doSearchwithLatitude:locCoord.latitude :locCoord.longitude];
           
            

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


-(void)doSearchwithLatitude:(float)latitude :(float)longitude{
   NSLog(@"Lat: %f",latitude);
   NSLog(@"Log: %f",longitude);
   
   MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
   [searchRequest setNaturalLanguageQuery:@"Restaurant cafe"];
   CLLocationCoordinate2D restCenter = CLLocationCoordinate2DMake(latitude, longitude);
   MKCoordinateRegion restRegion = MKCoordinateRegionMakeWithDistance(restCenter, 200, 200);
   [searchRequest setRegion:restRegion];
   
   MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
   [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
      
      //NSLog(@"res: %@", response);
      topTen = response;
      
      if (!error) {
         //for (MKMapItem *mapItem in [topTen mapItems]) {
            //NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
           // NSLog(@"Name: %@, MKAnnotation title: %@", [mapItem name], [[mapItem placemark] title]);
           // NSLog(@"Coordinate: %f %f", [[mapItem placemark] coordinate].latitude, [[mapItem placemark] coordinate].longitude);
            //}
          listButton.enabled = YES;
         
         
      } else {
         NSLog(@"Search Request Error: %@", [error localizedDescription]);
         listButton.enabled = NO;
      }
   }];
   
}








@end
