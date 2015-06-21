//
//  HomeViewController.m
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-20.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

@interface HomeViewController ()<UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIButton *registerNewButton;
@property (strong, nonatomic) IBOutlet UIButton *logOutButton;
@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) CLLocationManager *manager;


@end

@implementation HomeViewController
@synthesize registerNewButton;
@synthesize logOutButton;
@synthesize logInButton;

- (void)viewDidLoad {
    [super viewDidLoad];
   
   if(_manager == nil){
      _manager = [CLLocationManager new];
   }
   [_manager requestWhenInUseAuthorization];
  
}

-(void)viewWillAppear:(BOOL)animated{
   [super viewWillAppear:animated];
   
   self.navigationController.interactivePopGestureRecognizer.delegate = self;

   
   
   [self configureButtons];
}


// stop the view controller from swipe to pop
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
   return NO;
}

- (IBAction)registerNewClick:(UIButton *)sender {
   
   [self registerNewUser];
}



- (IBAction)logOutClick:(UIButton *)sender {
   [PFUser logOut];
   [self configureButtons];
}

- (IBAction)logInClick:(UIButton *)sender {
   
   if([self isSomeOneLoggedOn]){
     [self performSegueWithIdentifier:@"HomeToMaps" sender:nil];
   }
      
   else{
      [self LoginUser];
 
   }
   
}

#pragma mark - Configure Buttons

-(void)configureButtons{
   bool isLoggedOn = NO;
   // do we have someone logged on - check userName
   // there is actually always someone logged on but we check if they have a valid name
   isLoggedOn = [self isSomeOneLoggedOn];
   
   if(isLoggedOn) // we have a valid user logged ON
   {
      registerNewButton.enabled = NO;
      logInButton.enabled = YES;
      logOutButton.enabled = YES;
   }
   else
   {
      registerNewButton.enabled = YES;
      logInButton.enabled = YES;
      logOutButton.enabled = NO;
   }
   
}

-(bool)isSomeOneLoggedOn{
   // do we have someone logged on - check userName
   PFUser *user = [PFUser currentUser];
   return user.username == nil ? NO : YES ;
}

#pragma mark - SignUp and Register a New Regular User
-(void)registerNewUser{
   
   UIAlertController *alert= [UIAlertController
                              alertControllerWithTitle:@"Registration"
                              message:@"Register a new user."
                              preferredStyle:UIAlertControllerStyleAlert];
   
   UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                     
                                                  }];
   UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action){
                                                 
                                                 UITextField *textFieldName = alert.textFields[0];
                                                 UITextField *textFieldPassword = alert.textFields[1];
                                                 UITextField *textFieldEmail = alert.textFields[2];
                                                 NSString *userName = [textFieldName.text lowercaseString];
                                                 NSString *userPassword = textFieldPassword.text;
                                                 NSString *email = [textFieldEmail.text lowercaseString];
                                                 
                                                 [self signUpNewUser:userName userPassword:userPassword userEmail:email];
                                                 
                                              }];
   [alert addAction:cancel];
   [alert addAction:ok];
   
   [alert addTextFieldWithConfigurationHandler:^(UITextField *textFieldName) {
      textFieldName.placeholder = @"User Name";
      textFieldName.keyboardType = UIKeyboardTypeDefault;
      textFieldName.keyboardAppearance = UIKeyboardAppearanceAlert;
      textFieldName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      textFieldName.tintColor = [UIColor blackColor];
   }];
   
   [alert addTextFieldWithConfigurationHandler:^(UITextField *textFieldPassWord) {
      textFieldPassWord.placeholder = @"Password (6 characters min.)";
      textFieldPassWord.keyboardType = UIKeyboardTypeDefault;
      textFieldPassWord.keyboardAppearance = UIKeyboardAppearanceAlert;
      textFieldPassWord.secureTextEntry = YES;
      textFieldPassWord.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      textFieldPassWord.tintColor = [UIColor blackColor];
   }];
   
   [alert addTextFieldWithConfigurationHandler:^(UITextField *textFieldEmail) {
      textFieldEmail.placeholder = @"Email Address (optional)";
      textFieldEmail.keyboardType = UIKeyboardTypeEmailAddress;
      textFieldEmail.keyboardAppearance = UIKeyboardAppearanceAlert;
      textFieldEmail.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      textFieldEmail.tintColor = [UIColor blackColor];
   }];
   
   [self presentViewController:alert animated:YES completion:nil];
}

- (void)signUpNewUser:(NSString*)theUserName userPassword:(NSString*)theUserPassword userEmail:(NSString*)theUserEmail{
   
   // user name missing
   if([theUserName length] < 1){
      UIAlertController *errorAlert = [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"You require a user name."
                                       preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
      [errorAlert addAction:ok];
      [self presentViewController:errorAlert animated:YES completion:nil];
      return;
   }
   
   // check here if the password is long enough
   if([theUserPassword length] < 6){
      
      UIAlertController *errorAlert = [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"Your password must be at least 6 characters in length."
                                       preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
      [errorAlert addAction:ok];
      [self presentViewController:errorAlert animated:YES completion:nil];
      return;
   }
   
   // no spaces in password
   NSRange whiteSpaceRange = [theUserPassword rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
   if (whiteSpaceRange.location != NSNotFound) {
      UIAlertController *errorAlert = [UIAlertController
                                       alertControllerWithTitle:@"Error"
                                       message:@"Your password can't contain spaces"
                                       preferredStyle:UIAlertControllerStyleAlert];
      UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
      [errorAlert addAction:ok];
      [self presentViewController:errorAlert animated:YES completion:nil];
      return;
   }
   
   PFUser *user = [PFUser user];
   user.username = theUserName;
   user.password = theUserPassword;
   
   if(theUserEmail.length > 0){
      if([self validateEmail:theUserEmail]){
         user[@"email"] = theUserEmail;
      }
      else{
         UIAlertController *errorAlert = [UIAlertController
                                          alertControllerWithTitle:@"Problem"
                                          message:@"This is not a valid email address"
                                          preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
         [errorAlert addAction:ok];
         [self presentViewController:errorAlert animated:YES completion:nil];
         return;
      }
   }
   else
      [user setEmail:nil];
   
   
   
   //   user[@"isPurchased"] = [NSNumber numberWithBool:NO];
   //   user[@"isAnonymous"] = @"NO";
   

   [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

      if (!error) {
         [self finishLogin:theUserName theUserPassword:theUserPassword];
      }
      else
      {
         NSString *errorString = [[error userInfo] objectForKey:@"error"];
         UIAlertController *errorAlert = [UIAlertController
                                          alertControllerWithTitle:@"Error"
                                          message:errorString
                                          preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
         [errorAlert addAction:ok];
         [self presentViewController:errorAlert animated:YES completion:nil];
      }
   }];
}


#pragma mark - Login a Registered user
-(void)LoginUser{
   
   UIAlertController *alert= [UIAlertController
                              alertControllerWithTitle:@"Login"
                              message:@"Enter user name and password"
                              preferredStyle:UIAlertControllerStyleAlert];
   
   UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action) {
                                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                                  }];
   
   UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                              handler:^(UIAlertAction * action){
                                                 //Do Some action here
                                                 
                                                 UITextField *textFieldName = alert.textFields[0];
                                                 UITextField *textFieldPassword = alert.textFields[1];
                                                 NSString *userName = [textFieldName.text lowercaseString];
                                                 NSString *userPassword = textFieldPassword.text;
                                                 
                                                 [self finishLogin:userName theUserPassword:userPassword];
                                                 
                                              }];
   [alert addAction:cancel];
   [alert addAction:ok];
   
   [alert addTextFieldWithConfigurationHandler:^(UITextField *textFieldName) {
      textFieldName.placeholder = @"User Name";
      textFieldName.keyboardType = UIKeyboardTypeDefault;
      textFieldName.keyboardAppearance = UIKeyboardAppearanceAlert;
      textFieldName.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      textFieldName.tintColor = [UIColor blackColor];
   }];
   
   [alert addTextFieldWithConfigurationHandler:^(UITextField *textFieldPassWord) {
      textFieldPassWord.placeholder = @"Password";
      textFieldPassWord.keyboardType = UIKeyboardTypeDefault;
      textFieldPassWord.keyboardAppearance = UIKeyboardAppearanceAlert;
      textFieldPassWord.secureTextEntry = YES;
      textFieldPassWord.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
      textFieldPassWord.tintColor = [UIColor blackColor];
   }];
   
   [self presentViewController:alert animated:YES completion:nil];
}








// last step is to save
-(void)finishLogin:(NSString*)theUserName theUserPassword:(NSString *)theUserPassword{
   
   
   [PFUser logInWithUsernameInBackground:theUserName password:theUserPassword
                                   block:^(PFUser *user, NSError *error) {
                                      
                                      if (user)
                                      {
                                         [self performSegueWithIdentifier:@"HomeToMaps" sender:nil];
                                      }
                                      else
                                      {
                                         // The login failed. Check error to see why.
                                         NSString *errorString = [[error userInfo] objectForKey:@"error"];
                                         UIAlertController *errorAlert = [UIAlertController
                                                                          alertControllerWithTitle:@"Error"
                                                                          message:errorString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                                         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                                         [errorAlert addAction:ok];
                                         [self presentViewController:errorAlert animated:YES completion:nil];
                                         
                                      }
                                   }];
}

// insure that email address is of the correct format
- (BOOL)validateEmail:(NSString *)emailStr {
   NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
   NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
   return [emailTest evaluateWithObject:emailStr];
}







@end
