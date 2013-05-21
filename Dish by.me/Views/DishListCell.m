//
//  DishListCell.m
//  Dish by.me
//
//  Created by 전수열 on 13. 1. 6..
//  Copyright (c) 2013년 Joyfl. All rights reserved.
//

#import "DishListCell.h"
#import "Utils.h"
#import <QuartzCore/CALayer.h>
#import "CurrentUser.h"
#import "DMAPILoader.h"

@implementation DishListCell

static const NSInteger PhotoViewMaxLength = 292;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor clearColor];
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	_photoView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 12, 292, 292 )];
	_photoView.image = [UIImage imageNamed:@"placeholder.png"];
	_photoView.userInteractionEnabled = YES;
	[_photoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoViewDidTap)]];
	[self.contentView addSubview:_photoView];
	
	UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, 320, 350 )];
	frameView.image = [UIImage imageNamed:@"dish_border_big.png"];
	[self.contentView addSubview:frameView];
	
	_topGradientView = [[UIImageView alloc] initWithFrame:CGRectMake( 14, 12, 292, 35)];
	_topGradientView.image = [UIImage imageNamed:@"dish_border_gradient.png"];
	_topGradientView.alpha = 0;
	[self.contentView addSubview:_topGradientView];
	
	_userPhotoButton = [[UIButton alloc] initWithFrame:CGRectMake( 21, 19, 25, 25 )];
	_userPhotoButton.adjustsImageWhenHighlighted = NO;
	[_userPhotoButton setImage:[UIImage imageNamed:@"profile_thumbnail_border_list.png"] forState:UIControlStateNormal];
	[_userPhotoButton addTarget:self action:@selector(userPhotoButtonDidTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
	_userPhotoButton.layer.cornerRadius = 4;
	_userPhotoButton.clipsToBounds = YES;
	_userPhotoButton.alpha = 0;
	[self addSubview:_userPhotoButton];
	
	_userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 50, 18, 240, 25 )];
	_userNameLabel.textColor = [UIColor colorWithHex:0xFFFEFA alpha:1];
	_userNameLabel.backgroundColor = [UIColor clearColor];
	_userNameLabel.font = [UIFont systemFontOfSize:12];
	_userNameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.3];
	_userNameLabel.shadowOffset = CGSizeMake( 0, 1 );
	_userNameLabel.alpha = 0;
	[self.contentView addSubview:_userNameLabel];
	
	_commentIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 22, 280, 13, 17 )];
	_commentIconView.image = [UIImage imageNamed:@"icon_comment.png"];
	[self.contentView addSubview:_commentIconView];
	
	_commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 35, 280, 25, 13 )];
	_commentCountLabel.textColor = [UIColor whiteColor];
	_commentCountLabel.backgroundColor = [UIColor clearColor];
	_commentCountLabel.font = [UIFont fontWithName:@"SegoeUI-Bold" size:13];
	_commentCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_commentCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	_commentCountLabel.textAlignment = NSTextAlignmentCenter;
	[self.contentView addSubview:_commentCountLabel];
	
	_bookmarkIconView = [[UIImageView alloc] initWithFrame:CGRectMake( 59, 280, 13, 17 )];
	[self.contentView addSubview:_bookmarkIconView];
	
	_bookmarkCountLabel = [[UILabel alloc] initWithFrame:CGRectMake( 71, 280, 25, 13 )];
	_bookmarkCountLabel.textColor = [UIColor whiteColor];
	_bookmarkCountLabel.backgroundColor = [UIColor clearColor];
	_bookmarkCountLabel.font = [UIFont fontWithName:@"SegoeUI-Bold" size:13];
	_bookmarkCountLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_bookmarkCountLabel.shadowOffset = CGSizeMake( 0, 1 );
	_bookmarkCountLabel.textAlignment = NSTextAlignmentCenter;
	[self.contentView addSubview:_bookmarkCountLabel];
	
	_dishNameLabel = [[UILabel alloc] initWithFrame:CGRectMake( 16, 312, 225, 20 )];
	_dishNameLabel.textColor = [UIColor colorWithHex:0x58595A alpha:1];
	_dishNameLabel.font = [UIFont boldSystemFontOfSize:16];
	_dishNameLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.1];
	_dishNameLabel.shadowOffset = CGSizeMake( 0, 1 );
	[self.contentView addSubview:_dishNameLabel];
	
	_bookmarkButton = [[BookmarkButton alloc] init];
	_bookmarkButton.delegate = self;
	_bookmarkButton.parentView = self.contentView;
	_bookmarkButton.position = CGPointMake( 310, 311 );
	
	return self;
}

#pragma mark -
#pragma mark Getter/Setter

- (Dish *)dish
{
	return _dish;
}

- (void)setDish:(Dish *)dish atIndexPath:(NSIndexPath *)indexPath
{
	_dish = dish;
	_indexPath = indexPath;
	[self fillContents];
}

- (void)fillContents
{
	[_userPhotoButton setBackgroundImageWithURL:[NSURL URLWithString:_dish.userPhotoURL] placeholderImage:[UIImage imageNamed:@"profile_placeholder.png"] forState:UIControlStateNormal];
	
	if( _dish.croppedThumbnail )
	{
		_photoView.image = _dish.croppedThumbnail;
	}
	else
	{
		[_photoView setImageWithURL:[NSURL URLWithString:_dish.thumbnailURL] placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			_photoView.image = _dish.croppedThumbnail = [Utils cropImageToSquare:image];
		} failure:nil];
	}	
	_commentCountLabel.text = [NSString stringWithFormat:@"%d", _dish.commentCount];
	_dishNameLabel.text = _dish.dishName;
	_userNameLabel.text = _dish.userName;
	
	[self updateBookmarkUI];
	
	_bookmarkButton.hidden = ![CurrentUser user].loggedIn;
	_bookmarkButton.bookmarked = _dish.bookmarked;
	
	if( _dish.bookmarked )
		_bookmarkButton.buttonX = 10;
	else
		_bookmarkButton.buttonX = 75;
}

- (void)updateBookmarkUI
{
	_bookmarkCountLabel.text = [NSString stringWithFormat:@"%d", _dish.bookmarkCount];
	
	if( !_dish.bookmarked || ![CurrentUser user].loggedIn )
	{
		_bookmarkIconView.image = [UIImage imageNamed:@"icon_bookmark.png"];
		_bookmarkCountLabel.textColor = [UIColor whiteColor];
	}
	else
	{
		_bookmarkIconView.image = [UIImage imageNamed:@"icon_bookmark_selected.png"];
		_bookmarkCountLabel.textColor = [UIColor colorWithHex:0x0DCFEC alpha:1];
	}
}


#pragma mark -
#pragma mark Photo View

- (void)photoViewDidTap
{
	[_delegate dishListCell:self didTouchPhotoViewAtIndexPath:_indexPath];
}

- (void)userPhotoButtonDidTouchUpInside
{
	[_delegate dishListCell:self didTouchUserPhotoButtonAtIndexPath:_indexPath];
}


#pragma mark -
#pragma mark BookmarkButtonDelegate

- (void)bookmarkButton:(BookmarkButton *)button needsUpdateBookmarkUIAsBookmarked:(BOOL)bookmarked
{
	if( bookmarked )
	{
		_dish.bookmarked = YES;
		_dish.bookmarkCount++;
		[self updateBookmarkUI];
		
		[UIView animateWithDuration:0.18 animations:^{
			_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.8, 1.8);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.14 animations:^{
				_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.6, 0.6);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.12 animations:^{
					_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						_bookmarkIconView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
					}];
				}];
			}];
		}];
		
		[UIView animateWithDuration:0.2 delay:0.14 options:0 animations:^{
			_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.4, 1.4);
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.15 animations:^{
				_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.12 animations:^{
					_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						_bookmarkCountLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
					}];
				}];
			}];
		}];
	}
	else
	{
		_dish.bookmarked = NO;
		_dish.bookmarkCount--;
		[self updateBookmarkUI];
	}
}

- (void)bookmarkButton:(BookmarkButton *)button didChangeBookmarked:(BOOL)bookmarked
{
	if( bookmarked )
	{
		[_delegate dishListCell:self didBookmarkAtIndexPath:_indexPath];
	}
	else if( !bookmarked )
	{
		[_delegate dishListCell:self didUnbookmarkAtIndexPath:_indexPath];
	}
}

@end
