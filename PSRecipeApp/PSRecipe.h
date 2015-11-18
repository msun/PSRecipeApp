//
//  PSRecipe.h
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObject;
@class NSEntityDescription;

@interface PSRecipe : NSObject

@property (nonatomic) NSString *identifier;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *desc;
@property (nonatomic) NSMutableArray *images; // [UIImage]
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSMutableArray *steps; // [NSString]
@property (nonatomic) NSMutableArray *ingredients; // [NSString]

+ (NSEntityDescription *)entityDescription;
+ (NSEntityDescription *)partialEntityDescription;
- (PSRecipe *)initWithManagedObject:(NSManagedObject *)managedObject;

- (void)save;
- (void)savePartial;
- (void)erase;
- (BOOL)matchesSearchQuery:(NSString *)query;

@end
