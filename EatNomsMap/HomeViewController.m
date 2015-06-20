//
//  HomeViewController.m
//  EatNomsMap
//
//  Created by Donald Bertamini on 2015-06-20.
//  Copyright (c) 2015 Cloudy Coast Software. All rights reserved.
//

#import "HomeViewController.h"
#import <Parse/Parse.h>

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
//   NSString *theUserName = @"donbertamini@shaw.ca";
//   NSString *theUserPassword =  @"green32";
//   
//   NSLog(@"ready for a first user");
//   PFUser *user = [PFUser user];
//   user.username = theUserName;
//   user.password = theUserPassword;
//   
//   
//   [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//    
//      if (!error) {
//         [self finishLogin:theUserName theUserPassword:theUserPassword];
//      }
//      else
//      {
//         NSString *errorString = [[error userInfo] objectForKey:@"error"];
//         UIAlertController *errorAlert = [UIAlertController
//                                          alertControllerWithTitle:@"Error"
//                                          message:errorString
//                                          preferredStyle:UIAlertControllerStyleAlert];
//         UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
//         [errorAlert addAction:ok];
//         [self presentViewController:errorAlert animated:YES completion:nil];
//      }
//   }];

   
//   PFObject *testObject = [PFObject objectWithClassName:@"TestObject"];
 //  testObject[@"foo"] = @"bar";
 //  [testObject saveInBackground];
}

// last step is to save
-(void)finishLogin:(NSString*)theUserName theUserPassword:(NSString *)theUserPassword{
   

   [PFUser logInWithUsernameInBackground:theUserName password:theUserPassword
                                   block:^(PFUser *user, NSError *error) {
                                    
                                      if (user)
                                      {
                                         
                                        
                                         NSLog(@"logged in ok");
                                         //[self performSegueWithIdentifier:@"HomeToLoc" sender:nil];
                                         
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
