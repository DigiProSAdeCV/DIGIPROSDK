import Foundation
import UIKit

class EstaticosCell: UITableViewCell{

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    
}

public class EstaticosViewController: UIViewController{
    
    @IBOutlet weak var tblView: UITableView!
    public var estaticos: [(title: String, value: String)] = [(title: String, value: String)]()
    public var device: Device?
    public var controller: NuevaPlantillaViewController?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tblView.register(UINib(nibName: "BHXwStFfHaeZsbR", bundle: Cnstnt.Path.framework), forCellReuseIdentifier: "Cell")
        device = Device()
    }
    
    @objc public func refresh(){
        estaticos = (self.controller?.getStaticElements())!
        self.tblView.reloadData()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

// MARK: - TABLEVIEW
extension EstaticosViewController: UITableViewDelegate, UITableViewDataSource{
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estaticos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EstaticosCell
        let obj = estaticos[indexPath.row]
        cell.lblTitle.text = obj.title
        cell.lblValue.text = obj.value
        
        cell.selectionStyle = .none
        let additionalSeparatorThickness = CGFloat(1)
        
        let additionalSeparator = UIView(frame: CGRect(x: 0,
                                                       y: cell.frame.size.height - additionalSeparatorThickness, width: cell.frame.size.width, height: additionalSeparatorThickness))
        additionalSeparator.backgroundColor = UIColor.black
        cell.addSubview(additionalSeparator)
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 50
    }
}
