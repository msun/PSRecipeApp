//
//  PSImagesViewController.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/15/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSImagesViewController.h"
#import "PSImageTableViewCell.h"

static NSString *const ImageCellId = @"Image Cell";

@interface PSImagesViewController () <UITableViewDataSource, UITableViewDelegate,
                                      UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addImageButton;
@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation PSImagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.tableView.estimatedRowHeight = self.tableView.bounds.size.width;
    //self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    if (self.recipe.images.count >= 3) {
        self.addImageButton.enabled = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PSImageTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:ImageCellId forIndexPath:indexPath];
    cell.photoView.image = self.recipe.images[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recipe.images.count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                                                            title:@"Delete"
        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
            [self.recipe.images removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView reloadData];
        }];

    return @[deleteAction];
}

#pragma mark - UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    UIImage *image = info[UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = info[UIImagePickerControllerOriginalImage];
        if (image == nil) return;
    }
    [self.recipe.images addObject:image];
    if (self.recipe.images.count >= 3) {
        self.addImageButton.enabled = NO;
    }
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UINavigationControllerDelegate

- (void) navigationController: (UINavigationController *) navigationController  willShowViewController: (UIViewController *) viewController animated: (BOOL) animated {
    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(showCamera:)];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
    } else if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Library" style:UIBarButtonItemStylePlain target:self action:@selector(showLibrary:)];
        viewController.navigationItem.rightBarButtonItems = [NSArray arrayWithObject:button];
        viewController.navigationItem.title = @"Take Photo";
        viewController.navigationController.navigationBarHidden = NO;
    }
    UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissCameraLibrary:)];
    viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObject:button];
}

- (void)showCamera: (id) sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
}

- (void)showLibrary: (id) sender {
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)dismissCameraLibrary: (id) sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - IBAction

- (IBAction)addImageTapped:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self presentViewController:self.imagePicker animated:YES completion:NULL];
    }
}

#pragma mark - Getters

- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

@end
