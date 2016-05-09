//
//  JXViscous.m
//  JXViscous
//
//  Created by 王加祥 on 16/5/9.
//  Copyright © 2016年 Wangjiaxiang. All rights reserved.
//

#import "JXViscous.h"

#define kMAX 100

@interface JXViscous ()

/** 背景视图 */
@property (nonatomic,weak) UIView * smallView;

/** 背景半径 */
@property (nonatomic,assign) CGFloat smallRadius;
/** 不规则路径 */
@property (nonatomic, weak) CAShapeLayer *shapeLayer;
@end

@implementation JXViscous

- (void)awakeFromNib {
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

#pragma mark - init
- (void)setup {
    // 初始化代码
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.backgroundColor = [UIColor redColor];
    
    // 添加手势，
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
    
}
- (void)pan:(UIPanGestureRecognizer *)gesture {
    // 获取移动偏移
    CGPoint transP = [gesture translationInView:self];
    // 计算偏移
    CGPoint center = self.center;
    center.x += transP.x;
    center.y += transP.y;
    self.center = center;
    // 复原，相对于每次累加
    [gesture setTranslation:CGPointZero inView:self];
    
    // 移动距离，背景图片开始缩放
    CGFloat distance = [self circleCenterDistanceWithBigView:self.center smallView:self.smallView.center];
    CGFloat curRadius = self.smallRadius - distance / 10;
    
    if (distance > kMAX || curRadius <= 0) {
        // 当将要消失，或者背景的半径小于0的时候将其置为0
        curRadius = 0;
        // 拖动距离大于设置距离，隐藏背景，移除不规则路径，将其指针置空，否则不会执行不规则路径的懒加载
        self.smallView.hidden = YES;
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
    } else if (distance > 0 && self.smallView.hidden == NO){
        
        self.shapeLayer.path = [self pathWithbigView:self smallView:self.smallView].CGPath;
    }
    // 重新设置背景的尺寸
    self.smallView.bounds = CGRectMake(0, 0, curRadius * 2, curRadius * 2);
    self.smallView.layer.cornerRadius = curRadius;
    
    // 当手指结束拖动的时候还原
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        // 当手指结束拖动的时候，如果放开的距离大于我们设置的距离，我们需要移除控件
        if (distance > kMAX) {
            
            // 设置UIImageView
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:self.bounds];
            // 设置动画gif
            NSMutableArray * mutableArray = [NSMutableArray array];
            for (NSInteger i = 1; i<9; i++) {
                UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"%ld",i]];
                [mutableArray addObject:image];
            }
            imageView.animationImages = mutableArray;
            imageView.animationDuration = 0.4;
            imageView.animationRepeatCount = 1;
            [imageView startAnimating];
            [self addSubview:imageView];
            // 动画结束的时候移除控件
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self removeFromSuperview];
            });
            
            
        } else {
            // 不大于我们就还原操作
            self.smallView.hidden = NO;
            // 移除不规则路径
            [self.shapeLayer removeFromSuperlayer];
            self.shapeLayer = nil;
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
                self.center = self.smallView.center;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}
- (CGFloat)circleCenterDistanceWithBigView:(CGPoint)bigViewCenter smallView:(CGPoint)smallViewCenter {
    CGFloat distanceX = bigViewCenter.x - smallViewCenter.x;
    CGFloat distanceY = bigViewCenter.y - smallViewCenter.y;
    return sqrt(distanceX * distanceX + distanceY * distanceY);
}

- (UIBezierPath *)pathWithbigView:(UIView *)bigView smallView:(UIView *)smallView {
    // 获取当前两点位置以及位置比例
    CGPoint centerS = smallView.center;
    CGFloat centerSX = centerS.x;
    CGFloat centerSY = centerS.y;
    CGFloat radiusS = smallView.bounds.size.width / 2.0;
    
    CGPoint centerB = bigView.center;
    CGFloat centerBX = centerB.x;
    CGFloat centerBY = centerB.y;
    CGFloat radiusB = bigView.bounds.size.width / 2.0;
    
    // 两个圆心之间间距
    CGFloat d = [self circleCenterDistanceWithBigView:centerB smallView:centerS];
    CGFloat sin = (centerB.y - centerS.y) / d;
    CGFloat cos = (centerB.x - centerS.x) / d;
    
    CGPoint curA = CGPointMake(centerSX - radiusS * sin, centerSY + radiusS * cos);
    CGPoint curB = CGPointMake(centerSX + radiusS * sin, centerSY - radiusS * cos);
    CGPoint curC = CGPointMake(centerBX + radiusB * sin, centerBY - radiusB * cos);
    CGPoint curD = CGPointMake(centerBX - radiusB * sin, centerBY + radiusB * cos);
    CGPoint curO = CGPointMake(curA.x + d * cos / 2, curA.y + d * sin / 2);
    CGPoint curP = CGPointMake(curB.x + d * cos / 2, curB.y + d * sin / 2);
    
    UIBezierPath * path = [UIBezierPath bezierPath];
    // 点A开始
    [path moveToPoint:curA];
    // 绘制AB直线
    [path addLineToPoint:curB];
    // 绘制BC曲线
    [path addQuadCurveToPoint:curC controlPoint:curP];
    // 绘制CD直线
    [path addLineToPoint:curD];
    // 绘制DA曲线
    [path addQuadCurveToPoint:curA controlPoint:curO];
    
    return path;
}
#pragma mark - 自定义控件大小
- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    self.layer.cornerRadius = width / 2;
    
    // 值执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"%s",__func__);
        self.smallView.bounds = self.bounds;
        self.smallView.center = self.center;
        self.smallView.layer.cornerRadius = width / 2;
        self.smallRadius = width / 2;
    });
}

#pragma mark - 重写set方法
- (void)setViscousCount:(NSInteger)viscousCount {
    _viscousCount = viscousCount;
    [self setTitle:[NSString stringWithFormat:@"%zd",viscousCount] forState:UIControlStateNormal];
}

#pragma mark - 懒加载
- (UIView *)smallView {
    if (_smallView == nil) {
        UIView * smallView = [[UIView alloc] init];
        smallView.backgroundColor = self.backgroundColor;
        _smallView = smallView;
        // 将视图添加到控件的父视图上，位置在控件之下
        [self.superview insertSubview:smallView belowSubview:self];
    }
    return _smallView;
}

- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer == nil) {
        CAShapeLayer * shapeLayer = [CAShapeLayer layer];
        _shapeLayer = shapeLayer;
        // 填充颜色
        shapeLayer.fillColor = self.backgroundColor.CGColor;
        [self.superview.layer insertSublayer:shapeLayer below:self.layer];
    }
    return _shapeLayer;
}
@end
