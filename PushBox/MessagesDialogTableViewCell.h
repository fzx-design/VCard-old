//
//  MessagesDialogTableViewCell.h
//  PushBox
//
//  Created by Ren Kelvin on 10/11/11.
//  Copyright 2011 同济大学. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessagesDialogTableViewCell : UITableViewCell
{
    UITextView* _fromTextView;
    UITextView* _toTextView;
    UIImageView* _fromTopImageView;
    UIImageView* _fromCenterImageView;
    UIImageView* _fromButtomImageView;
    UIImageView* _toTopImageView;
    UIImageView* _toCenterImageView;
    UIImageView* _toButtomImageView;
}

@property (nonatomic, retain) IBOutlet UITextView* fromTextView;
@property (nonatomic, retain) IBOutlet UITextView* toTextView;

@property (nonatomic, retain) IBOutlet UIImageView* fromTopImageView;
@property (nonatomic, retain) IBOutlet UIImageView* fromCenterImageView;
@property (nonatomic, retain) IBOutlet UIImageView* fromButtomImageView;
@property (nonatomic, retain) IBOutlet UIImageView* toTopImageView;
@property (nonatomic, retain) IBOutlet UIImageView* toCenterImageView;
@property (nonatomic, retain) IBOutlet UIImageView* toButtomImageView;

@end
