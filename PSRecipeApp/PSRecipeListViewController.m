//
//  PSRecipeListViewController.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSRecipeListViewController.h"
#import "PSAddRecipeViewController.h"
#import "PSRecipesListTableViewCell.h"
#import "PSRecipeManager.h"

static NSString *const RecipeListCellId = @"Recipe List Cell";
static NSString *const RecipeIconBlank = @"recipe-icon-blank";
static NSString *const ToAddRecipe = @"RecipesListToAddRecipeSegue";
static NSString *const ToEditRecipe = @"RecipesListToEditRecipeSegue";

@interface PSRecipeListViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) PSRecipe *currentRecipe;
@property (nonatomic) NSMutableArray *searchRecipes;
@end

@implementation PSRecipeListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[PSRecipeManager sharedManager] loadRecipes];
    self.searchField.delegate = self;
    self.searchRecipes = [[[PSRecipeManager sharedManager] getRecipes] mutableCopy];
    self.currentRecipe = [[PSRecipeManager sharedManager] getPartial];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.currentRecipe) {
        [[PSRecipeManager sharedManager] erasePartials];
        [self performSegueWithIdentifier:ToAddRecipe sender:self];
    } else {
        [self updateSearchRecipesWithQuery:self.searchField.text];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.searchField endEditing:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ToAddRecipe]) {
        PSAddRecipeViewController *vc = [segue destinationViewController];
        vc.isEditing = NO;
        vc.recipe = self.currentRecipe;
        self.currentRecipe = nil;
    } else if ([segue.identifier isEqualToString:ToEditRecipe]) {
        PSAddRecipeViewController *vc = [segue destinationViewController];
        vc.isEditing = YES;
        vc.recipe = self.currentRecipe;
        self.currentRecipe = nil;
    }
}

- (IBAction)unwindToRecipeListViewController:(UIStoryboardSegue *)unwindSegue {

}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *query = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self updateSearchRecipesWithQuery:query];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSRecipesListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RecipeListCellId forIndexPath:indexPath];
    PSRecipe *recipe = [self.searchRecipes objectAtIndex:indexPath.row];
    
    cell.photoView.image = (recipe.images.count >= 1) ? [recipe.images firstObject] : [UIImage imageNamed:RecipeIconBlank];
    cell.recipeNameLabel.text = recipe.name;
    cell.recipeDescriptionLabel.text = recipe.desc;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchRecipes.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchField endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.currentRecipe = self.searchRecipes[indexPath.row];
    [self performSegueWithIdentifier:ToEditRecipe sender:self];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:@"Delete"
                                                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        PSRecipe *recipe = self.searchRecipes[indexPath.row];
        [[PSRecipeManager sharedManager] eraseRecipe:recipe];
        [self updateSearchRecipesWithQuery:self.searchField.text];
    }];
    
    return @[deleteAction];
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.tableView];
}

#pragma mark - IBAction

- (IBAction)didTap:(id)sender {
    [self.searchField endEditing:YES];
}

#pragma mark - Misc

- (void)updateSearchRecipesWithQuery:(NSString *)query {
    self.searchRecipes = [[NSMutableArray alloc] init];
    NSArray *recipes = [[PSRecipeManager sharedManager] getRecipes];
    for (PSRecipe *recipe in recipes) {
        if ([recipe matchesSearchQuery:query]) {
            [self.searchRecipes addObject:recipe];
        }
    }
    [self.tableView reloadData];
}

@end
