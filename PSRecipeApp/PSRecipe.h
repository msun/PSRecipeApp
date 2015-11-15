//
//  PSRecipe.h
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSRecipe : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSInteger *minutes;
@property (nonatomic) NSArray *steps; // [NSString]
@property (nonatomic) NSArray *ingredients; // [NSString]

@end
