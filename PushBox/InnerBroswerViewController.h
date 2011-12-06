//
//  InnerBroswerViewController.h
//  PushBox
//
//  Created by Kelvin Ren on 10/23/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIApplicationAddition.h"
#import <MediaPlayer/MPMusicPlayerController.h>

@interface InnerBroswerViewController : UIViewController<UIWebViewDelegate>
{
    UIWebView *_webView;
    
    UIActivityIndicatorView *_loadingIndicator;
    
    BOOL isIpodPlaying;
    
    NSString* _targetURL;
}

- (void)loadLink:(NSString*)link;

- (IBAction)closeButtonClicked:(id)sender;
- (IBAction)goSafariButtonClicked:(id)sender;

@property (nonatomic, retain) IBOutlet UIWebView* webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (nonatomic, retain) NSString* targetURL;

@end
