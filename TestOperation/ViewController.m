//
//  ViewController.m
//  TestOperation
//
//  Created by qiang on 16/3/10.
//  Copyright © 2016年 acqiang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [self testNSBlockOperation];
//    [self testOperationQueue];
    [self test];

}

-(void)testNSBlockOperation{
    //创建NSBlockOperation对象
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation---%@", [NSThread currentThread]);
    }];
    
    //添加多个Block
    for (NSInteger i = 0; i < 6; i++) {
        [operation addExecutionBlock:^{
            NSLog(@"---download%ld：%@", i, [NSThread currentThread]);
        }];
    }
    
    
    //开始任务，用NSOperationQueue无需手动start方法
    //    [operation start];
    
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 添加任务到队列中（自动异步执行）
    [queue addOperation:operation];
}

-(void)testOperationQueue{
    /**
     假设有A、B、C三个操作，要求：
     1. 3个操作都异步执行
     2. 操作C依赖于操作B
     3. 操作B依赖于操作A
     */
    
    // 1.创建一个队列（非主队列）
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建3个操作
    NSBlockOperation *operationC = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---操作C---%@", [NSThread currentThread]);
    }];
    
    NSBlockOperation *operationA = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---操作A---%@", [NSThread currentThread]);
    }];
    NSBlockOperation *operationB = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"---操作B---%@", [NSThread currentThread]);
    }];
    
    // 设置依赖
    [operationB addDependency:operationA];
    [operationC addDependency:operationB];
    
    // 3.添加操作到队列中（自动异步执行任务）
    [queue addOperation:operationA];
    [queue addOperation:operationB];
    [queue addOperation:operationC];
    
}

-(void)test{
    NSLog(@"-----test-----%@",[NSThread currentThread]);
    NSBlockOperation *operation1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"------operation1 begin------");
        sleep(5);
        NSLog(@"------operation1 end------");
    }];
    operation1.queuePriority = NSOperationQueuePriorityHigh;
    
    NSBlockOperation *operation2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"------operation2 begin------");
        sleep(1);
        NSLog(@"------operation2 end------");
    }];
    
    NSBlockOperation *operation3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"------operation3 begin------");
        sleep(2);
        NSLog(@"------operation3 end------");
    }];
    
    operation2.completionBlock = ^{
        NSLog(@"------operation2 finished in completionBlock------");
    };
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperation:operation2];
    [queue addOperation:operation3];
    [queue addOperation:operation1];
    [queue waitUntilAllOperationsAreFinished];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
