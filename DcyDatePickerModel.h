//
//  DcyDatePickerModel.h
//  DatePickerView
//
//  Created by  on 2020/2/17.
//  Copyright © 2020 . All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DcyDatePickerModel : NSObject
//  起始时间戳
@property (nonatomic,assign) NSTimeInterval startTimeInter;
// 终止时间戳
@property (nonatomic,assign) NSTimeInterval endTimeInter;

/***********下面不用传参*************/
// 当前年的周数
@property (nonatomic,assign) NSInteger  weekCount;
// 当前年的第几周
@property (nonatomic,assign) NSInteger  weekForYear;
// 转换后的时间字符串
@property (nonatomic,copy) NSString *weekDateString;
// 选择时间的时间戳
@property (nonatomic,assign) NSTimeInterval selectTimeInterval;
// 年起始的第几周
@property (nonatomic,assign) NSInteger  startWeekOfYear;
@property (nonatomic,copy) NSArray *weekBeginAndEndArray;
@end

NS_ASSUME_NONNULL_END
