//
//  main.m
//  LongRetainCycle
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

- (void)dealloc
{
    self.block = nil;
    NSLog(@"%s,%d",__FUNCTION__, __LINE__); // never called
    [super dealloc];
}

- (void)callblock
{
    self.block();
}
@end

@interface User : NSObject
@property (nonatomic, retain) BlockContainer *container;
@property (nonatomic, retain) NSMutableArray* queue;
@end

@implementation User
@synthesize container = _container;
@synthesize queue = _queue;

- (void)dealloc
{
    self.queue = nil;
    self.container = nil;
    NSLog(@"%s,%d",__FUNCTION__, __LINE__); // never called
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
    }
    return self;
}

- (void)setupBlock
{
    NSLog (@"%s,%d retainCount:%ld",__FUNCTION__,__LINE__,[self retainCount]);
    /*
     * retain cycle:
     * case 1: A + B + C
     * case 2: A + B + D
     * case 3: A + B + E
     * case 4: A + B + F
     */
    
    BlockContainer * tempContainer = [[BlockContainer alloc] init];
    // A. self('user') retain 'container'
    self.container = tempContainer;
    [tempContainer release];
    
    // B. 'container' retain 'block'
    _container.block = ^() {
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
        [user setupBlock];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
        [user.container callblock];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
        [user release];
        NSLog (@"%s,%d %@ retainCount:%ld",__FUNCTION__,__LINE__,user,[user retainCount]);
    }
    NSLog(@"%s,%d exit",__FUNCTION__, __LINE__);    
    return 0;
}
