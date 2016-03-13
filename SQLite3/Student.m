//
//  Student.m
//  FMDB
//
//  Created by zhuming on 15/12/24.
//  Copyright (c) 2015年 zhuming. All rights reserved.
//

#import "Student.h"

@implementation Student

+ (Student *)creatStudent:(NSString *)name age:(NSString *)age address:(NSString *)address{
    Student *model = [[Student alloc] init];
    model.name = name;
    model.age = age;
    model.address = address;
    return model;
}

@end
