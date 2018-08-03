//
//  Header.h
//  zaozao
//
//  Created by OSU on 16/4/20.
//  Copyright © 2016年 miao. All rights reserved.
//

#ifndef GSDefine_h
#define GSDefine_h

//log

#ifdef DEBUG
#define GSDLog(...) NSLog(__VA_ARGS__);
#define GSDDLog(...) GSDLog(@"GSDebugDetailLog:\nfile:%@\nfunc:%s\nline:%d\ninfo:%@\n\n",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],__FUNCTION__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define GSDLog(...) /* */
#define GSDDLog(...) /* */
#endif


//block

#define WEAKSELF __weak typeof(self) _self = self;
#define WEAK_TYPE(var,_var) __weak typeof(var) _var = var;

#define BLOCKSELF __block typeof(self) blockSelf = self;
#define BLOCK_TYPE(block,_block) __block typeof(block) _block = block;
#define BLOCK_TYPE_COPY(block,_block) __block typeof(block) _block = Block_copy(block);


//

#define GSSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define GSSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


//color

#define GSRGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/** 传入一个十六进制的数如0xffffff*/
#define GSColorHex(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1]

#endif /* Header_h */
