//
//  MapaViewController.swift
//  DIGIPROSDKATO
//
//  Created by Alberto Echeverri Carrillo on 18/02/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

public protocol MapaSearchViewControllerDelegate {
    func didDismiss(location: CLLocationCoordinate2D?)
}

public class MapaSearchViewController: UIViewController {
    
    //Propiedades:
    public var onDismissCallback : ((UIViewController) -> ())?
    
    private var ubicacionesEncontradas: [MKMapItem] = []
    private var userLocation: CLLocationCoordinate2D?
    private var userCustomPin: MKPointAnnotation = MKPointAnnotation()
    private var locationManager: CLLocationManager = CLLocationManager()
    private let cellID: String = "MapaCell"
    private var hasSetInitialLocation: Bool = false
    
    //Outlets:
    private var mapView: MKMapView = {
        let mapView: MKMapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        return mapView
    }()
    
    private var tableView: UITableView = {
        let table: UITableView = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.alpha = 0.0
        return table
    }()
    
    private var searchBar: UISearchBar = {
        let searchBar: UISearchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.showsCancelButton = true
        
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Listo", style: .plain, target: MapaSearchViewController.self, action: #selector(didTapListo(_:)))
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: MapaSearchViewController.self, action: nil)
        bar.items = [space,done]
        bar.sizeToFit()
        searchBar.inputAccessoryView = bar
        
        return searchBar
    }()
    
    private var dismissButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .purple
        button.addTarget(MapaSearchViewController.self, action: #selector(didTapDismiss(_:)), for: .touchUpInside)
        //TODO: Localize
        button.setTitle("✕", for: UIControl.State())
        button.setTitleColor(.white, for: UIControl.State())
        button.backgroundColor = .red
        return button
    }()
    
    private var acceptButton: UIButton = {
        let button: UIButton = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(didTapAccept(_:)), for: .touchUpInside)
        button.setTitle("✓", for: UIControl.State())
        button.setTitleColor(.white, for: UIControl.State())
        return button
    }()
    
    public var delegate: MapaSearchViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.mapView.delegate = self
        
        self.tableView.register(MapCell.self, forCellReuseIdentifier: cellID)
        
        self.searchBar.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        self.view.addSubview(mapView)
        self.view.addSubview(dismissButton)
        self.view.addSubview(acceptButton)
        self.view.addSubview(searchBar)
        self.view.addSubview(tableView)
        
        view.backgroundColor = .white
        
        //Constraints:
        NSLayoutConstraint.activate([
            //Constraints de Barra de busqueda:
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            //Map View:
            mapView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -72),
            //Constraints de Tabla:
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -72),
            
            dismissButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 4),
            dismissButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            dismissButton.widthAnchor.constraint(equalToConstant: 64),
            dismissButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            
            acceptButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 4),
            acceptButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            acceptButton.widthAnchor.constraint(equalToConstant: 64),
            acceptButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
        
        dismissButton.layer.cornerRadius = 32
        acceptButton.layer.cornerRadius = 32
        
        //Funcionalidad de picar al mapa:
        self.userCustomPin = MKPointAnnotation()
        userCustomPin.title = "Tu Ubicacion"
        mapView.addAnnotation(userCustomPin)
        
        let setPinGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(setPinWith(tap:)))
        mapView.addGestureRecognizer(setPinGesture)
       
    }
    
    @objc private func setPinWith(tap: UILongPressGestureRecognizer) {
        let location = tap.location(in: self.mapView)
        userLocation = mapView.convert(location, toCoordinateFrom: self.mapView)
        userCustomPin.coordinate = userLocation!
        userCustomPin.title = "\(userLocation!.latitude),\(userLocation!.longitude)"
        mapView.addAnnotation(userCustomPin)
    }
    
    @objc private func didTapDismiss(_ sender: UIButton) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    @objc private func didTapSearch(_ sender: UIButton) {
        //Conseguir el texto del textField:
        searchBar.resignFirstResponder()
        guard let queryText = self.searchBar.text else { return }
        self.search(query: queryText)
    }
    
    @objc private func didTapListo(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
    }
    
    @objc private func didTapAccept(_ sender: UIButton) {
        delegate?.didDismiss(location: userLocation)
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        onDismissCallback?(self)
    }
    
    private func search(query: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        searchRequest.region = MKCoordinateRegion()
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else { return }
            self.ubicacionesEncontradas = response.mapItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.animateAlpha(hide: false)
            }
        }
    }
}

//MARK: TableView Delegate
extension MapaSearchViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Obtener las coordenadas y regresarlas
        let item: MKMapItem = ubicacionesEncontradas[indexPath.row]
        let coordinate = item.placemark.coordinate
        userLocation = coordinate
        
        let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan())
        userCustomPin.coordinate = coordinate
        userCustomPin.title = "\(coordinate.latitude),\(coordinate.longitude)"
        self.mapView.addAnnotation(userCustomPin)
        
        DispatchQueue.main.async {
            self.mapView.setRegion(region, animated: true)
            self.tableView.animateAlpha(hide: true)
        }
    }
}

//MARK: TableView DataSource
extension MapaSearchViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.ubicacionesEncontradas.count > 0 {
            return ubicacionesEncontradas.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! MapCell
        let item = ubicacionesEncontradas[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

//MARK: UITextField Delegate
extension MapaSearchViewController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.search(query: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.animateAlpha(hide: true)
    }
}

//MARK: MKMapViewDelegate Delegate
extension MapaSearchViewController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }

        return annotationView
    }
}
//MARK: CLLocationManagerDelegate
extension MapaSearchViewController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 && !hasSetInitialLocation {
            if let coordinate = locations.first?.coordinate {
                userLocation = coordinate
                let region: MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan())
                userCustomPin.coordinate = coordinate
                self.mapView.addAnnotation(userCustomPin)
                hasSetInitialLocation = true
                locationManager.stopUpdatingLocation()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.mapView.setRegion(region, animated: true)
                }
            }
        }
    }
}

//Celda para mostrar elementos encontrados en la la busqueda:
private class MapCell: UITableViewCell {
    
    private var nombre: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var direccion: UILabel = {
        let label: UILabel = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nombre)
        contentView.addSubview(direccion)
        
        NSLayoutConstraint.activate([
            nombre.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            nombre.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            nombre.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            
            direccion.topAnchor.constraint(equalTo: nombre.bottomAnchor),
            direccion.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            direccion.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            direccion.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with item: MKMapItem) {
        //Configurar
        nombre.text = item.name
        direccion.text = item.placemark.title
    }
}

extension UITableView {
    /// Animates alpha property to 0 or 1 depending on `hide` value
    /// - Parameters:
    ///   - hide: boolean that determines to hide or to show tableView
    ///   - seconds: TimeInterval indicating speed of animation
    public func animateAlpha(hide: Bool, seconds: TimeInterval = 0.25) {
        if hide { //alpha to 0.0
            UIView.animate(withDuration: seconds, animations: {
                self.alpha = 0.0
            })
        } else { //alpha to 1.0
            UIView.animate(withDuration: seconds, animations: {
                self.alpha = 1.0
            })
        }
    }
}
