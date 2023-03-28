import Foundation
import UIKit
import MapKit
import CoreLocation


public class FormatoGoogleView: UIView{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtInfo: UITextView!
    
    
}

public class UbicacionFormatoViewController: UIViewController, APIDelegate, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate{
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) { }
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) { }
    public func sendStatusCodeMessage(message: String, error: enumErrorType) { }
    public func didSendError(message: String, error: enumErrorType) { }
    public func didSendResponse(message: String, error: enumErrorType) { }
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) { }
    
    var locationManager:CLLocationManager!
    var locations = [(lat: Double?, lon: Double?)]()
    let cellReuseIdentifier = "cell"
    var annotationPin: MKPointAnnotation?
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var vwEffect: UIVisualEffectView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnExit: UIButton!
    
    public var filteredFormatoData = [FEFormatoData]()
    let sdkAPI = APIManager<UbicacionFormatoViewController>()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sdkAPI.delegate = self
        self.tableview.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        self.titleLabel.text = "ubcvw_lbl_title".langlocalized()
        self.titleLabel.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 14.0)
        self.btnExit.backgroundColor = .clear
        self.btnExit.layer.cornerRadius = 5.0
        self.btnExit.layer.borderWidth = 1.0
        self.btnExit.layer.borderColor = Cnstnt.Color.blue.cgColor
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        //locationManager.delegate = self
        // user activated automatic authorization info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        map.delegate = self
        
        map.showsUserLocation = true
        map.mapType = .mutedStandard
        map.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.setFormatoMarker()
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* if self.locations[0].lat != nil && self.locations[0].lon != nil{
     
        }*/
        
        
    }*/
    
    @IBAction func backAction(_ sender: Any) {
        print("Entra a botón")
        self.dismiss(animated: true)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = MKMapViewDefaultAnnotationViewReuseIdentifier
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
            annotationView!.displayPriority = .required
            
        }
        
        return annotationView
       
    }
    
   
    
    
    public func setFormatoMarker(){
        for formato in filteredFormatoData {
            //let state_marker = GMSMarker()
            let latlon = getJsonFormat(formato)
            if latlon == nil{
                locations.append((lat: nil, lon: nil))
                continue
            }
            self.annotationPin = MKPointAnnotation()
            locations.append((lat: (latlon!.lat as NSString).doubleValue, lon: (latlon!.lon as NSString).doubleValue))
            
            self.annotationPin!.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latlon!.lat)! , longitude: CLLocationDegrees(latlon!.lon)! )
            self.annotationPin?.title = formato.NombreExpediente
            self.annotationPin?.subtitle = formato.CoordenadasFormato
            self.map.addAnnotation(self.annotationPin!)
            
            
        }
        
    }
    
    public func getJsonFormat(_ formato: FEFormatoData) -> (lat: String, lon: String)?{
        do{
            let customJson = self.sdkAPI.DGSDKgetJson(formato)
            if customJson == nil{ return nil }
            
            let dict = try JSONSerializer.toDictionary(customJson!)
            for dato in dict{
                
                let dictValor = dato.value as! NSMutableDictionary
                var coordenadas = dictValor.value(forKey: "coordenadasplantilla") as? String ?? "0,0"
                if coordenadas == "0,0"{
                    coordenadas = dictValor.value(forKey: "valor") as? String ?? "0,0"
                }
                
                if dato.key as! String == "formElec_element0"{
                    let latlon = coordenadas.split{$0 == ","}.map(String.init)
                    let lat = latlon[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    let lon = latlon[1].trimmingCharacters(in: .whitespacesAndNewlines)
                    return (lat, lon)
                }
            }
        }catch{ return nil }
        return nil
    }
    
   
    
    // MARK: - Table View
    public func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return filteredFormatoData.count }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)
        let object = filteredFormatoData[indexPath.row]
        
            cell?.textLabel?.text = "\(object.NombreExpediente.uppercased())"
        cell?.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
        cell?.textLabel?.textColor = UIColor(named: "black", in: Cnstnt.Path.framework, compatibleWith: nil)
        
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Go to Position
        let location = locations[indexPath.row]
        if location.lat != nil || location.lon != nil{
            
            self.annotationPin!.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.lat!) , longitude: CLLocationDegrees(location.lon!) )
            let center = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.lat!) , longitude: CLLocationDegrees(location.lon!))
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
            self.map.setRegion(region, animated: true)
            self.map.selectAnnotation(self.annotationPin!, animated: true)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 45.0; }
}
