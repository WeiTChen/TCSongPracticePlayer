//
//  NSString+MD5.h
//  MD5
//
//  Created by zhuchenglong on 15/11/26.
//  Copyright © 2015年 zhuchenglong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)
/**
 *  32位MD5加密
 *
 *  @return 32位MD5加密结果
 */
- (NSString *)MD5;

/**
 *  SHA1加密
 *
 *  @return SHA1加密结果
 */
- (NSString *)SHA1;

@end
