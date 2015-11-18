//
//  PSRecipeManager.h
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/15/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSRecipe.h"

@interface PSRecipeManager : NSObject

+ (id)sharedManager;

- (void)loadRecipes;
- (NSArray *)getRecipes;
- (void)addRecipe:(PSRecipe *)recipe;
- (void)eraseRecipe:(PSRecipe *)recipe;

- (PSRecipe *)getPartial;
- (void)erasePartials;

@end
