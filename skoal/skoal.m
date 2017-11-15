// skoal.m
//
// Copyright (c) 2017 BANYAN
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "skoal.h"

static skoal *_instance = nil;

@implementation skoal

+(instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+(instancetype)copyWithZone:(nullable NSZone *)zone{
    return _instance;
}

-(instancetype)init{
    if (self = [super init]) {
        self.store = [[HKHealthStore alloc] init];
    }
    return self;
}

///-------------------------
#pragma mark - 获取权限
///-------------------------
-(void)requestHealthPermissionWithBlock:(HealthStorePermissionResponseBlock)block
{
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        if (![HKHealthStore isHealthDataAvailable]) {
            DLog(@"skoal->该设备不支持HealthKit");
        }else{
            HKHealthStore *store = [[HKHealthStore alloc] init];
            NSSet *readObjectTypes = [self readObjectTypes];
            NSSet *writeObjectTypes = [self writeObjectTypes];
            [store requestAuthorizationToShareTypes:writeObjectTypes readTypes:readObjectTypes completion:^(BOOL success, NSError * _Nullable error) {
                if (success == YES) {
                    block(HealthStorePermissionResponseSuccess);
                }else{
                    block(HealthStorePermissionResponseError);
                }
            }];
        }
    }else{
        DLog(@"skoal->HealthyKit暂不支持iOS8以下系统,请更新你的系统。")
    }
}

///-------------------------
#pragma mark - 步数
///-------------------------
-(void)readStepCountFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion   ///读取当天步数
{
    HKSampleType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepCountType predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double sum = 0;
        for (HKQuantitySample *sample in results) {
            sum += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(sum,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)readStepCountFromHealthStoreWithStartTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(double value,NSError *error))completion   ///读取一个时间段步数
{
    HKSampleType *stepCountType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByPeriodOfTimeWithStartTime:startTime endTime:endTime];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:stepCountType predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double sum = 0;
        for (HKQuantitySample *sample in results) {
            sum += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(sum,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeStepCountToHealthStoreWithStepCount:(double)setpCount completion:(void(^)(BOOL response))completion     ///写入当天步数
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:setpCount];
   
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}
-(void)writeStepCountToHealthStoreWithStepCount:(double)setpCount startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL response))completion     ///写入指定时间段步数
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:setpCount];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDate *newStartDate = [formatter dateFromString:startTime];
    NSDate *newEndDate = [formatter dateFromString:endTime];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:newStartDate endDate:newEndDate metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}

///-------------------------
#pragma mark - 身高
///-------------------------
-(void)readHeightFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion  ///读取身高数据
{
    HKSampleType *heightType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heightType predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double height = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];

        completion(height,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeHeightToHealthStoreWithHeight:(double)Height completion:(void(^)(BOOL response))completion  ///写入身高数据
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:Height];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}

///-------------------------
#pragma mark - 体重
///-------------------------
-(void)readBodyMassFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion   ///读取体重
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double bodyMass = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bodyMass,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBodyMassToHealthStoreWithBodyMass:(double)bodyMass completion:(void(^)(BOOL response))completion    ///写入体重
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit gramUnit] doubleValue:bodyMass * 1000];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}

///-------------------------
#pragma mark - 身体质量指数
///-------------------------
-(void)readBodyMassIndexFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion  ///读取身体质量指数
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double bodyMassIndex = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bodyMassIndex,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBodyMassIndexToHealthStoreWithBodyMassIndex:(double)bodyMassIndex completion:(void(^)(BOOL response))completion  ///写入身体质量指数
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:bodyMassIndex];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}

///-------------------------
#pragma mark - 步行&跑步距离
///-------------------------
-(void)readDistanceWalkingRunningFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion     ///读取步行&跑步距离
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double distanceWalkingRunning = 0;
        for (HKQuantitySample *sample in results) {
            distanceWalkingRunning += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(distanceWalkingRunning / 1000,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeDistanceWalkingRunningToHealthStoreWithBodyMassIndex:(double)distanceWalkingRunning completion:(void(^)(BOOL response))completion   ///写入步行&跑步距离
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit meterUnit] doubleValue:distanceWalkingRunning * 1000];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}

///-------------------------
#pragma mark - 以爬楼层
///-------------------------
-(void)readFlightsClimbedFromHealthStoreWithCompletion:(void(^)(NSInteger value,NSError *error))completion  ///读取以爬楼层
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double flightsClimbed = 0;
        for (HKQuantitySample *sample in results) {
            flightsClimbed += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(flightsClimbed,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeFlightsClimbedToHealthStoreWithBodyMassIndex:(NSInteger)flightsClimbed completion:(void(^)(BOOL response))completion    ///写入以爬楼层
{
    
}


///-------------------------
#pragma mark - 谓词样本
///-------------------------
-(NSPredicate *)predicateSampleByToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateNow = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateNow];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:(HKQueryOptionNone)];
    
    return predicate;   //predicate sample is the day data(谓词样本为当天数据)
}
-(NSPredicate *)predicateSampleByLatestData
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *dateNow = [NSDate date];
    
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateNow];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:0 endDate:endDate options:(HKQueryOptionNone)];
    
    return predicate;   //predicate sample is the latest data(谓词样本为最新数据)
}
-(NSPredicate *)predicateSampleByPeriodOfTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDate *newStartDate = [formatter dateFromString:startTime];
    NSDate *newEndDate = [formatter dateFromString:endTime];    
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:newStartDate endDate:newEndDate options:(HKQueryOptionNone)];
    
    return predicate;   //predicate sample is time period data(谓词样本为时间段数据)
}

///-------------------------
#pragma mark - 权限集合
///-------------------------
-(NSSet *)readObjectTypes   ///读权限集合
{
    HKQuantityType *Height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];    //身高
    
    HKQuantityType *BodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];   //体重
    
    HKQuantityType *BodyMassIndex= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];   //身体质量指数
    
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];   //步数
    
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];   //步行 + 跑步距离
    
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];   //已爬楼层
    
    HKQuantityType *RespiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //呼吸速率
    
    HKQuantityType *DietaryEnergyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];   //膳食能量消耗
    
    HKQuantityType *OxygenSaturation = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];   //血氧饱和度
    
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //体温
    
    HKQuantityType *BloodGlucose = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];   //血糖
    
    HKQuantityType *BloodPressureSystolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];   //血压收缩压
    
    HKQuantityType *BloodPressureDiastolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];   //血压舒张压
    
    HKObjectType *StandHour = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierAppleStandHour];   //站立小时
    
    HKObjectType *ActivitySummary = [HKObjectType activitySummaryType];   //健身记录
    
    HKObjectType *BiologicalSex = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];   //性别
    
    HKObjectType *DateOfBirth = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];   //出生日期
    
    HKObjectType *BloodType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];   //血型
    
    HKObjectType *FitzpatrickSkin = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType];   //日光反应型皮肤类型
   
    HKObjectType *SleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];    //睡眠分析
    
    HKObjectType *MenstrualFlow = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];   //月经
    
    HKObjectType *IntermenstrualBleeding = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding];   //点滴出血
    
    HKObjectType *SexualActivity = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];   //性行为

    return [NSSet setWithObjects:Height,
                                   BodyMass,
                                   BodyMassIndex,
                                   StepCount,
                                   DistanceWalkingRunning,
                                   FlightsClimbed,
                                   RespiratoryRate,
                                   DietaryEnergyConsumed,
                                   OxygenSaturation,
                                   BodyTemperature,
                                   BloodGlucose,
                                   BloodPressureSystolic,
                                   BloodPressureDiastolic,
                                   StandHour,
                                   ActivitySummary,
                                   BiologicalSex,
                                   DateOfBirth,
                                   BloodType,
                                   FitzpatrickSkin,
                                   SleepAnalysis,
                                   MenstrualFlow,
                                   IntermenstrualBleeding,
                                   SexualActivity,
                                   nil];
}
-(NSSet *)writeObjectTypes  ///写权限集合
{
    HKQuantityType *Height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];   //身高
    
    HKQuantityType *BodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];   //体重
    
    HKQuantityType *BodyMassIndex= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];   //身体质量指数
    
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];   //步数
    
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];   //步行 + 跑步距离
    
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];   //已爬楼层
   
    HKQuantityType *RespiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //呼吸速率
    
    HKQuantityType *DietaryEnergyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];   //膳食能量消耗
    
    HKQuantityType *OxygenSaturation = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];   //血氧饱和度
    
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];   //体温
    
    HKQuantityType *BloodGlucose = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];   //血糖
    
    HKQuantityType *BloodPressureSystolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];   //血压收缩压
    
    HKQuantityType *BloodPressureDiastolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];   //血压舒张压
    
    HKObjectType *SleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];   //睡眠分析
    
    HKObjectType *MenstrualFlow = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];   //月经
    
    HKObjectType *IntermenstrualBleeding = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding];   //点滴出血
    
    HKObjectType *SexualActivity = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];   //性行为
    
    return [NSSet setWithObjects:Height,
                                   BodyMass,
                                   BodyMassIndex,
                                   StepCount,
                                   DistanceWalkingRunning,
                                   FlightsClimbed,
                                   RespiratoryRate,
                                   DietaryEnergyConsumed,
                                   OxygenSaturation,
                                   BodyTemperature,
                                   BloodGlucose,
                                   BloodPressureSystolic,
                                   BloodPressureDiastolic,
                                   SleepAnalysis,
                                   MenstrualFlow,
                                   IntermenstrualBleeding,
                                   SexualActivity,
                                    nil];
}

@end
