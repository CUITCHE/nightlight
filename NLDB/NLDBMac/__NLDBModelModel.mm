//
//  __NLDBModelModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__NLDBModelModel.h"
#import "__NLDBDataModelClassProperty.h"
#import "NLDataModel.h"
#include <objc/runtime.h>

static NSArray<Class> *__NLDBDataModelAllowedTypes = @[[NSNumber class], [NSString class], [NSMutableString class],
                                                      [NSData class], [NSMutableData class], [NSDate class],
                                                      [NSDecimalNumber class]];

@interface __NLDBModelModel ()

@property (nonatomic) Class modelClass;
@property (nonatomic, strong) NSMutableDictionary<NSString *, __NLDBDataModelClassProperty *> *propertyIndex;

@property (nonatomic) BOOL has_pk;
@end

@implementation __NLDBModelModel

- (instancetype)initWithModelClass:(Class)cls
{
    if (self = [super init]) {
        _modelClass = cls;
        _propertyIndex = [NSMutableDictionary dictionary];
        [self ___];
    }
    return self;
}

- (void)___
{
    if (![self.modelClass isSubclassOfClass:[NLDataModel class]]) {
        NSAssert(NO, @"Class must be inherited by NLDataModel");
        return;
    }
    Class cls = self.modelClass;
    while (cls != [NLDataModel class]) {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for (unsigned int i=0; i<propertyCount; ++i) {
            objc_property_t property = properties[i];
            const char *attrs = property_getAttributes(property);
            NSString *propertyAttributes = @(attrs);
            NSArray<NSString *> *attributeItems = [propertyAttributes componentsSeparatedByString:@","];

            if ([attributeItems containsObject:@"R"]) {
                continue;
            }
            __NLDBDataModelClassProperty *mcp = [[__NLDBDataModelClassProperty alloc] init];
            mcp.type = cls;
            mcp.name = @(property_getName(property));

            NSScanner *scanner = [NSScanner scannerWithString:propertyAttributes];
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            NSString *propertyType = nil;
            if ([scanner scanUpToString:@"\"" intoString:&propertyType]) {
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                while ([scanner scanString:@"<" intoString:nil]) {
                    mcp.type = NSClassFromString(propertyType);
                    if (![__NLDBDataModelAllowedTypes containsObject:mcp.type]) {
                        [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support %@. See supported tpye:%@", propertyType, __NLDBDataModelAllowedTypes];
                    }

                    NSString *protocolDescription = nil;
                    [scanner scanUpToString:@">" intoString:&protocolDescription];
                    NSArray<NSString *> *protocolNames = [protocolDescription componentsSeparatedByString:@","];
                    if ([protocolNames containsObject:@"_ignore"]) {
                        mcp.is_ignore = 1;
                        break;
                    }

                    if ([protocolNames containsObject:@"_primary_key"]) {
                        if (self.has_pk) {
                            [NSException raise:@"NLDB build syntax" format:@"There has existed a primary key:%@", [self __pk_info]];
                        }
                        mcp.is_pk = 1;
                        goto secodPriority;
                    }
                    if ([protocolNames containsObject:@"_foreign_key"]) {
                        mcp.is_fk = 1;
                    }
                secodPriority:
                    if ([protocolNames containsObject:@"_null"]) {
                        mcp.is_null = 1;
                        goto constraints_end;
                    }
                    if ([protocolNames containsObject:@"_check"]) {
                        mcp.is_check = 1;
                        goto constraints_end;
                    }
                    if ([protocolNames containsObject:@"_default"]) {
                        mcp.is_default = 1;
                        goto constraints_end;
                    }
                constraints_end:
                    [_propertyIndex setObject:mcp forKey:mcp.name];
                    break;
                }
            } else if ([scanner scanString:@"{" intoString:nil]) {
                [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support structure."];
            } else {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&propertyType];
            }
        }
        free(properties);
        cls = [cls superclass];
    }
}

- (NSString *)__pk_info
{
    __block NSString *msg = nil;
    [self.propertyIndex enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, __NLDBDataModelClassProperty * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.is_pk) {
            *stop = YES;
            msg = key;
        }
    }];
    return msg;
}

@end
