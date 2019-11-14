//
//  localizacion.swift
//  CMMSN
//
//  Created by 2020-1 on 11/6/19.
//  Copyright © 2019 2020-1. All rights reserved.
//

import Foundation
import MapKit
import AddressBook

class Localizacion: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    //var icono: UIImage?
    
    init(title: String, subtitle: String, coordinate:CLLocationCoordinate2D/*,icono: UIImage*/){
        self.title = title
        self.coordinate = coordinate
        self.subtitle = subtitle
        //self.icono = icono
        
    }
    
    
    
    
    func mapItem() -> MKMapItem
    {
        let addressDictionary = [String(kABPersonAddressStreetKey) : subtitle]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDictionary)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(title) \(subtitle)"
        
        return mapItem
    }
}



