//
//  CommentCell.h
//  Dish by.me
//
//  Created by 전수열 on 12. 9. 22..
//  Copyright (c) 2012년 Joyfl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Comment;

@interface CommentCell : UITableViewCell
{
	Comment *comment;
	
	UIButton *profileImageButton;
	UILabel *nameLabel;
	UILabel *timeLabel;
	UITextView *messageView;
}

@property (nonatomic, retain) Comment *comment;

- (id)initWithResueIdentifier:(NSString *)resueIdentifier;
- (void)loadProfileImage;

@end
