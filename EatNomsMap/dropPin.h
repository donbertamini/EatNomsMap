//
//  dropPin.h
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-20.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface dropPin : NSObject <MKAnnotation>{
   
   CLLocationCoordinate2D coordinate;
   NSString *title;
   NSString *subTitle;

  
   
}

@property (nonatomic, assign)CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subTitle;
@property (nonatomic, copy) NSString *title;



@end
