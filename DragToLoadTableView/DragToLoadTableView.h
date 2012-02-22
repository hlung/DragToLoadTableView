/*
 * This file is part of the DragToLoadTableView package.
 * (c) Thongchai Kolyutsakul <thongchaikol@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 27/1/2011.
 */

#import <Foundation/Foundation.h>

typedef enum {
    DragToLoadTableStateIdle,
    DragToLoadTableStateLoadingTop,
	DragToLoadTableStateLoadingBottom
} DragToLoadTableState;

@protocol DragToLoadTableViewDelegate,DragTableDelegate;

@interface DragToLoadTableView : UITableView <UITableViewDelegate,UITableViewDataSource> {
	IBOutlet NSObject <DragToLoadTableViewDelegate> *dragDelegate; // startLoadTop,startLoadBottom
	IBOutlet NSObject <DragTableDelegate> *tableDelegate; // handle UITableView delegate and dataSource
	
	UIView *topView;
	UIActivityIndicatorView *idViewTop;
	UILabel *labelTop;
	UILabel *labelDateTop;
	UIImageView *arrowTop;
	BOOL isArrowOn;
	
	UIView *bottomView;
	UIActivityIndicatorView *idViewBottom;
	UILabel *labelBottom;
	UIImageView *arrowBottom;
    	
	int offset_old; //preserve old offset when loadingTop for animation
	int num_bottom_row; //show or hide bottomView in the last table section, normally 0 or 1
	int kCellHeight, kStatusBarHeight, kTriggerDist, kDateLabelOffset;
	
	BOOL isLoadingTop;
	DragToLoadTableState state;
}
@property (nonatomic, assign) NSObject <DragToLoadTableViewDelegate> *dragDelegate;
@property (nonatomic, assign) NSObject <DragTableDelegate> *tableDelegate;
@property (nonatomic, retain) UIView *bottomView;
@property (nonatomic, assign) int num_bottom_row, kCellHeight, kStatusBarHeight, kTriggerDist, kDateLabelOffset;
-(void)stopAllLoadingAnimation;

// enable or disable pull up to load
-(void)enableLoadBottom;
-(void)disableLoadBottom;

-(void)triggerLoadTop;
-(void)triggerLoadBottom;
@end

@protocol DragToLoadTableViewDelegate
@optional
-(void)startLoadTop;
-(void)startLoadBottom;
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