//
//  DcyDatePickerView.m
//  DatePickerView
//
//  Created by  on 2020/2/17.
//  Copyright © 2020 . All rights reserved.
//

#import "DcyDatePicker.h"
#import "DcyDateTimeTool.h"
#define PICKER_HEIGHT 160
@interface DcyDatePicker ()<UIPickerViewDelegate,UIPickerViewDataSource>
// view
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong) UIView *toolView;
@property (nonatomic,strong) UIButton *cancelBtn;
@property (nonatomic,strong) UIButton *certainBtn;
@property (nonatomic,strong) UIPickerView *pickerView;
@property (nonatomic,strong) UIDatePicker *datePicker;
// data
@property (nonatomic,strong) NSMutableArray *yearArray;
@property (nonatomic,strong) NSMutableArray *monthArray;
@property (nonatomic,strong) NSMutableArray *dayArray;
@property (nonatomic,strong) NSMutableArray *weekArray;
@property (nonatomic,strong) NSMutableDictionary *weekCountDict;
// other
@property (nonatomic,strong) DcyDatePickerModel *datePickerModel;
@property (nonatomic,copy)  NSString *currentDate;
@property (nonatomic,assign) DcyDatePickerViewStyle pickerStyle;
@property (nonatomic ,copy) void(^clickCertainBtnBlock)(NSTimeInterval startTime,NSTimeInterval endTime,NSString *selectDateString);
@property (nonatomic,assign) NSInteger selectYearRow;
@property (nonatomic,assign) NSInteger selectMonthRow;
@property (nonatomic,assign) NSInteger selectWeekRow;
@property (nonatomic,assign) NSInteger selectDayRow;
@property (nonatomic,assign) NSInteger numberOfPickerRow;
@property (nonatomic,assign) int dayNumber;
@property (nullable, nonatomic, strong) NSDate *minimumDate;//最小显示的日期
@property (nullable, nonatomic, strong) NSDate *maximumDate;//
@property (nonatomic,strong) NSString *year;
@property (nonatomic,strong) NSString *month;
@property (nonatomic,strong) NSString *day;
//应该跟新天数了,当月份或年份被选择过或是刚进入为true，需要刷新day
@property (nonatomic,assign) BOOL dayShouldChangeEnable;
@end

@implementation DcyDatePicker
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
            clickCertainBtnBlock:(void (^)(NSTimeInterval startTime,NSTimeInterval endTime,NSString *selectDateString))clickCertainBtnBlock {
    [[[self alloc] init] showWithDateModel:datePickerModel
                              DcyDatePickerViewStyle:pickerStyle
                                           superView:superView
                                            animated:animated
                                clickCertainBtnBlock:clickCertainBtnBlock];
}

/// 获取默认的时间字符串
/// @param style 样式
/// @param minimumTime 最小时间戳
/// @param maximumTime 最大时间戳
+ (NSArray *)getDefaultDateArrayWithStyle:(DcyDatePickerViewStyle)style minimumTime:(NSTimeInterval)minimumTime maximumTime:(NSTimeInterval)maximumTime {
    switch (style) {
        case DcyDatePickerViewStyleYearMonth:
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:maximumTime];
            NSInteger monthLength = [DcyDateTimeTool getInMonthNumberOfDaysWithDate:date];
            NSString *dateString = [DcyDateTimeTool stringFromDate:date DateFormat:@"yyyy-MM"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                  [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
                       
            // 起始时间
           NSString *startDateString = [dateString stringByAppendingString:@"-01 00:00:00"];
           NSDate *startDate = [dateFormatter dateFromString:startDateString];
          NSTimeInterval  startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:startDate];
               
           // 终止时间
            NSString *endDateString = [dateString stringByAppendingFormat:@"-%ld 23:59:59",monthLength];
           NSDate *endDate = [dateFormatter dateFromString:endDateString];
           NSTimeInterval endTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:endDate];
            
            return @[@(startTimeInterval),@(endTimeInterval),[DcyDateTimeTool stringFromDate:[NSDate dateWithTimeIntervalSince1970:maximumTime] DateFormat:@"yyyy-MM"]];
        }
            break;
        case DcyDatePickerViewStyleYearMonthDay:
        {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:maximumTime];
            NSString *dateString = [DcyDateTimeTool stringFromDate:date DateFormat:@"yyyy-MM-dd"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            // 起始时间
              NSString *startDateString = [dateString stringByAppendingString:@" 00:00:00"];
              NSDate *startDate = [dateFormatter dateFromString:startDateString];
              NSTimeInterval startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:startDate];
                  
              // 终止时间
               NSString *endDateString =  [dateString stringByAppendingString:@" 23:59:59"];
              NSDate *endDate = [dateFormatter dateFromString:endDateString];
             NSTimeInterval endTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:endDate];
            
            return @[@(startTimeInterval),@(endTimeInterval),[DcyDateTimeTool stringFromDate:[NSDate dateWithTimeIntervalSince1970:maximumTime] DateFormat:@"yyyy-MM-dd"]];
        }  
            break;
        case DcyDatePickerViewStyleYearWeek:
        {
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:maximumTime];
            NSCalendar*calendar = [NSCalendar currentCalendar];
            NSDateComponents *endComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:endDate];
            NSDateComponents *comps = [[NSDateComponents alloc] init];
               [comps setYearForWeekOfYear:endComps.year];
               [comps setWeekOfYear:endComps.weekOfYear];
           NSDate *dateFromDateComponentsForDate = [calendar dateFromComponents:comps];
           // 每周第一天 和 最后一天
           NSArray *dateArray = [DcyDateTimeTool backToPassedTimeWithDate:dateFromDateComponentsForDate];
            NSInteger startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:dateArray.firstObject];
            NSInteger endTimeInterval =  [DcyDateTimeTool getEndTimeIntervalWithDate:dateArray[1]];
            return @[@(startTimeInterval),@(endTimeInterval),[NSString stringWithFormat:@"第%ld周%@",comps.weekOfYear,dateArray.lastObject]];
        }
            break;
        default:
            break;
    }
    return nil;
}

///// 移除选择器
///// @param animated 是否动画
///// @param dismissBlock 完成回调
//+ (void)dismissWithAnimated:(BOOL)animated
//               dismissBlock:(void (^)(void))dismissBlock {
//    [[DcyDatePicker shareInstance] dismissWithAnimated:animated dismissBlock:dismissBlock];
//}

/// 显示选择器
/// @param datePickerModel 初始数据model
/// @param pickerStyle 选择器样式
/// @param superView 父视图
/// @param animated 是否动画
/// @param clickCertainBtnBlock 点击确定的回调
- (void)showWithDateModel:(DcyDatePickerModel *)datePickerModel
        DcyDatePickerViewStyle:(DcyDatePickerViewStyle)pickerStyle
                superView:(UIView *)superView
                        animated:(BOOL)animated
            clickCertainBtnBlock:(void (^)(NSTimeInterval startTime,NSTimeInterval endTime,NSString *selectDateString))clickCertainBtnBlock {
    _datePickerModel = datePickerModel;
    _pickerStyle = pickerStyle;
    _clickCertainBtnBlock = clickCertainBtnBlock;
    [self setupViewsWithSuperView:superView];
    [self getCurrentDate];
    [self showPickerViewAnimated:animated];
}

/// 移除选择器
/// @param animated 是否动画
/// @param dismissBlock 完成回调
- (void)dismissWithAnimated:(BOOL)animated
                dismissBlock:(void (^)(void))dismissBlock {
     if (animated) {
          [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
                    self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height + self.bgView.height;
                } completion:^(BOOL finished) {
                    [self cleanPicker];
                    if (dismissBlock) {
                        dismissBlock ();
                    }
                }];
        }else {
            self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height + self.bgView.height;
            [self cleanPicker];
        }
}

- (void)setupViewsWithSuperView:(UIView *)superView {
    self.frame = superView.bounds;
   [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapViewAction:)]];
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [superView addSubview:self];
    if (!_bgView) {
        CGRect frame;
        if (@available(iOS 11.0, *)) {
            frame = CGRectMake(0, 0, self.width, PICKER_HEIGHT + 50 + SAFE_AREA_BOTTOM);
        } else {
            frame = CGRectMake(0, 0, self.width, PICKER_HEIGHT + 50);
        }
        
        _bgView = [[UIView alloc] initWithFrame:frame];
        _bgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_bgView];
    }
    
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _bgView.frame.size.width, 50)];
        _toolView.backgroundColor = [UIColor whiteColor];
        [_bgView addSubview:_toolView];
    }
    
    self.cancelBtn.frame = CGRectMake(20, 0, 50, _toolView.height);
    self.certainBtn.frame = CGRectMake(_toolView.width - 50 - 20, 0, 50, _toolView.height);
    
    [_toolView addSubview:self.cancelBtn];
    [_toolView addSubview:self.certainBtn];
    
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, _toolView.height - 0.5, _toolView.width, 0.5)];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"dddddd"];
     [_toolView addSubview:bottomLine];
    
    CGRect frame;
    if (@available(iOS 11.0, *)) {
        frame = CGRectMake(0, CGRectGetMaxY(_toolView.frame), _bgView.frame.size.width, _bgView.frame.size.height - _toolView.frame.size.height - SAFE_AREA_BOTTOM);
    } else {
        frame = CGRectMake(0, CGRectGetMaxY(_toolView.frame), _bgView.frame.size.width, _bgView.frame.size.height - _toolView.frame.size.height);
    }
//    CGRect frame = CGRectMake(0, CGRectGetMaxY(_toolView.frame), _bgView.frame.size.width, _bgView.frame.size.height - _toolView.frame.size.height);
//    switch (_pickerStyle) {
//        case DcyDatePickerViewStyleYearMonthDay:
//        {
//            self.datePicker.frame = frame;
//           [_bgView addSubview: self.datePicker];
////            self.pickerView.frame = frame;
////            [_bgView addSubview:self.pickerView];
//        }
//            break;
//        case DcyDatePickerViewStyleYearWeek:
//        {
//            self.pickerView.frame = frame;
//           [_bgView addSubview:self.pickerView];
//        }
//            break;
//        case DcyDatePickerViewStyleYearMonth:
//        {
//            self.pickerView.frame = frame;
//           [_bgView addSubview:self.pickerView];
//        }
//            break;
//        default:
//            break;
//    }
    self.pickerView.frame = frame;
    [_bgView addSubview:self.pickerView];
}

- (void)getCurrentDate {
    switch (_pickerStyle) {
        case DcyDatePickerViewStyleYearMonthDay:
        {
//            [self setDefaultDate:[DcyDateTimeTool getCurrentTimesDateString]];
//            _currentDate = [DcyDateTimeTool getCurrentTimesDateString];
//             self.datePicker.datePickerMode = UIDatePickerModeDate;
//            //设置格式显示年月日
//              self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh-CN"]; // 本地化为中文公历
//              self.datePicker.minimumDate =  [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.startTimeInter];
//
//             self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.endTimeInter];
            self.minimumDate =  [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.startTimeInter];
                self.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.endTimeInter];
            self.month = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"M"];
            self.year = [DcyDateTimeTool stringFromDate:self.maximumDate  DateFormat:@"y"];

            [self getYesArr];
            [self getMonthArr];
            [self getDayArr];
            
             NSString *defaultYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"y"];
            NSUInteger yeasRow = [self.yearArray indexOfObject:defaultYearStr];
            NSString *defaultMonthStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"M"];
            NSUInteger monthRow = [self.monthArray indexOfObject:defaultMonthStr];
            NSString *defaultDayStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"d"];
            NSUInteger dayRow = [self.dayArray indexOfObject:defaultDayStr];
                
            [self.pickerView reloadAllComponents];
            
            if (yeasRow < self.yearArray.count) {
                [self.pickerView selectRow:yeasRow inComponent:0 animated:NO];
            }
            
            if (monthRow < self.monthArray.count) {
                [self.pickerView selectRow:monthRow  inComponent:1 animated:NO];
            }
         
            if (self.pickerStyle == DcyDatePickerViewStyleYearMonthDay) {
                if (dayRow < self.dayArray.count) {
                    [self.pickerView selectRow:dayRow  inComponent:2 animated:NO];
                }
            }
        }
            break;
        case DcyDatePickerViewStyleYearWeek:
        {
            _selectYearRow = 0;
            _selectWeekRow = 0;
            _numberOfPickerRow = 52;
            NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.startTimeInter];
            NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.endTimeInter];
            NSCalendar*calendar = [NSCalendar currentCalendar];
            NSDateComponents *startComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth |  NSCalendarUnitWeekOfYear fromDate:startDate];
            NSDateComponents *endComps = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear fromDate:endDate];
            NSInteger startYear = startComps.year;
            NSInteger endYear = endComps.year;
            // 获取多少年数
            if (startYear <= endYear) {
                for (int i = 0; i <= endYear - startYear; i ++) {
                    NSString *yearString = [NSString stringWithFormat:@"%ld",startYear + i];
                    [self.yearArray addObject:yearString];
                }
            }
            _selectYearRow = self.yearArray.count - 1;
            _weekCountDict = [NSMutableDictionary dictionary];
             NSMutableDictionary *modelDict = [NSMutableDictionary dictionary];
            // 获取每年的周数
            if (self.yearArray.count == 1) {
                DcyDatePickerModel *pickerModel = [[DcyDatePickerModel alloc] init];
                 // 知道有多少个周，起始第几周，获取当年剩余的周
                 pickerModel.weekCount = endComps.weekOfYear - startComps.weekOfYear + 1;
                 pickerModel.startWeekOfYear = startComps.weekOfYear;
                 pickerModel.weekForYear = [self.yearArray.firstObject integerValue];
                 [modelDict setValue:pickerModel forKey:[NSString stringWithFormat:@"%@",self.yearArray.firstObject]];
            }else {
                for (int i = 0; i <  self.yearArray.count; i ++) {
                     DcyDatePickerModel *pickerModel = [[DcyDatePickerModel alloc] init];
                    if (i == 0 || i == self.yearArray.count - 1) {
                       if (i == 0) {
                            // 知道有多少个周，起始第几周，获取当年剩余的周
                          pickerModel.weekCount = 52 - startComps.weekOfYear + 1;
                           pickerModel.startWeekOfYear = startComps.weekOfYear;
                        }else {
                             // 知道有多少个周，起始第几周，获取当年剩余的周
                            pickerModel.weekCount = 52 - endComps.weekOfYear + 1;
                            pickerModel.startWeekOfYear = 1;
                        }
                        pickerModel.weekForYear = [self.yearArray[i] integerValue];
                        [modelDict setValue:pickerModel forKey:[NSString stringWithFormat:@"%@",self.yearArray[i]]];
                    }else  {
                        pickerModel.weekForYear = [self.yearArray[i] integerValue];
                        pickerModel.weekCount = 52;
                         pickerModel.startWeekOfYear = 1;
                        [modelDict setValue:pickerModel forKey:[NSString stringWithFormat:@"%@",self.yearArray[i]]];
                    }
                }
            }
            
            // 获取每周的开始和终止日期
            for (int i = 0; i <  self.yearArray.count; i ++) {
                // 获取每年的周数
                NSMutableArray *tempWeekArray = [NSMutableArray array];
                DcyDatePickerModel *pickerModel = [modelDict objectForKey:self.yearArray[i]];
                for (int i = 0; i < pickerModel.weekCount; i ++) {
                    DcyDatePickerModel *weekPickerModel = [[DcyDatePickerModel alloc] init];
                    // 当前是第几周
                    NSInteger currentWeek = pickerModel.startWeekOfYear + i;
                    NSDateComponents *comps = [[NSDateComponents alloc] init];
                    [comps setYearForWeekOfYear:pickerModel.weekForYear];
                    [comps setWeekOfYear:currentWeek];
                    NSDate *dateFromDateComponentsForDate = [calendar dateFromComponents:comps];
                    weekPickerModel.selectTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:dateFromDateComponentsForDate];
                    // 每周第一天 和 最后一天
                    NSArray *dateArray = [DcyDateTimeTool backToPassedTimeWithDate:dateFromDateComponentsForDate];
                    NSString *weekDateString =  [NSString stringWithFormat:@"第%ld周%@",currentWeek,dateArray.lastObject];
                    weekPickerModel.weekDateString = weekDateString;
                    weekPickerModel.weekBeginAndEndArray = @[dateArray.firstObject,dateArray[1]];
                    weekPickerModel.weekForYear = pickerModel.weekForYear;
                    weekPickerModel.startWeekOfYear = pickerModel.startWeekOfYear;
                    [tempWeekArray addObject:weekPickerModel];
                }
                
                if (i == 0) {
                       _numberOfPickerRow = tempWeekArray.count;
                   }
                
                if (i == self.yearArray.count - 1) {
                    _selectWeekRow = tempWeekArray.count - 1;
                }
//                [self.weekArray addObject:tempWeekArray];
                [_weekCountDict setValue:tempWeekArray forKey:self.yearArray[i]];
            }
            [self.pickerView reloadAllComponents];
            
            [self.pickerView selectRow:_selectYearRow inComponent:0 animated:NO];
            [self.pickerView selectRow:_selectWeekRow inComponent:1 animated:NO];
        }
            break;
        case DcyDatePickerViewStyleYearMonth:
        {
            
            self.minimumDate =  [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.startTimeInter];
          self.maximumDate = [NSDate dateWithTimeIntervalSince1970:self.datePickerModel.endTimeInter];

            self.month = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"M"];
            self.year = [DcyDateTimeTool stringFromDate:self.maximumDate  DateFormat:@"y"];
         
            [self getYesArr];
            [self getMonthArr];
            
            [self.pickerView reloadAllComponents];
            
            NSString *defaultYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"y"];
                NSUInteger yeasRow = [self.yearArray indexOfObject:defaultYearStr];
                
                NSString *defaultMonthStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"M"];
                NSUInteger monthRow = [self.monthArray indexOfObject:defaultMonthStr];
                
                if (yeasRow < self.yearArray.count) {
                    [self.pickerView selectRow:yeasRow inComponent:0 animated:NO];
                }
                
                if (monthRow < self.monthArray.count) {
                    [self.pickerView selectRow:monthRow  inComponent:1 animated:NO];
                }

        }
            break;
        default:
            break;
    }
    
    
}

#pragma mark - Method
/**
 *  格式化处理获取的日期
 *
 *  @param date 当前日期或者是选择的日期
 *
 *  @return 日期字符串(2015-05-01)
 */
- (NSString*)getFormatDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    
    
    // 获取年月日
    NSString *year  = [NSString stringWithFormat:@"%ld", [dateComponent year]];
    NSString *month = [NSString stringWithFormat:@"%ld", [dateComponent month]];
    NSString *day   = [NSString stringWithFormat:@"%ld", [dateComponent day]];

    // 对月日不足10的前面补0
    if (month.length == 1) month = [NSString stringWithFormat:@"0%@", month];
    if (day.length == 1)   day = [NSString stringWithFormat:@"0%@", day];
 
    // 返回格式化日期
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    return dateStr;
}

- (void)showPickerViewAnimated:(BOOL)animated {
    _bgView.sd_y = [UIScreen mainScreen].bounds.size.height + _bgView.height;
    self.alpha = 0;
       if (animated) {
           [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
               self.alpha = 1;
               self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height - self.bgView.height;
           } completion:^(BOOL finished) {
               
           }];
       }else {
           self.alpha = 1;
           self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height - self.bgView.height;
       }
}

- (void)dismissPickerViewAnimated:(BOOL)animated {
    if (animated) {
      [UIView animateWithDuration:0.25 delay:0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
                self.alpha = 0;
                self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height + self.bgView.height;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self cleanPicker];
            }];
    }else {
        self.bgView.sd_y = [UIScreen mainScreen].bounds.size.height + self.bgView.height;
        [self removeFromSuperview];
        [self cleanPicker];
    }
}

/**
 *  设置默认日期
 *
 *  @param dateStr 当前默认日期
 */
-(void)setDefaultDate:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *destDate = [dateFormatter dateFromString:dateStr];
    if (destDate) {
        [self.datePicker setDate:destDate animated:NO];
    }
}

- (NSDate *)getDateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day
{
    NSCalendar *greCalendar = [NSCalendar currentCalendar];
    //  定义一个NSDateComponents对象，设置一个时间点
    NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
    [dateComponentsForDate setDay:day];
    [dateComponentsForDate setMonth:month];
    [dateComponentsForDate setYear:year];
    NSDate *dateFromDateComponentsForDate = [greCalendar dateFromComponents:dateComponentsForDate];
    return dateFromDateComponentsForDate;
}

- (void)getYesArr {
    NSString *maxYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"yyyy"];
    NSString *minYearStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"yyyy"];
    int difference = [maxYearStr intValue] - [minYearStr intValue];
    if (difference < 0 || difference == 0) {
        [self.yearArray addObject:maxYearStr];
        return;
    }
    for (int i = 0; i <= difference; i ++) {
        NSString *yesS = [NSString stringWithFormat:@"%d",[minYearStr intValue] + i];
        [self.yearArray addObject:yesS];
    }
    [self YearMonthEqual_pickerView:self.pickerView inComponent:0 month:[self.month intValue] Year:[self.year intValue]];
}
 
- (void)getMonthArr {
    NSString *maxMonthStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"MM"];
    NSString *maxYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"yyyy"];
    
    NSString *minMonthStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"MM"];
    NSString *minYearStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"yyyy"];
    
    if ([maxYearStr intValue] == [minYearStr intValue]) {
        for (int i = [minMonthStr intValue]; i<=[maxMonthStr intValue]; i++) {
            NSString *yesS = [NSString stringWithFormat:@"%d",i];
            [self.monthArray addObject:yesS];
        }
        return;
    }
    [self YearMonthEqual_pickerView:self.pickerView inComponent:0 month:[self.month intValue] Year:[self.year intValue]];
}

- (void)getDayArr {
    [self calculateDayWithMonth:[self.month intValue] andYear:[self.year intValue]];
}
//根据month和year计算对应的天数
- (void)calculateDayWithMonth:(int) month andYear:(int) year{
    float yearF = [self.year floatValue]/4; //能被4整除的是闰年
    float yearI = (int)yearF; //若yearI和yearF不一样，也就是说没有被整除，则不是闰年
    //当然以上计算没有包括：能被100整除，但不能被400整除的，不是闰年，因为2000年已过2100年还远....
    
    switch (month) {
        case 1:_dayNumber = 31; break;
        case 2:
            if(yearF != yearI){_dayNumber = 28;}else{
                _dayNumber = 29;}break;
        case 3:_dayNumber = 31;break;
        case 4:_dayNumber = 30;break;
        case 5:_dayNumber = 31;break;
        case 6:_dayNumber = 30;break;
        case 7:_dayNumber = 31;break;
        case 8:_dayNumber = 31;break;
        case 9:_dayNumber = 30;break;
        case 10:_dayNumber = 31;break;
        case 11:_dayNumber = 30;break;
        case 12:_dayNumber = 31;break;
        default:_dayNumber = 31;break;
    }
 
    NSString *maxYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"yyyy"];
    NSString *maxMonthStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"MM"];
    NSString *maxDayStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"dd"];
    
    NSString *minYearStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"yyyy"];
    NSString *minMonthStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"MM"];
    NSString *minDayStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"dd"];
 
    if ([minYearStr intValue] == year && [minMonthStr intValue] == month && [maxYearStr intValue] == year && [maxMonthStr intValue] == month) {
        self.dayArray = [NSMutableArray array];
        for (int i = [minDayStr intValue]; i <= [maxDayStr intValue]; i++) {
            NSString *yesS = [NSString stringWithFormat:@"%d",i];
            [self.dayArray addObject:yesS];
        }
        return;
    }
    
    if ([minYearStr intValue] == year && [minMonthStr intValue] == month) {
        self.dayArray = [NSMutableArray array];
        for (int i = [minDayStr intValue]; i<=_dayNumber; i++) {
            NSString *yesS = [NSString stringWithFormat:@"%d",i];
            [self.dayArray addObject:yesS];
        }
        return;
    }
 
    if ([maxYearStr intValue] == year && [maxMonthStr intValue] == month) {
        self.dayArray = [NSMutableArray array];
        for (int i = 1; i<=[maxDayStr intValue]; i++) {
            NSString *yesS = [NSString stringWithFormat:@"%d",i];
            [self.dayArray addObject:yesS];
        }
        return;
    }
    [self setDaysForMonth:_dayNumber]; //此处调用函数，将dayArray重新赋值；
}

- (void)YearMonthEqual_pickerView:(UIPickerView *)pickerView inComponent:(NSInteger)component month:(int)month Year:(int) year {
    NSString *maxYearStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"yyyy"];
    NSString *maxMonthStr = [DcyDateTimeTool stringFromDate:self.maximumDate DateFormat:@"MM"];
 
    if (component == 0) {
        self.monthArray = [NSMutableArray array];
        if ([maxYearStr intValue] != year) {
            NSString *minMonthStr = [DcyDateTimeTool stringFromDate:self.minimumDate DateFormat:@"MM"];
            for (int i = [minMonthStr intValue]; i <= 12; i++) {
                NSString *yesS = [NSString stringWithFormat:@"%d",i];
                [self.monthArray addObject:yesS];
            }
            [pickerView reloadComponent:1];
        }else {
            for (int i = 1; i<=[maxMonthStr intValue]; i++) {
                NSString *yesS = [NSString stringWithFormat:@"%d",i];
                [self.monthArray addObject:yesS];
            }
            if ([maxMonthStr intValue] < [self.month intValue]) {
                self.month = maxMonthStr;
                month = [maxMonthStr intValue];
            }
            [pickerView reloadComponent:1];
        }
    }
}

/// 获取时间戳
//- (NSInteger)getTimestampWithDate:(NSDate *)date {
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterMediumStyle];
//    [formatter setTimeStyle:NSDateFormatterShortStyle];
//    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//    //设置时区,这个对于时间的处理有时很重要
//    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
//    [formatter setTimeZone:timeZone];
////    NSLog(@"时间:%@",[formatter stringFromDate:date]);
//    //时间转时间戳的方法:
//    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] longLongValue];
////    NSLog(@"设备当前的时间戳:%ld",(long)timeSp); //时间戳的值
//    return timeSp;
//}

//- (NSTimeInterval)getEndTimeIntervalWithDate:(NSDate *)date {
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    [calendar setTimeZone: timeZone];
//
//    NSDateComponents *weekEndComps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
//    NSDateComponents *newComps = [[NSDateComponents alloc] init];
//
//    [newComps setDay:weekEndComps.day - 1];
//     [newComps setMonth:weekEndComps.month];
//    if (newComps.month == 1 && newComps.day == 0) {
//         [newComps setYear:weekEndComps.year - 1];
//    }else {
//         [newComps setYear:weekEndComps.year];
//    }
//    [newComps setHour:23];
//    [newComps setMinute:59];
//    [newComps setSecond:59];
//    NSDate *endDate = [calendar dateFromComponents:newComps];
//    return [self getTimestampWithDate:endDate];
//}

-(void)setDaysForMonth:(int) dayNumber{
    self.dayArray = nil;
    self.dayArray = [NSMutableArray array];
    for (int index=1; index <= _dayNumber; index++) {
        [_dayArray addObject:[@(index) stringValue]];
    }
}

- (void)cleanPicker {
    _bgView = nil;
    _cancelBtn = nil;
    _certainBtn = nil;
    _datePicker = nil;
    _pickerView = nil;
   _toolView = nil;
    _yearArray = nil;
    _weekArray = nil;
    _monthArray = nil;
    _dayArray = nil;
    _dayShouldChangeEnable = NO;
    self.weekCountDict  = nil;
    self.month = nil;
    self.year = nil;
    self.day = nil;
    self.minimumDate = nil;
    self.maximumDate = nil;
    _selectWeekRow = 0;
    _selectYearRow = 0;
    _selectMonthRow = 0;
    self.datePickerModel = nil;
    _currentDate = nil;
    _numberOfPickerRow = 0;
    _dayNumber = 0;
    self.maximumDate = nil;
    self.minimumDate = nil;
}

#pragma mark - Action
- (void)onClickCancelBtnAction:(UIButton *)btn {
    [self dismissPickerViewAnimated:YES];
}

- (void)onClickCertainBtnAction:(UIButton *)btn {
    [self dismissPickerViewAnimated:YES];
    NSTimeInterval startTimeInterval = 0.0;
    NSTimeInterval endTimeInterval = 0.0;
    NSString *selectDateString = nil;
    switch (_pickerStyle) {
        case DcyDatePickerViewStyleYearWeek:
        {
            NSInteger yearRow = [self.pickerView selectedRowInComponent:0];
            NSInteger weekRow = [self.pickerView selectedRowInComponent:1];
            NSString *currentYear = self.yearArray[yearRow];
            DcyDatePickerModel *model = self.weekCountDict[currentYear][weekRow];
             startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:model.weekBeginAndEndArray.firstObject];

            endTimeInterval = [DcyDateTimeTool getEndTimeIntervalWithDate:model.weekBeginAndEndArray.lastObject];
            
            selectDateString = model.weekDateString;
        }
            break;
        case DcyDatePickerViewStyleYearMonthDay:
        {
            NSInteger yearRow = [self.pickerView selectedRowInComponent:0];
            NSInteger monthRow = [self.pickerView selectedRowInComponent:1];
            NSInteger dayRow = [self.pickerView selectedRowInComponent:2];
            NSString *selectDateTimeString = [NSString stringWithFormat:@"%@-%@-%@",self.yearArray[yearRow],self.monthArray[monthRow],self.dayArray[dayRow]];
            
            NSString *newDateString = [selectDateTimeString stringByAppendingString:@" 00:00:00"];
              
           NSDate *startDate = [DcyDateTimeTool dateFromString:newDateString DateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSDateComponents *endComps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:startDate];
            startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:startDate];
            
            NSString *endDateString = [NSString stringWithFormat:@"%ld-%ld-%ld        23:59:59",endComps.year,endComps.month,endComps.day];
            NSDate *endDate = [DcyDateTimeTool dateFromString:endDateString DateFormat:@"YYYY-MM-dd HH:mm:ss"];
            endTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:endDate];
            
            selectDateString = selectDateTimeString;
        }
            break;
        case DcyDatePickerViewStyleYearMonth:
        {
            NSInteger yearRow = [self.pickerView selectedRowInComponent:0];
            NSInteger monthRow = [self.pickerView selectedRowInComponent:1];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
            NSString *dateString = [NSString stringWithFormat:@"%@-%@",self.yearArray[yearRow],self.monthArray[monthRow]];
            // 起始时间
            NSString *startDateString = [NSString stringWithFormat:@"%@-01 00:00:00",dateString];
            NSDate *startDate = [dateFormatter dateFromString:startDateString];
            startTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:startDate];
            
            // 终止时间
            NSInteger monthLength = [DcyDateTimeTool getInMonthNumberOfDaysWithDate:[DcyDateTimeTool dateFromString:dateString DateFormat:@"yyyy-MM"]];
           NSString *endDateString = [dateString stringByAppendingFormat:@"-%ld 23:59:59",monthLength];
          NSDate *endDate = [dateFormatter dateFromString:endDateString];
           endTimeInterval = [DcyDateTimeTool getSecTimestampWithDate:endDate];
            
            selectDateString = [NSString stringWithFormat:@"%@-%@",self.yearArray[yearRow],self.monthArray[monthRow]];
        }
            break;
        default:
            break;
    }
    
    if (self.clickCertainBtnBlock) {
        self.clickCertainBtnBlock(startTimeInterval,endTimeInterval,selectDateString);
    }
}

// 点击空白区域响应
- (void)onTapViewAction:(UITapGestureRecognizer *)tapGesture {
     // 回收 View
      CGPoint point = [tapGesture locationInView:self];
      
      if (point.y < CGRectGetMinY(_bgView.frame) ||
          point.y > CGRectGetMaxY(_bgView.frame) ||
          point.x < CGRectGetMinX(_bgView.frame) ||
          point.x > CGRectGetMaxX(_bgView.frame)) {
          [self dismissPickerViewAnimated:YES];
      }
}

- (void)dataPickerValueChanged:(UIDatePicker *)picker
{
    NSString *dateStr = [self getFormatDate:picker.date];
    _currentDate = dateStr;
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.pickerStyle == DcyDatePickerViewStyleYearMonthDay) {
        return 3;
    }else {
        return 2;
    }
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_pickerStyle == DcyDatePickerViewStyleYearWeek) {
        if (component == 0) {
               return self.yearArray.count;
           }else {
               return _numberOfPickerRow;
           }
    }else if (_pickerStyle == DcyDatePickerViewStyleYearMonth) {
        if (component == 0) {
            return self.yearArray.count;
        }else{
            return self.monthArray.count;
        }
    }else  {
        if (component == 0) {
            return self.yearArray.count;
        }else if(component ==1){
            return self.monthArray.count;
        } else {
            return self.dayArray.count;
        }
    }
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if (_pickerStyle == DcyDatePickerViewStyleYearWeek) {
        if (component == 0) {
            return self.yearArray[row];
        }
        else if (component == 1)
        {
            if (self.yearArray.count <= 0) {
                return nil;
            }
            NSArray *array = self.weekCountDict[self.yearArray[_selectYearRow]];
            if (array.count <= 0 || row > array.count - 1) {
                return nil;
            }
            DcyDatePickerModel *model = array[row];
            return model.weekDateString;
        }
    }else  {
       if (component == 0) {
            return [NSString stringWithFormat:@"%@",[self.yearArray objectAtIndex:row]];
        }else if( component == 1){
            return [NSString stringWithFormat:@"%@",[self.monthArray objectAtIndex:row]];
        }else {
            return [NSString stringWithFormat:@"%@",[self.dayArray objectAtIndex:row]];
        }
    }
    return nil;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (_pickerStyle == DcyDatePickerViewStyleYearMonthDay) {
        return floor(pickerView.width / 3.0);
    }else {
        if (component == 0) {
              return 120;
        } else {
              return _bgView.width - 120;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_pickerStyle == DcyDatePickerViewStyleYearWeek) {
        if (component == 0) {
            _selectYearRow = row;
            _numberOfPickerRow = [self.weekCountDict[self.yearArray[row]] count];
            [_pickerView selectRow:0 inComponent:1 animated:YES];
            [_pickerView reloadComponent:1];
        }else{
            _selectWeekRow = row;
        }
    }else {
      if(component == 0){
            _dayShouldChangeEnable = true;
            self.year = self.yearArray[row];
            self.selectYearRow = (int)row;
            [self.pickerView reloadComponent:0];
            [self YearMonthEqual_pickerView:pickerView inComponent:0 month:[self.month intValue] Year:[self.year intValue]];
        }else if(component == 1){
            _dayShouldChangeEnable = true;
            self.month = self.monthArray[row];
            self.selectMonthRow = (int)row;
            [pickerView reloadComponent:1];
            [self YearMonthEqual_pickerView:pickerView inComponent:1 month:[self.month intValue] Year:[self.year intValue]];
        }else{
            self.day = _dayArray[row];
            self.selectDayRow = (int)row;
            [pickerView reloadComponent:2];
        }
        if (self.pickerStyle == DcyDatePickerViewStyleYearMonthDay) {
            if(_dayShouldChangeEnable){
                //调用计算天数的函数
                [self calculateDayWithMonth:[self.month intValue] andYear:[self.year intValue]];
                //由于更新的时候self.selectRowDay很可能大于 天数的最大值，比如self.selectRowDay为31，而天数最大值切换至了29，所以若超出，则需要将selectRowDay重新赋值
                if(self.selectDayRow > _dayNumber-1){
                    self.selectDayRow = _dayNumber-1;
                }
                [pickerView reloadComponent:2];
                _dayShouldChangeEnable = false;
            }
        }
    }
}

#pragma mark - Lazy load
- (NSMutableArray *)yearArray {
    if (!_yearArray) {
        _yearArray = [NSMutableArray array];
    }
    return _yearArray;
}

- (NSMutableArray *)monthArray {
    if (!_monthArray) {
        _monthArray = [NSMutableArray array];
    }
    return _monthArray;
}

- (NSMutableArray *)weekArray {
    if (!_weekArray) {
        _weekArray = [NSMutableArray array];
    }
    return _weekArray;
}

- (NSMutableArray *)dayArray {
    if (!_dayArray) {
        _dayArray = [NSMutableArray array];
    }
    return _dayArray;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.backgroundColor = [UIColor whiteColor];
    }
    return _pickerView;
}

- (UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _cancelBtn.backgroundColor = [UIColor whiteColor];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithHexString:@"878787"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(onClickCancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)certainBtn {
    if (!_certainBtn) {
        _certainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _certainBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        _certainBtn.backgroundColor = [UIColor whiteColor];
        [_certainBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_certainBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_certainBtn addTarget:self action:@selector(onClickCertainBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _certainBtn;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]init];
        _datePicker.backgroundColor = [UIColor whiteColor];
        [_datePicker addTarget:self action:@selector(dataPickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePicker;
}

@end
