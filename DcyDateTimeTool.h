//
//  DcyDateTimeTool.h
//  DatePickerView
//
//  Created by  on 2020/2/18.
//  Copyright © 2020 . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DcyDateTimeTool : NSObject
//获取年月日对象
+ (NSDateComponents *)getDateComponents:(NSDate *)date;
//获得某年的周数
+ (NSInteger)getWeek_AccordingToYear:(NSInteger)year;
/**
 *  获取某年某周的范围日期
 *
 *  @param year       年份
 *  @param weekofYear year里某个周
 *
 *  @return 时间范围字符串
 */
+(NSString*)getWeekRangeDate_Year:(NSInteger)year WeakOfYear:(NSInteger)weekofYear;

// 获取某个日期当前周的 第一天 和最后一天的  日期
+ (NSString *)getWeekTimeByDate:(NSDate *)date;

/// 获取秒级的时间戳
/// @param date date
+ (NSTimeInterval)getSecTimestampWithDate:(NSDate *)date;

/// 获取终止时间戳
/// @param date date
+ (NSTimeInterval)getEndTimeIntervalWithDate:(NSDate *)date;

/// 获取一周的起始时间和结束时间
/// @param date date description
+ (NSArray *)backToPassedTimeWithDate:(NSDate *)date;

/// date转时间戳
/// @param date date
//+ (NSInteger)getTimestampWithDate:(NSDate *)date;

/**************************当前时间********************************/
+ (NSDateComponents *)getCurrentDateComponents;
+ (NSInteger)getCurrentWeek;
+ (NSInteger)getCurrentYear;
+ (NSInteger)getCurrentQuarter;
+ (NSInteger)getCurrentMonth;
+ (NSInteger)getCurrentDay;
+ (NSDate *)dateFromString:(NSString *)dateString DateFormat:(NSString *)DateFormat;
// 获取当前时间的字符串
+ (NSString*)getCurrentTimesDateString;
//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date DateFormat:(NSString *)DateFormat;
/// 获取当月的天数
+ (NSInteger)getInMonthNumberOfDaysWithDate:(NSDate *)date;
//时间追加
+ (NSString *)dateByAddingTimeInterval:(NSTimeInterval)TimeInterval DataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat;
//日期字符串格式化
+ (NSString *)getDataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat;
+ (NSString *)getFormat:(NSString *)dateString;
/**
 *  json日期转iOS时间
 *
 *  @param string /Date()
 */
+(NSString *)interceptTimeStampFromStr:(NSString *)string DateFormat:(NSString *)DateFormat;
@end

NS_ASSUME_NONNULL_END
