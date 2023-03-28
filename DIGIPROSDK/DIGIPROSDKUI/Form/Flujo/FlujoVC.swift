//
//  FlujoVC.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 25/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

open class FlujoMain{
    
    public static func create(flowsList: [FEPlantillaMerge]?, delegate: FlujoVCDelegate?)->UIViewController{
        let viewVC : FlujoVC? = FlujoVC()
        if let view = viewVC{
            view.flowsList = flowsList
            view.delegate = delegate
            return view
        }
        return UIViewController()
    }
}

public protocol FlujoVCDelegate:AnyObject{
    func onFlowSelected(flowSelected: FEPlantillaMerge?)
}

class FlujoVC: UIViewController {
    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var flowsTable: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    lazy var btnClose: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(self.onDissmisView), for: .touchUpInside)
        let image = UIImage(named: "baseline_clear_black_48pt", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor.init(hexFromString: "#ffffff")
        btn.imageView?.contentMode = .scaleAspectFit
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return btn
    }()
    lazy var btnUpdate: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
       // btn.addTarget(self, action: #selector(self.onDissmisView), for: .touchUpInside)
        let image = UIImage(named: "icon-downloaddata", in: Cnstnt.Path.framework, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        btn.setImage(image, for: .normal)
        btn.tintColor = UIColor.init(hexFromString: "#ffffff")
        btn.imageView?.contentMode = .scaleAspectFit
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return btn
    }()
    weak var delegate: FlujoVCDelegate?
    public var flowsList: [FEPlantillaMerge]? = [FEPlantillaMerge]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraint()
        flowsTable.reloadData()
    }
    
    private func setupUI(){
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.addSubview(containerView)
        view.addSubview(btnClose)
        view.addSubview(btnUpdate)
        containerView.addSubview(flowsTable)
    }
    
    private func setupConstraint(){
        NSLayoutConstraint.activate([
            
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.7),
            
            flowsTable.topAnchor.constraint(equalTo: containerView.topAnchor),
            flowsTable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            flowsTable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            flowsTable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            btnClose.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -10),
            btnClose.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            btnClose.heightAnchor.constraint(equalToConstant: 46),
            btnClose.widthAnchor.constraint(equalToConstant: 46),
            
            btnUpdate.bottomAnchor.constraint(equalTo: containerView.topAnchor, constant: -10),
            btnUpdate.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            btnUpdate.heightAnchor.constraint(equalToConstant: 46),
            btnUpdate.widthAnchor.constraint(equalToConstant: 46),
        ])
    }
    
    @objc private func onDissmisView(_ sender: UIButton){
        self.dismiss(animated: true)
    }
}

extension FlujoVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flowsList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell"){
            let obj = flowsList?[indexPath.row]
            cell.selectionStyle = .none
            cell.textLabel?.text = "\(obj?.NombreFlujo ?? "")"
            cell.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
            cell.textLabel?.textColor = UIColor(named: "black", in: Cnstnt.Path.framework, compatibleWith: nil)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.delegate?.onFlowSelected(flowSelected: self.flowsList?[indexPath.row])
        }
       
    }
    
}
