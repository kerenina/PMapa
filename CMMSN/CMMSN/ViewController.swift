//
//  ViewController.swift
//  CMMSN
//
//  Created by 2020-1 on 11/6/19.
//  Copyright © 2019 2020-1. All rights reserved.
//

import UIKit
import MapKit
import AddressBook

struct pines: Codable{
    let latitud: Float
    let longitud: Float
    let titulo: String
    let subtitulo: String
    //let icono: UIImage
}

let path = Bundle.main.path(forResource: "puntos", ofType: "json")
let jsonData = NSData(contentsOfFile: path!)
let rutas = try! JSONDecoder().decode([pines].self, from: jsonData! as Data)


class ViewController: UIViewController,MKMapViewDelegate {
    
    
    @IBOutlet weak var mapita: MKMapView!
    @IBOutlet weak var selector: UISegmentedControl!
    @IBOutlet weak var selector2: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapita.delegate = self
        
    
        let locainicial = CLLocation(latitude: 19.326704, longitude: -99.181526)
        zoom(location: locainicial)
        
       
        for pin in rutas{
            let uno = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitud) , longitude: CLLocationDegrees(pin.longitud))
            let dos = Localizacion(title: pin.titulo, subtitle: pin.subtitulo, coordinate: uno )
            mapita.addAnnotation(dos)
        }//pinrutas
         }//viewdidload
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        locationManager.requestWhenInUseAuthorization()

        //connfigurar precision
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        //FILTRO saber cada cuanto las actualizaciones de mov
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapita.delegate = self
        
       mapita.showsUserLocation = true
      checkLocationServiceAuthenticationStatus()

    }
    
    
    // locacion actual
    
    var locationManager = CLLocationManager()
    
    func checkLocationServiceAuthenticationStatus()
    {
        locationManager.delegate = self as? CLLocationManagerDelegate
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapita.showsUserLocation = true
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    // direccion
    
    var currentPlacemark: CLPlacemark?
    
    
    
    @IBAction func showDirection(sender: Any)
    {
        guard let currentPlacemark = currentPlacemark else {
            return
        }
        
        let directionRequest = MKDirections.Request()
        let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
        
        directionRequest.source = MKMapItem.forCurrentLocation()
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .walking
        
        // calculate the directions / route
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (directionsResponse, error) in
            guard let directionsResponse = directionsResponse else {
                if let error = error {
                    print("error en la direccion")
                }
                return
            }
            
            let route = directionsResponse.routes[0]
            self.mapita.removeOverlays(self.mapita.overlays)
            self.mapita.addOverlay(route.polyline, level: .aboveRoads)
            let routeRect = route.polyline.boundingMapRect
            self.mapita.setRegion(MKCoordinateRegion(routeRect), animated: true)
        }
    }
    
    //cambiar ruta
    @IBAction func Back(_ sender: Any) {
        self.mapita.removeOverlays(self.mapita.overlays)
        let locainicial = CLLocation(latitude: 19.326704, longitude: -99.181526)
        zoom(location: locainicial)
    }
    
    
    @IBAction func cambiarVista(_ sender: Any) {
        
        switch selector.selectedSegmentIndex {
        case 0:
            mapita.mapType = .standard
            
        case 1:
            mapita.mapType = .satellite
            
        case 2:
            mapita.mapType = .hybrid
        default:
            break
        }
    } // func cambiar vista
    
    
    

    

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let linea = MKPolylineRenderer(overlay: overlay)
        linea.strokeColor = .orange
        linea.lineWidth = 4.0
        return linea
        
    }
        
    let region: CLLocationDistance = 1500
    func zoom(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion (center: location.coordinate,latitudinalMeters: region * 2.0, longitudinalMeters: region * 2.0)
        mapita.setRegion(coordinateRegion, animated: true)
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations.last!
        self.mapita.showsUserLocation = true
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if let annotation = annotation as? Localizacion {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }
            
            return view
        }
        
        return nil
    }
    

    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
        if let location = view.annotation as? Localizacion {
            self.currentPlacemark = MKPlacemark(coordinate: location.coordinate)
        }
    }
    
  
    
    
    
    
}//clase

