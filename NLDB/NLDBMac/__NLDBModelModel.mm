//
//  __NLDBModelModel.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__NLDBModelModel.h"
#include <objc/runtime.h>
#import "NLDataModel.h"
#import "__NLDBDataModelClassProperty.h"
#import "__SqlDDL.h"

static NSArray<Class> *__NLDBDataModelAllowedTypes = @[[NSNumber class], [NSString class], [NSMutableString class],
                                                      [NSData class], [NSMutableData class], [NSDate class],
                                                      [NSDecimalNumber class]];

@interface __NLDBModelModel ()

@property (nonatomic) Class modelClass;
@property (nonatomic, strong) NSMutableDictionary<NSString *, __NLDBDataModelClassProperty *> *propertyIndex;
@property (nonatomic, copy) NSString *sqliteSql;

@end

@implementation __NLDBModelModel

- (instancetype)initWithModelClass:(Class)cls
{
    if (self = [super init]) {
        _modelClass = cls;
        _propertyIndex = [NSMutableDictionary dictionary];
        [self __init__];
    }
    return self;
}

- (void)__init__
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
                    break;
                }
            } else if ([scanner scanString:@"{" intoString:nil]) {
                [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support structure."];
            } else {
                [scanner scanCharactersFromSet:[NSCharacterSet alphanumericCharacterSet] intoString:&propertyType];
            }
            [_propertyIndex setObject:mcp forKey:mcp.name];
        }
        free(properties);
        cls = [cls superclass];
    }
}

- (NSString *)parseForTableName
{
    unsigned int count = 0;
    NSString *tableName = nil;
    // try to find table name from protocols.
    Protocol *__unsafe_unretained * protocol = class_copyProtocolList(self.modelClass, &count);
    for (unsigned int i=0; i<count; ++i) {
        NSString *pName = @(protocol_getName(protocol[i]));
        if ([pName hasPrefix:@"__"] && [pName hasSuffix:@"__"]) {
            tableName = [pName substringFromIndex:2];
            if (tableName.length > 2) {
                tableName = [tableName substringToIndex:tableName.length - 2];
            }
            if (tableName.length == 0) {
                tableName = nil;
            }
        }
    }
    if (protocol) {
        free(protocol);
    }
    if (!tableName) { // try to find table name from method
        if (class_respondsToSelector(self.modelClass, @selector(confirmTableName))) {
            tableName = [self.modelClass confirmTableName];
        }
    }
    if (!tableName) {
        [NSException raise:@"NLDB syntax error" format:@"There is not a vaild table name for model:%@", NSStringFromClass(self.modelClass)];
    }
    return tableName;
}

- (void)parse
{
    NSMutableString *sql = [NSMutableString stringWithString:@"CREATE TABLE"];
}

- (NSString *)sqliteSql
{
    if (_sqliteSql.length == 0) {
        [self parse];
    }
    return _sqliteSql.copy;
}

@end
