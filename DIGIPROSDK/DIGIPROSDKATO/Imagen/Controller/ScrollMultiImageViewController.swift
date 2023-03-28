import Foundation
import UIKit

import Eureka

class ScrollMultiImageViewController: UIViewController, UIScrollViewDelegate {
    
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.isPagingEnabled = true
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        return scroll
    }()
    var imagePreview: UIImage!
    var animatedImage: UIImage!
    
    var imageArray = [UIImage]()
    var flagImage: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if flagImage{
            self.animatedImage = UIImage.animatedImage(with: imageArray, duration: 3.0)
            
            let imageName = "yourImage.png"
            _ = UIImage(named: imageName)
            let imageView = UIImageView(image: self.animatedImage!)
            
            self.view.addSubview(imageView)
        }
        
    }
    
    
    func setupImages(_ images: [UIImage]){
        
        for i in 0..<images.count {
            
            let imageView = UIImageView()
            imageView.image = images[i]
            let xPosition = UIScreen.main.bounds.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: scrollView.frame.width, height: scrollView.frame.height)
            imageView.contentMode = .scaleAspectFit
            
            scrollView.contentSize.width = scrollView.frame.width * CGFloat(i + 1)
            scrollView.addSubview(imageView)
            scrollView.delegate = self
            
            
        }
        
        self.view.addSubview(scrollView)
        
    }

    
}
