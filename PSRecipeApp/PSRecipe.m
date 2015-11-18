//
//  PSRecipe.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSRecipe.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"

@implementation PSRecipe

+(NSString *)createRecipeIdentifier
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString * uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);
    
    return uuidString;
}

+ (NSEntityDescription *)entityDescription {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:appDelegate.managedObjectContext];
}

+ (NSEntityDescription *)partialEntityDescription {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return [NSEntityDescription entityForName:@"PartialRecipe" inManagedObjectContext:appDelegate.managedObjectContext];
}

- (PSRecipe *)initWithManagedObject:(NSManagedObject *)managedObject {
    self = [super init];
    if (self) {
        self.identifier = [managedObject valueForKey:@"identifier"];
        self.name = [managedObject valueForKey:@"name"];
        self.desc = [managedObject valueForKey:@"desc"];
        NSNumber *number = [managedObject valueForKey:@"minutes"];
        self.minutes = [number integerValue];
        NSData *data = [managedObject valueForKey:@"images"];
        self.images = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        data = [managedObject valueForKey:@"steps"];
        self.steps = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        data = [managedObject valueForKey:@"ingredients"];
        self.ingredients = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return self;
}

- (NSManagedObject *)fetchWithEntityDescription:(NSEntityDescription *)entityDescription {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObject *managedObject;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"identifier", self.identifier];
    [fetchRequest setPredicate:predicate];
    NSError *fetchError = nil;
    NSArray *fetchResult = [appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    if (fetchError) {
        NSLog(@"Unable to execute fetch request.");
        NSLog(@"%@, %@", fetchError, fetchError.localizedDescription);
        return nil;
    }
    
    if (fetchResult.count <= 0) {
        NSLog(@"No recipe fetched");
    } else {
        NSLog(@"fetchResult: %@", fetchResult);
        managedObject = [fetchResult firstObject];
    }
    
    return managedObject;
}

- (void)saveWithEntityDescription:(NSEntityDescription *)entityDescription {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    NSManagedObject *managedObject = [self fetchWithEntityDescription:entityDescription];
    if (managedObject == nil) {
        managedObject = [[NSManagedObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:appDelegate.managedObjectContext];
        self.identifier = [[self class] createRecipeIdentifier];
        [managedObject setValue:self.identifier forKey:@"identifier"];
    }

    [managedObject setValue:self.name forKey:@"name"];
    [managedObject setValue:self.desc forKey:@"desc"];
    NSNumber *number = [NSNumber numberWithInteger:self.minutes];
    [managedObject setValue:number forKey:@"minutes"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.images];
    [managedObject setValue:data forKey:@"images"];
    data = [NSKeyedArchiver archivedDataWithRootObject:self.steps];
    [managedObject setValue:data forKey:@"steps"];
    data = [NSKeyedArchiver archivedDataWithRootObject:self.ingredients];
    [managedObject setValue:data forKey:@"ingredients"];
    
    NSError *saveError = nil;
    if (![managedObject.managedObjectContext save:&saveError]) {
        NSLog(@"Can't save managedObject: %@, %@", saveError, saveError.localizedDescription);
    }
}

- (void)save {
    [self saveWithEntityDescription:[PSRecipe entityDescription]];
}

- (void)savePartial {
    [self saveWithEntityDescription:[PSRecipe partialEntityDescription]];
}

- (void)erase {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObject *managedObject = [self fetchWithEntityDescription:[PSRecipe entityDescription]];
    if (managedObject == nil) {
        NSLog(@"Erase: Could not fetch");
        return;
    }
    
    [appDelegate.managedObjectContext deleteObject:managedObject];
    
    NSError *deleteError = nil;
    if (![managedObject.managedObjectContext save:&deleteError]) {
        NSLog(@"Unable to save managed object context.");
        NSLog(@"Can't delete managedObject: %@, %@", deleteError, deleteError.localizedDescription);
    }
}

- (BOOL)matchesSearchQuery:(NSString *)query {
    NSString *queryString = [query stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (queryString.length <= 0) return YES;
    
    for (NSString *string in @[self.name,
                               self.desc,
                               [NSString stringWithFormat: @"%ld", (long)self.minutes]]) {
        if ([string containsString:queryString]) return YES;
    }
    
    for (NSString *string in self.steps) {
        if ([string containsString:queryString]) return YES;
    }
    
    for (NSString *string in self.ingredients) {
        if ([string containsString:queryString]) return YES;
    }

    return NO;
};

@end

@implementation NSString (PSRecipeAdditions)
- (BOOL)containsString:(NSString *)string {
    NSRange rng = [self rangeOfString:string options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
    return rng.location != NSNotFound;
}
@end
