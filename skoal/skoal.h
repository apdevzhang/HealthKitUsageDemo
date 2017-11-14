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

/**!
 * @brief 获取HealthyKit权限
 */
-(void)requestHealthPermissionWithBlock:(HealthStorePermissionResponseBlock)block;

/**!
 * @brief 读取身高
 */
//-(void)readHeightFromHealthStoreWithUnit:(HKUnit *)unit withCompletion:(void(^)(double value,NSError *error))completion;
-(void)readHeightFromHealthStoreWith;
-(void)readHeightFromHealthStoreSourceiPhone;

@end
