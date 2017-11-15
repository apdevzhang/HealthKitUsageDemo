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

+(instancetype)sharedInstance;

@property (nonatomic,copy) HealthStorePermissionResponseBlock permissionResponseBlock;

@property (nonatomic,strong) HKHealthStore *store;

///-------------------------
#pragma mark - 获取权限
///-------------------------
/**!
 * @brief 获取权限
 */
-(void)requestHealthPermissionWithBlock:(HealthStorePermissionResponseBlock)block;

///-------------------------
#pragma mark - 步数
///-------------------------
/**!
 * @brief 读取当天步数
 */
-(void)readStepCountFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;

/**!
 * @brief 读取一个时间段步数
 */
-(void)readStepCountFromHealthStoreWithStartTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(double value,NSError *error))completion;

/**!
 * @brief 写入当天步数
 */
-(void)writeStepCountToHealthStoreWithStepCount:(double)setpCount completion:(void(^)(BOOL response))completion;

/**!
 * @brief 写入指定时间段步数
 */
-(void)writeStepCountToHealthStoreWithStepCount:(double)setpCount startTime:(NSString *)startTime endTime:(NSString *)endTime completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - 身高
///-------------------------
/**!
 * @brief 读取身高(cm)
 */
-(void)readHeightFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
/**!
 * @brief 写入身高(cm)
 */
-(void)writeHeightToHealthStoreWithHeight:(double)Height completion:(void(^)(BOOL response))completion;

///-------------------------
#pragma mark - 体重
///-------------------------
/**!
 * @brief 读取体重(KG)
 */
-(void)readBodyMassFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
/**!
 * @brief 写入体重(KG)
 */
-(void)writeBodyMassToHealthStoreWithBodyMass:(double)bodyMass completion:(void(^)(BOOL response))completion;

///-------------------------
#pragma mark - 身体质量指数
///-------------------------
/**!
 * @brief 读取身体质量指数
 */
-(void)readBodyMassIndexFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
/**!
 * @brief 写入身体质量指数
 */
-(void)writeBodyMassIndexToHealthStoreWithBodyMassIndex:(double)bodyMassIndex completion:(void(^)(BOOL response))completion;

///-------------------------
#pragma mark - 步行&跑步距离
///-------------------------
/**!
 * @brief 读取步行&跑步距离(KM)
 */
-(void)readDistanceWalkingRunningFromHealthStoreWithCompletion:(void(^)(double value,NSError *error))completion;
/**!
 * @brief 写入步行&跑步距离(KM)
 */
-(void)writeDistanceWalkingRunningToHealthStoreWithBodyMassIndex:(double)distanceWalkingRunning completion:(void(^)(BOOL response))completion;


///-------------------------
#pragma mark - 以爬楼层
///-------------------------
/**!
 * @brief 读取以爬楼层
 */
-(void)readFlightsClimbedFromHealthStoreWithCompletion:(void(^)(NSInteger value,NSError *error))completion;
/**!
 * @brief 写入以爬楼层
 */
-(void)writeFlightsClimbedToHealthStoreWithBodyMassIndex:(NSInteger)flightsClimbed completion:(void(^)(BOOL response))completion;

@end
