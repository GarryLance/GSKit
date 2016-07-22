//
//  GSTool.m
//  zaozao
//
//  Created by OSU on 16/5/13.
//  Copyright © 2016年 miao. All rights reserved.
//

#import "GSTool.h"

@implementation GSTool

+ (UIViewController *)findViewController:(UIResponder *)responder
{
    if([responder.nextResponder isKindOfClass:[UIViewController class]])
    {
        return (UIViewController *)responder.nextResponder;
    }
    else
    {
        return [self findViewController:responder.nextResponder];
    }
}

@end
