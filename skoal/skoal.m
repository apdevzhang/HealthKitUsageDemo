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
+(id)copyWithZone:(nullable NSZone *)zone{
    return _instance;
}

#pragma mark - 获取HealthyKit权限
<<<<<<< HEAD
-(void)requestHealthPermissionWithBlock:(HealthStorePermissionResponseBlock)block
=======
-(void)requestHealthyPermissionWithCallback:(HealthyStorePermissionResponseBlock)block
>>>>>>> e2c3e5f62944f4ddc4334ce63adf3dfbe2a593b4
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

-(void)readHeightFromHealthStoreWithUnit:(HKUnit *)unit withCompletion:(void(^)(double value,NSError *error))completion
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    ///----
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *dateNow = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:dateNow];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    //;
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierStartDate ascending:false];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:heightType predicate:predicate limit:1 sortDescriptors:@[sortDescriptor] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        HKQuantitySample *sample = results.firstObject;
        if (completion) {
            double value = [sample.quantity doubleValueForUnit:unit];
            completion(value,error);
        }
    }];
    HKHealthStore *store = [[HKHealthStore alloc] init];
    [store executeQuery:query];
}


#pragma mark - 读权限集合
-(NSSet *)readObjectTypes
{
    //身高
    HKQuantityType *Height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    //体重
    HKQuantityType *BodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    //身体质量指数
    HKQuantityType *BodyMassIndex= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    //步数
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //步行 + 跑步距离
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    //已爬楼层
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    //呼吸速率
    HKQuantityType *RespiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    //膳食能量消耗
    HKQuantityType *DietaryEnergyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    //血氧饱和度
    HKQuantityType *OxygenSaturation = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    //体温
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    //血糖
    HKQuantityType *BloodGlucose = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    
    //血压收缩压
    HKQuantityType *BloodPressureSystolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    //血压舒张压
    HKQuantityType *BloodPressureDiastolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    //站立小时
    HKObjectType *StandHour = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierAppleStandHour];
    
    //健身记录
    HKObjectType *ActivitySummary = [HKObjectType activitySummaryType];
    
    //性别
    HKObjectType *BiologicalSex = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    //出生日期
    HKObjectType *DateOfBirth = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    
    //血型
    HKObjectType *BloodType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType];

    //日光反应型皮肤类型
    HKObjectType *FitzpatrickSkin = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType];
    
    //睡眠分析
    HKObjectType *SleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    //月经
    HKObjectType *MenstrualFlow = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];

    //点滴出血
    HKObjectType *IntermenstrualBleeding = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding];
    
    //性行为
    HKObjectType *SexualActivity = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];

    return [NSSet setWithObjects:Height,BodyMass,BodyMassIndex,StepCount,DistanceWalkingRunning,FlightsClimbed,RespiratoryRate,DietaryEnergyConsumed,OxygenSaturation,BodyTemperature,BloodGlucose,BloodPressureSystolic,BloodPressureDiastolic,StandHour,ActivitySummary,BiologicalSex,DateOfBirth,BloodType,FitzpatrickSkin,SleepAnalysis,MenstrualFlow,IntermenstrualBleeding,SexualActivity, nil];
}

#pragma mark - 写权限集合
-(NSSet *)writeObjectTypes
{
    //身高
    HKQuantityType *Height = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    //体重
    HKQuantityType *BodyMass = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    //身体质量指数
    HKQuantityType *BodyMassIndex= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex];
    
    //步数
    HKQuantityType *StepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    //步行 + 跑步距离
    HKQuantityType *DistanceWalkingRunning= [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    //已爬楼层
    HKObjectType *FlightsClimbed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    //呼吸速率
    HKQuantityType *RespiratoryRate = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    //膳食能量消耗
    HKQuantityType *DietaryEnergyConsumed = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    //血氧饱和度
    HKQuantityType *OxygenSaturation = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    //体温
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    //血糖
    HKQuantityType *BloodGlucose = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    
    //血压收缩压
    HKQuantityType *BloodPressureSystolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    //血压舒张压
    HKQuantityType *BloodPressureDiastolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    //睡眠分析
    HKObjectType *SleepAnalysis = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    //月经
    HKObjectType *MenstrualFlow = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];
    
    //点滴出血
    HKObjectType *IntermenstrualBleeding = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding];
    
    //性行为
    HKObjectType *SexualActivity = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];
    
    return [NSSet setWithObjects:Height,BodyMass,BodyMassIndex,StepCount,DistanceWalkingRunning,FlightsClimbed,RespiratoryRate,DietaryEnergyConsumed,OxygenSaturation,BodyTemperature,BloodGlucose,BloodPressureSystolic,BloodPressureDiastolic,SleepAnalysis,MenstrualFlow,IntermenstrualBleeding,SexualActivity, nil];
}

@end
