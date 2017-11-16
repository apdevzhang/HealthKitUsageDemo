// skoal.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

///-------------------------
#pragma mark - DEBUG
///-------------------------
#ifdef DEBUG
#define DLog(FORMAT, ...) fprintf(stderr, "%s [Line %zd]\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);
#else
#define DLog(FORMAT, ...) nil
#endif


typedef NS_ENUM(NSUInteger,HealthStorePermissionResponse) {
    HealthStorePermissionResponseError = 0,
    HealthStorePermissionResponseSuccess
};

typedef void (^HealthStorePermissionResponseBlock)(HealthStorePermissionResponse permissionResponse);

@interface skoal : NSObject
@property (nonatomic,copy) HealthStorePermissionResponseBlock permissionResponseBlock;
@property (nonatomic,strong) HKHealthStore *store;

+(instancetype)sharedInstance;

///-------------------------
#pragma mark - AccessPermission(获取权限)
///-------------------------
-(void)requestHealthPermissionWithBlock:(HealthStorePermissionResponseBlock)block;


///-------------------------
#pragma mark - StepCount(步数)
///-------------------------
-(void)readStepCountFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)readStepCountFromHealthStoreWithStartTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(double value,NSError *error))completion;
-(void)writeStepCountToHealthStoreWithUnit:(double)setpCount completion:(void(^)(BOOL response))completion;
-(void)writeStepCountToHealthStoreWithUnit:(double)setpCount startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - Height(身高)
///-------------------------
-(void)readHeightFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeHeightToHealthStoreWithUnit:(double)Height completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - BodyMass(体重)
///-------------------------
-(void)readBodyMassFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;    /// kg
-(void)writeBodyMassToHealthStoreWithUnit:(double)bodyMass completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - BodyMassIndex(身体质量指数)
///-------------------------
-(void)readBodyMassIndexFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeBodyMassIndexToHealthStoreWithUnit:(double)bodyMassIndex completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - DistanceWalkingRunning(步行+跑步距离)
///-------------------------
-(void)readDistanceWalkingRunningFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeDistanceWalkingRunningToHealthStoreWithUnit:(double)distanceWalkingRunning completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - FlightsClimbed(以爬楼层)
///-------------------------
-(void)readFlightsClimbedFromHealthStoreWithCompletion:(void(^)(NSInteger value,NSError *error))completion;
-(void)writeFlightsClimbedToHealthStoreWithUnit:(NSInteger)flightsClimbed completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - RespiratoryRate(呼吸速率)
///-------------------------
-(void)readRespiratoryRateFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeRespiratoryRateToHealthStoreWithUnit:(double)respiratoryRate completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - DietaryEnergyConsumed(膳食能量消耗)
///-------------------------
-(void)readDietaryEnergyConsumedFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeDietaryEnergyConsumedToHealthStoreWithUnit:(double)dietaryEnergyConsumed completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - OxygenSaturation(血氧饱和度)
///-------------------------
-(void)readOxygenSaturationFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


///-------------------------
#pragma mark - BodyTemperature(体温)
///-------------------------
-(void)readBodyTemperatureFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeBodyTemperatureToHealthStoreWithUnit:(double)bodyTemperature completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - BloodGlucose(血糖)
///-------------------------
-(void)readBloodGlucoseFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;    /// mg/dl
-(void)writeBloodGlucoseToHealthStoreWithUnit:(double)bloodGlucose completion:(void(^)(BOOL response))completion;

///-------------------------
#pragma mark - BloodPressure(血压)
///-------------------------
-(void)readBloodPressureSystolicFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeBloodPressureSystolicToHealthStoreWithUnit:(double)bloodPressureSystolic completion:(void(^)(BOOL response))completion;
-(void)readBloodPressureDiastolicFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
-(void)writeBloodPressureDiastolicToHealthStoreWithUnit:(double)bloodPressureDiastolic completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - StandHour(站立小时)
///-------------------------
-(void)readStandHourFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


///-------------------------
#pragma mark - BiologicalSex(性别)
///-------------------------
-(void)readBiologicalSexFromHealthStoreWithCompletion:(void(^)(NSString *sex,NSError *error))completion;


///-------------------------
#pragma mark - DateOfBirth(出生日期)
///-------------------------
-(void)readDateOfBirthFromHealthStoreWithCompletion:(void(^)(NSDate *date,NSError *error))completion;


///-------------------------
#pragma mark - BloodType(血型)
///-------------------------
-(void)readBloodTypeFromHealthStoreWithCompletion:(void(^)(NSString *bloodType,NSError *error))completion;


///-------------------------
#pragma mark - FitzpatrickSkin(日光反应型皮肤类型)
///-------------------------
-(void)readFitzpatrickSkinFromHealthStoreWithCompletion:(void(^)(NSString *skinType,NSError *error))completion;


///-------------------------
#pragma mark - SleepAnalysis(睡眠分析)
///-------------------------
-(void)readSleepAnalysisFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


///-------------------------
#pragma mark - MenstrualFlow(月经)
///-------------------------
-(void)readMenstrualFlowFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


///-------------------------
#pragma mark - IntermenstrualBleeding(点滴出血)
///-------------------------
-(void)readIntermenstrualBleedingFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


///-------------------------
#pragma mark - SexualActivity(性行为)
///-------------------------
-(void)readSexualActivityFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;


@end
