import AVFoundation
import UIKit

import Eureka

class FiltrosModificarViewController: UIViewController, UINavigationControllerDelegate, CropViewControllerDelegate {

    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var lblTitleView: UILabel!
    @IBOutlet weak var imgAnexo: UIImageView!
    @IBOutlet weak var bntOpcUno: UIButton!
    @IBOutlet weak var lblOpcUno: UILabel!
    @IBOutlet weak var bntOpcDos: UIButton!
    @IBOutlet weak var lblOpcDos: UILabel!
    @IBOutlet weak var bntOpcTres: UIButton!
    @IBOutlet weak var lblOpcTres: UILabel!
    @IBOutlet weak var bntOpcSave: UIButton!
    @IBOutlet weak var lblOpcSave: UILabel!
    
    public var row: RowOf<String>!
    public var onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)?
    
    private var croppedRect = CGRect.zero
    private var croppedAngle = 0
    
    var atributos: Atributos_imagen?
    var preview: UIImage? = nil
    var tipo: String = ""
    var formDelegate: FormularioDelegate?
    var imgOriginal : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnClose.backgroundColor = UIColor.red
        self.btnClose.layer.cornerRadius = self.btnClose.frame.height / 2
        self.btnClose.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        
        self.lblTitleView.font = UIFont(name: ConfigurationManager.shared.fontLatoBlod, size: CGFloat(ConfigurationManager.shared.fontSizeHeight))
        self.lblTitleView.text = tipo == "Modificar" ? "Edición de imagen: " : "Filtros de imagen: "
        
        self.imgAnexo.image = preview
        
        let nameImage1 = tipo == "Modificar" ? "ic_recortar" : "ic_imgNormal"
        self.bntOpcUno = self.formDelegate?.configButton(tipo:  "circulofondo", btnStyle: self.bntOpcUno, nameIcono: nameImage1, titulo: "", colorFondo: self.atributos?.colortomarfoto ?? "#1E88E5", colorTxt: self.atributos?.colortextotomarfoto ?? "#FFFFFF")
        
        self.lblOpcUno.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.lblOpcUno.text = tipo == "Modificar" ? "Recortar" : "Normal"
        
        let nameImage2 = tipo == "Modificar" ? "ic_giraIzq" : "ic_imgBN"
        self.bntOpcDos = self.formDelegate?.configButton(tipo:  "circulofondo", btnStyle: self.bntOpcDos, nameIcono: nameImage2, titulo: "", colorFondo: self.atributos?.colortomarfoto ?? "#1E88E5", colorTxt: self.atributos?.colortextotomarfoto ?? "#FFFFFF")
        
        self.lblOpcDos.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.lblOpcDos.text = tipo == "Modificar" ? "  Girar a la izquierda" : "B & N"
        
        let nameImage3 = tipo == "Modificar" ? "ic_giraDer" : "ic_escGrises"
        self.bntOpcTres = self.formDelegate?.configButton(tipo:  "circulofondo", btnStyle: self.bntOpcTres, nameIcono: nameImage3, titulo: "", colorFondo: self.atributos?.colortomarfoto ?? "#1E88E5", colorTxt: self.atributos?.colortextotomarfoto ?? "#FFFFFF")
        
        self.lblOpcTres.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.lblOpcTres.text = tipo == "Modificar" ? "Girar a la derecha" : "Escala de grises"
        
        self.bntOpcSave = self.formDelegate?.configButton(tipo:  "circulofondo", btnStyle: self.bntOpcSave, nameIcono: "ic_save", titulo: "", colorFondo: "#6DB657", colorTxt: "#FFFFFF")
        
        self.lblOpcSave.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(ConfigurationManager.shared.fontSizeNormal))
        self.lblOpcSave.text = "Guardar"
        
    }
    
    @IBAction func btnOpcUnoAction(_ sender: Any) {
        if tipo == "Modificar" {
            let cropController = CropViewController(croppingStyle: CropViewCroppingStyle.default, image: self.imgAnexo.image!)
            cropController.delegate = self
            cropController.rotateButtonsHidden = true
            cropController.aspectRatioPickerButtonHidden = true
            //self.present(cropController, animated: true, completion: nil)
            let viewFrame = view.convert(imgAnexo.frame, to: navigationController?.view)
            cropController.presentAnimatedFrom(self,
                                                    fromImage: self.imgAnexo.image,
                                                    fromView: nil,
                                                    fromFrame: viewFrame,
                                                    angle: self.croppedAngle,
                                                    toImageFrame: self.croppedRect,
                                                    setup: { self.imgAnexo.isHidden = true },
                                                    completion: { self.imgAnexo.isHidden = false })
        } else if tipo == "Filtros" {
            if let auxOrg = self.imgOriginal {
                self.imgAnexo.image = auxOrg
            } else {
                self.imgAnexo.image = preview
            }
        }
    }
    
    @IBAction func btnOpcDosAction(_ sender: Any) {
        if tipo == "Modificar" {
            self.imgAnexo.contentMode = .scaleAspectFit
            self.imgAnexo.image = self.imgAnexo.image?.rotated(by: 270.0)
        } else if tipo == "Filtros" {
            if let imgBN = self.imgAnexo.image?.tonal {
                self.imgAnexo.image = imgBN
            }
        }
    }
    
    @IBAction func btnOpcTresAction(_ sender: Any) {
        if tipo == "Modificar" {
            self.imgAnexo.contentMode = .scaleAspectFit
            self.imgAnexo.image = self.imgAnexo.image?.rotated(by: 90.0)
        } else if tipo == "Filtros" {
            if let imgGrises = self.imgAnexo.image?.noir {
                self.imgAnexo.image = imgGrises
            }
        }
    }
    
    @IBAction func btnOpcSaveAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.onFinishedAction?(.success(true))
    }
    
    @IBAction func btnCloseAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configure(onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)? = nil) {
        self.onFinishedAction = onFinishedAction
    }
    
    public func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.croppedRect = cropRect
        self.croppedAngle = angle
        self.imgAnexo.image = image
        cropViewController.dismiss(animated: false, completion: nil)
        self.dismiss(animated: true, completion: {self.onFinishedAction?(.success(true))})
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    var tonal: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectTonal") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
    
    func rotated(by degrees: CGFloat) -> UIImage {
        let radians : CGFloat = degrees * CGFloat(.pi / 180.0)
        let rotatedViewBox = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t = CGAffineTransform(rotationAngle: radians)
        rotatedViewBox.transform = t
        let rotatedSize = rotatedViewBox.frame.size
        let roundedSize = CGSize(width: Int(rotatedSize.width), height: Int(rotatedSize.height))
        UIGraphicsBeginImageContextWithOptions(roundedSize, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        guard let bitmap = UIGraphicsGetCurrentContext(), let cgImage = self.cgImage else {
          return self
        }
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        bitmap.rotate(by: radians)
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
          return self
        }
        return newImage
      }
}

