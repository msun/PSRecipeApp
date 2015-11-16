//
//  PSAddRecipeViewController.h
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSRecipe;

@interface PSAddRecipeViewController : UIViewController

@property (nonatomic) PSRecipe *recipe;
@property (nonatomic, assign) BOOL isEditing;

@end
