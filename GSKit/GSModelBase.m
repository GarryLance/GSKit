//
//  GSModelBase.m
//  GSKitDemo
//
//  Created by OSU on 16/7/27.
//  Copyright © 2016年 GarryLance. All rights reserved.
//

#import "GSModelBase.h"
#import "GSDefine.h"
#import <objc/runtime.h>

@interface GSModelBase ()
{
    NSUInteger gs_hash;
}

@end


@implementation GSModelBase

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        //哈希值设置为自己的地址
        gs_hash = (NSUInteger)self;
    }
    return self;
}


- (NSString *)description
{
#ifdef DEBUG
    NSMutableString *strv = [NSMutableString string];
    
    NSString *tableName = [NSString stringWithUTF8String:class_getName([self class])];
    [strv appendFormat:@"\n--%@: \n",tableName];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        //获取属性名字
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        
        //获取属性类型
        const char *attributes = property_getAttributes(property);
        NSString *propertyType = [NSString stringWithUTF8String:attributes];
        
        if ([propertyType hasPrefix:@"TB"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (BOOL): %d  \n",propertyName,[[self valueForKey:propertyName] intValue]]];
        }
        else if ([propertyType hasPrefix:@"Ti"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (int): %d  \n",propertyName,[[self valueForKey:propertyName] intValue]]];
        }
        else if ([propertyType hasPrefix:@"Td"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (double): %.2lf \n",propertyName,[[self valueForKey:propertyName] doubleValue]]];
        }
        else if ([propertyType hasPrefix:@"Tf"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (float): %.2lf \n",propertyName,[[self valueForKey:propertyName] floatValue]]];
        }
        else if ([propertyType hasPrefix:@"Tq"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (integer): %ld \n",propertyName,(long)[[self valueForKey:propertyName] integerValue]]];
        }
        else if ([propertyType hasPrefix:@"Tc"])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (char): %ld \n",propertyName,(long)[[self valueForKey:propertyName] charValue]]];
        }
        else if ([propertyType hasPrefix:@"T@\"NSArray\""])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (NSArray): [ \n",propertyName]];
            NSArray * array = [self valueForKey:propertyName];
            for (id obj in array)
            {
                [strv appendFormat:@"%@",obj];
            }
            [strv appendString:@"]\n\n"];
        }
        else if ([propertyType hasPrefix:@"T@\"NSString\""])
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (NSString): \"%@\" \n",propertyName,[self valueForKey:propertyName]]];
        }
        else
        {
            [strv appendString:[NSString stringWithFormat:@"%@ (%@): (%@) \n",propertyName,[[[[propertyType componentsSeparatedByString:@"T@\""] lastObject] componentsSeparatedByString:@"\""] firstObject],[self valueForKey:propertyName]]];
        }
    }
    
    return strv;
#endif
    
    return nil;
}


- (BOOL)isEqual:(id)object
{
    if (object && [object isKindOfClass:[self class]])
    {
        BOOL isEqual = YES;
        BLOCK_TYPE(isEqual, _isEqual)
        [self traversePropertyBlock:^(int index, NSString *propertyName, NSString *propertyType, BOOL isModelBaseClass, id value) {
            
            id objectValue = [object valueForKey:propertyName];
            if (![value isEqual:objectValue]
                && !(!value && !objectValue))//排除两者都为nil的情况
            {
                _isEqual = NO;
            }
        }];
        return _isEqual;
    }
    return NO;
}


- (NSUInteger)hash
{
    return self->gs_hash;
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder
{
    [self traversePropertyBlock:^(int index, NSString *propertyName, NSString *propertyType, BOOL isModelBaseClass, id value) {
        
        //归档
        if ([value isKindOfClass:[GSModelBase class]])
        {
            value = [NSKeyedArchiver archivedDataWithRootObject:value];
        }
        if (!value) return;
        [coder encodeObject:value forKey:propertyName];
    }];
}


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self)
    {
        [self traversePropertyBlock:^(int index, NSString *propertyName, NSString *propertyType, BOOL isModelBaseClass, id value) {
            
            //反归档
            id decodeValue = [coder decodeObjectForKey:propertyName];
            if (decodeValue)
            {
                if([propertyType hasPrefix:@"T@\""] &&
                   [NSClassFromString([[[[propertyType componentsSeparatedByString:@"T@\""] lastObject] componentsSeparatedByString:@"\""] firstObject]) isSubclassOfClass:[GSModelBase class]])
                {
                    decodeValue = [NSKeyedUnarchiver unarchiveObjectWithData:decodeValue];
                }
                [self setValue:decodeValue forKey:propertyName];
            }
        }];
    }
    return self;
}


#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    GSModelBase * copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        //浅拷贝对象的哈希值与被拷贝的一致，以用于集合类型key
        copy->gs_hash = self->gs_hash;
        
        [self traversePropertyBlock:^(int index, NSString *propertyName, NSString *propertyType, BOOL isModelBaseClass, id value) {
            
            //浅拷贝
            id copyValue = [value copyWithZone:zone];
            [copy setValue:copyValue forKey:propertyName];
            [copyValue release];
        }];
    }
    return copy;
}


#pragma mark NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    if (copy)
    {
        [self traversePropertyBlock:^(int index, NSString *propertyName, NSString *propertyType, BOOL isModelBaseClass, id value) {
            
            //深拷贝
            id copyValue = [value mutableCopyWithZone:zone];
            [copy setValue:copyValue forKey:propertyName];
            [copyValue release];
        }];
    }
    return copy;
}


#pragma mark Other

/**遍历属性*/
- (void)traversePropertyBlock:(void(^)(int index, NSString * propertyName, NSString * propertyType, BOOL isModelBaseClass, id value))block
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        
        //获取属性名字
        const char         *name = property_getName(property);
        NSString   *propertyName = [NSString stringWithUTF8String:name];
        
        //获取属性类型
        const char *attributes = property_getAttributes(property);
        NSString *propertyType = [NSString stringWithUTF8String:attributes];
        
        //获取属性值
        id value = [self valueForKey:propertyName];
        
        //属性是否子类
        BOOL isModelBaseClass = NO;
        if (value && [propertyType hasPrefix:@"T@\""])
        {
            if([NSClassFromString([[[[propertyType componentsSeparatedByString:@"T@\""] lastObject] componentsSeparatedByString:@"\""] firstObject]) isSubclassOfClass:[GSModelBase class]])
            {
                isModelBaseClass = YES;
            }
        }
        
        if (block)
        {
            block(i,propertyName,propertyType,isModelBaseClass,value);
        }
    }
}

@end
