//
//  main.m
//  RetainCycle
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
    NSLog (@"%s,%d",__FUNCTION__,__LINE__); // never called.
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog (@"%s,%d",__FUNCTION__,__LINE__);
    }
    return self;
}

- (void)setupBlock
{
    NSLog (@"%s,%d",__FUNCTION__,__LINE__);
    /*
     * retain cycle:
     * case 1: A + B
     * case 2: A + C
     * case 3: A + D
     */
    
    // A. self retain block
    self.block = ^{
        // Xcode Warning: Capturing 'self' strongly in this block is likely to lead to a retain cycle
        
        // B. reference member variable, indirect reference self, block implicit retain self
        if(self.queue == nil)
            self.queue = [NSMutableArray array];
        
        // C. direct reference self, block explict retain self
        [_queue addObject:[NSNull null]];
        
        // D. direct reference self, block explict retain self
        NSLog(@"object is %@",self);        
    };
    NSLog (@"%s,%d",__FUNCTION__,__LINE__);
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
        NSLog (@"%s,%d",__FUNCTION__,__LINE__);
    }
    NSLog (@"%s,%d end",__FUNCTION__,__LINE__);
    return 0;
}
