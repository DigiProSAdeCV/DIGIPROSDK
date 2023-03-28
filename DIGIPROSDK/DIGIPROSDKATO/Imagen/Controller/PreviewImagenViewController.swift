
import UIKit
import Foundation

internal class PreviewImagenViewController: UIViewController{
    
    private lazy var imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    private lazy var scrollContainer: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 3
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
        scroll.delegate = self
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        scroll.addGestureRecognizer(doubleTapRecognizer)
        return scroll
    }()
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil)
        image?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.addTarget(self, action: #selector(dismissAction(_:)), for: .touchUpInside)
        return button
    }()
    public var dataImage : Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        guard let named = dataImage else{return}
        self.imageView.image = UIImage(data: named)
    }
    
    private func commonInit() {
        // Setup image view
        view.backgroundColor = .black.withAlphaComponent(0.7)
        view.addSubview(scrollContainer)
        view.addSubview(closeButton)
        scrollContainer.addSubview(imageView)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            closeButton.heightAnchor.constraint(equalToConstant: 46),
            closeButton.widthAnchor.constraint(equalToConstant: 46),
            scrollContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: scrollContainer.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollContainer.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: scrollContainer.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: scrollContainer.centerYAnchor)
        ])
    }
    
    @objc private func dismissAction(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if scrollContainer.zoomScale == 1 {
            scrollContainer.setZoomScale(2, animated: true)
        } else {
            scrollContainer.setZoomScale(1, animated: true)
        }
    }
}
extension PreviewImagenViewController: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

open class PreviewImagenViewMain{
    static func create(dataImage: Data?)->UIViewController{
        let viewController : PreviewImagenViewController? = PreviewImagenViewController()
        if let view = viewController{
            view.dataImage = dataImage
            return view
        }
        return UIViewController()
    }
}
