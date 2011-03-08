//
//  DragToLoadTableViewCustom.m
//  Memoli
//
//  Created by Hlung on 27/1/2554.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DragToLoadTableViewCustom.h"

@interface DragToLoadTableViewCustom (private)
-(void)setTableViewRefresh;
-(void)setTableViewNormal;
-(int)calcBottomOffset:(UIScrollView*)scrollView;
-(NSString*)getCurrentDateString;
@end

#define kLABEL_TOP	 @"Pull down to refresh..."
#define kRELEASE_TOP @"Release to update..."
#define kLOADING_TOP @"Updating..."

#define kLABEL_BOTTOM   @"Pull up to load more..."
#define kRELEASE_BOTTOM @"Release to load more..."
#define kLOADING_BOTTOM @"Updating cached data..."

@implementation DragToLoadTableViewCustom

@synthesize listener,tableDelegate;
@synthesize bottomView,num_buttom_row,kCellHeight, kStatusBarHeight, kTriggerDist, kDateLabelOffset;

-(id)initWithCoder:(NSCoder*)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		kCellHeight = 60.0f; // height of top and bottom loading views
		kTriggerDist = 5.0f; // releasing distance before triggering load
		kStatusBarHeight = 20.0f;
		kDateLabelOffset = 17.0f;
		int arrow_offset = 40.0f;

		state = DragToLoadTableStateIdle;
		num_buttom_row = 0;
		
		// TOP
		topView = [[UIView alloc] initWithFrame:CGRectMake(0, -kCellHeight, 320, kCellHeight)];
		topView.backgroundColor = [UIColor grayColor];
		
		labelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, kCellHeight)];
		labelTop.textAlignment = UITextAlignmentCenter;
		labelTop.backgroundColor = [UIColor whiteColor];
		labelTop.text = kLABEL_TOP;
		[topView addSubview:labelTop];
		[labelTop release];
		
		labelDateTop = [[UILabel alloc] initWithFrame:CGRectMake(0, kDateLabelOffset, 320, kCellHeight)];
		labelDateTop.textAlignment = UITextAlignmentCenter;
		labelDateTop.backgroundColor = [UIColor clearColor];
		labelDateTop.textColor = [UIColor grayColor];
		labelDateTop.font = [UIFont fontWithName:@"Helvetica" size:12.0f];
		labelDateTop.text = [self getCurrentDateString];
		[topView addSubview:labelDateTop];
		[labelDateTop release];
		
		idViewTop = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		idViewTop.center = CGPointMake(arrow_offset, kCellHeight/2);
		idViewTop.hidesWhenStopped = YES;
		[topView addSubview:idViewTop];
		[idViewTop release];
		
		UIImage *arrow = [UIImage imageNamed:@"blueArrow.png"];
		int arrow_W = arrow.size.width*0.7;
		int arrow_H = arrow.size.height*0.7;
		
		imageTop = [[UIImageView alloc] initWithFrame:
					CGRectMake(idViewTop.center.x-arrow_W/2, idViewTop.center.y-arrow_H/2, 
							   arrow_W, arrow_H)];
		imageTop.image = arrow;
		imageTop.transform = CGAffineTransformMakeRotation(M_PI);
		[topView addSubview:imageTop];
		[imageTop release];
		imageTop.alpha = 1;
		
		[self addSubview:topView];
		[topView release];
		
		
		// BOTTOM
		bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, kCellHeight)];
		bottomView.backgroundColor = [UIColor grayColor];
		
		labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, kCellHeight)];
		labelBottom.textAlignment = UITextAlignmentCenter;
		labelBottom.backgroundColor = [UIColor whiteColor];
		labelBottom.text = kLABEL_BOTTOM;
		[bottomView addSubview:labelBottom];
		[labelBottom release];
		
		idViewBottom = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		idViewBottom.center = CGPointMake(arrow_offset, kCellHeight/2);
		idViewBottom.hidesWhenStopped = YES;
		[bottomView addSubview:idViewBottom];
		[idViewBottom release];
		
		imageBottom = [[UIImageView alloc] initWithFrame:
					CGRectMake(idViewBottom.center.x-arrow_W/2, idViewBottom.center.y-arrow_H/2, 
							   arrow_W, arrow_H)];
		imageBottom.image = arrow;
		[bottomView addSubview:imageBottom];
		[imageBottom release];
		imageBottom.alpha = 1;
		//**later release bottomView in dealloc, unlike topView**
		
		self.delegate = self;
		self.dataSource = self; //can overwrite dataSource inside parent nib or viewDidLoad
	}
	return self;
}

#pragma mark -
#pragma mark External

-(void)stopAllLoadingAnimation {
	[idViewTop stopAnimating];
	labelTop.text = kLABEL_TOP;
	[idViewBottom stopAnimating];
	labelBottom.text = kLABEL_BOTTOM;
	if (state == DragToLoadTableStateLoadingTop) {
		labelDateTop.text = [self getCurrentDateString];
	}
	if (self.contentOffset.y <= 0)  {
		[self performSelector:@selector(setTableViewNormal) withObject:nil afterDelay:0];
	}
	imageTop.alpha = imageBottom.alpha = 1;
	state = DragToLoadTableStateIdle;
}

-(void)enableLoadButtom {
	num_buttom_row = 1;
	[self reloadData];
}

-(void)disableLoadButtom {
	
	num_buttom_row = 0;
	
	[self reloadData];  // need reloadData here cuz the relaodSection method in 'disableLoadButtom' 
						// will check numberOfRowsInSection consistency. And since we add rows to 
						// the first section we need to update the numberOfRowsInSection to avoid SIGABRT
	
	// smoothly remove bottom section
	[self reloadSections:[NSIndexSet indexSetWithIndex:[self numberOfSectionsInTableView:self]-1] withRowAnimation:UITableViewRowAnimationBottom];
	
	[self reloadData];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return nil;
	}
	else {
		if ([tableDelegate respondsToSelector:@selector(tableView:viewForHeaderInSection:) ]) {
			return [tableDelegate tableView:tableView viewForHeaderInSection:section];
		}
		return nil;
	}
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return nil;
	}
	else {
		if ([tableDelegate respondsToSelector:@selector(tableView:viewForFooterInSection:) ]) {
			return [tableDelegate tableView:tableView viewForFooterInSection:section];
		}
		return nil;
	}	
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return 0.0;
	}
	else {
		if ([tableDelegate respondsToSelector:@selector(tableView:heightForHeaderInSection:) ]) {
			return [tableDelegate tableView:tableView heightForHeaderInSection:section];
		}
		return 0.0;
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return 0.0;
	}
	else {
		if ([tableDelegate respondsToSelector:@selector(tableView:heightForFooterInSection:) ]) {
			return [tableDelegate tableView:tableView heightForFooterInSection:section];
		}
		return 0.0;
	}	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == [self numberOfSectionsInTableView:tableView]-1) {
		return kCellHeight;
	}
	else {
		if ([tableDelegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:) ]) {
			return [tableDelegate tableView:tableView heightForRowAtIndexPath:indexPath];
		}
		return kCellHeight;
	}
}


#pragma mark -
#pragma mark UITableView Delegates (DragTableDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
	if ([tableDelegate respondsToSelector:@selector(numberOfSectionsInTableView:) ]) {
		//NSLog(@"numberOfSectionsInTableView %d",[tableDelegate numberOfSectionsInTableView:tableView]+1);
		return [tableDelegate numberOfSectionsInTableView:tableView]+1;
	}
	else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return self.num_buttom_row;
	} 
	else {
		//*** place your row count here ***//
		if ([tableDelegate respondsToSelector:@selector(tableView:numberOfRowsInSection:) ]) {
			NSLog(@"numRow %d",[tableDelegate tableView:tableView numberOfRowsInSection:section]);
			return [tableDelegate tableView:tableView numberOfRowsInSection:section];
		}
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)itableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([indexPath section] == [self numberOfSectionsInTableView:itableView]-1) {
		static NSString *reuseIden = @"cellMore";
		UITableViewCell *cell = [itableView dequeueReusableCellWithIdentifier:reuseIden];
		if(cell == nil)
		{
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIden] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			[cell addSubview:bottomView];
		}
		return cell;
	}
	else {
		//*** place your cells here ***//
		if ([tableDelegate respondsToSelector:@selector(tableView:cellForRowAtIndexPath:) ]) {
			return [tableDelegate tableView:itableView cellForRowAtIndexPath:indexPath];
		}
	}
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return nil;
	} 
	if ([tableDelegate respondsToSelector:@selector(tableView:titleForHeaderInSection:) ]) {
		return [tableDelegate tableView:tableView titleForHeaderInSection:section];
	}
	return nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == [self numberOfSectionsInTableView:tableView]-1) {
		return nil;
	} 
	if ([tableDelegate respondsToSelector:@selector(tableView:titleForFooterInSection:) ]) {
		return [tableDelegate tableView:tableView titleForFooterInSection:section];
	}
	return nil;
}

#pragma mark -
#pragma mark scrollView delegates

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	
	if (state == DragToLoadTableStateIdle) {
		// scroll over top
		if (scrollView.contentOffset.y <= -kCellHeight-kTriggerDist) {
			[self triggerLoadTop];
			
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setTableViewNormal) object:nil];
			offset_old = scrollView.contentOffset.y; //preserve old offset
			
			scrollView.bounces = NO; // disable off edge auto scroll, *xx* flash to top bug *xx*
			scrollView.scrollEnabled = NO;
			scrollView.showsVerticalScrollIndicator = NO;
			scrollView.alpha = 0; // *oo* hide flash top bug *oo* 
			
			[self performSelector:@selector(setTableViewRefresh) withObject:nil afterDelay:0];
		}
		// scroll below bottom
		else if (num_buttom_row > 0) { // if loadButtom enabled
			if (scrollView.contentOffset.y >= kTriggerDist+[self calcBottomOffset:scrollView]) {
				[self triggerLoadBottom];
			}
		}
	}
}

-(void)triggerLoadTop {
	[self stopAllLoadingAnimation];
	state = DragToLoadTableStateLoadingTop;
	
	[UIView beginAnimations:nil context:nil]; // arrow spin back and fade out
	[UIView setAnimationDuration:0.3f];
	imageTop.alpha = 0;
	imageTop.transform = CGAffineTransformMakeRotation(M_PI);
	[UIView commitAnimations];
	
	[idViewTop startAnimating];
	labelTop.text = kLOADING_TOP;
	
	if ([listener respondsToSelector:@selector(startLoadTop) ]){
		[listener performSelectorOnMainThread:@selector(startLoadTop) withObject:nil waitUntilDone:YES];
	}
}

-(void)triggerLoadBottom {
	[self stopAllLoadingAnimation];
	state = DragToLoadTableStateLoadingBottom;
	imageBottom.alpha = 0;
	[idViewBottom startAnimating];
	labelBottom.text = kLOADING_BOTTOM;
	if ([listener respondsToSelector:@selector(startLoadButtom) ]){
		[listener performSelectorOnMainThread:@selector(startLoadButtom) withObject:nil waitUntilDone:YES];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView { 
	scrollView.scrollEnabled = YES; 
	scrollView.showsVerticalScrollIndicator = YES;
	scrollView.bounces = YES; 
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (!scrollView.isDecelerating && state == DragToLoadTableStateIdle) { // have to be dragging
		if (imageTop.alpha){
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3f];
			if (scrollView.contentOffset.y <= -kCellHeight-kTriggerDist) {
				imageTop.transform = CGAffineTransformIdentity;
				labelTop.text = kRELEASE_TOP;
			}
			else {
				imageTop.transform = CGAffineTransformMakeRotation(M_PI);
				labelTop.text = kLABEL_TOP;
			}
			[UIView commitAnimations];
		}
		if (imageBottom.alpha){
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3f];
			if (scrollView.contentOffset.y >= kTriggerDist+[self calcBottomOffset:scrollView]) {
				imageBottom.transform = CGAffineTransformMakeRotation(M_PI);
				labelBottom.text = kRELEASE_BOTTOM;
			}
			else {
				imageBottom.transform = CGAffineTransformIdentity;
				labelBottom.text = kLABEL_BOTTOM;
			}
			[UIView commitAnimations];
		}
	}
}


#pragma mark Internal

-(NSString*)getCurrentDateString {
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"dd/MM/yyyy HH:mm"];
	NSDate *now = [[[NSDate alloc] init] autorelease];
	return [NSString stringWithFormat:@"Last updated: %@",[format stringFromDate:now]];
}

-(int)calcBottomOffset:(UIScrollView*)scrollView {
	int buttomOffset = scrollView.contentSize.height - scrollView.frame.size.height;
	if (buttomOffset < 0) buttomOffset = 0;
	return buttomOffset;
}

-(void)enableBounce { self.bounces = YES; }

-(void)setTableViewRefresh {
	self.alpha = 1;
	[self setContentOffset:CGPointMake(0, offset_old) animated:NO];
	[self setContentOffset:CGPointMake(0, -kCellHeight) animated:YES];
}

-(void)setTableViewNormal {
	if (state == DragToLoadTableStateLoadingTop) [self setContentOffset:CGPointMake(0, -kCellHeight) animated:NO];
	[self setContentOffset:CGPointMake(0, 0) animated:YES];
	state = DragToLoadTableStateIdle;
}


- (void)dealloc {
	[bottomView release];
	bottomView = nil;
    [super dealloc];
}

@end
