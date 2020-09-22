//
//  ViewController.m
//  ReactiveTest
//
//  Created by 段庆烨 on 2020/9/20.
//  Copyright © 2020 段庆烨. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self testCreateSignal];
    
    
}

- (void)enumArray{
    NSArray * array = @[@1,@2,@3,@4,@5];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"\n当前线程：%@\n位置：%ld\n单位：%@\n",[NSThread currentThread],idx,obj);
    }];
}

/// 先开进水阀 再开出水阀
- (void)testCreateSignal {
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 每当有订阅者订阅信号，就会调用此block。
        // 3.发送信号
        [subscriber sendNext:@"糖水"];
        [subscriber sendNext:@"盐水"];
        [subscriber sendNext:@"辣椒水"];
        // 如果不再发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        // 5.订阅完成
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            // 7.当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"信号被阻断");
        }];
    }];
    // 2.订阅信号,依次获取步骤3中传递的信息
    // (此方法隐藏了两件事：一是创建订阅者RACSubscriber，二是为信号配置订阅者并触发订阅任务。其目的是简化信号订阅逻辑)
    [siganl subscribeNext:^(id x) {
        // 4.每当有信号sendNext: ，就会调用此block.
        NSLog(@"接收到数据:%@",x);
    } error:^(NSError *error) {
        NSLog(@"信号发送失败");
    } completed:^{
        // 6.第5步中[subscriber sendCompleted];执行后直接走此处方法
        NSLog(@"信号发送完成");
    }];
    // 8.继续订阅信号，依次获取步骤3中传递的信息
    [siganl subscribeNext:^(id x) {
        // 每当有信号sendNext: ，就会调用此block.
        NSLog(@"接收到数据:%@",x);
    }];
}

/// 可以先开出水阀 再开进水阀
- (void)testRACSubject {
    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    // 2.订阅信号
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    [subject subscribeNext:^(id x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
    
    // 3.发送信号
    [subject sendNext:@"糖水"];
    [subject sendNext:@"盐水"];
    [subject sendNext:@"辣椒水"];
}


@end
