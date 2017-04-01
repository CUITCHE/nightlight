//
//  CHDBCourseDataModel.h
//  NLDB
//
//  Created by hejunqiu on 2017/4/1.
//  Copyright © 2017年 CHE. All rights reserved.
//

#import <NLDB/NLDB.h>

NLDBTable(course)

@interface CHDBCourseDataModel : NLDataModel <__course__>

@property (nonatomic, strong) NSNumber<_primary_key> *id;

@end
