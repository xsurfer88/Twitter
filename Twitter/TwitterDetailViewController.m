//
//  TwitterDetailViewController.m
//  Twitter
//
//  Created by Yang Zi on 9/14/14.
//
//

#import "TwitterDetailViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface TwitterDetailViewController ()

@end

@implementation TwitterDetailViewController

@synthesize  userName, createdDate, tweetText, avatarImageView, tweet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    userName.text = tweet.subtitle;
    createdDate.text = tweet.createdAt;
    
    tweetText.text = tweet.title;
    tweetText.textAlignment = NSTextAlignmentLeft;
    [tweetText setNumberOfLines:0];
    [tweetText sizeToFit];
    
    if ([tweet.avatar length] > 0 ){
        NSURL *url = [NSURL URLWithString:tweet.avatar];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *img = [[UIImage alloc] initWithData:data];
        avatarImageView.image = img;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tweetTapped:(id)sender {
    [self retweet];
}

- (void) retweet
{
    // Request access to the Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating a request to get the info about a user on Twitter
                
               SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweet.tweetId]] parameters:nil];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we reached the reate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSDictionary *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            NSLog(@"twdata=%@", TWData);
                            
                            if (error != nil){
                                NSString *errorMessage = @"There are errors on retweeting";
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Retweet" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alertView show];
                            }else {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Retweet" message:@"Retweet successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alertView show];
                            }
                            
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}

- (IBAction)favoriteTapped:(id)sender {
    // Request access to the Twitter accounts
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error){
        if (granted) {
            
            NSArray *accounts = [accountStore accountsWithAccountType:accountType];
            
            // Check if the users has setup at least one Twitter account
            
            if (accounts.count > 0)
            {
                ACAccount *twitterAccount = [accounts objectAtIndex:0];
                
                // Creating a request to get the info about a user on Twitter
                
                SLRequest *twitterInfoRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/favorites/create.json?id=%@", tweet.tweetId]] parameters:nil];
                [twitterInfoRequest setAccount:twitterAccount];
                
                // Making the request
                
                [twitterInfoRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // Check if we reached the reate limit
                        
                        if ([urlResponse statusCode] == 429) {
                            NSLog(@"Rate limit reached");
                            return;
                        }
                        
                        // Check if there was an error
                        
                        if (error) {
                            NSLog(@"Error: %@", error.localizedDescription);
                            return;
                        }
                        
                        // Check if there is some response data
                        
                        if (responseData) {
                            
                            NSError *error = nil;
                            NSDictionary *TWData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
                            
                            NSLog(@"twdata=%@", TWData);
                           
                            if (error != nil){
                                NSString *errorMessage = @"There are errors on favoriting";
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Favorite" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alertView show];
                            }else {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Favorite" message:@"Favorite successfully!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                [alertView show];
                            }
                        }
                    });
                }];
            }
        } else {
            NSLog(@"No access granted");
        }
    }];
}
@end
