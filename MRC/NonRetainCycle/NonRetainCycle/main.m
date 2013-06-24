//
//  main.m
//  NonRetainCycle
//
//  Created by 巩 鹏军 on 13-6-24.
//  Copyright (c) 2013年 巩 鹏军. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MyBlock)(void);

@interface BlockContainer : NSObject
@property (nonatomic, copy) MyBlock block;
@end

@implementation BlockContainer
@synthesize block = _block;

- (void)dealloc {
    self.block = nil;
    NSLog(@"%s,%d",__FUNCTION__, __LINE__);
    [super dealloc];
}

- (void)callblock {
    self.block();
}
@end

@interface User : NSObject
@property (nonatomic, retain) NSMutableArray* queue;
@end

@implementation User
@synthesize queue = _queue;

- (void)dealloc
{
    self.queue = nil;
    NSLog(@"%s,%d",__FUNCTION__, __LINE__);
    [super dealloc];
}

- (id)init {
    if ((self = [super init]))
    {
        NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
    }
    return self;
}

- (BlockContainer *)setupBlock
{
    NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
    
    /*
     * NO retain cycle:
     * case 1: A + B + C
     * case 2: A + B + D
     * case 3: A + B + E
     * case 4: A + B + F
     */
    
    // A. 'self (user)' do NOT retain 'container'
    BlockContainer * container = [[[BlockContainer alloc] init] autorelease];
    
    // B. 'container' retain 'block'
    container.block = ^() {
        NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
        
        // C. reference member variable, indirect reference self, block implicit retain self (user)
        if(self.queue == nil)
            self.queue = [NSMutableArray array];
        
        // D. direct reference self, block explict retain self (user)
        [_queue addObject:[NSNull null]];
        
        
        // E. direct reference self, block explict retain self (user)
        [self done];
        
        // F. direct reference self, block explict retain self (user)
        NSLog(@"object is %@",self);
    };
    NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
    return container;
}


- (void)done
{
    NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
}

@end

int main(int argc, const char * argv[])
{
    NSLog(@"%s,%d start",__FUNCTION__, __LINE__);
    @autoreleasepool
    {
        User *user = [[User alloc] init];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
        BlockContainer * container = [user setupBlock];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
        [container callblock];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
        [user release];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
    }
    NSLog(@"%s,%d exit",__FUNCTION__, __LINE__);
    return 0;
}
