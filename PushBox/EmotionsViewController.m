//
//  EmotionsViewController.m
//  PushBox
//
//  Created by Kelvin Ren on 11/22/11.
//  Copyright (c) 2011 同济大学. All rights reserved.
//

#import "EmotionsViewController.h"
#import "PushBoxAppDelegate.h"
#import "Emotion.h"
#import "UIImageViewAddition.h"

@implementation EmotionsViewController

@synthesize emotions = _emotions;
@synthesize scrollView = _scrollView;
@synthesize pageControl = _pageControl;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -

- (void)initEmotions
{
    // fetch from coredata
    NSManagedObjectContext* context = [(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription                                                  entityForName:@"Emotion" inManagedObjectContext:context];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[[[NSString alloc] initWithFormat:@"category == \"心情\""] autorelease]];
    [request setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]                                                                      initWithKey:@"phrase" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    self.emotions = [NSMutableArray arrayWithArray:array];
}

- (NSString*)emotionClicked:(UIButton *)button
{
    // index
    CGRect frame = button.frame;
    int x = frame.origin.x;
    int y = frame.origin.y;
    int page = x / 204;
    int colum = x % 204 / 34;
    int row = y / 36;
    int index = 24*page+6*row+colum;

    NSString* phrase = [(Emotion*)[self.emotions objectAtIndex:index] phrase];
    
    [self.delegate didSelectEmotion:phrase];
    
    return phrase;
}

- (void)addEmotionAtRow:(int)row colum:(int)colum page:(int)page url:(NSString*)url
{
    // TODO
    int xOffset = 204 * page + 34 * colum;
    int yOffset = 36 * row;
    CGRect frame = CGRectMake(xOffset, yOffset, 34, 36);
    UIImageView* emotionPic = [[UIImageView alloc] initWithFrame:frame];
    [emotionPic setContentMode:UIViewContentModeCenter];
    UIButton* emotionButton = [[UIButton alloc] initWithFrame:frame];
    [emotionButton addTarget:self action:@selector(emotionClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [emotionButton setTag:(24*page+6*row+colum)];
    [emotionPic loadImageFromURL:url completion:^(void){
        [self.scrollView addSubview:emotionPic];
        [self.scrollView addSubview:emotionButton];
    } cacheInContext:[(PushBoxAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]];
//    [emotionPic release];
//    [emotionButton release];
}

- (void)initEmotionPics
{
    for (int i = 0; i < [self.emotions count]; i++) {
        int row = 0;
        int colum = 0;
        int page = 0;
        page = i / 24;
        row = i % 24 / 6;
        colum = i % 24 % 6;
        
        NSString* url = [(Emotion*)[self.emotions objectAtIndex:i] url];
        [self addEmotionAtRow:row colum:colum page:page url:url];
    }
    
    [self.scrollView setContentSize:CGSizeMake(204 * ([self.emotions count]/24 + 1), 144)];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // init _emotions
    [self initEmotions];
    
    // init emotionPics
    [self initEmotionPics];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

@end
