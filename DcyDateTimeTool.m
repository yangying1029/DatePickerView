//
//  DcyDateTimeTool.m
//  DatePickerView
//
//  Created by  on 2020/2/18.
//  Copyright © 2020 . All rights reserved.
//

#import "DcyDateTimeTool.h"

@implementation DcyDateTimeTool
//获取年月日对象
+(NSDateComponents *)getDateComponents:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
//    [calendar setFirstWeekday:2]; //设置每周的开始是星期一
//    [calendar setMinimumDaysInFirstWeek:7]; //设置一周至少需要几天
    return [calendar components:
            NSCalendarUnitYear|
            NSCalendarUnitMonth|
            NSCalendarUnitDay|
            NSCalendarUnitWeekOfYear|
            NSCalendarUnitQuarter fromDate:date];
}
 
//获得某年的周数
+(NSInteger)getWeek_AccordingToYear:(NSInteger)year {
    
    NSDateComponents *comps = [DcyDateTimeTool getDateComponents:[DcyDateTimeTool dateFromString:[NSString stringWithFormat:@"%ld-12-31",year] DateFormat:@"yyyy-MM-dd"]];
    NSInteger week = [comps weekOfYear];
    if (week == 1) {
        return 52;
    }else {
        return week;
    }
}
 
/**
 *  获取某年某周的范围日期
 *
 *  @param year       年份
 *  @param weekofYear year里某个周
 *
 *  @return 时间范围字符串
 */
+(NSString*)getWeekRangeDate_Year:(NSInteger)year WeakOfYear:(NSInteger)weekofYear
{
    NSString *weekDate = @"";
    NSString *timeAxis = [NSString stringWithFormat:@"%ld-06-01 12:00:00",(long)year];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:timeAxis];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    /**这两个参数的设置影响着周次的个数和划分*****************/
    [calendar setFirstWeekday:2]; //设置每周的开始是星期一
//    [calendar setMinimumDaysInFirstWeek:7]; //设置一周至少需要几天
    NSDateComponents *comps = [calendar components:(NSCalendarUnitWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                          fromDate:date];
    //时间轴是当前年的第几周
    NSInteger todayIsWeek = [comps weekOfYear];
    if ([DcyDateTimeTool getWeek_AccordingToYear:year] == 53) {
        todayIsWeek += 1;
    }
    //获取时间轴是星期几 1(星期天) 2(星期一) 3(星期二) 4(星期三) 5(星期四) 6(星期五) 7(星期六)
    NSInteger todayIsWeekDay = [comps weekday];
    // 计算当前日期和这周的星期一和星期天差的天数
    //firstDiff 星期一相差天数 、 lastDiff 星期天相差天数
    long firstDiff,lastDiff;
    if (todayIsWeekDay == 1) {
        firstDiff = -6;
        lastDiff = 0;
    }else
    {
        firstDiff = [calendar firstWeekday] - todayIsWeekDay;
        lastDiff = 8 - todayIsWeekDay;
    }
    
    NSDate *firstDayOfWeek= [NSDate dateWithTimeInterval:24*60*60*firstDiff sinceDate:date];
    NSDate *lastDayOfWeek= [NSDate dateWithTimeInterval:24*60*60*lastDiff sinceDate:date];
    
    long weekdifference = weekofYear - todayIsWeek;
    
    firstDayOfWeek= [NSDate dateWithTimeInterval:24*60*60*7*weekdifference sinceDate:firstDayOfWeek];
    lastDayOfWeek= [NSDate dateWithTimeInterval:24*60*60*7*weekdifference sinceDate:lastDayOfWeek];
    
    weekDate = [NSString stringWithFormat:@"第%ld周(%@-%@)",weekofYear,[DcyDateTimeTool stringFromDate:firstDayOfWeek DateFormat:@"yyyy年M月d号"],[DcyDateTimeTool stringFromDate:lastDayOfWeek DateFormat:@"yyyy年M月d号"]];
    
    return weekDate;
}
 
/**************************当前时间********************************/
+(NSDateComponents *)getCurrentDateComponents {
    return [DcyDateTimeTool getDateComponents:[NSDate date]];
}
+(NSInteger)getCurrentWeek {
    NSInteger week = [[DcyDateTimeTool stringFromDate:[NSDate date] DateFormat:@"w"] intValue];
    return week;
}
+(NSInteger)getCurrentYear{
    NSInteger year = [[DcyDateTimeTool stringFromDate:[NSDate date] DateFormat:@"y"] intValue];
    return year;
}
 
+(NSInteger)getCurrentQuarter{
    NSInteger quarter = [[DcyDateTimeTool stringFromDate:[NSDate date] DateFormat:@"q"] intValue];
    return quarter;
}
 
+(NSInteger)getCurrentMonth{
    NSInteger month = [[DcyDateTimeTool stringFromDate:[NSDate date] DateFormat:@"M"] intValue];
    return month;
}
 
+(NSInteger)getCurrentDay{
    NSInteger day = [[DcyDateTimeTool stringFromDate:[NSDate date] DateFormat:@"d"] intValue];
    return day;
}
 
//NSString转NSDate
+(NSDate *)dateFromString:(NSString *)dateString DateFormat:(NSString *)DateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormat];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
}
 
//NSDate转NSString
+ (NSString *)stringFromDate:(NSDate *)date DateFormat:(NSString *)DateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:DateFormat];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    return destDateString;
}
 
//时间追加
+ (NSString *)dateByAddingTimeInterval:(NSTimeInterval)TimeInterval DataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat {
    NSString *str = nil;
    NSDate *date = [self dateFromString:dateStr DateFormat:DateFormat];
    NSDate * newDate = [date dateByAddingTimeInterval:TimeInterval];
    str = [self stringFromDate:newDate DateFormat:DateFormat];
    return str;
}
 
//日期字符串格式化
+(NSString *)getDataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat {
   return [self getDataTime:dateStr DateFormat:DateFormat oldDateFormat:nil];
}

+ (NSString*)getCurrentTimesDateString {
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
     //现在时间,你可以输出来看下是什么格式
     NSDate *datenow = [NSDate date];
     //----------将nsdate按formatter格式转成nsstring
     NSString *currentTimeString = [formatter stringFromDate:datenow];
     return currentTimeString;
 }

/// 获取当月的天数
+ (NSInteger)getInMonthNumberOfDaysWithDate:(NSDate *)date
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}


// 获取某个日期当前周的 第一天 和最后一天的  日期
+ (NSString *)getWeekTimeByDate:(NSDate *)date
{
//    NSDate *nowDate =[self theTargetStringConversionDate:@"2017-01-02"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday fromDate:date];
    // 获取今天是周几
    NSInteger weekDay = [comp weekday];
    // 获取几天是几号
    NSInteger day = [comp day];
//    NSLog(@"星期几%ld----%ld号",(long)weekDay,(long)day);
    
    // 计算当前日期和本周的星期一和星期天相差天数
    long firstDiff,lastDiff;
    //    weekDay = 1;
    if (weekDay == 1)
    {
        firstDiff = -6;
        lastDiff = 0;
    }
    else
    {
        firstDiff = [calendar firstWeekday] - weekDay + 1;
        lastDiff = 8 - weekDay;
    }
//    NSLog(@"firstDiff: %ld   lastDiff: %ld",firstDiff,lastDiff);
    
    // 在当前日期(去掉时分秒)基础上加上差的天数
    NSDateComponents *firstDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay  fromDate:date];
    [firstDayComp setDay:day + firstDiff];
    NSDate *firstDayOfWeek = [calendar dateFromComponents:firstDayComp];
    
    NSDateComponents *lastDayComp = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay   fromDate:date];
    [lastDayComp setDay:day + lastDiff];
    NSDate *lastDayOfWeek = [calendar dateFromComponents:lastDayComp];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM月dd日"];
    NSString *firstDay = [formatter stringFromDate:firstDayOfWeek];
    NSString *lastDay = [formatter stringFromDate:lastDayOfWeek];
    NSLog(@"%@=======%@",firstDay,lastDay);
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@",firstDay,lastDay];
    
    return dateStr;
    
}

+ (NSArray *)backToPassedTimeWithDate:(NSDate *)date
{
//    NSDate *date = [[NSDate date] dateByAddingTimeInterval:- 7 * 24 * 3600 * number];
    //滚动后，算出当前日期所在的周（周一－周日）
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *comp = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitDay fromDate:date];
    NSInteger daycount = [comp weekday] - 2;
    
    NSDate *weekdaybegin = [date dateByAddingTimeInterval:-daycount*60*60*24];
    NSDate *weekdayend = [date dateByAddingTimeInterval:(6-daycount)*60*60*24];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:weekdaybegin];
    NSDateComponents *components1 = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:weekdayend];
    
    NSDate *startDate = [calendar dateFromComponents:components];//这个不能改
    
    NSDate *endDate = [calendar dateFromComponents:components1];
//    NSDate *endDate1 = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate1 options:0];
    
    //获取今天0点到明天0点的时间
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc]init];
    [formatter1 setDateFormat:@"MM/dd"];
    NSString *str1 = [formatter1 stringFromDate:startDate];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"MM/dd"];
    NSString *str2 = [formatter2 stringFromDate:endDate];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@",str1,str2];
    
    return @[startDate,endDate,dateStr];
}

+ (NSTimeInterval)getSecTimestampWithDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:dd"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
//    NSLog(@"时间:%@",[formatter stringFromDate:date]);
    //时间转时间戳的方法:
    NSTimeInterval timeSp = [date timeIntervalSince1970];
//    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}

+ (NSTimeInterval)getEndTimeIntervalWithDate:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [calendar setTimeZone: timeZone];
    
    NSDateComponents *weekEndComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDateComponents *newComps = [[NSDateComponents alloc] init];
    
//    [newComps setDay:weekEndComps.day - 1];
//     [newComps setMonth:weekEndComps.month];
//    if (newComps.month == 1 && newComps.day == 0) {
//         [newComps setYear:weekEndComps.year - 1];
//    }else {
//         [newComps setYear:weekEndComps.year];
//    }
    [newComps setYear:weekEndComps.year];
    [newComps setMonth:weekEndComps.month];
    [newComps setDay:weekEndComps.day];
    [newComps setHour:23];
    [newComps setMinute:59];
    [newComps setSecond:59];
    NSDate *endDate = [calendar dateFromComponents:newComps];
    return [DcyDateTimeTool getSecTimestampWithDate:endDate];
}
 
+(NSString *)getDataTime:(NSString *)dateStr DateFormat:(NSString *)DateFormat oldDateFormat:(NSString *)oldDateFormat {
    
    if (!dateStr || [dateStr isEqualToString:@"—"]) {
        return @"—";
    }
    
    if ([dateStr isEqualToString:@"0"]) {
        return @"0";
    }
    
    if ([dateStr rangeOfString:@"+"].location != NSNotFound) {
        NSArray *strarray = [dateStr componentsSeparatedByString:@"+"];
        dateStr = strarray[0];
    }
    
    if ([dateStr rangeOfString:@"."].location != NSNotFound) {
        NSArray *strarray = [dateStr componentsSeparatedByString:@"."];
        dateStr = strarray[0];
    }
    
    if ([dateStr rangeOfString:@"T"].location != NSNotFound) {
        dateStr = [dateStr stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    
    NSDateFormatter *newDateFormatter = [[NSDateFormatter alloc]init];
    [newDateFormatter setDateFormat:DateFormat];
    
    NSDateFormatter *oldDateFormatter = [[NSDateFormatter alloc] init];
    
    if (oldDateFormat) {
        [oldDateFormatter setDateFormat:oldDateFormat];
    }else {
        [oldDateFormatter setDateFormat:[self getFormat:dateStr]];
    }
    
    NSDate *date = [oldDateFormatter dateFromString:dateStr];
    
    return [newDateFormatter stringFromDate:date];
}
 
+(int)getNumberOfCharactersInString:(NSString *)str c:(char)c {
    int count = 0;
    if ([str rangeOfString:[NSString stringWithFormat:@"%c",c]].location != NSNotFound){
        for (int i=0;i<str.length;i++){
            if ([str characterAtIndex:i] == c){
                count++;
            }
        }
    }
    return count;
}
 
+(NSString *)getFormat:(NSString *)dateString {
    NSString *str = [NSString new];
    int size = [self getNumberOfCharactersInString:dateString c:'-'];
    if (size == 0){
        str = [str stringByAppendingString:@"yyyy"];
    }else if (size == 1){
        str = [str stringByAppendingString:@"yyyy-MM"];
    }else if (size == 2){
        str = [str stringByAppendingString:@"yyyy-MM-dd"];
    }
    size = [self getNumberOfCharactersInString:dateString c:':'];
    if (size == 0 && [dateString rangeOfString:@" "].location != NSNotFound){
        str = [str stringByAppendingString:@" HH"];
    }else if (size == 1){
        str = [str stringByAppendingString:@" HH:mm"];
    }else if (size == 2){
        str = [str stringByAppendingString:@" HH:mm:ss"];
    }
    return str;
}
 
/**
 *  json日期转iOS时间
 *
 *  @param string /Date()
 */
+(NSString *)interceptTimeStampFromStr:(NSString *)string DateFormat:(NSString *)DateFormat {
    if (!string || [string length] == 0 ) // 传入时间戳为空 返回
    {
        return @"—";
    }
    NSMutableString * mutableStr = [NSMutableString stringWithString:string];
    NSString * timeStampString = [NSString string];
    //  遍历取出括号内的时间戳
    for (int i = 0; i < string.length; i ++) {
        NSRange startRang = [mutableStr rangeOfString:@"("];
        NSRange endRang = [mutableStr rangeOfString:@")"];
        if (startRang.location != NSNotFound) {
            // 左边括号位置
            NSInteger leftLocation = startRang.location;
            // 右边括号距离左边括号的长度
            NSInteger rightLocation = endRang.location - startRang.location;
            // 截取括号时间戳内容
            timeStampString = [mutableStr substringWithRange:NSMakeRange(leftLocation + 1,rightLocation - 1)];
        }
    }
    
    // 把时间戳转化成时间
    NSTimeInterval interval=[timeStampString doubleValue] / 1000.0;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *objDateformat = [[NSDateFormatter alloc] init];
    [objDateformat setDateFormat:DateFormat];//年月日时分秒
    NSString * timeStr = [NSString stringWithFormat:@"%@",[objDateformat stringFromDate: date]];
    return timeStr;

}
@end
