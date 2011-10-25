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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super release];
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
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:link]];
    [_webView loadRequest:request];
}

- (IBAction)closeButtonClicked:(id)sender
{
    //
    [[UIApplication sharedApplication] dismissModalViewController];
    [self.webView loadRequest:[[NSURLRequest alloc] initWithURL:[[NSURL alloc] initWithString:@"about:blank"]]];
    MPMusicPlayerController* ipodMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    NSLog(@"%@", [[ipodMusicPlayer nowPlayingItem] description]);
    [ipodMusicPlayer play];

    [self release];
}

- (IBAction)goSafariButtonClicked:(id)sender
{
    [[UIApplication sharedApplication] openURL:[[self.webView request] URL]];
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
