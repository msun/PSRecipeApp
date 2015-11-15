//
//  PSAddRowTableViewCell.m
//  PSRecipeApp
//
//  Created by Matthew Sun on 11/14/15.
//  Copyright © 2015 Matthew Sun. All rights reserved.
//

#import "PSAddRowTableViewCell.h"

@interface PSAddRowTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@end

@implementation PSAddRowTableViewCell

- (void)awakeFromNib {
    self.addButton.userInteractionEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
