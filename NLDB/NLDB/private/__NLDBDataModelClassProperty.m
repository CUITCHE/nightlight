//
//  __NLDBDataModelClassProperty.m
//  NLDB
//
//  Created by hejunqiu on 2017/3/27.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "__NLDBDataModelClassProperty.h"

struct __NLDBDataModelClassPropertyFlags {
    NSInteger _pk : 1;
    NSInteger _fk : 1;
    NSInteger _null : 1;
    NSInteger _check : 1;
    NSInteger _default : 1;
    NSInteger _mutable : 1;
    NSInteger _ignore : 1;
};

@interface __NLDBDataModelClassProperty ()
{
    struct __NLDBDataModelClassPropertyFlags _flags;
}

@end

@implementation __NLDBDataModelClassProperty

- (BOOL)is_pk
{
    return _flags._pk;
}

- (BOOL)is_fk
{
    return _flags._fk;
}

- (BOOL)is_null
{
    return _flags._null;
}

- (BOOL)is_check
{
    return _flags._check;
}

- (BOOL)is_default
{
    return _flags._default;
}

- (BOOL)is_ignore
{
    return _flags._ignore;
}

- (BOOL)is_mutable
{
    return _flags._mutable;
}

- (void)setIs_pk:(BOOL)is_pk
{
    _flags._pk = is_pk;
}

- (void)setIs_fk:(BOOL)is_fk
{
    _flags._fk = is_fk;
}

- (void)setIs_null:(BOOL)is_null
{
    _flags._null = is_null;
}

- (void)setIs_check:(BOOL)is_check
{
    _flags._check = is_check;
}

- (void)setIs_default:(BOOL)is_default
{
    _flags._default = is_default;
}

- (void)setIs_ignore:(BOOL)is_ignore
{
    _flags._ignore = is_ignore;
}

- (void)setIs_mutable:(BOOL)is_mutable
{
    _flags._mutable = is_mutable;
}

@end
