//
// @author Levi Eggert
//

#import <UIKit/UIKit.h>

#import "FLMPView.h"
#import "FLMPSPDisplayObject.h"

@class APPUIViewController;
@class APPSparrowViewController;

typedef enum{
    FlumpExampleTypeUIKit = 1,
    FlumpExampleTypeSparrow = 2
}FlumpExampleType;

@interface APPRootViewController : UIViewController<FLMPViewDelegate, FLMPSPDisplayObjectDelegate>{
    
}

@property(nonatomic, weak) IBOutlet UIImageView *backgroundImage;
@property(nonatomic, weak) IBOutlet UIButton *btFlumpUIKitExample;
@property(nonatomic, weak) IBOutlet UIButton *btFlumpSparrowExample;
@property(nonatomic, weak) IBOutlet UIButton *btPlay;
@property(nonatomic, weak) IBOutlet UIButton *btPause;
@property(nonatomic, weak) IBOutlet UIButton *btStop;
@property(nonatomic, weak) IBOutlet UIButton *btLoop;
@property(nonatomic, weak) IBOutlet UILabel *lbFrame;
@property(nonatomic, weak) IBOutlet UILabel *lbAnimationComplete;

@property(nonatomic, weak) IBOutlet NSLayoutConstraint *lbAnimationCompleteTopConstraint;

@property(nonatomic, strong) APPUIViewController *uiViewController;
@property(nonatomic, strong) APPSparrowViewController *sparrowViewController;
@property(nonatomic, assign) FlumpExampleType flumpExampleType;
@property(nonatomic, assign) NSInteger lbFrameCount;

@end
