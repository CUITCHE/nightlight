//
//  __NLDBDataModelClassProperty.h
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class __NLDBPrimitiveTypeTuple;

@interface __NLDBDataModelClassProperty : NSObject

@property (nonatomic) BOOL is_pk;
@property (nonatomic) BOOL is_fk;
@property (nonatomic) BOOL is_null;
@property (nonatomic) BOOL is_check;
@property (nonatomic) BOOL is_default;
@property (nonatomic) BOOL is_ignore;

@property (nonatomic) BOOL is_mutable;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, nullable) Class type;
@property (nonatomic, strong, nullable) __NLDBPrimitiveTypeTuple *RAIIType;

@end

NS_ASSUME_NONNULL_END
