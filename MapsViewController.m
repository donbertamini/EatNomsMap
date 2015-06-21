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
@property (strong, nonatomic) NSArray *topTen;

@property (weak, nonatomic) IBOutlet UITextField *restNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *restTitleTextField;

@property (nonatomic, strong) NSString *currentName;
@property (nonatomic, strong) NSString *currentTitle;
@property (nonatomic, assign) float currentLatitude;
@property (nonatomic, assign) float currentLongitude;


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
@synthesize currentName;
@synthesize currentTitle;
@synthesize currentLatitude;
@synthesize currentLongitude;


#pragma mark - View Conroller Life Cycle
- (void)viewDidLoad {
   [super viewDidLoad];
   listButton.enabled=NO;
   geoCoder = [[CLGeocoder alloc]init];
   mapView.showsUserLocation=YES;
   
   UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
   [self.mapView addGestureRecognizer:longPressGesture];
}

-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:animated];
   
   // monica CLLocation *lastLoc = [[CLLocation alloc] initWithLatitude:18.940500 longitude:-99.262535];
   
   NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
   float lastRegionDelta = [pref floatForKey:@"lastRegionDelta"];
   float lastLatitude = [pref floatForKey:@"lastLatitude"];
   float lastLongitude = [pref floatForKey:@"lastLongitude"];
   CLLocation *lastLoc = [[CLLocation alloc] initWithLatitude:lastLatitude longitude:lastLongitude];
   
   MKCoordinateRegion myRegion = {{0.0,0.0},{0.0,0.0}};
   myRegion.center.latitude = lastLoc.coordinate.latitude;
   myRegion.center.longitude = lastLoc.coordinate.longitude;
   myRegion.span.longitudeDelta = lastRegionDelta;
   myRegion.span.latitudeDelta = lastRegionDelta;
   [mapView setRegion:myRegion animated:YES];
   
}

-(void)viewWillDisappear:(BOOL)animated{
   [super viewWillDisappear:animated];
   
   // save map size and location
   NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
   if(pref){
      float lastRegionDelta = mapView.region.span.latitudeDelta;
      float lastLatitude = mapView.region.center.latitude;
      float lastLongitude = mapView.region.center.longitude;
      
      [pref setFloat:lastRegionDelta forKey:@"lastRegionDelta"];
      [pref setFloat:lastLatitude forKey:@"lastLatitude"];
      [pref setFloat:lastLongitude forKey:@"lastLongitude"];
      [pref synchronize];
   }

}

-(void)viewDidAppear:(BOOL)animated{
   [super viewDidAppear:animated];
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
   if ([segue.identifier isEqualToString:@"MapToList"])
   {
      MapListViewController *mapListVC = (MapListViewController *)[segue destinationViewController];
      mapListVC.restList = topTen;
   }
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
            
            [self doSearchwithLatitude:locCoord.latitude :locCoord.longitude];
           
         }
         else
            NSLog(@"error: %@,", error);
      }];

   }
}

// fill out the 4 current values
-(void)doSearchwithLatitude:(float)latitude :(float)longitude{
   
   MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
   [searchRequest setNaturalLanguageQuery:@"Restaurant cafe"];
   CLLocationCoordinate2D restCenter = CLLocationCoordinate2DMake(latitude, longitude);
   MKCoordinateRegion restRegion = MKCoordinateRegionMakeWithDistance(restCenter, 200, 200);
   [searchRequest setRegion:restRegion];
   
   MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
   [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
      
      // capture the array of mapItems for a table
      topTen = [response mapItems];
      
      if (!error) {
//         for (MKMapItem *mapItem in [response mapItems]) {
//            //NSLog(@"Name: %@, Placemark title: %@", [mapItem name], [[mapItem placemark] title]);
//            //NSLog(@"Name: %@, MKAnnotation title: %@", [mapItem name], [[mapItem placemark] title]);
//            //NSLog(@"Coordinate: %f %f", [[mapItem placemark] coordinate].latitude, [[mapItem placemark] coordinate].longitude);
//         }
         
      
         
         // grab the first record and populate some current values and 2 text fields
         MKMapItem *firstItem = [[response mapItems]firstObject];
         currentName = [firstItem name];
         restNameTextField.text = currentName;
         currentTitle = [[firstItem placemark] title];
         restTitleTextField.text = currentTitle;
         
         // current latitude stays exactly where pin dropped but can change if saved from list.
         currentLatitude =  latitude; //[[firstItem placemark] coordinate].latitude;
         currentLongitude = longitude;  //[[firstItem placemark] coordinate].longitude;
         NSLog(@"cl: %f", currentLatitude);
         NSLog(@"cl: %f", currentLongitude);
         listButton.enabled = YES;
         
         
      } else {
         NSLog(@"Search Request Error: %@", [error localizedDescription]);
         listButton.enabled = NO;
         currentName = @"";
         restNameTextField.text = currentName;
         currentTitle = @"";
         restTitleTextField.text = currentTitle;
      }
   }];
   
}








@end
