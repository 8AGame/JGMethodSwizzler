//
//  AppDelegate.m
//  JGMethodSwizzler
//
//  Created by Jonas Gessner on 22.08.13.
//  Copyright (c) 2013 Jonas Gessner. All rights reserved.
//

#import "AppDelegate.h"
#import "JGMethodSwizzler.h"

@implementation AppDelegate


static BOOL testFailed = NO;

#define JGTestCheck(condition, description) if (!condition) {testFailed = YES; NSLog(@"Test Failed: %@", description);}

- (int)a:(int)b {
    return b-2;
}

+ (CGRect)testRect {
    return CGRectMake(0.0f, 1.0f, 2.0f, 3.0f);
}


+ (CGRect)testRect2:(CGRect)r {
    return CGRectInset(r, 10.0f, 10.0f);
}

- (NSObject *)applySwizzles {
    int add = arc4random_uniform(50);
    
    [self.class swizzleInstanceMethod:@selector(a:) withReplacement:^ JGMethodReplacementProviderBlock {
        return ^ JGMethodReplacement(int, AppDelegate *, int b) {
            int orig = JGCastOriginal(int, b);
            return orig+add;
        };
    }];
    
    int yoo = arc4random_uniform(100);
    
    int aa = [self a:yoo];
    
    JGTestCheck(aa == yoo+add, @"Integer calculation mismatch");
    
    
    
    [self.class swizzleClassMethod:@selector(testRect) withReplacement:^ JGMethodReplacementProviderBlock {
        return ^ JGMethodReplacement(CGRect, const Class *) {
            CGRect orig = JGCastOriginal(CGRect);
            
            return CGRectInset(orig, -5.0f, -5.0f);
        };
    }];
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), -5.0f, -5.0f)), @"CGRect swizzling failed");
    
    [self.class swizzleClassMethod:@selector(testRect2:) withReplacement:^ JGMethodReplacementProviderBlock {
        return ^ JGMethodReplacement(CGRect, const Class *, CGRect rect) {
            CGRect orig = JGCastOriginal(CGRect, rect);
            
            return CGRectInset(orig, -5.0f, -5.0f);
        };
    }];
    
    
    CGRect testRect = (CGRect){{(CGFloat)arc4random_uniform(100), (CGFloat)arc4random_uniform(100)}, {(CGFloat)arc4random_uniform(100), (CGFloat)arc4random_uniform(100)}};
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:testRect], CGRectInset(CGRectInset(testRect, 10.0f, 10.0f), -5.0f, -5.0f)), @"CGRect swizzling (2) failed");
    
    
    NSObject *object = [NSObject new];
    
    
    [object swizzleMethod:@selector(description) withReplacement:^ JGMethodReplacementProviderBlock {
        return ^ JGMethodReplacement(NSString *, NSObject *) {
            NSString *orig = JGCastOriginal(NSString *);
            
            return [orig stringByAppendingString:@"Only swizzled this instance"];
        };
    }];
    
    JGTestCheck([[object description] hasSuffix:@"Only swizzled this instance"] && ![[[NSObject new] description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed");
    
    [object swizzleMethod:@selector(init) withReplacement:^ JGMethodReplacementProviderBlock {
        return ^ JGMethodReplacement(id, NSObject *) {
            id orig = JGCastOriginal(id);
            
            return orig;
        };
    }];
    
    return object;
}


- (void)removeSwizzles1:(NSObject *)object {
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    BOOL ok2 = [object deswizzle];
    BOOL ok3 = deswizzleInstances();
    
    JGTestCheck(ok3 == NO && ok == YES && ok1 == YES && ok2 == NO && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok4 = [self.class deswizzleInstanceMethod:@selector(a:)];
    
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok6 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok8 = [self.class deswizzleAllInstanceMethods];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    
    JGTestCheck(ok10 == NO && ok9 == NO && ok8 == NO && ok7 == NO && ok4 == YES && ok5 == YES && ok6 == YES && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}

- (void)removeSwizzles2:(NSObject *)object {
    BOOL ok2 = [object deswizzle];
    BOOL ok3 = deswizzleInstances();
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    
    JGTestCheck(ok3 == NO && ok == NO && ok1 == NO && ok2 == YES && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok6 = [self.class deswizzleInstanceMethod:@selector(a:)];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok8 = [self.class deswizzleAllInstanceMethods];
    
    
    BOOL ok4 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    JGTestCheck(ok10 == NO && ok8 == NO && ok9 == NO && ok6 == YES && ok7 == NO && ok4 == NO && ok5 == NO && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}



- (void)removeSwizzles3:(NSObject *)object {
    BOOL ok3 = deswizzleInstances();
    BOOL ok2 = [object deswizzle];
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    
    JGTestCheck(ok3 == YES && ok == NO && ok1 == NO && ok2 == NO && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok6 = [self.class deswizzleAllInstanceMethods];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok8 = [self.class deswizzleInstanceMethod:@selector(a:)];
    
    BOOL ok4 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    JGTestCheck(ok9 == NO && ok10 == NO && ok6 == YES && ok7 == YES && ok4 == NO && ok5 == NO && ok8 == NO && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}



- (void)removeSwizzles4:(NSObject *)object {
    BOOL ok3 = deswizzleInstances();
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    BOOL ok2 = [object deswizzle];
    
    JGTestCheck(ok3 == YES && ok == NO && ok1 == NO && ok2 == NO && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok6 = [self.class deswizzleAllInstanceMethods];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    BOOL ok8 = [self.class deswizzleInstanceMethod:@selector(a:)];
    
    BOOL ok4 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    JGTestCheck(ok10 == NO && ok9 == YES && ok6 == NO && ok7 == NO && ok4 == NO && ok5 == NO && ok8 == NO && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}



- (void)removeSwizzles5:(NSObject *)object {
    BOOL ok3 = deswizzleInstances();
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    BOOL ok2 = [object deswizzle];
    
    JGTestCheck(ok3 == YES && ok == NO && ok1 == NO && ok2 == NO && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok6 = [self.class deswizzleAllInstanceMethods];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    BOOL ok8 = [self.class deswizzleInstanceMethod:@selector(a:)];
    
    BOOL ok4 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    JGTestCheck(ok10 == YES && ok9 == NO && ok6 == NO && ok7 == NO && ok4 == NO && ok5 == NO && ok8 == NO && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}



- (void)removeSwizzles6:(NSObject *)object {
    BOOL ok11 = deswizzleAll();
    
    
    BOOL ok3 = deswizzleInstances();
    BOOL ok = [object deswizzleMethod:@selector(description)];
    BOOL ok1 = [object deswizzleMethod:@selector(init)];
    BOOL ok2 = [object deswizzle];
    
    JGTestCheck(ok11 == YES && ok3 == NO && ok == NO && ok1 == NO && ok2 == NO && ![[object description] hasSuffix:@"Only swizzled this instance"], @"Instance swizzling failed (1)");
    
    
    BOOL ok10 = deswizzleGlobal();
    
    BOOL ok9 = [self.class deswizzleAllMethods];
    
    BOOL ok6 = [self.class deswizzleAllInstanceMethods];
    BOOL ok7 = [self.class deswizzleAllClassMethods];
    
    BOOL ok8 = [self.class deswizzleInstanceMethod:@selector(a:)];
    
    BOOL ok4 = [self.class deswizzleClassMethod:@selector(testRect)];
    BOOL ok5 = [self.class deswizzleClassMethod:@selector(testRect2:)];
    
    
    JGTestCheck(ok10 == NO && ok9 == NO && ok6 == NO && ok7 == NO && ok4 == NO && ok5 == NO && ok8 == NO && [self a:10] == 8, @"Deswizzling failed");
    
    JGTestCheck(CGRectEqualToRect([self.class testRect], CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)), @"Deswizzling failed (1)");
    
    
    JGTestCheck(CGRectEqualToRect([self.class testRect2:CGRectMake(0.0f, 1.0f, 2.0f, 3.0f)], CGRectInset(CGRectMake(0.0f, 1.0f, 2.0f, 3.0f), 10.0f, 10.0f)), @"Deswizzling failed (2)");
}


- (void)test {
    NSObject *object = [self applySwizzles];
    
    [self removeSwizzles1:object];
    
    
    object = [self applySwizzles];
    
    [self removeSwizzles2:object];
    
    
    
    object = [self applySwizzles];
    
    [self removeSwizzles3:object];
    
    
    object = [self applySwizzles];
    
    [self removeSwizzles4:object];
    
    
    
    object = [self applySwizzles];
    
    [self removeSwizzles5:object];
    
    
    
    object = [self applySwizzles];
    
    [self removeSwizzles6:object];
    
    
//    For debugging purposes: (function needs to be uncommented in JGMethodSwizzler.m in order to work)
//    FOUNDATION_EXTERN NSString *getStatus();
//    NSLog(@"STATUS %@", getStatus());
}



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    
    //We've got some pretty extensive tests gong on here:
    [self test];
    
    if (!testFailed) {
        NSLog(@"Tests Succeeded. Elapsed Time: %f", CFAbsoluteTimeGetCurrent()-start);
    }
    
    return YES;
}

@end
