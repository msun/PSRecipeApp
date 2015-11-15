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
@property (nonatomic) NSString *desc;
@property (nonatomic) NSInteger minutes;
@property (nonatomic) NSMutableArray *steps; // [NSString]
@property (nonatomic) NSMutableArray *ingredients; // [NSString]

@end
