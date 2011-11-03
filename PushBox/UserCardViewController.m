//
//  UserCardViewController.m
//  PushBox
//
//  Created by Xie Hasky on 11-7-29.
//  Copyright 2011年 同济大学. All rights reserved.
//

#import "UserCardViewController.h"
#import "User.h"
#import "WeiboClient.h"

@implementation UserCardViewController

@synthesize backButton = _backButton;
@synthesize relationshipStateLabel = _relationshipStateLabel;
@synthesize delegate = _delegate;

@synthesize switchView = _switchView;

- (void)dealloc
{
    NSLog(@"UserCardViewController dealloc");
    
    [_backButton release];
    [_relationshipStateLabel release];
	[_switchView release];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.backButton = nil;
    self.relationshipStateLabel = nil;
	self.switchView = nil;
}

- (id)initWithUsr:(User *)user
{
    self = [super init];
    self.user = user;
    return self;
}

- (void)setRelationshipState
{
    WeiboClient *client = [WeiboClient client];
    
    [client setCompletionBlock:^(WeiboClient *client) {
        NSDictionary *dict = client.responseJSONObject;
        dict = [dict objectForKey:@"target"];
        
        BOOL followedByMe = [[dict objectForKey:@"followed_by"] boolValue];
        BOOL followingMe = [[dict objectForKey:@"following"] boolValue];
        
		[self.switchView setOn:followedByMe animated:YES];
        
        NSString *state = nil;
        if (followingMe) {
            state = [NSString stringWithFormat:NSLocalizedString(@"%@ 正关注你", nil), self.user.screenName];
        }
        else {
            state = [NSString stringWithFormat:NSLocalizedString(@"%@ 未关注你", nil), self.user.screenName];
        }
        self.relationshipStateLabel.text = state;
    }];
    
    [client getRelationshipWithUser:self.user.userID];
}

- (IBAction)atButtonClicked:(id)sender
{
    PostViewController *vc = [[PostViewController alloc] initWithType:PostViewTypePost];
    [[UIApplication sharedApplication] presentModalViewController:vc atHeight:kModalViewHeight];
    vc.textView.text = [[[NSString alloc] initWithFormat:@"@%@ ", self.user.screenName] autorelease];
    
    [vc release];
}

- (void)configureView
{
    [super configureView];
	self.switchView.delegate = self;
	[self.switchView setType:SwitchTypeFollow];
    self.relationshipStateLabel.text = @"";
    [self setRelationshipState];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureView];
}

- (IBAction)backButtonClicked:(id)sender {
	if (self.navigationController.viewControllers.count > 1) {
		[self.navigationController popViewControllerAnimated:YES];
	} else if(self.navigationController.viewControllers.count == 1){
		[UserCardNaviViewController sharedUserCardDismiss];
		[self.delegate userCardViewControllerDidDismiss:self];
	}
}

- (void)switchedOn
{
	WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        
    }];
    [client follow:self.user.userID];
}

- (void)switchedOff
{
	WeiboClient *client = [WeiboClient client];
    [client setCompletionBlock:^(WeiboClient *client) {
        
    }];
    [client unfollow:self.user.userID];
}

@end
