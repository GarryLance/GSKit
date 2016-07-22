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
#define BLOCKSELF __block typeof(self) blockSelf = self;
#define BLOCK_TYPE(block,_block) __block typeof(block) _block = block;
#define BLOCK_TYPE_COPY(block,_block) __block typeof(block) _block = Block_copy(block);


//

#define GSSCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define GSSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


#endif /* Header_h */
