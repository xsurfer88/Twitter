//
//  TwitterViewController.h
//  Twitter
//
//  Created by Yang Zi on 9/13/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "mapAnnotation.h"

@interface TwitterViewController : UIViewController <UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    mapAnnotation *selectedAnnotation;
    
    NSTimer *loadTweetsTimer;
}

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@end
