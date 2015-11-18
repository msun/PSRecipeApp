//
//  PSAddRecipeViewController.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSAddRecipeViewController.h"
#import "PSAddRowTableViewCell.h"
#import "PSImagesViewController.h"
#import "PSRecipe.h"
#import "PSRecipeManager.h"
#import "PSTextFieldTableViewCell.h"

static NSString *const TextFieldCellId = @"Text Field Cell";
static NSString *const AddRowCellId = @"Add Row Cell";
static NSString *const ImagesCellId = @"Images Cell";
static NSString *const ToImagesSegue = @"AddRecipeToImagesSegue";
static NSString *const UnwindToRecipesListSegue = @"unwindFromAddRecipeToRecipeList";

@interface PSAddRecipeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PSAddRecipeViewController

typedef NS_ENUM(NSInteger, RecipeSection) {
    RecipeSectionName,
    RecipeSectionDescription,
    RecipeSectionImages,
    RecipeSectionMinutes,
    RecipeSectionSteps,
    RecipeSectionIngredients,
    RecipeSectionCount
};

#pragma mark - Lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _isEditing = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isEditing) {
        self.navigationItem.title = @"Edit Recipe";
    } else {
        self.recipe = [[PSRecipe alloc] init];
        self.recipe.name = @"";
        self.recipe.desc = @"";
        self.recipe.images = [[NSMutableArray alloc] init];
        self.recipe.minutes = 0;
        self.recipe.steps = [[NSMutableArray alloc] initWithObjects:@"", nil];
        self.recipe.ingredients = [[NSMutableArray alloc] initWithObjects:@"", nil];
    }
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 220.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:UnwindToRecipesListSegue]) {
        if (self.isEditing) {
            [self.recipe save];
        } else {
            [[PSRecipeManager sharedManager] addRecipe:self.recipe];
        }
    } else if ([[segue identifier] isEqualToString:ToImagesSegue]) {
        PSImagesViewController *vc = [segue destinationViewController];
        vc.recipe = self.recipe;
    }
}

#pragma mark - UITableViewDataSource

-(void)editingChanged:(id)sender {
    UITextField *textField = sender;
    CGPoint buttonOriginInTableView = [textField convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonOriginInTableView];

    switch (indexPath.section) {
        case RecipeSectionName:        self.recipe.name = textField.text; return;
        case RecipeSectionDescription: self.recipe.desc = textField.text; return;
        case RecipeSectionImages:      return;
        case RecipeSectionMinutes:     self.recipe.minutes = [textField.text intValue]; return;
        case RecipeSectionSteps:       self.recipe.steps[indexPath.row] = textField.text; return;
        case RecipeSectionIngredients: self.recipe.ingredients[indexPath.row] = textField.text; return;
    }
}

- (PSTextFieldTableViewCell *)dequeuePSTextFieldTableViewCellForIndexPath:(NSIndexPath *)indexPath {
    PSTextFieldTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:TextFieldCellId forIndexPath:indexPath];
    
    if (cell.textField.allTargets.count == 0) {
        [cell.textField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case RecipeSectionName: {
            PSTextFieldTableViewCell *cell = [self dequeuePSTextFieldTableViewCellForIndexPath:indexPath];
            cell.label.text = @"Recipe Name";
            cell.textField.text = self.recipe.name;
            return cell;
        }
        case RecipeSectionDescription: {
            PSTextFieldTableViewCell *cell = [self dequeuePSTextFieldTableViewCellForIndexPath:indexPath];
            cell.label.text = @"Description";
            cell.textField.text = self.recipe.desc;
            return cell;
        }
        case RecipeSectionImages: {
            UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ImagesCellId forIndexPath:indexPath];
            return cell;
        }
        case RecipeSectionMinutes: {
            PSTextFieldTableViewCell *cell = [self dequeuePSTextFieldTableViewCellForIndexPath:indexPath];
            cell.label.text = @"Cooking Minutes";
            cell.textField.text = [NSString stringWithFormat: @"%ld", (long)self.recipe.minutes];
            return cell;
        }
        case RecipeSectionSteps: {
            if (indexPath.row < self.recipe.steps.count) {
                PSTextFieldTableViewCell *cell = [self dequeuePSTextFieldTableViewCellForIndexPath:indexPath];
                cell.label.text = [NSString stringWithFormat:@"Step %d", indexPath.row + 1];
                cell.textField.text = self.recipe.steps[indexPath.row];
                return cell;
            } else if (indexPath.row == self.recipe.steps.count) {
                PSAddRowTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AddRowCellId forIndexPath:indexPath];
                cell.label.text = @"Add Another Step";
                return cell;
            }
            return nil;
        }
        case RecipeSectionIngredients: {
            if (indexPath.row < self.recipe.ingredients.count) {
                PSTextFieldTableViewCell *cell = [self dequeuePSTextFieldTableViewCellForIndexPath:indexPath];
                cell.label.text = [NSString stringWithFormat:@"Ingredient %d", indexPath.row + 1];
                cell.textField.text = self.recipe.ingredients[indexPath.row];
                return cell;
            } else if (indexPath.row == self.recipe.ingredients.count) {
                PSAddRowTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:AddRowCellId forIndexPath:indexPath];
                cell.label.text = @"Add Another Ingredient";
                return cell;
            }
            return nil;
        }
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case RecipeSectionName: return 1;
        case RecipeSectionDescription: return 1;
        case RecipeSectionImages: return 1;
        case RecipeSectionMinutes: return 1;
        case RecipeSectionSteps: return self.recipe.steps.count + 1;
        case RecipeSectionIngredients: return self.recipe.ingredients.count + 1;
        default: return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return RecipeSectionCount;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case RecipeSectionSteps:
            if (indexPath.row >= self.recipe.steps.count) return NO;
            return YES;
        case RecipeSectionIngredients:
            if (indexPath.row >= self.recipe.ingredients.count) return NO;
            return YES;
        default:
            return NO;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.view endEditing:YES];
    
    switch (indexPath.section) {
        case RecipeSectionImages:
            [self performSegueWithIdentifier:ToImagesSegue sender:self];
            break;
        case RecipeSectionSteps:
            if (indexPath.row == self.recipe.steps.count) {
                [self.recipe.steps addObject:@""];
                [self.tableView reloadData];
            }
            break;
        case RecipeSectionIngredients:
            if (indexPath.row == self.recipe.ingredients.count) {
                [self.recipe.ingredients addObject:@""];
                [self.tableView reloadData];
            }
            break;
        default:
            break;
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case RecipeSectionSteps:
            if (indexPath.row >= self.recipe.steps.count) return @[];
            break;
        case RecipeSectionIngredients:
            if (indexPath.row >= self.recipe.steps.count) return @[];
            break;
        default:
            return @[];
    }

    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:@"Delete"
        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            switch (indexPath.section) {
                case RecipeSectionSteps:
                    [self.recipe.steps removeObjectAtIndex:indexPath.row];
                    break;
                case RecipeSectionIngredients:
                    [self.recipe.ingredients removeObjectAtIndex:indexPath.row];
                    break;
                default:
                    break;
            }
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
    }];
    
    return @[deleteAction];
}

@end
