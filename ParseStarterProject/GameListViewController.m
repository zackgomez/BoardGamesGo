//
//  GameListViewController.m
//  ParseStarterProject
//
//  Created by Zack Gomez on 12/12/13.
//
//

#import "GameListViewController.h"
#import <Parse/Parse.h>
#import "QuickDialog.h"

@implementation GameListViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    if (![PFUser currentUser] || ![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        [self showLoginModal];
    }
    
    self.games = [[NSMutableArray alloc] init];
    
    self.tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view = self.tableView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewGameDialog)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(previousMenu)];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)showNewGameDialog {
    QRootElement *root = [[QRootElement alloc] init];
    root.title = @"New Game";
    root.grouped = YES;
    QSection *section = [[QSection alloc] init];
    QEntryElement *name_element = [[QEntryElement alloc] initWithTitle:@"Game" Value:@"Puerto Rico"];
    QDecimalElement *players_element = [[QDecimalElement alloc] initWithTitle:@"Number of Players" value:@4];
    players_element.fractionDigits = 0;
    QBooleanElement *publish_element = [[QBooleanElement alloc] initWithTitle:@"Broadcast game" BoolValue:NO];
    
    [root addSection:section];
    [section addElement:name_element];
    [section addElement:players_element];
    [section addElement:publish_element];
    
    QSection *final_section = [[QSection alloc] init];
    QButtonElement *submit_element = [[QButtonElement alloc] initWithTitle:@"Make Game"];
    submit_element.onSelected = ^() {
        NSLog(@"Submitted baby");
        
        PFUser *user = [PFUser currentUser];
        if (!user) {
            return;
        }
        PFObject *new_game_obj = [PFObject objectWithClassName:@"Game"];
        new_game_obj[@"owner"] = user;
        new_game_obj[@"name"] = name_element.textValue;
        new_game_obj[@"players"] = players_element.numberValue;
        new_game_obj[@"published"] = @(publish_element.boolValue);
        [new_game_obj saveInBackground];
        [self.games addObject:new_game_obj];
        
        [self.navigationController popViewControllerAnimated:YES];
    };
    [final_section addElement:submit_element];
    [root addSection:final_section];
    
    QuickDialogController *dialog = [QuickDialogController controllerForRoot:root];
    [self.navigationController pushViewController:dialog animated:YES];
}

- (void)previousMenu {
    [PFUser logOut];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.games.count;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"All Games";
    }
    return nil;
}

- (void)showLoginModal {
    PFLogInViewController *logInController = [[PFLogInViewController alloc] init];
    logInController.delegate = self;
    logInController.fields = PFLogInFieldsFacebook;
    [self presentModalViewController:logInController animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"MyReuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:reuseIdentifier];
    }
    int index =[indexPath indexAtPosition:1];
    PFObject* game = self.games[index];
    
    cell.textLabel.text = game[@"name"];
    return cell;
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            
            NSLog(@"Facebook id %@", facebookID);
            PFUser *user = [PFUser currentUser];
            user[@"display_name"] = name;
            [user saveInBackground];
            [self.tableView reloadData];
        }
    }];
}

- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
}

@end