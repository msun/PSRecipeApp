//
//  PSRecipeManager.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/15/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSRecipeManager.h"

@interface PSRecipeManager ()

@property (nonatomic) NSMutableArray *recipes; // [PSRecipe]

@end

@implementation PSRecipeManager

+ (id)sharedManager {
    static PSRecipeManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.recipes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray *)getRecipes {
    return self.recipes;
}

- (void)addRecipe:(PSRecipe *)recipe {
    [self.recipes addObject:recipe];
}

@end
