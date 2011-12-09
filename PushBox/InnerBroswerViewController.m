//
//  InnerBroswerViewController.m
//  PushBox
//
//  Created by Kelvin Ren on 10/23/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import "InnerBroswerViewController.h"

@implementation InnerBroswerViewController

@synthesize webView = _webView;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize targetURL = _targetURL;

static InnerBroswerViewController* sharedBrowser = nil;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

+ (InnerBroswerViewController*)browser
{
    @synchronized(self){
        if (sharedBrowser == nil) {
            sharedBrowser = [[[self alloc] init] autorelease];
        }
    }
    return  sharedBrowser;
}

- (void)dealloc
{
    [_webView stopLoading];
    [_webView setDelegate:nil];
    [_webView release];
    [_loadingIndicator release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    MPMusicPlayerController* ipodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
//    if ([ipodMusicPlayer playbackState] == MPMusicPlaybackStatePlaying) {
//        isIpodPlaying = YES;
//    }
//    else {
//        isIpodPlaying = NO;
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.webView = nil;
    self.loadingIndicator = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)loadLink:(NSString*)link
{
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[[[NSURL alloc] initWithString:link] autorelease]];
    [_webView loadRequest:request];
	[request release];
}

- (IBAction)closeButtonClicked:(id)sender
{
    //
    [[UIApplication sharedApplication] dismissModalViewController];
    [self.webView loadRequest:[[[NSURLRequest alloc] initWithURL:[[[NSURL alloc] initWithString:@"about:blank"] autorelease]] autorelease]];
    
//    if (isIpodPlaying) {
//        MPMusicPlayerController* ipodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
//        NSLog(@"%@", [[ipodMusicPlayer nowPlayingItem] description]);
//        [ipodMusicPlayer play];
//    }

    [self release];
}

- (IBAction)goSafariButtonClicked:(id)sender
{
    //    [[UIApplication sharedApplication] openURL:[[self.webView request] URL]];
    NSURL* url = [[NSURL alloc] initWithString:self.targetURL];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator stopAnimating];
}

@end
