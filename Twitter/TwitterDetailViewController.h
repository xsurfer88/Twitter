//
//  TwitterDetailViewController.h
//  Twitter
//
//  Created by Yang Zi on 9/14/14.
//
//

#import <UIKit/UIKit.h>
#import "mapAnnotation.h"

@interface TwitterDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *createdDate;
@property (strong, nonatomic) IBOutlet UILabel *tweetText;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (strong, nonatomic) mapAnnotation *tweet;
@property (strong, nonatomic) IBOutlet UIButton *tweetTapped;
@property (strong, nonatomic) IBOutlet UIButton *favorite;
@end
