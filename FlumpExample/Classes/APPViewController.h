//
//  CViewController.h
//  CFlump
//
//  Created by Levi Eggert on 4/17/14.
//  Copyright (c) 2014 Levi Eggert. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLMPView.h"

@class FLMPExport;

@interface APPViewController : UIViewController<FLMPViewDelegate>{
    
}

@property(nonatomic, weak) IBOutlet UIView *flumpContainer;
@property(nonatomic, weak) IBOutlet UIButton *btPlay;
@property(nonatomic, weak) IBOutlet UIButton *btPause;
@property(nonatomic, weak) IBOutlet UIButton *btStop;
@property(nonatomic, weak) IBOutlet UIButton *btLoop;
@property(nonatomic, weak) IBOutlet UILabel *lbFrame;
@property(nonatomic, weak) IBOutlet UILabel *lbAnimationComplete;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *lbAnimationCompleteTopConstraint;

@property(nonatomic, strong) FLMPView *flumpView;

@end
