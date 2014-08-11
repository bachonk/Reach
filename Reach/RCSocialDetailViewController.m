//
//  RCSocialDetailViewController.m
//  Reach
//
//  Created by Tom Bachant on 8/3/14.
//  Copyright (c) 2014 Tom Bachant. All rights reserved.
//

#import "RCSocialDetailViewController.h"

#import "LinkedInManager.h"

static const NSString *kLinkedInURLPrefix = @"https://www.linkedin.com/profile/view?id=";

@interface RCSocialDetailViewController ()

@end

@implementation RCSocialDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithContact:(Contact *)contact {
    self = [super init];
    if (self) {
        _contact = contact;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = _contact.fullName;
    
    UIBarButtonItem *barBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showOptions)];
    self.navigationItem.rightBarButtonItem = barBut;
    
    LinkedInContact *linkedInObj = (LinkedInContact *)_contact;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:linkedInObj.profileLink]]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Merging

- (void)showOptions {
    
    NSString *openText = [LinkedInManager hasLinkedInApp] ? NSLocalizedString(@"Open in LinkedIn App", nil) : NSLocalizedString(@"Open in Safari", nil);
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:openText, nil];
    [ac showInView:self.view];
    
}

#pragma mark - Web Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[request URL].absoluteString rangeOfString:@"linkedin://"].location != NSNotFound) {
        // Trying to open linked in app
        // Not gonna happen
        return NO;
    }
    
    return YES;
    
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        [RCExternalRequestHandler openLinkedInProfile:_contact forceSafari:NO];
    }
    
}

@end
