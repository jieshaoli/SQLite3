//
//  Student.h
//  FMDB
//
//  Created by zhuming on 15/12/24.
//  Copyright (c) 2015年 zhuming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

/**
 *  姓名
 */
@property (nonatomic,copy)NSString *name;
/**
 *  年龄
 */
@property (nonatomic,copy)NSString *age;
/**
 *  地址
 */
@property (nonatomic,copy)NSString *address;


+ (Student *)creatStudent:(NSString *)name age:(NSString *)age address:(NSString *)address;



@end
