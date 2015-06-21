//
//  MapListViewController.h
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-21.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapListViewController : UIViewController

@property (nonatomic, strong) MKLocalSearchResponse *restList;

@end
