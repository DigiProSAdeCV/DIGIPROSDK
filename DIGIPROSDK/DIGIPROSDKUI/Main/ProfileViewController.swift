//
//  MenuViewController.swift
//  DGApp
//
//  Created by Jonathan Viloria M on 1/15/19.
//  Copyright © 2019 Digipro Movil. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

public class ProfileViewController: UIViewController{
    
    lazy var btnProfileImageEdit: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage.init(named: "ic_editMeta", in: Cnstnt.Path.framework, with: nil), for: .normal)
        btn.layer.cornerRadius = 18
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.backgroundColor = UIColor.init(hexFromString: "#00B2F2")
        btn.clipsToBounds = true
        btn.addTarget(self, action: #selector(changeImg(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var btnCancelEdit: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.cancelEditAction(_:)), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.cornerRadius = 18
        btn.clipsToBounds = true
        return btn
    }()
    lazy var lblTitleEdition: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var containerView: UIScrollView = {
        let sv = UIScrollView()
        sv.bounces = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.backgroundColor = .white
        return sv
    }()
    lazy var containerHeader: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var containerBlueHeader: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(hexFromString: "#011520")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var imgUser: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        if ConfigurationManager.shared.usuarioUIAppDelegate.UserThumbnail != ""{
            btn.setImage(ConfigurationManager.shared.usuarioUIAppDelegate.UserThumbnail.stringBase64EncodeToImage(), for: .normal)
        } else {
            btn.setImage(UIImage(named: "user_image", in: Cnstnt.Path.framework, compatibleWith: nil), for: .normal)
        }
        btn.imageView?.contentMode = .scaleAspectFill
        btn.layer.cornerRadius = 60
        btn.clipsToBounds = true
        return btn
    }()
    lazy var btnContinue: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.saveEditAction(_:)), for: .touchUpInside)
        btn.backgroundColor = UIColor.init(hexFromString: "#00B2F2")
        btn.tintColor = .white
        btn.setTitle("Guardar", for: .normal)
        btn.layer.cornerRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    //Profile information
    lazy var lblInformation: UILabel = {
        let lbl = UILabel()
        lbl.text = "Datos personales"
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.init(hexFromString: "#00B2F2")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var containerInformationStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    lazy var lblNameEdit: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblApellidoP: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblApellidoM: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblEmail: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var txtNombre: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtApePat: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtApeMat: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtEmail: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    
    //Profile location
    lazy var lblLocation: UILabel = {
        let lbl = UILabel()
        lbl.text = "Domicilio"
        lbl.font = .systemFont(ofSize: 14, weight: .regular)
        lbl.textColor = UIColor.init(hexFromString: "#00B2F2")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var containerLocationStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    lazy var lblAddress: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblColony: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblDelMun: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblCP: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblState: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblCountry: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var lblDesc: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    lazy var txtAddres: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtColony: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtDelegMun: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtState: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtCountry: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtDescrip: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    lazy var txtCP: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tf.heightAnchor.constraint(equalToConstant: 40)
        ])
        return tf
    }()
    
    var device: Device?
    lazy var imagePicker = UIImagePickerController()
    var path = "\(ConfigurationManager.shared.guid).png"
    var sdkAPI : APIManager<ProfileViewController>?
    
    
    override public func viewDidLoad(){
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hexFromString: "#011520")
        onBuildUI()
        onBuildConstraint()
        sdkAPI = APIManager<ProfileViewController>()
        sdkAPI?.delegate = self
        editUserAction()
    }
    
    private func onBuildUI(){
        view.addSubview(containerView)
        containerView.addSubview(containerHeader)
        containerHeader.addSubview(containerBlueHeader)
        containerHeader.addSubview(lblTitleEdition)
        containerHeader.addSubview(btnCancelEdit)
        containerHeader.addSubview(imgUser)
        containerHeader.addSubview(btnProfileImageEdit)
        containerView.addSubview(lblInformation)
        containerView.addSubview(containerInformationStack)
        containerInformationStack.addArrangedSubview(lblNameEdit)
        containerInformationStack.addArrangedSubview(txtNombre)
        containerInformationStack.addArrangedSubview(lblApellidoP)
        containerInformationStack.addArrangedSubview(txtApePat)
        containerInformationStack.addArrangedSubview(lblApellidoM)
        containerInformationStack.addArrangedSubview(txtApeMat)
        containerInformationStack.addArrangedSubview(lblEmail)
        containerInformationStack.addArrangedSubview(txtEmail)
        containerView.addSubview(lblLocation)
        containerView.addSubview(containerLocationStack)
        containerLocationStack.addArrangedSubview(lblAddress)
        containerLocationStack.addArrangedSubview(txtAddres)
        containerLocationStack.addArrangedSubview(lblColony)
        containerLocationStack.addArrangedSubview(txtColony)
        containerLocationStack.addArrangedSubview(lblDelMun)
        containerLocationStack.addArrangedSubview(txtDelegMun)
        containerLocationStack.addArrangedSubview(lblCP)
        containerLocationStack.addArrangedSubview(txtCP)
        containerLocationStack.addArrangedSubview(lblState)
        containerLocationStack.addArrangedSubview(txtState)
        containerLocationStack.addArrangedSubview(lblCountry)
        containerLocationStack.addArrangedSubview(txtCountry)
        containerLocationStack.addArrangedSubview(lblDesc)
        containerLocationStack.addArrangedSubview(txtDescrip)
        containerView.addSubview(btnContinue)
        
    }
    private func onBuildConstraint(){
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            containerHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerHeader.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            containerHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerHeader.heightAnchor.constraint(equalToConstant: 200),
            
            btnCancelEdit.topAnchor.constraint(equalTo: containerHeader.topAnchor, constant: 20),
            btnCancelEdit.trailingAnchor.constraint(equalTo: containerHeader.trailingAnchor, constant: -20),
            btnCancelEdit.heightAnchor.constraint(equalToConstant: 36),
            btnCancelEdit.widthAnchor.constraint(equalToConstant: 36),
            
            containerBlueHeader.topAnchor.constraint(equalTo: containerHeader.topAnchor),
            containerBlueHeader.leadingAnchor.constraint(equalTo: containerHeader.leadingAnchor),
            containerBlueHeader.trailingAnchor.constraint(equalTo: containerHeader.trailingAnchor),
            containerBlueHeader.heightAnchor.constraint(equalTo: containerHeader.heightAnchor, multiplier: 0.6),
            
            lblTitleEdition.centerXAnchor.constraint(equalTo: containerHeader.centerXAnchor),
            lblTitleEdition.topAnchor.constraint(equalTo: containerHeader.topAnchor, constant: 20),
            lblTitleEdition.leadingAnchor.constraint(equalTo: containerHeader.leadingAnchor, constant: 20),
            lblTitleEdition.trailingAnchor.constraint(equalTo: containerHeader.trailingAnchor, constant: -20),
            
            imgUser.heightAnchor.constraint(equalToConstant: 120),
            imgUser.widthAnchor.constraint(equalToConstant: 120),
            imgUser.centerYAnchor.constraint(equalTo: containerHeader.centerYAnchor, constant: 20),
            imgUser.centerXAnchor.constraint(equalTo: containerHeader.centerXAnchor),
            
            btnProfileImageEdit.heightAnchor.constraint(equalToConstant: 36),
            btnProfileImageEdit.widthAnchor.constraint(equalToConstant: 36),
            btnProfileImageEdit.trailingAnchor.constraint(equalTo: imgUser.trailingAnchor),
            btnProfileImageEdit.bottomAnchor.constraint(equalTo: imgUser.bottomAnchor),
            
            lblInformation.topAnchor.constraint(equalTo: containerHeader.bottomAnchor),
            lblInformation.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            containerInformationStack.topAnchor.constraint(equalTo: lblInformation.bottomAnchor, constant: 10),
            containerInformationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            containerInformationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            lblLocation.topAnchor.constraint(equalTo: containerInformationStack.bottomAnchor, constant: 20),
            lblLocation.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            containerLocationStack.topAnchor.constraint(equalTo: lblLocation.bottomAnchor, constant: 10),
            containerLocationStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            containerLocationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            btnContinue.topAnchor.constraint(equalTo: containerLocationStack.bottomAnchor, constant: 20),
            btnContinue.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 30),
            btnContinue.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -30),
            btnContinue.heightAnchor.constraint(equalToConstant: 40),
            btnContinue.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -60),
        ])
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    override public var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    @objc private func changeImg(_ sender: UIButton) {
        self.presentedViewController?.dismiss(animated: true, completion: nil)
        let alert = UIAlertController(title: "Escoger Imágen", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cámara", style: .default, handler: { _ in
            UILoader.show(parent: self.view)
            DispatchQueue.main.async{
                self.openCameraProfile()
            }
            UILoader.remove(parent: self.view)
        }))
        
        alert.addAction(UIAlertAction(title: "Galería", style: .default, handler: { _ in
            UILoader.show(parent: self.view)
            DispatchQueue.main.async{
                self.openGalleryProfile()
            }
            UILoader.remove(parent: self.view)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancelar", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCameraProfile() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission(); break;
        case .authorized:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
            break;
        case .restricted, .denied: alertCameraAccessNeeded();
        @unknown default: break;
        }
    }
    
    func openGalleryProfile()
    {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - AUTHORIZATION
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            guard accessGranted == true else { return }
        })
    }
    
    func alertCameraAccessNeeded() {
        let settingsAppURL = URL(string: UIApplication.openSettingsURLString)!
        let alert = UIAlertController(
            title: "alrt_warning".langlocalized(),
            message: "alrt_camerause".langlocalized(),
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: "alrt_cancel".langlocalized(), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "alrt_allow".langlocalized(), style: .cancel, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func editUserAction() {
        self.btnCancelEdit.backgroundColor = UIColor.red
        self.btnCancelEdit.setImage(UIImage(named: "close", in: Cnstnt.Path.framework, compatibleWith: nil), for: UIControl.State.normal)
        
        self.lblNameEdit.text = "regs_lbl_name".langlocalized()
        self.lblApellidoP.text = "lstn_lbl_father".langlocalized()
        self.lblApellidoM.text = "lstn_lbl_mother".langlocalized()
        self.lblEmail.text = "infad_lbl_mail".langlocalized()
        self.lblAddress.text = "infad_lbl_address".langlocalized()
        self.lblColony.text = "infad_lbl_col".langlocalized()
        self.lblDelMun.text = "infad_lbl_delMun".langlocalized()
        self.lblCP.text = "infad_lbl_cp".langlocalized()
        self.lblState.text = "infad_lbl_state".langlocalized()
        self.lblCountry.text = "infad_blb_country".langlocalized()
        self.lblDesc.text = "Descripción"
        
        if ConfigurationManager.shared.usuarioUIAppDelegate.Nombre != ""
        { self.txtNombre.text = ConfigurationManager.shared.usuarioUIAppDelegate.Nombre
            self.lblTitleEdition.text = String(format: "usr_lbl_titleEdit".langlocalized(), ConfigurationManager.shared.usuarioUIAppDelegate.Nombre)
        } else {    self.txtNombre.placeholder = "regs_lbl_name".langlocalized() }
        
        if ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoP != ""
        { self.txtApePat.text = ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoP
        } else {    self.txtApePat.placeholder = "lstn_lbl_father".langlocalized() }
        
        if ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoM != ""
        { self.txtApeMat.text = ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoM
        } else {    self.txtApeMat.placeholder = "lstn_lbl_mother".langlocalized()  }
        
        if ConfigurationManager.shared.usuarioUIAppDelegate.Email != ""
        { self.txtEmail.text = ConfigurationManager.shared.usuarioUIAppDelegate.Email
        } else {    self.txtEmail.placeholder = "infad_lbl_mail".langlocalized() }
        if ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress.contains("\\\"") {
            ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress = ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress.replacingOccurrences(of: "\\\"", with: "\"")
        }
        let currentAddress = FEUserAddress(json: ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress)
        
        if currentAddress.CalleNumero != "" {
            self.txtAddres.text = currentAddress.CalleNumero
        } else {
            self.txtAddres.placeholder = "infad_lbl_address".langlocalized()
        }
        if currentAddress.Colonia != "" {
            self.txtColony.text = currentAddress.Colonia
        }
        else { self.txtColony.placeholder = "infad_lbl_col".langlocalized() }
        
        if currentAddress.DelMun != "" {
            self.txtDelegMun.text = currentAddress.DelMun
        } else { self.txtDelegMun.placeholder = "infad_lbl_delMun".langlocalized() }
        
        if currentAddress.CP != ""
        { self.txtCP.text = currentAddress.CP
        } else {    self.txtCP.placeholder = "infad_lbl_cp".langlocalized() }
        
        if currentAddress.Estado != ""
        { self.txtState.text = currentAddress.Estado
        } else { self.txtState.placeholder = "infad_lbl_state".langlocalized()   }
        
        if currentAddress.Pais != ""
        {self.txtCountry.text = currentAddress.Pais
        } else { self.txtCountry.placeholder = "infad_blb_country".langlocalized() }
        
        if currentAddress.Descripcion != ""
        { self.txtDescrip.text = currentAddress.Descripcion
        } else {    self.txtDescrip.placeholder = "Descripción" }
    }
    
    @objc func cancelEditAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func saveEditAction(_ sender: UIButton) {
        if (String(self.txtEmail.text ?? "") == "") || (!UtilsF.regexMatchesEmail(text: self.txtEmail.text!)) {
            let alert = UIAlertController(
                title: "rules_required".langlocalized(),
                message: "alrt_invalid_mail_des".langlocalized(),
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .cancel, handler: { (alert) -> Void in
                self.txtEmail.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let namefull = "\(String(self.txtNombre.text ?? "")) \(String(self.txtApePat.text ?? "")) \(String(self.txtApeMat.text ?? ""))"
            ConfigurationManager.shared.usuarioUIAppDelegate.NombreCompleto = namefull
            ConfigurationManager.shared.usuarioUIAppDelegate.Nombre = String(self.txtNombre.text ?? "")
            ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoP = String(self.txtApePat.text ?? "")
            ConfigurationManager.shared.usuarioUIAppDelegate.ApellidoM = String(self.txtApeMat.text ?? "")
            
            ConfigurationManager.shared.usuarioUIAppDelegate.Email = String(self.txtEmail.text ?? "")
            let currentAddress = FEUserAddress(json: ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress)
            ConfigurationManager.shared.usuarioUIAppDelegate.UserAddress = "{\\\"DomicilioID\\\": \(currentAddress.DomicilioID), \\\"Descripcion\\\": \\\"\(String(self.txtDescrip.text ?? ""))\\\", \\\"CalleNumero\\\": \\\"\(String(self.txtAddres.text ?? ""))\\\", \\\"Colonia\\\": \\\"\(String(self.txtColony.text ?? ""))\\\", \\\"DelMun\\\": \\\"\(String(self.txtDelegMun.text ?? ""))\\\", \\\"Estado\\\": \\\"\(String(self.txtState.text ?? ""))\\\", \\\"CP\\\": \\\"\(String( self.txtCP.text ?? ""))\\\", \\\"Pais\\\": \\\"\(String( self.txtCountry.text ?? ""))\\\"}"
            DispatchQueue.main.async {
                UILoader.show(parent: self.view)
            }
            self.sdkAPI?.updateUserProfile(delegate: self)
                .then({ response in
                    DispatchQueue.main.async {
                        UILoader.remove(parent: self.view)
                        let alert = UIAlertController(
                            title: "Exito",
                            message: "Se ha completado la actualización de tu perfil",
                            preferredStyle: UIAlertController.Style.alert
                        )
                        alert.addAction(UIAlertAction(title: "Salir", style: .cancel, handler: { (alert) in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }).catch({ error in
                    DispatchQueue.main.async {
                        UILoader.remove(parent: self.view)
                        let alert = UIAlertController(
                            title: "Advertencia",
                            message: error.localizedDescription,
                            preferredStyle: UIAlertController.Style.alert
                        )
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .cancel, handler: { _ in }))
                        self.present(alert, animated: true, completion: nil)
                    }
            })
        }
    }
    
    
}

extension ProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.dismiss(animated: true, completion: {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
               
                DispatchQueue.main.async {
                    UILoader.show(parent: self.view)
                }
                self.sdkAPI?.updateImageProfile(delegate: self)
                    .then({ response in
                        DispatchQueue.main.async {
                            let resizeImage = image.resized(withPercentage: 0.3)
                            let dataJpg = resizeImage?.jpegData(compressionQuality: 1)
                            let _ = ConfigurationManager.shared.utilities.saveImageProfile(image, "ImageProfile" , name: self.path)
                            ConfigurationManager.shared.usuarioUIAppDelegate.UserThumbnail = dataJpg?.base64EncodedString() ?? ""
                            UILoader.remove(parent: self.view)
                            if ConfigurationManager.shared.usuarioUIAppDelegate.UserThumbnail != ""{
                                self.imgUser.setImage(ConfigurationManager.shared.usuarioUIAppDelegate.UserThumbnail.stringBase64EncodeToImage(), for: .normal)
                            }
                        }
                    }).catch({ error in
                        DispatchQueue.main.async {
                            UILoader.remove(parent: self.view)
                        }
                    })
            }
        })
        
    }
}

extension ProfileViewController: APIDelegate{
    public func sendStatus(message: String, error: enumErrorType, isLog: Bool, isNotification: Bool) {}
    public func sendStatusCompletition(initial: Float, current: Float, final: Float) {}
    public func sendStatusCodeMessage(message: String, error: enumErrorType) {}
    public func didSendError(message: String, error: enumErrorType) {}
    public func didSendResponse(message: String, error: enumErrorType) {}
    public func didSendResponseHUD(message: String, error: enumErrorType, porcentage: Int) {}
}
