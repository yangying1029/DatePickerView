# DatePickerView
iOS 年周，年月，年月日，日期选择器
# 使用方法
 
    DcyDatePickerModel *model = [[DcyDatePickerModel alloc] init];
   
    model.startTimeInter = [beginTime doubleValue]/1000;
    model.endTimeInter = [endTime doubleValue]/1000;
    
   
    [DcyDatePicker showWithDateModel:model DcyDatePickerViewStyle:DcyDatePickerViewStyleYearWeek superView:self.view animated:YES clickCertainBtnBlock:^(NSTimeInterval startTime, NSTimeInterval endTime, NSString * _Nonnull selectDateString) {
        
      NSLog(@"%@",selectDateString);
        
    }];
