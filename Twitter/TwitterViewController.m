//
//  TwitterViewController.m
//  Twitter
//
//  Created by Yang Zi on 9/13/14.
//
//

#import "TwitterViewController.h"
#import "mapAnnotation.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "TwitterDetailViewController.h"

@interface TwitterViewController ()
@property (nonatomic,strong) NSURLConnection *connection;
@property (nonatomic,strong) NSMutableData *buffer;
@property (nonatomic,strong) NSMutableArray *results;
@property (nonatomic,strong) ACAccountStore *accountStore;

@end
@implementation TwitterViewController
@synthesize mapView;

- (void)viewDidLoad{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 10;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    userLocation = [locationManager location];
    
    mapView.showsUserLocation = YES;
    [mapView setMapType:MKMapTypeStandard];
    [mapView setZoomEnabled:YES];
    [mapView setScrollEnabled:YES];
    self.mapView.delegate = self;
    
    [self loadTweets];
    
    loadTweetsTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(loadTweets) userInfo:nil repeats:YES];
    
}

- (void)viewDidUnload{
    locationManager = nil;
    userLocation = nil;
    selectedAnnotation = nil;
    [self setMapView:nil];
    [loadTweetsTimer invalidate];

    [super viewDidUnload];
   
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    userLocation = newLocation;
    [self loadTweets];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    MKPinAnnotationView *myPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
    myPin.pinColor = MKPinAnnotationColorPurple;
    
    UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [advertButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    myPin.rightCalloutAccessoryView = advertButton;
    myPin.draggable = NO;
    myPin.highlighted = YES;
    myPin.canShowCallout = YES;
    
    return myPin;
    
}

- (void)click:(id)sender{
    
    if (mapView.selectedAnnotations.count == 0)
    {
        //no annotation is currently selected
        return;
    }
    
    id<MKAnnotation> selectedAnn = [mapView.selectedAnnotations objectAtIndex:0];
    
    if ([selectedAnn isKindOfClass:[mapAnnotation class]])
    {
        mapAnnotation *ann = (mapAnnotation *)selectedAnn;
        selectedAnnotation = ann;
    }
    else
    {
        NSLog(@"selected annotation (not a annotation) = %@", selectedAnn);
    }
    
    [self performSegueWithIdentifier:@"detailView" sender:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -
#pragma mark === Text field delegate methods ===
#pragma mark -

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.text)
    {
        [self performSegueWithIdentifier:@"SegueSearchView" sender:textField];
    }
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark === Segue ===
#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailView"])
    {
        TwitterDetailViewController *viewController = segue.destinationViewController;
        viewController.tweet = selectedAnnotation;
    }
}

#pragma mark -

#define RESULTS_COUNT @"100"

- (ACAccountStore *)accountStore
{
    if (_accountStore == nil)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

- (void)loadTweets
{
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             CLLocationCoordinate2D coordinate = [userLocation coordinate];
             
             NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
             NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
            
             NSString *geoCode = [NSString stringWithFormat:@"%@,%@,1mi", latitude, longitude];
             NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
             NSDictionary *parameters = @{@"count" : RESULTS_COUNT,
                                          @"geocode" :geoCode,
                                          @"result_type" : @"recent"};
             
             SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:parameters];
             
             NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
             slRequest.account = [accounts lastObject];
             NSURLRequest *request = [slRequest preparedURLRequest];
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
             });
         }
         else
         {
             
             dispatch_async(dispatch_get_main_queue(), ^{
               
             });
         }
     }];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.buffer = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.buffer appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    
    NSError *jsonParsingError = nil;
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:self.buffer options:0 error:&jsonParsingError];
    
    self.results = jsonResults[@"statuses"];
    
    //NSLog(@"results=%@", self.results);
    [self refresh];
    
    if ([self.results count] == 0)
    {
        NSArray *errors = jsonResults[@"errors"];
        if ([errors count])
        {
            NSLog(@"there is errors");
        }
        else
        {
            NSLog(@"successfully fetch");
        }
    }
    
    self.buffer = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.connection = nil;
    self.buffer = nil;
    
    [self handleError:error];
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)cancelConnection
{
    if (self.connection != nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.connection cancel];
        self.connection = nil;
        self.buffer = nil;
    }
}

-(void)refresh{
    for (NSDictionary *s in self.results){
        
        NSDictionary *tweet = s;
        
        if (tweet[@"geo"] != NULL && tweet[@"geo"]  != [ NSNull null ] ){
        NSDictionary *geo = tweet[@"geo"];
        NSArray *coordinate = geo[@"coordinates"];
        NSString *latitude = coordinate[0];
        NSString *longitude = coordinate[1];
        
        double miles = 1.0;
        double scalingFactor =
        ABS( cos(2 * M_PI * userLocation.coordinate.latitude /360.0) );
        
        MKCoordinateSpan span;
        span.latitudeDelta = miles/69.0;
        span.longitudeDelta = miles/( scalingFactor*69.0 );
        
        MKCoordinateRegion region;
        region.span = span;
        region.center = userLocation.coordinate;
        
        [mapView setRegion:region animated:YES];
        mapView.showsUserLocation = YES;

        MKCoordinateRegion userRegion = { {0.0, 0.0}, {0.0, 0.0} };
        userRegion.center.latitude = [latitude doubleValue];
        userRegion.center.longitude = [longitude doubleValue];
           
        userRegion.span.longitudeDelta = 0.02f;
        userRegion.span.latitudeDelta = 0.02f;
        
        mapAnnotation *ann= [[mapAnnotation alloc] init];
        ann.coordinate = userRegion.center;
        ann.tweetId = tweet[@"id"];
        ann.title = tweet[@"text"];
        NSDictionary *user = tweet[@"user"];
        ann.subtitle = user[@"name"];
        ann.avatar = user[@"profile_image_url"];
        ann.createdAt = tweet[@"created_at"];
        
        [mapView addAnnotation:ann];
        }
    }
}
@end
