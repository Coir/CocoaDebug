//
//  Example
//  man
//
//  Created by man 11/11/2018.
//  Copyright © 2020 man. All rights reserved.
//

#import "_Sandboxer.h"
#import "_DirectoryContentsTableViewController.h"

@interface _Sandboxer ()

@property (nonatomic, strong) UINavigationController *homeDirectoryNavigationController;

@end

@implementation _Sandboxer

@synthesize homeTitle = _homeTitle;

+ (_Sandboxer *)shared {
    static _Sandboxer *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[_Sandboxer alloc] _init];
    });
    
    return _sharedInstance;
}

- (instancetype)_init {
    if (self = [super init]) {
        [self _config];
    }
    
    return self;
}

#pragma mark - Private Methods

- (void)_config {
    _systemFilesHidden = YES;
    _homeFileURL = [NSURL fileURLWithPath:NSHomeDirectory() isDirectory:YES];
    _extensionHidden = NO;
    _shareable = YES;
}

#pragma mark - Setters

- (void)setHomeTitle:(NSString *)title {
    if (![_homeTitle isEqualToString:title]) {
        _homeTitle = [title copy];
        [[self.homeDirectoryNavigationController.viewControllers firstObject] setTitle:_homeTitle];
    }
}

#pragma mark - Getters

- (NSString *)homeTitle {
    if (nil == _homeTitle) {
        _homeTitle = @"Sandbox";
    }
    
    return _homeTitle;
}

- (UINavigationController *)homeDirectoryNavigationController {
    if (!_homeDirectoryNavigationController) {
        _DirectoryContentsTableViewController *directoryContentsTableViewController = [[_DirectoryContentsTableViewController alloc] init];
        directoryContentsTableViewController.homeDirectory = YES;
        directoryContentsTableViewController.fileInfo = [[_FileInfo alloc] initWithFileURL:self.homeFileURL];
        directoryContentsTableViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _homeDirectoryNavigationController = [[UINavigationController alloc] initWithRootViewController:directoryContentsTableViewController];
        //适配iOS13以后的tabbar颜色、属性，沙盒的VC是OC写的，NavVC使用的是UINavVC，需要单独再设置一遍
        UINavigationBarAppearance *barAppearance = UINavigationBarAppearance.new;
        barAppearance.backgroundColor = UIColor.darkGrayColor;
        barAppearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.systemGreenColor,
                                              NSFontAttributeName: [UIFont boldSystemFontOfSize:20]};
        _homeDirectoryNavigationController.navigationBar.tintColor = UIColor.systemGreenColor;
        _homeDirectoryNavigationController.navigationBar.standardAppearance = barAppearance;
        _homeDirectoryNavigationController.navigationBar.scrollEdgeAppearance = barAppearance;
    }
    
    return _homeDirectoryNavigationController;
}

@end
