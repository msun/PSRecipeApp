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

@interface PSRecipeListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) PSRecipe *currentRecipe;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ToAddRecipe]) {

    } else if ([segue.identifier isEqualToString:ToEditRecipe]) {
        PSAddRecipeViewController *vc = [segue destinationViewController];
        vc.isEditing = YES;
        vc.recipe = self.currentRecipe;
    }
}

- (IBAction)unwindToRecipeListViewController:(UIStoryboardSegue *)unwindSegue {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSRecipesListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:RecipeListCellId forIndexPath:indexPath];
    PSRecipe *recipe = [[[PSRecipeManager sharedManager] getRecipes] objectAtIndex:indexPath.row];
    
    cell.photoView.image = (recipe.images.count >= 1) ? [recipe.images firstObject] : [UIImage imageNamed:RecipeIconBlank];
    cell.recipeNameLabel.text = recipe.name;
    cell.recipeDescriptionLabel.text = recipe.desc;

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[PSRecipeManager sharedManager] getRecipes].count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.currentRecipe = [[PSRecipeManager sharedManager] getRecipes][indexPath.row];
    [self performSegueWithIdentifier:ToEditRecipe sender:self];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:@"Delete"
                                                                          handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        PSRecipe *recipe = [[PSRecipeManager sharedManager] getRecipes][indexPath.row];
        [[PSRecipeManager sharedManager] deleteRecipe:recipe];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteAction];
}

@end
