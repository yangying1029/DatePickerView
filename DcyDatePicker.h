//
//  DcyDatePickerView.h
//  DatePickerView
//
//  Created by  on 2020/2/17.
//  Copyright © 2020 . All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DcyDatePickerModel.h"
#import "UIView+Addition.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, DcyDatePickerViewStyle) {
    // 年月日
    DcyDatePickerViewStyleYearMonthDay,
    // 年月
    DcyDatePickerViewStyleYearMonth,
    // 年周
    DcyDatePickerViewStyleYearWeek,
};
@interface DcyDatePicker : UIView

/// 显示选择器
/// @param datePickerModel 初始数据model
/// @param pickerStyle 选择器样式
/// @param superView 父视图
/// @param animated 是否动画
/// @param clickCertainBtnBlock 点击确定的回调
+ (void)showWithDateModel:(DcyDatePickerModel *)datePickerModel
        DcyDatePickerViewStyle:(DcyDatePickerViewStyle)pickerStyle
                superView:(UIView *)superView
                        animated:(BOOL)animated
            clickCertainBtnBlock:(void (^)(NSTimeInterval startTime,NSTimeInterval endTime,NSString *selectDateString))clickCertainBtnBlock;

/// 获取默认的时间字符串
/// @param style 样式
/// @param minimumTime 最小时间戳
/// @param maximumTime 最大时间戳
/// 返回数组，第一个是起始时间戳，第二个是结束时间戳，第三个是默认最新的时间字符串
+ (NSArray *)getDefaultDateArrayWithStyle:(DcyDatePickerViewStyle)style minimumTime:(NSTimeInterval)minimumTime maximumTime:(NSTimeInterval)maximumTime;
@end

NS_ASSUME_NONNULL_END
