import UIKit
import UserNotifications



public class NewFirstViewController: UIViewController, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet private weak var imageOne: UIImageView!
    @IBOutlet private weak var imageTwo: UIImageView!
    @IBOutlet private weak var imageThree: UIImageView!
    @IBOutlet private weak var imageFour: UIImageView!
    @IBOutlet private weak var imageFive: UIImageView!
    @IBOutlet private weak var imageSix: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var buttonNext: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    var novedades = ["onbfst_tbl_one".langlocalized(), "onbfst_tbl_two".langlocalized(), "onbfst_tbl_three".langlocalized(), "onbfst_tbl_four".langlocalized()]

    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        self.imageOne.hero.id = "circleOne"
        self.imageTwo.hero.id = "circleTwo"
        self.titleLabel.hero.id = "titleLabel"
        self.infoLabel.hero.id = "infoLabel"
        self.buttonNext.hero.id = "buttonNext"
        self.tableView.hero.id = "buttonNext"
        
        self.titleLabel.text = "onbfst_lbl_title".langlocalized()
        self.infoLabel.text = "onbfst_lbl_info".langlocalized()
        self.buttonNext.setTitle("onbfst_btn_next".langlocalized(), for: .normal)
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        view.addGestureRecognizer(leftSwipe)
        
        self.backgroundImage.image = UIImage (named: "novedades", in: Cnstnt.Path.framework, compatibleWith: nil)
        if let auxImage = UIImage (named: "gray_silhouette", in: Cnstnt.Path.framework, compatibleWith: nil)
        {
            self.imageOne.image = auxImage.withRenderingMode(.alwaysTemplate)
            self.imageOne.tintColor = Cnstnt.Color.green
            self.imageTwo.image = auxImage.withRenderingMode(.alwaysTemplate)
            self.imageTwo.tintColor = UIColor.lightGray
            self.imageThree.image =  auxImage.withRenderingMode(.alwaysTemplate)
            self.imageThree.tintColor = UIColor.lightGray
            self.imageFour.image = auxImage.withRenderingMode(.alwaysTemplate)
            self.imageFour.tintColor = UIColor.lightGray
            self.imageFive.image = auxImage.withRenderingMode(.alwaysTemplate)
            self.imageFive.tintColor = UIColor.lightGray
            self.imageSix.image = auxImage.withRenderingMode(.alwaysTemplate)
            self.imageSix.tintColor = UIColor.lightGray
        }
        
        let nib = UINib(nibName: "HKnDOAEbJMkPWAH", bundle: Cnstnt.Path.framework)
        self.tableView.register(nib, forCellReuseIdentifier: "NOVEDADESCELL")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.buttonNext.layer.cornerRadius = 5.0
        
        self.registerForPushNotifications()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // 1. Check if permission granted
            guard granted else { return }
            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        let destination = SecondViewController.init(nibName: "wmBLEwwHGQQwQEg", bundle: Cnstnt.Path.framework)
        destination.modalPresentationStyle = .fullScreen
        self.present(destination, animated: true, completion: nil)
    }
    

    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
        if (sender.direction == .left){
            let destination = SecondViewController.init(nibName: "wmBLEwwHGQQwQEg", bundle: Cnstnt.Path.framework)
            destination.modalPresentationStyle = .fullScreen
            self.present(destination, animated: true, completion: nil)
        }
    }

}

extension NewFirstViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.novedades.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NOVEDADESCELL", for: indexPath) as! NovedadesTableViewCell
        
        cell.infoLabel.text! = self.novedades[indexPath.row]
        cell.iconImage.image = UIImage (named: "check", in: Cnstnt.Path.framework, compatibleWith: nil)
        
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.performSegue(withIdentifier: "showDetail", sender: self)
       
    }
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50//Choose your custom row height
    }
    
    
    
    
}
