//
//  DragToLoadTableViewCustom.h
//  Memoli
//
//  Created by Hlung on 27/1/2554.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DragToLoadTableStateIdle,
    DragToLoadTableStateLoadingTop,
	DragToLoadTableStateLoadingBottom
} DragToLoadTableState;

@protocol DragToLoadTableViewCustomListener,DragTableDelegate;

@interface DragToLoadTableViewCustom : UITableView <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet NSObject <DragToLoadTableViewCustomListener> *listener; // startLoadTop,startLoadBottom
	IBOutlet NSObject <DragTableDelegate> *tableDelegate; // handle UITableView delegate and dataSource
	
	UIView *topView;
	UIActivityIndicatorView *idViewTop;
	UILabel *labelTop;
	UILabel *labelDateTop;
	UIImageView *imageTop;
	BOOL isArrowOn;
	
	UIView *bottomView;
	UIActivityIndicatorView *idViewBottom;
	UILabel *labelBottom;
	UIImageView *imageBottom;
	
	int offset_old; //preserve old offset when loadingTop for animation
	int num_buttom_row; //show or hide bottomView in the last table section, normally 0 or 1
	int kCellHeight, kStatusBarHeight, kTriggerDist, kDateLabelOffset;
	
	BOOL isLoadingTop;
	DragToLoadTableState state;
}
@property (nonatomic, assign) NSObject <DragToLoadTableViewCustomListener> *listener;
@property (nonatomic, assign) NSObject <DragTableDelegate> *tableDelegate;
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, assign) int num_buttom_row, kCellHeight, kStatusBarHeight, kTriggerDist, kDateLabelOffset;
-(void)stopAllLoadingAnimation;
-(void)enableLoadButtom;
-(void)disableLoadButtom;
-(void)triggerLoadTop;
-(void)triggerLoadBottom;
@end

@protocol DragToLoadTableViewCustomListener
@optional
-(void)startLoadTop;
-(void)startLoadButtom;
@end

@protocol DragTableDelegate
@optional
// delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
// dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)itableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
@end