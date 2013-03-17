//
//  Protocols.h
//  Mapp
//
//  Created by Edwin B Shankle III on 11/2/11.
//  Copyright (c) 2011 BA3, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModalViewPresenter
- (void)dismissModalViewController:(NSString *)viewControllerName;
@end
