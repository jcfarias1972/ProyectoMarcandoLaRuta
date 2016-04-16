//
//  ViewController.swift
//  ProyectoMarcandoLaRuta
//
//  Created by Juan Carlos Farías Arredondo on 14/04/16.
//  Copyright © 2016 Comisión Federal de Electricidad DCS. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapa: MKMapView!
    @IBOutlet weak var swiNormal: UISwitch!
    @IBOutlet weak var swiSatelite: UISwitch!
    @IBOutlet weak var swiHibrido: UISwitch!
    
    private let manejador = CLLocationManager()
    private var contar: Int = 0
    private var distanciaIni:Double = 0.0
    private var recorrido:Double = 0.0
    
    private var posicion : CLLocation!
    private var distancia : Double = 0;
    
    private var medir:Double = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manejador.delegate = self
        manejador.desiredAccuracy = kCLLocationAccuracyBest
        manejador.requestWhenInUseAuthorization()
    }
    
    @IBAction func tipoNormal(sender: UISwitch) {
        if sender.on {
            swiSatelite.setOn(false, animated: true)
            swiHibrido.setOn(false, animated: true)
            mapa.mapType = MKMapType.Standard
        }else{
            swiNormal.setOn(true, animated: true)
        }
    }
    
    @IBAction func tipoSatelite(sender: UISwitch) {
        if sender.on {
            swiNormal.setOn(false, animated: true)
            swiHibrido.setOn(false, animated: true)
            mapa.mapType = MKMapType.Satellite
        }else{
            swiSatelite.setOn(true, animated: true)
        }
    }
    
    @IBAction func tipoHibrido(sender: UISwitch) {
        if sender.on {
            swiSatelite.setOn(false, animated: true)
            swiNormal.setOn(false, animated: true)
            mapa.mapType = MKMapType.Hybrid
        }else{
            swiHibrido.setOn(true, animated: true)
        }
    }
    
    //implmentar funciones del protocolo...
    //1ro. el método que solicita autorización...
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse{
            manejador.startUpdatingLocation()
            manejador.distanceFilter = medir
            mapa.showsUserLocation = true
            mapa.zoomEnabled = true
            print("Autorizado")
        }else{
            manejador.stopUpdatingLocation()
            mapa.showsUserLocation = false
            print("No Autorizado")
        }
    }
    
    //2do. método que recibe las lecturas.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        var punto = CLLocationCoordinate2D()
        //var puntoInicial = CLLocation()
        let localiza = manager.location!
        print ("Latitud: \(localiza.coordinate.latitude) Longitud \(localiza.coordinate.longitude)")
        
        if posicion == nil {
            posicion = userLocation
            distancia = 0
            
            let latitude:CLLocationDegrees = userLocation.coordinate.latitude
            let longitude:CLLocationDegrees = userLocation.coordinate.longitude
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            mapa.setRegion(region, animated: false)
            
            pintaPin()
        } else {
            let distanciaActual = userLocation.distanceFromLocation(posicion)
            if distanciaActual >= 50 {
                distancia += distanciaActual
                posicion = userLocation
                let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
                punto.latitude = posicion.coordinate.latitude
                punto.longitude = posicion.coordinate.longitude
                let region : MKCoordinateRegion = MKCoordinateRegion(center: punto, span: span)
                mapa.setRegion(region, animated: true)
                pintaPin()
            }
        }
        
    }
    
    func pintaPin() {
        let titulo : String = "Lat:\(posicion.coordinate.longitude), Lon:\(posicion.coordinate.latitude)"
        let subtitulo : String = "Distancia: \(String(format: "%.2f",distancia)) mts."
        
        let annotation = MKPointAnnotation()
        annotation.title = titulo
        annotation.subtitle = subtitulo
        annotation.coordinate = posicion.coordinate
        mapa.addAnnotation(annotation)
    }
    
    //3ro. Método que se lanza si ocurre un error...
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alerta = UIAlertController(title: "Error...", message: "Tipo: \(error.code)", preferredStyle: .Alert)
        let accionOK = UIAlertAction(title: " OK ", style: .Default, handler: {
            accion in
            //No hacemos nada....
        })
        alerta.addAction(accionOK)
        self.presentViewController(alerta, animated: true, completion: nil)
    }
    
    @IBAction func cambiaDistancia(sender: UITextField) {
        self.medir = Double(sender.text!)!
        
        manejador.distanceFilter = medir
    }
    
}


