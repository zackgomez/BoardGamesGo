//
//  GameListViewController.h
//  ParseStarterProject
//
//  Created by Zack Gomez on 12/12/13.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface GameListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, PFLogInViewControllerDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSMutableArray* games;

@end
