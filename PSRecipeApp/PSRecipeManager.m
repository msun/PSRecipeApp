//
//  PSRecipeManager.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/15/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSRecipeManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

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
    [recipe save];
}

- (void)deleteRecipe:(PSRecipe *)recipe {
    [self.recipes removeObject:recipe];
    [recipe erase];
}

- (void)loadRecipes { // [NSManagedObject] of entity Recipe
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[PSRecipe entityDescription]];
    NSError *fetchError = nil;
    NSArray *managedObjects = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
        return;
    }
    
    for (NSManagedObject *managedObject in managedObjects) {
        PSRecipe *recipe = [[PSRecipe alloc] initWithManagedObject:managedObject];
        [self.recipes addObject:recipe];
    }
}

@end
