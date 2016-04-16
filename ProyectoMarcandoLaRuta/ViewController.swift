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
        
        var punto = CLLocationCoordinate2D()
        var puntoInicial = CLLocation()
        let localiza = manager.location!
        print ("Latitud: \(localiza.coordinate.latitude) Longitud \(localiza.coordinate.longitude)")
        
        if (contar == 0){
            punto.latitude = localiza.coordinate.latitude
            punto.longitude = localiza.coordinate.longitude
            let pin = MKPointAnnotation()
            pin.title = "Inicio: Lat: \(localiza.coordinate.latitude) Long: \(localiza.coordinate.longitude)"
            pin.subtitle = "Distancia recorrida: 0 metros"
            pin.coordinate = punto
            mapa.addAnnotation(pin)
            
            let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: punto, span: span)
            mapa.setRegion(region, animated: true)
            
            puntoInicial = localiza
            contar += 1
            
            distanciaIni = puntoInicial.distanceFromLocation(puntoInicial)
            print("Distancia Inicial: \(distanciaIni)")
            
        }else{
            recorrido += medir
            punto.latitude = localiza.coordinate.latitude
            punto.longitude = localiza.coordinate.longitude
            let pin = MKPointAnnotation()
            pin.title = "Lat: \(localiza.coordinate.latitude) Long: \(localiza.coordinate.longitude)"
            
            let distancia = localiza.distanceFromLocation(puntoInicial)
            print("\(distancia)")
            pin.subtitle = "Distancia recorrida: \(recorrido) metros"
            pin.coordinate = punto
            mapa.addAnnotation(pin)
            
            let span : MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
            let region : MKCoordinateRegion = MKCoordinateRegion(center: punto, span: span)
            mapa.setRegion(region, animated: true)
            contar += 1
        }
        
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


