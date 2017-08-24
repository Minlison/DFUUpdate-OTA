//
//  DFUCommonDefine.h
//  DFU
//
//  Created by MinLison on 2017/8/21.
//  Copyright © 2017年 minlison. All rights reserved.
//

#ifndef DFUCommonDefine_h
#define DFUCommonDefine_h

#define DFUTOOL_BLOCK_CALL(obj,...) if ([obj __VA_ARGS__])   [obj __VA_ARGS__]
#define DFUTOOL_IS_NULLString(string) ((string == nil) || ([string isKindOfClass:[NSNull class]]) || (![string isKindOfClass:[NSString class]])||[string isEqualToString:@""] || [string isEqualToString:@"<null>"] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]== 0 )

#endif /* DFUCommonDefine_h */
