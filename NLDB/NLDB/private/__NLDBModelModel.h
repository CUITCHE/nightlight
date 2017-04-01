//
//  __NLDBModelModel.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class __NLDBDataModelClassProperty;

@interface __NLDBModelModel : NSObject

@property (nonatomic, readonly) Class modelClass;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, __NLDBDataModelClassProperty *> *propertyIndex;

@property (nonatomic, copy, readonly) NSString *sqliteSql;
@property (nonatomic, strong, readonly) NSString *tableName;

@property (nonatomic, strong, readonly) NSArray<NSString *> *properties;

- (instancetype)initWithModelClass:(Class)cls;

@end

NS_ASSUME_NONNULL_END
