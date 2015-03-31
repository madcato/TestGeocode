//
//  ViewController.m
//  TestGeocode
//
//  Created by Daniel Vela on 30/03/15.
//  Copyright (c) 2015 Daniel Vela. All rights reserved.
//

#import "ViewController.h"
@import MapKit;
@import CoreLocation;
@import AddressBookUI;

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UITextField *input;
@property (strong, nonatomic) IBOutlet UITableView *contentView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSString* currentSearch;
@property (assign, nonatomic) BOOL searching;
@property (strong, nonatomic) CLGeocoder* geocoder;

@property (strong, nonatomic) NSArray* places;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.searching = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    NSString* searchTerm = [[textField text] stringByReplacingCharactersInRange:range withString:string];
    [self searchFor:searchTerm];
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell* cell = [self.contentView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    CLPlacemark* placemark = self.places[indexPath.row];
    cell.textLabel.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO);

    
    return cell;
}

#pragma mark - Search methods

-(void)searchFor:(NSString*)searchTerm {
    if (searchTerm.length < 3) return; // No buscamos textos menores de 4 letras
    
    if (self.searching) return; // Si ya hay una búsqueda activa, no iniciamos otra
    
    if ([self.currentSearch isEqualToString:searchTerm]) return; // Si el termino de búsqueda es igual que el último buscado, no volvemos a pedir datos.
    
    [self startNewSearchFor:searchTerm];
}

-(void)startNewSearchFor:(NSString*)searchTerm {
    self.currentSearch = searchTerm;
    self.searching = YES;
    self.geocoder = [[CLGeocoder alloc] init];
    
    [self.geocoder geocodeAddressString:searchTerm completionHandler:^(NSArray* placemarks,NSError* error){
        self.searching = NO;
        if (error) {
            NSLog(@"Error en gecoding: %@, buscando: %@", [error localizedDescription], searchTerm);
            self.currentSearch = nil;
            return;
        }
        self.places = placemarks;
        [self.contentView reloadData];
    }];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CLPlacemark* placemark = self.places[indexPath.row];
    CLLocationCoordinate2D coord = placemark.location.coordinate;
    MKCoordinateSpan span = {.latitudeDelta =  0.005, .longitudeDelta =  0.005};
    MKCoordinateRegion region = {coord, span};
    [self.mapView setRegion:region];
    
    // Simple annotation
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:coord];
    [self.mapView addAnnotation:annotation];
    
    [self.input resignFirstResponder];

}
@end
