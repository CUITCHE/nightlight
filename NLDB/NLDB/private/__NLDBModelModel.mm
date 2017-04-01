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
#import "__NLDBPrimitiveTypeTuple.h"

using namespace std;

extern __NLDBModelModel* contactClass(Class cls);

static NSArray<Class> *__NLDBDataModelAllowedTypes = @[[NSNumber class], [NSString class], [NSMutableString class],
                                                       [NSData class], [NSMutableData class], [NSDate class],
                                                       [NSDecimalNumber class]];
static NSDictionary<NSString *, __NLDBPrimitiveTypeTuple *> *__NLDBDataModelPrimitives
= @{@"f": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Float typeString:@"float"],
    @"d": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Double typeString:@"double"],
    @"i": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Int typeString:@"int"],
    @"I": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Int typeString:@"unsgined int"],
    @"s": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::SmallInt typeString:@"short"],
    @"S": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::SmallInt typeString:@"unsgined short"],
    @"l": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Integer typeString:@"NSInteger"],
    @"L": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Integer typeString:@"NSUInteger"],
    @"q": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::BigInt typeString:@"long long"],
    @"Q": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::UnsignedBigInt typeString:@"unsgined long long"],
    @"B": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::Boolean typeString:@"BOOL"],
    @"c": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::TinyInt typeString:@"char"],
    @"C": [__NLDBPrimitiveTypeTuple tupleWithType:__SqlType::TinyInt typeString:@"unsigned char"]};

using __NLDBPropertyString = NSString *;


@interface __NLDBModelModel ()

@property (nonatomic) Class modelClass;
@property (nonatomic, strong) NSMutableDictionary<__NLDBPropertyString, __NLDBDataModelClassProperty *> *propertyIndex;
@property (nonatomic, strong) NSMutableArray<__NLDBDataModelClassProperty *> *order_property;
@property (nonatomic, copy) NSString *sqliteSql;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSArray<NSString *> *properties;
@property (nonatomic, strong) NSArray<NSString *> *propertiesExcludesAutomaticIncreasement;

@property (nonatomic) BOOL flag_confirmTableName;
@property (nonatomic) BOOL flag_confirmNSStringSizeConnectsToKey;
@property (nonatomic) BOOL flag_confirmNSNumberTypeConnectsToKey;
@property (nonatomic) BOOL flag_confirmForeignKeyConnectToKey;
@property (nonatomic) BOOL flag_confirmCheckConstraintsConnectToKey;
@property (nonatomic) BOOL flag_confirmDefaultConstraintsConnectToKey;
@property (nonatomic) BOOL flag_confirmWhetherIgnoreProperty;

@end

@implementation __NLDBModelModel

- (instancetype)initWithModelClass:(Class)cls
{
    if (self = [super init]) {
        _modelClass = cls;
        _propertyIndex = [NSMutableDictionary dictionary];
        _order_property = [NSMutableArray array];
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
            if ([scanner scanString:@"@\"" intoString:&propertyType]) {
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                mcp.type = NSClassFromString(propertyType);
                while ([scanner scanString:@"<" intoString:nil]) {
                    NSAssert(mcp.type, @"Undefined class type:%@", propertyType);
                    if (![__NLDBDataModelAllowedTypes containsObject:mcp.type]) {
                        [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support %@. See supported tpye:%@", propertyType, __NLDBDataModelAllowedTypes];
                    }

                    NSString *protocolDescription = nil;
                    [scanner scanUpToString:@">" intoString:&protocolDescription];
                    NSArray<NSString *> *protocolNames = [protocolDescription componentsSeparatedByString:@","];
                    if ([protocolNames containsObject:@"_ignore"]) {
                        mcp = nil;
                        goto __add_mcp__;
                    }

                    if ([protocolNames containsObject:@"_primary_key"]) {
                        mcp.is_pk = 1;
                        goto __add_mcp__;
                    }
                    if ([protocolNames containsObject:@"_foreign_key"]) {
                        mcp.is_fk = 1;
                        goto __add_mcp__;
                    }
                    if ([protocolNames containsObject:@"_null"]) {
                        mcp.is_null = 1;
                        goto __add_mcp__;
                    }
                    if ([protocolNames containsObject:@"_check"]) {
                        mcp.is_check = 1;
                        goto __add_mcp__;
                    }
                    if ([protocolNames containsObject:@"_default"]) {
                        mcp.is_default = 1;
                        goto __add_mcp__;
                    }
                }
            } else if ([scanner scanString:@"{" intoString:nil]) {
                [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support structure."];
            } else {
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                __NLDBPrimitiveTypeTuple *ptt = __NLDBDataModelPrimitives[propertyType];
                if (!ptt) {
                    [NSException raise:@"NLDB Data type is not allowed" format:@"NLDB don't support type-coding:%@ for index(%u) of class(%@).", propertyType, i, NSStringFromClass(cls)];
                }
                mcp.RAIIType = ptt;
            }
        __add_mcp__:
            if (mcp) {
                [_propertyIndex setObject:mcp forKey:mcp.name];
                [_order_property addObject:mcp];
            }
        }
        free(properties);
        cls = [cls superclass];
    }
    [self __method_responds__];
    _tableName = [self __find_tablename__];
}

- (void)__method_responds__
{
    self.flag_confirmTableName = [self.modelClass respondsToSelector:@selector(confirmTableName)];
    self.flag_confirmNSStringSizeConnectsToKey = [self.modelClass respondsToSelector:@selector(confirmNSStringSizeConnectsToKey:)];
    self.flag_confirmNSNumberTypeConnectsToKey = [self.modelClass respondsToSelector:@selector(confirmNSNumberTypeConnectsToKey:)];
    self.flag_confirmForeignKeyConnectToKey = [self.modelClass respondsToSelector:@selector(confirmForeignKeyConnectToKey:)];
    self.flag_confirmCheckConstraintsConnectToKey = [self.modelClass respondsToSelector:@selector(confirmCheckConstraintsConnectToKey:)];
    self.flag_confirmDefaultConstraintsConnectToKey = [self.modelClass respondsToSelector:@selector(confirmDefaultConstraintsConnectToKey:)];
    self.flag_confirmWhetherIgnoreProperty = [self.modelClass respondsToSelector:@selector(confirmWhetherIgnoreProperty:)];
}

- (NSString *)__find_tablename__
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
        if (!!class_getClassMethod(self.modelClass, @selector(confirmTableName))) {
            tableName = [self.modelClass confirmTableName];
        }
        if (!tableName) {
            [NSException raise:@"NLDB syntax error" format:@"There is not a vaild table name for model:%@", NSStringFromClass(self.modelClass)];
        }
    }
    return tableName;
}

- (void)__columnToNSStringClass:(__NLDBDataModelClassProperty *)mcp maker:(__SqlDDL &)maker
{
    tuple<NLDBStringType, NSUInteger> capacity(NLDBStringTypePureText, -1);
    if (self.flag_confirmNSStringSizeConnectsToKey) {
        capacity = [self.modelClass confirmNSStringSizeConnectsToKey:mcp.name];
    }
    __SqlType sqlType = __SqlType::Int;
    switch (get<0>(capacity)) {
        case NLDBStringTypePureText:
            sqlType = __SqlType::Text;
            break;
        case NLDBStringTypeChar:
            sqlType = __SqlType::Char;
            break;
        case NLDBStringTypeUnicodeChar:
            sqlType = __SqlType::NChar;
            break;
        case NLDBStringTypeVarchar:
            sqlType = __SqlType::Varchar;
            break;
        case NLDBStringTypeUnicodeVarchar:
            sqlType = __SqlType::NVarchar;
            break;
        default:
            break;
    }
    maker.column(mcp.name, sqlType, capacity);
}

- (void)__columnToNSDataClass:(__NLDBDataModelClassProperty *)mcp maker:(__SqlDDL &)maker
{
    maker.column(mcp.name, __SqlType::Blob);
}

- (void)__columnToNSDateClass:(__NLDBDataModelClassProperty *)mcp maker:(__SqlDDL &)maker
{
    maker.column(mcp.name, __SqlType::DateTime);
}

- (void)__columnToNSDecimalNumberClass:(__NLDBDataModelClassProperty *)mcp maker:(__SqlDDL &)maker
{
    maker.column(mcp.name, __SqlType::Decimal);
}

- (void)__columnToNSNumberClass:(__NLDBDataModelClassProperty *)mcp maker:(__SqlDDL &)maker
{
    if (self.flag_confirmNSNumberTypeConnectsToKey) {
        const char *type = [self.modelClass confirmNSNumberTypeConnectsToKey:mcp.name];
        __NLDBPrimitiveTypeTuple *ptt = __NLDBDataModelPrimitives[@(type)];
        if (ptt) {
            maker.column(mcp.name, ptt.type);
        } else {
            [NSException raise:@"NLDB NSNumber type not allowed" format:@"%s is not be supported.", type];
        }
    } else {
        if (mcp.is_pk) {
            maker.column(mcp.name, __SqlType::Integer);
        } else {
            maker.column(mcp.name, __SqlType::Double);
        }
    }
}

- (void)__parse__
{
    __SqlDDL maker;
    NSInteger has_a_fk = 0;
    maker.create(self.tableName);
    for (__NLDBDataModelClassProperty *obj in _order_property) {
        if (obj.is_ignore) {
            goto __end__;
        }
        if (self.flag_confirmWhetherIgnoreProperty) {
            if ([self.modelClass confirmWhetherIgnoreProperty:obj.name]) {
                continue;
            }
        }
        // make column name and type
        if (obj.type) { // this is an Objective-C object.
            Class cls = obj.type;
            if ([cls isSubclassOfClass:[NSString class]]) {
                [self __columnToNSStringClass:obj maker:maker];
            } else if ([cls isSubclassOfClass:[NSData class]]) {
                [self __columnToNSDataClass:obj maker:maker];
            } else if ([cls isSubclassOfClass:[NSDate class]]) {
                [self __columnToNSDateClass:obj maker:maker];
            } else if ([cls isSubclassOfClass:[NSDecimalNumber class]]) {
                [self __columnToNSDecimalNumberClass:obj maker:maker];
            } else if ([cls isSubclassOfClass:[NSNumber class]]) {
                [self __columnToNSNumberClass:obj maker:maker];
            }
        } else {
            NSAssert(obj.RAIIType, @"RAIIType must not be nil when obj's type is nil.");
            maker.column(obj.name, obj.RAIIType.type);
        }
        // add constraints
        if (obj.is_pk) { // primary key
            maker.pk();
            // Syntax check.
            if (obj.is_null) {
                [NSException raise:@"NLDB SQL Sytax Error" format:@"A primary key is non-null, but you specified it to null."];
            }
            goto __end__;
        }

        if (obj.is_fk) {
            ++has_a_fk;
            // Syntax check.
            if (obj.is_null) {
                [NSException raise:@"NLDB SQL Sytax Error" format:@"A foreign key is non-null, but you specified it to null."];
            }
            goto __end__;
        }

        if (obj.is_default) {
            if (self.flag_confirmDefaultConstraintsConnectToKey) {
                id def = [self.modelClass confirmDefaultConstraintsConnectToKey:obj.name];
                maker.Default(def);
            } else {
                [NSException raise:@"NLDB SQL Sytax Error" format:@"You'd better to implement method:+(id)confirmDefaultConstraintsConnectToKey:"];
            }
            goto __end__;
        }

        if (obj.is_check) {
            if (self.flag_confirmCheckConstraintsConnectToKey) {
                NSString *statement = [self.modelClass confirmCheckConstraintsConnectToKey:obj.name];
                maker.check(statement);
            } else {
                [NSException raise:@"NLDB SQL Sytax Error" format:@"You'd better to implement method:+(NSString *)confirmCheckConstraintsConnectToKey:"];
            }
        }

    __end__:
        if (!obj.is_null) {
            maker.nonull();
        }
    };
    if (has_a_fk) {
        for (__NLDBDataModelClassProperty *obj in _order_property) {
            if (!obj.is_fk) {
                continue;
            }
            if (self.flag_confirmForeignKeyConnectToKey) {
                tuple<Class, NSString *> package = [self.modelClass confirmForeignKeyConnectToKey:obj.name];
                Class __cls = get<0>(package);
                __NLDBModelModel *mm = contactClass(__cls);
                NSString *field = get<1>(package);
                if (!mm.propertyIndex[field]) {
                    [NSException raise:@"NLDB SQL Sytax Error" format:@"Target model(%@) has not a property named %@", NSStringFromClass(__cls), field];
                }
                maker.fk(obj.name, field, mm.tableName);
            } else {
                [NSException raise:@"NLDB SQL Sytax Error" format:@"You'd better to implement method:+(tuple<Class, NSString *>)confirmForeignKeyConnectToKey:"];
            }
            if (!--has_a_fk) {
                break;
            }
        };
    }
    maker.end();
    _sqliteSql = maker.getClause();
}

#pragma mark - property
- (NSString *)sqliteSql
{
    if (_sqliteSql.length == 0) {
        [self __parse__];
    }
    return _sqliteSql.copy;
}

- (NSArray<NSString *> *)properties
{
    if (!_properties) {
        _properties = self.propertyIndex.allKeys;
    }
    return _properties;
}

- (NSArray<NSString *> *)propertiesExcludesAutomaticIncreasement
{
    if (_propertiesExcludesAutomaticIncreasement == nil) {
        NSMutableArray<NSString *> *res = [NSMutableArray arrayWithCapacity:_order_property.count];
        for (__NLDBDataModelClassProperty *mcp in _order_property) {
            if (mcp.is_pk && mcp.RAIIType.type == __SqlType::Integer) {
                // this is sqlite. when type is integer and constraints with primary key.
                continue;
            }
            [res addObject:mcp.name];
        }
        _propertiesExcludesAutomaticIncreasement = res;
    }
    return _propertiesExcludesAutomaticIncreasement;
}

@end

NSString *__log(Class modelClass, NSArray *modelObject, int flag)
{
    if (![modelClass isSubclassOfClass:[NLDataModel class]]) {
        return nil;
    }
    if (modelClass == [NLDataModel class]) {
        return @"";
    }
    __NLDBModelModel *mm = contactClass(modelClass);
    // init with header
    NSMutableString *logString = [NSMutableString stringWithFormat:@"|%@\n",[mm.properties componentsJoinedByString:@"\t\t|"]];
    for (id obj in modelObject) {
        NSMutableArray<NSString *> *component = [NSMutableArray arrayWithCapacity:mm.properties.count];
        for (__NLDBDataModelClassProperty *mcp in mm.order_property) {
            NSString *str = [NSString stringWithFormat:@"%@", [obj valueForKey:mcp.name]];
            if (flag == 0 && str.length > 8) {
                str = [str stringByReplacingCharactersInRange:NSMakeRange(8, str.length - 8) withString:@"..."];
            }
            [component addObject:str];
        }
        [logString appendFormat:@"|%@\n", [component componentsJoinedByString:@"\t\t|"]];
    }

    return logString;
}
