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
	Comment *_comment;
	NSIndexPath *_indexPath;
	
	UIImageView *_lineView;
	UIButton *_profileImageButton;
	UILabel *_nameLabel;
	UILabel *_timeLabel;
	UILabel *_messageLabel;
}

@property (nonatomic, readonly) Comment *comment;

- (id)initWithResueIdentifier:(NSString *)resueIdentifier;
- (void)setComment:(Comment *)comment atIndexPath:(NSIndexPath *)indexPath;

@end
