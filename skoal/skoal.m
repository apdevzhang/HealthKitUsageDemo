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
            DLog(@"skoal:该设备不支持HealthKit");
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
        DLog(@"skoal:HealthyKit暂不支持iOS8以下系统,请更新你的系统。");
    }
}


///-------------------------
#pragma mark - 步数
///-------------------------
-(void)readStepCountFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
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
-(void)readStepCountFromHealthStoreWithStartTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(double value,NSError *error))completion
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
-(void)writeStepCountToHealthStoreWithUnit:(double)setpCount completion:(void(^)(BOOL response))completion
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
-(void)writeStepCountToHealthStoreWithUnit:(double)setpCount startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL response))completion
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
-(void)readHeightFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
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
-(void)writeHeightToHealthStoreWithUnit:(double)Height completion:(void(^)(BOOL response))completion
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
-(void)readBodyMassFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
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
-(void)writeBodyMassToHealthStoreWithUnit:(double)bodyMass completion:(void(^)(BOOL response))completion
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
-(void)readBodyMassIndexFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
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
-(void)writeBodyMassIndexToHealthStoreWithUnit:(double)bodyMassIndex completion:(void(^)(BOOL response))completion
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
-(void)readDistanceWalkingRunningFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
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
-(void)writeDistanceWalkingRunningToHealthStoreWithUnit:(double)distanceWalkingRunning completion:(void(^)(BOOL response))completion
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
-(void)readFlightsClimbedFromHealthStoreWithCompletion:(void(^)(NSInteger value,NSError *error))completion
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
-(void)writeFlightsClimbedToHealthStoreWithUnit:(NSInteger)flightsClimbed completion:(void(^)(BOOL response))completion;
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:flightsClimbed];
    
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
#pragma mark - 呼吸速率
///-------------------------
-(void)readRespiratoryRateFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double respiratoryRate = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(respiratoryRate,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeRespiratoryRateToHealthStoreWithUnit:(double)respiratoryRate completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierRespiratoryRate];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"count/min"] doubleValue:respiratoryRate];
    
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
#pragma mark - DietaryEnergyConsumed(膳食能量消耗)
///-------------------------
-(void)readDietaryEnergyConsumedFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double dietaryEnergyConsumed = 0;
        for (HKQuantitySample *sample in results) {
            dietaryEnergyConsumed += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(dietaryEnergyConsumed,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeDietaryEnergyConsumedToHealthStoreWithUnit:(double)dietaryEnergyConsumed completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit kilocalorieUnit] doubleValue:dietaryEnergyConsumed];
    
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
#pragma mark - OxygenSaturation(血氧饱和度)
///-------------------------
-(void)readOxygenSaturationFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double oxygenSaturation = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(oxygenSaturation,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - BodyTemperature(体温)
///-------------------------
-(void)readBodyTemperatureFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double bodyTemperature = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bodyTemperature,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBodyTemperatureToHealthStoreWithUnit:(double)bodyTemperature completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit degreeCelsiusUnit] doubleValue:bodyTemperature];
    
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
#pragma mark - BloodGlucose(血糖)
///-------------------------
-(void)readBloodGlucoseFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double bloodGlucose = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bloodGlucose,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBloodGlucoseToHealthStoreWithUnit:(double)bloodGlucose completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit unitFromString:@"mg/dl"] doubleValue:bloodGlucose];
    
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
#pragma mark - BloodPressure(血压)
///-------------------------
-(void)readBloodPressureSystolicFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double bloodPressureSystolic = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bloodPressureSystolic,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBloodPressureSystolicToHealthStoreWithUnit:(double)bloodPressureSystolic completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit millimeterOfMercuryUnit] doubleValue:bloodPressureSystolic];
    
    HKQuantitySample *sample = [HKQuantitySample quantitySampleWithType:type quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    [self.store saveObject:sample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            completion(YES);
        }else {
            completion(NO);
        }
    }];
}
-(void)readBloodPressureDiastolicFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByLatestData];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double bloodPressureDiastolic = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(bloodPressureDiastolic,error);
    }];
    
    [self.store executeQuery:query];
}
-(void)writeBloodPressureDiastolicToHealthStoreWithUnit:(double)bloodPressureDiastolic completion:(void(^)(BOOL response))completion
{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit millimeterOfMercuryUnit] doubleValue:bloodPressureDiastolic];
    
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
#pragma mark - StandHour(站立小时)
///-------------------------
-(void)readStandHourFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierAppleStandHour];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double sum = 0;
        for (HKQuantitySample *sample in results) {
            sum += [[[NSString stringWithFormat:@"%@",sample.quantity] componentsSeparatedByString:@" "][0] doubleValue];
        }
        
        completion(sum,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - BiologicalSex(性别)
///-------------------------
-(void)readBiologicalSexFromHealthStoreWithCompletion:(void(^)(NSString *sex,NSError *error))completion
{
    NSError *error = nil;
    HKBiologicalSexObject *sexObject = [self.store biologicalSexWithError:&error];

    NSString *sex = nil;
    switch (sexObject.biologicalSex) {
        case HKBiologicalSexNotSet:
            sex = @"未设置";
            break;
        case HKBiologicalSexMale:
            sex = @"女性";
            break;
        case HKBiologicalSexFemale:
            sex = @"男性";
            break;
        case HKBiologicalSexOther:
            sex = @"其它";
            break;
        default:
            break;
    }
    completion(sex,error);
}


///-------------------------
#pragma mark - DateOfBirth(出生日期)
///-------------------------
-(void)readDateOfBirthFromHealthStoreWithCompletion:(void(^)(NSDate *date,NSError *error))completion
{
    NSError *error = nil;
    NSDateComponents *components = [self.store dateOfBirthComponentsWithError:&error];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *date = [calendar dateFromComponents:components];
    
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSTimeInterval interval = [zone secondsFromGMTForDate:date];
    
    NSDate *dateOfBrith = [date dateByAddingTimeInterval:interval];
    
    completion(dateOfBrith,error);
}


///-------------------------
#pragma mark - BloodType(血型)
///-------------------------
-(void)readBloodTypeFromHealthStoreWithCompletion:(void(^)(NSString *bloodType,NSError *error))completion
{
    NSError *error = nil;
    HKBloodTypeObject *bloodTypeObject = [self.store bloodTypeWithError:&error];
    
    NSString *type = nil;
    switch (bloodTypeObject.bloodType) {
        case HKBloodTypeNotSet:
            type = @"未设置";
            break;
        case HKBloodTypeAPositive:
            type = @"A型血阳性";
            break;
        case HKBloodTypeANegative:
            type = @"A型血阴性";
            break;
        case HKBloodTypeBPositive:
            type = @"B型血阳性";
            break;
        case HKBloodTypeBNegative:
            type = @"B型血阴性";
            break;
        case HKBloodTypeABPositive:
            type = @"AB型血阳性";
            break;
        case HKBloodTypeABNegative:
            type = @"AB型血阴性";
            break;
        case HKBloodTypeOPositive:
            type = @"O型血阳性";
            break;
        case HKBloodTypeONegative:
            type = @"O型血阴性";
            break;
        default:
            break;
    }
    completion(type,error);    
}


///-------------------------
#pragma mark - FitzpatrickSkin(日光反应型皮肤类型)
///-------------------------
-(void)readFitzpatrickSkinFromHealthStoreWithCompletion:(void(^)(NSString *skinType,NSError *error))completion
{
    NSError *error = nil;
    HKFitzpatrickSkinTypeObject *skinTypeObject = [self.store fitzpatrickSkinTypeWithError:&error];
    
    NSString *type = nil;
    switch (skinTypeObject.skinType) {
        case HKFitzpatrickSkinTypeNotSet:
            type = @"未设置";
            break;
        case HKFitzpatrickSkinTypeI:
            type = @"I型";
            break;
        case HKFitzpatrickSkinTypeII:
            type = @"II型";
            break;
        case HKFitzpatrickSkinTypeIII:
            type = @"III型";
            break;
        case HKFitzpatrickSkinTypeIV:
            type = @"IV型";
            break;
        case HKFitzpatrickSkinTypeV:
            type = @"V型";
            break;
        case HKFitzpatrickSkinTypeVI:
            type = @"VI型";
            break;
        default:
            break;
    }
    completion(type,error);    
}


///-------------------------
#pragma mark - SleepAnalysis(睡眠分析)
///-------------------------
-(void)readSleepAnalysisFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double sleepAnalysis = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(sleepAnalysis,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - MenstrualFlow(月经)
///-------------------------
-(void)readMenstrualFlowFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierMenstrualFlow];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double menstrualFlow = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];

        completion(menstrualFlow,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - IntermenstrualBleeding(点滴出血)
///-------------------------
-(void)readIntermenstrualBleedingFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierIntermenstrualBleeding];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {

        double intermenstrualBleeding = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(intermenstrualBleeding,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - SexualActivity(性行为)
///-------------------------
-(void)readSexualActivityFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion
{
    HKSampleType *type = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSexualActivity];
    
    NSSortDescriptor *startSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *endSort = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    NSPredicate *predicate = [self predicateSampleByToday];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type predicate:predicate limit:0 sortDescriptors:@[startSort,endSort] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
    
        double sexualActivity = [[[NSString stringWithFormat:@"%@",results.firstObject] componentsSeparatedByString:@" "][0] doubleValue];
        
        completion(sexualActivity,error);
    }];
    
    [self.store executeQuery:query];
}


///-------------------------
#pragma mark - 谓词样本
///-------------------------
-(NSPredicate *)predicateSampleByToday  //predicate sample is the day data(谓词样本为当天数据)
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
    
    return predicate;
}
-(NSPredicate *)predicateSampleByLatestData    //predicate sample is the latest data(谓词样本为最新数据)
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
    
    return predicate;
}
-(NSPredicate *)predicateSampleByPeriodOfTimeWithStartTime:(NSString *)startTime endTime:(NSString *)endTime    //predicate sample is time period data(谓词样本为时间段数据)
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDate *newStartDate = [formatter dateFromString:startTime];
    NSDate *newEndDate = [formatter dateFromString:endTime];    
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:newStartDate endDate:newEndDate options:(HKQueryOptionNone)];
    
    return predicate;
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
    
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];   //体温
    
    HKQuantityType *BloodGlucose = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];   //血糖
    
    HKQuantityType *BloodPressureSystolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];   //血压收缩压
    
    HKQuantityType *BloodPressureDiastolic = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];   //血压舒张压
    
    HKCategoryType *StandHour = [HKCategoryType categoryTypeForIdentifier:HKCategoryTypeIdentifierAppleStandHour];   //站立小时
    
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
    
    HKQuantityType *BodyTemperature = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature];   //体温
    
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
