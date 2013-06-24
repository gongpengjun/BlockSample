//
//  main.m
//  RetainCycleFix
//
//  Created by 巩 鹏军 on 13-6-24.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MyBlock)(void);

@interface BlockContainer : NSObject
@property (nonatomic, retain) NSMutableArray* queue;
@property (nonatomic, copy) MyBlock block;
- (void)callblock;
@end

@implementation BlockContainer
@synthesize block = _block;
@synthesize queue = _queue;

- (void)dealloc
{
    self.block = nil;
    NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)self,self,[self retainCount]);
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)self,self,[self retainCount]);
    }
    return self;
}

- (void)setupBlock
{
    NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)self,self,[self retainCount]);
    /*
     * NO retain cycle:
     * case 1: A + B
     * case 2: A + C
     * case 3: A + D
     */
    
    // In non-ARC, '__block' break retain cycle
    __block BlockContainer *blockSelf = self;
    NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)blockSelf,blockSelf,[blockSelf retainCount]);
    
    // A. self retain block
    self.block = ^{
        // B. reference blockSelf
        if(blockSelf.queue == nil)
            blockSelf.queue = [NSMutableArray array];
        
        // C. reference blockSelf
        [blockSelf.queue addObject:[NSNull null]];
        
        // D. reference blockSelf
        NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)blockSelf,blockSelf,[blockSelf retainCount]);
    };
    NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)self,self,[self retainCount]);
}

- (void)callblock
{
    self.block();
}

@end

int main(int argc, const char * argv[])
{
    NSLog (@"%s,%d start",__FUNCTION__,__LINE__);
    BlockContainer *container = nil;
    @autoreleasepool
    {
        container = [[BlockContainer alloc] init];
        [container setupBlock];
        [container callblock];
        NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)container,container,[container retainCount]);
        [container release];
        container = nil;
        NSLog(@"%s,%d 0x%X %@ retainCount:%ld",__FUNCTION__,__LINE__,(unsigned int)container,container,[container retainCount]);
    }
    NSLog (@"%s,%d end",__FUNCTION__,__LINE__);
    return 0;
}
