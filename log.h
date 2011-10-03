/*
 *  log.h
 *  QuickDic
 *
 *  Created by Donut on 11. 10. 3..
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#ifdef DEBUG
#	define DLog(fmt, ...)	NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#   define VLog(...)		NSLog(__VA_ARGS__)
#else
#	define DLog(...)
#   define VLog(...)
#endif