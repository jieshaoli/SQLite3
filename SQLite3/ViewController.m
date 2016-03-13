//
//  ViewController.m
//  SQLite3
//
//  Created by zhuming on 16/1/4.
//  Copyright (c) 2016年 zhuming. All rights reserved.
//

#import "ViewController.h"
#import <sqlite3.h>
#import "Student.h"

#define FILE_NAME   @"SQLtest"
#define TABLE_NAME  @"SQLtest"

@interface ViewController (){
    sqlite3 *dataBase;
}
@property (nonatomic,strong)NSArray *nameArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameArray = @[@"①",@"②",@"③",@"④",@"⑤",@"⑥"];
    NSLog(@"FilePath = %@",[self getFilePath:FILE_NAME]);
    [self creatDataBase];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  根据文件名获取文件路径
 *
 *  @param fileName 文件名
 *
 *  @return 返回文件路径
 */
- (NSString *)getFilePath:(NSString *)fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documetsDirectory = [paths objectAtIndex:0];
    return [documetsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",fileName]];
}
/**
 *  打开数据库
 *
 *  @return YES:打开成功  NO:打开失败
 */
- (BOOL)openDataBase{
    int result = sqlite3_open([self getFilePath:FILE_NAME].UTF8String, &dataBase);
    if (result == SQLITE_OK) {
        NSLog(@"数据库打开成功");
        return YES;
    }
    else{
        NSLog(@"数据库打开失败");
        return NO;
    }
}
/**
 *  关闭数据库
 */
- (void)closeDataBase{
    sqlite3_close(dataBase);
}
/**
 *  数据库中创建表
 */
- (void)creatDataBase{
    if (![self openDataBase]) {
        return;
    }
    NSString *creatSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (rowid INTEGER PRIMARY KEY AUTOINCREMENT, name text,age text,address text)",TABLE_NAME];
    char *errorMsg;
    int result = sqlite3_exec(dataBase, creatSQL.UTF8String, NULL, NULL, &errorMsg);
    if (result == SQLITE_OK) {
        [self closeDataBase];
        NSLog(@"表单：%@创建成功",TABLE_NAME);
    }
    else{
        NSLog(@"表单：%@创建失败：%s",TABLE_NAME,errorMsg);
    }
}
/**
 *  以学生模型插入数据库
 *
 *  @param student 学生数据模型
 */
- (void)insterStudent:(Student *)student{
    if (![self openDataBase]) {
        return;
    }
    NSString *insterSQL = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (name,age,address) VALUES (?,?,?)",TABLE_NAME];
    char *errorMsg;
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, insterSQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        sqlite3_bind_text(stmt, 1, student.name.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 2, student.age.UTF8String, -1, nil);
        sqlite3_bind_text(stmt, 3, student.address.UTF8String, -1, nil);
    }
    if (sqlite3_step(stmt) != SQLITE_DONE) {
        NSLog(@"数据插入失败：%s",errorMsg);
    }
    else NSLog(@"数据插入成功");
    sqlite3_finalize(stmt);
    [self closeDataBase];
}
/**
 *  更新一个学生的数据
 *
 *  @param student 学生数据模型
 */
- (void)updateStudent:(Student *)student{
    if (![self openDataBase]) {
        return;
    }
    NSString *updateSQL = [NSString stringWithFormat:@"UPDATE %@ SET age = '%@' WHERE name = '%@'",TABLE_NAME,student.age,student.name];
    char *errorMsg;
    if (sqlite3_exec(dataBase, updateSQL.UTF8String, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"数据更新成功");
        [self closeDataBase];
    }
    else{
        NSLog(@"数据修改失败：%s",errorMsg);
    }
}
/**
 *  根据姓名删除学生
 *
 *  @param student 学生模型
 */
- (void)deleteStudent:(Student *)student{
    if (![self openDataBase]) {
        return;
    }
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE name = '%@'",TABLE_NAME,student.name];
    char *errorMsg;
    if (sqlite3_exec(dataBase, deleteSQL.UTF8String, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"数据删除成功");
        [self closeDataBase];
    }
    else{
        NSLog(@"数据删除失败：%s",errorMsg);
    }
}
/**
 *  删除全部数据
 */
- (void)deleteAllStudent{
    if (![self openDataBase]) {
        return;
    }
    NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@ WHERE 1>0",TABLE_NAME];
    char *errorMsg;
    if (sqlite3_exec(dataBase, deleteSQL.UTF8String, NULL, NULL, &errorMsg) == SQLITE_OK) {
        NSLog(@"数据删除成功");
        [self closeDataBase];
    }
    else{
        NSLog(@"数据删除失败：%s",errorMsg);
    }
}
/**
 *  根据学生姓名查找学生
 *
 *  @param student 学生数据模型
 *
 *  @return 同一个姓名的学生
 */
- (NSMutableArray *)selectStudent:(Student *)student{
    if (![self openDataBase]) {
        return nil;
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *selecteSQL = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE name = '%@'",TABLE_NAME,student.name];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, selecteSQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        NSLog(@"筛选成功");
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableString *name=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSMutableString *age=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *address=[NSString stringWithCString:(char*)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            Student *stu = [Student creatStudent:name age:age address:address];
            [dataArray addObject:stu];
        }
        sqlite3_finalize(stmt);
        [self closeDataBase];
        return dataArray;
    }
    else{
        NSLog(@"筛选失败");
        return nil;
    }
}
/**
 *  获取数据库里面的全部数据
 *
 *  @return 学生数据的集合
 */
- (NSMutableArray *)selectAllStudent{
    if (![self openDataBase]) {
        return nil;
    }
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSString *selecteSQL = [NSString stringWithFormat:@"SELECT * FROM %@",TABLE_NAME];
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(dataBase, selecteSQL.UTF8String, -1, &stmt, nil) == SQLITE_OK) {
        NSLog(@"筛选成功");
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            NSMutableString *name=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 1) encoding:NSUTF8StringEncoding];
            NSMutableString *age=[NSMutableString stringWithCString:(char*)sqlite3_column_text(stmt, 2) encoding:NSUTF8StringEncoding];
            NSString *address=[NSString stringWithCString:(char*)sqlite3_column_text(stmt, 3) encoding:NSUTF8StringEncoding];
            Student *stu = [Student creatStudent:name age:age address:address];
            [dataArray addObject:stu];
        }
        sqlite3_finalize(stmt);
        [self closeDataBase];
        return dataArray;
    }
    else{
        NSLog(@"筛选失败");
        return nil;
    }
}

/**
 *  随机生成一个学生数据模型
 *
 *  @return 学生数据模型
 */
- (Student *)getStudent{
    Student *student = [Student creatStudent:self.nameArray[arc4random()%6] age:[NSString stringWithFormat:@"%u",arc4random()%100] address:[NSString stringWithFormat:@"%u",arc4random()%1000]];
    return student;
}

/**
 *  插入数据库按钮按下
 *
 *  @param sender sender description
 */
- (IBAction)insterBtnClick:(UIButton *)sender {
    [self insterStudent:[self getStudent]];
    
}
/**
 *  更新数据
 *
 *  @param sender sender description
 */
- (IBAction)modifyBtnClick:(UIButton *)sender {
    [self updateStudent:[Student creatStudent:@"④" age:@"1" address:@"深圳"]];
}
/**
 *  从数据库删除数据
 *
 *  @param sender sender description
 */
- (IBAction)deleteBtnClick:(UIButton *)sender {
    [self deleteStudent:[Student creatStudent:@"②" age:nil address:nil]];
}
/**
 *  清空数据库
 *
 *  @param sender sender description
 */
- (IBAction)clearAll:(UIButton *)sender {
    [self deleteAllStudent];
}
/**
 *  查找同一个姓名的学生
 *
 *  @param sender sender description
 */
- (IBAction)selectBtnClick:(UIButton *)sender {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self selectStudent:[Student creatStudent:@"①" age:nil address:nil]]];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Student *student = (Student *)obj;
        NSLog(@"name = %@",student.name);
        NSLog(@"age = %@",student.age);
        NSLog(@"address = %@",student.address);
    }];
}

/**
 *  获取全部数据
 *
 *  @param sender sender description
 */
- (IBAction)selectAllBtnClick:(UIButton *)sender {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[self selectAllStudent]];
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Student *student = (Student *)obj;
        NSLog(@"name = %@",student.name);
        NSLog(@"age = %@",student.age);
        NSLog(@"address = %@",student.address);
    }];
}
@end
