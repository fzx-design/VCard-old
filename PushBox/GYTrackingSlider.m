//
//  GYTrackingSlider.m
//  PushBox
//
//  Created by Gabriel Yeah on 11-11-21.
//  Copyright (c) 2011年 同济大学. All rights reserved.
//

#import "GYTrackingSlider.h"
#import "AnimationProvider.h"

@implementation GYTrackingSlider

@synthesize trackPopoverView;
@synthesize thumbRect;

#pragma mark - Private methods

- (void)_constructSlider {
	
	trackPopoverView = [[SliderTrackPopoverView alloc] init];
	
	trackPopoverView.view.hidden = YES;
	
	CGRect _thumbRect = self.thumbRect;
	
	CGRect popupRect = CGRectOffset(_thumbRect, 0, -_thumbRect.size.height);
	
	CGRect frame = trackPopoverView.view.frame;
	frame.origin.x = popupRect.origin.x - 8;
	frame.origin.y = popupRect.origin.y - 20;
	
	trackPopoverView.view.frame = frame;
	
	[self addSubview:trackPopoverView.view];
}

- (void)_fadePopupViewInAndOut:(BOOL)aFadeIn {
	
	if (aFadeIn) {
		trackPopoverView.view.hidden = NO;
		trackPopoverView.view.layer.anchorPoint = CGPointMake(0.5, 1);
		[trackPopoverView.view.layer addAnimation:[AnimationProvider popoverAnimation] forKey:nil];
	} else {
		[UIView animateWithDuration:0.3 animations:^{
			trackPopoverView.view.alpha = 0.0;
		} completion:^(BOOL finished) {
			trackPopoverView.view.hidden = YES;
			trackPopoverView.view.alpha = 1.0;
		}];
	}
	
}

- (void)_positionAndUpdatePopupView {
    CGRect _thumbRect = self.thumbRect;
	
	CGRect popupRect = CGRectOffset(_thumbRect, 0, -_thumbRect.size.height);
	
	CGRect frame = trackPopoverView.view.frame;
	frame.origin.x = popupRect.origin.x - 8;
	frame.origin.y = popupRect.origin.y - 20;
	
	trackPopoverView.view.frame = frame;
}

#pragma mark - Memory management

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self _constructSlider];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _constructSlider];
    }
    return self;
}

- (void)dealloc {
	[trackPopoverView release];
    [super dealloc];
}

#pragma mark - UIControl touch event tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	
	CGPoint touchPoint = [touch locationInView:self];
	
    if(CGRectContainsPoint(self.thumbRect, touchPoint)) {
        [self _positionAndUpdatePopupView];
        [self _fadePopupViewInAndOut:YES]; 
    }
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self _positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self _fadePopupViewInAndOut:NO];
    [super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark - Custom property accessors

- (CGRect)thumbRect {
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbR = [self thumbRectForBounds:self.bounds 
								   trackRect:trackRect
									   value:self.value];
    return thumbR;
}

@end
