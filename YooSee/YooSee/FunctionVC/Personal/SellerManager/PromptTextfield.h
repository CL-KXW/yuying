//
//  PromptTextfield.h
//  YooSee
//
//  Created by 周后云 on 16/3/9.
//  Copyright © 2016年 chenlei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptTextfield : UIView

@property(nonatomic,weak)IBOutlet UIView *lineView;
@property(nonatomic,weak)IBOutlet UILabel *promptLabel;
@property(nonatomic,weak)IBOutlet UITextField *inputTextField;

@end
