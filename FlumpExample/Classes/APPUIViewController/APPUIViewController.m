//
// @author Levi Eggert
//

#import "APPUIViewController.h"

#import "FLMPExport.h"
#import "FLMPUIAtlas.h"
#import "FLMPView.h"

@implementation APPUIViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    self.flumpViewUIKit = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    
    //flumpExportUIKit
    FLMPExport *flumpExportUIKit = [[FLMPExport alloc] initWithFlumpXMLFileName:@"test3" atlasClass:[FLMPUIAtlas class]];
    
    //flumpViewUIKit
    self.flumpViewUIKit = [[FLMPView alloc] initWithFlumpExport:flumpExportUIKit movieName:@"test3_movie"];
    [self.view addSubview:self.flumpViewUIKit];
    self.flumpViewUIKit.layer.position =  CGPointMake([UIScreen mainScreen].bounds.size.width / 2.0f + 30.0f, 380.0f);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
