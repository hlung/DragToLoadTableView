/*
 * This file is part of the DragToLoadTableView package.
 * (c) Thongchai Kolyutsakul <thongchaikol@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * Created on 8/3/2011.
 */

#import <UIKit/UIKit.h>

@interface DragToLoadTableViewAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

