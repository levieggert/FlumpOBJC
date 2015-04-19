//
//  CViewController.h
//  CFlump
//
//  Created by Levi Eggert on 4/17/14.
//  Copyright (c) 2014 Levi Eggert. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FLMPExport;
@class FLMPMovie;

@interface APPViewController : UIViewController{
    
}

@property(nonatomic, strong) IBOutlet UIView *view;
@property(nonatomic, weak) IBOutlet UIView *flumpContainer;
@property(nonatomic, weak) IBOutlet UIButton *btPlay;
@property(nonatomic, weak) IBOutlet UIButton *btPause;
@property(nonatomic, weak) IBOutlet UIButton *btStop;

@property(nonatomic, strong) FLMPExport *flumpExport;
@property(nonatomic, strong) FLMPMovie *flumpMovie;

@end
