//
//  SmartCardViewController.h
//  PushBox
//
//  Created by Ren Kelvin on 10/18/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import "CoreDataViewController.h"
#import "UserCardViewController.h"
#import "UserCardNaviViewController.h"
#import "DetailImageViewController.h"
#import "CommentsTableViewController.h"
#import "CommentViewController.h"
#import "PostViewController.h"
#import "InnerBroswerViewController.h"
#import "UIAudioAddition.h"
#import "FXLabel.h"
#import <MessageUI/MessageUI.h>

#define kNotificationNameModalCardPresented @"kNotificationNameModalCardPresented"
#define kNotificationNameModalCardDismissed @"kNotificationNameModalCardDismissed"
#define kNotificationNameCardDeleted @"kNotificationNameCardDeleted"
#define kNotificationNameCardShouldDeleteCard @"kNotificationNameCardShouldDeleteCard"
#define kNotificationNameCardShouldUnfavorCard @"kNotificationNameCardShouldUnfavorCard"

#define kIPad1CoverOffset 20

@class Status;

@interface SmartCardViewController : CoreDataViewController<DetailImageViewControllerDelegate, 
UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UserCardViewControllerDelegate, CommentsTableViewControllerDelegate, UIWebViewDelegate> {
    UIImageView *_profileImageView;
    UILabel *_screenNameLabel;
    UILabel *_dateLabel;
    UIButton *_actionsButton;
    UILabel *_repostCountLabel;
    UILabel *_commentCountLabel;
    UIButton *_addFavourateButton;
	UIScrollView *_tweetScrollView;
    UIImageView *_tweetImageView;
	UITextView *_tweetTextView;
    UIWebView *_postWebView;
    UIWebView *_repostWebView;
	UITextView *_repostTextView;
	UIImageView *_repostView;
    UILabel *_trackLabel;
    UIView *_trackView;
    FXLabel *_trackLabel2;
    UIView *_trackView2;
    FXLabel *_trackLabel1;
    UIView *_trackView1;
    FXLabel *_trackLabel3;
    UIView *_trackView3;
    FXLabel *_trackLabel4;
    UIView *_trackView4;
    UIImageView *_imageCoverImageView;
    UIImageView *_musicBackgroundImageView;
    UIImageView *_musicCoverImageView;
    UIImageView *_gifIcon;
    UIButton *_playButton;
    UILabel *_recentActNotifyLabel;
    UILabel *_locationLabel;
    UIImageView *_locationIconImageView;
    
    Boolean isTrack;
    
    NSString *_musicLink;
    
    Status *_status;
	
    UIImageView *_readImageView;
    UIImageView* _iPad1Cover;
    
    int b;
    
    Boolean isLoadTrackEnd;
}

@property(nonatomic, retain) IBOutlet UIImageView* profileImageView;
@property(nonatomic, retain) IBOutlet UIImageView* gifIcon;
@property(nonatomic, retain) IBOutlet UILabel* screenNameLabel;
@property(nonatomic, retain) IBOutlet UILabel* dateLabel;
@property(nonatomic, retain) IBOutlet UIButton* actionsButton;
@property(nonatomic, retain) IBOutlet UILabel* repostCountLabel;
@property(nonatomic, retain) IBOutlet UILabel* commentCountLabel;
@property(nonatomic, retain) IBOutlet UIButton* addFavourateButton;
@property(nonatomic, retain) IBOutlet UIScrollView* tweetScrollView;
@property(nonatomic, retain) IBOutlet UIImageView* tweetImageView;
@property(nonatomic, retain) IBOutlet UITextView* tweetTextView;
@property(nonatomic, retain) IBOutlet UIWebView* postWebView;
@property(nonatomic, retain) IBOutlet UIWebView* repostWebView;
@property(nonatomic, retain) IBOutlet UITextView* repostTextView;
@property(nonatomic, retain) IBOutlet UIImageView* repostView;
@property(nonatomic, retain) IBOutlet UIImageView* locationIconImageView;
@property(nonatomic, retain) IBOutlet UILabel* locationLabel;
@property(nonatomic, retain) IBOutlet UIView* trackView;
@property(nonatomic, retain) IBOutlet UILabel* trackLabel;
@property(nonatomic, retain) IBOutlet UIView* trackView1;
@property(nonatomic, retain) IBOutlet FXLabel* trackLabel1;
@property(nonatomic, retain) IBOutlet UIView* trackView2;
@property(nonatomic, retain) IBOutlet FXLabel* trackLabel2;
@property(nonatomic, retain) IBOutlet UIView* trackView3;
@property(nonatomic, retain) IBOutlet FXLabel* trackLabel3;
@property(nonatomic, retain) IBOutlet UIView* trackView4;
@property(nonatomic, retain) IBOutlet FXLabel* trackLabel4;
@property(nonatomic, retain) IBOutlet UIImageView* imageCoverImageView;
@property(nonatomic, retain) IBOutlet UIImageView* musicBackgroundImageView;
@property(nonatomic, retain) IBOutlet UIImageView* musicCoverImageView;
@property(nonatomic, retain) IBOutlet UIButton* playButton;
@property(nonatomic, retain) IBOutlet UILabel* recentActNotifyLabel;

@property (nonatomic, retain) IBOutlet UIImageView* readImageView;
@property (nonatomic, retain) IBOutlet UIImageView* iPad1Cover;

@property(nonatomic, retain) NSString* musicLink;

@property(nonatomic, retain) Status* status;

- (void)clear;

- (void)reloadSmartCard;

- (IBAction)actionsButtonClicked:(UIButton *)sender;
- (IBAction)profileImageButtonClicked:(id)sender;
- (IBAction)commentButtonClicked:(id)sender;
- (IBAction)repostButtonClicked:(id)sender;
- (IBAction)addFavButtonClicked:(UIButton *)sender;
- (IBAction)askOwnerButtonClicked:(UIButton *)sender;

@end
