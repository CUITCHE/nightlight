//
//  CHDBTeacherDataModel.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import "NLDataModel.h"

NLDBTable(teacher)

@interface CHDBTeacherDataModel : NLDataModel <__teacher__>

@property (nonatomic, strong) NSNumber<_primary_key> *id;
@property (nonatomic, strong) NSNumber<_foreign_key> *courseId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *hiringDateTime;
@property (nonatomic, strong) NSData *headImage;
@property (nonatomic, strong) NSDecimalNumber *slary;

@property (nonatomic) int a;
@property (nonatomic) float b;
@property (nonatomic) double c;
@property (nonatomic) BOOL d;
@property (nonatomic) NSInteger e;

@end
