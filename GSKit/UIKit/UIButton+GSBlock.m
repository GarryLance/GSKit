//
//  UIButton+GSBlock.m
//  zaozao
//
//  Created by OSU on 16/5/25.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "UIButton+GSBlock.h"
#import <objc/runtime.h>

@interface UIButton ()

@property(strong,nonatomic) NSMutableDictionary * buttonBLockDictionary;

@end



@implementation UIButton (GSBlock)


static char GSButtonBLockDictionary;


- (void)setButtonBLockDictionary:(NSMutableDictionary *)buttonBLockDictionary
{
    [self willChangeValueForKey:@"buttonBLockDictionary"];
    objc_setAssociatedObject(self, &GSButtonBLockDictionary, buttonBLockDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"buttonBLockDictionary"];
}


- (NSMutableDictionary *)buttonBLockDictionary
{
    return objc_getAssociatedObject(self, &GSButtonBLockDictionary);
}


- (void)addAction:(GSActionBlock)block forControlEvents:(UIControlEvents)controlEvents
{
    if (!self.buttonBLockDictionary)
    {
        self.buttonBLockDictionary = [NSMutableDictionary dictionary];
    }
    [self.buttonBLockDictionary setObject:block forKey:[NSNumber numberWithUnsignedInteger:controlEvents]];
    [self addTarget:self action:@selector(blockAction:) forControlEvents:controlEvents];
}


- (void)blockAction:(UIButton *)sender
{
    for (NSNumber * number in self.buttonBLockDictionary)
    {
        NSUInteger controlEvents = [number unsignedIntegerValue];
        if (controlEvents & sender.allControlEvents)
        {
            GSActionBlock block = [self.buttonBLockDictionary objectForKey:[NSNumber numberWithUnsignedInteger:controlEvents]];
            block(sender);
            break;
        }
    }
}


@end
