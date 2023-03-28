//
//  HomeLeftMenuViewController.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 02/02/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

class VerticalButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentHorizontalAlignment = .left
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        centerButtonImageAndTitle()
    }

    private func centerButtonImageAndTitle() {
        let titleSize = self.titleLabel?.frame.size ?? .zero
        let imageSize = self.imageView?.frame.size  ?? .zero
        let spacing: CGFloat = 6.0
        self.imageEdgeInsets = UIEdgeInsets(top: -(titleSize.height + spacing),left: 0, bottom: 0, right:  -titleSize.width)
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(imageSize.height + spacing), right: 0)
     }
}

protocol HomeMenuHeaderViewProtocol: AnyObject{
    func onEditMenu()
}

class HomeMenuHeaderView: UIView{
    
    weak var delegate: HomeMenuHeaderViewProtocol?
    lazy var profileBtn: VerticalButton = {
        let btn = VerticalButton()
        btn.setTitle("Editar Perfil", for: .normal)
        let image = UIImage(named: "menuProfile_ic", in: Cnstnt.Path.framework, with: nil)
        btn.setImage(image, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(self.onEditProfileAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .none
        addSubview(profileBtn)
        NSLayoutConstraint.activate([
            profileBtn.heightAnchor.constraint(equalToConstant: 100),
            profileBtn.widthAnchor.constraint(equalToConstant: 80),
            profileBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
            profileBtn.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 30),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func onEditProfileAction(_ sender: UIButton){
        delegate?.onEditMenu()
    }
}

class HomeOptionViewCell: UITableViewCell{
    
    lazy var dotView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.init(hexFromString: "#FFFFFF")
        return view
    }()
    
    lazy var lblTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 3
        label.textAlignment = .left
        label.textColor = UIColor(hexFromString: "#FFFFFF")
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        backgroundColor = .clear
        addSubview(lblTitle)
        addSubview(dotView)
        NSLayoutConstraint.activate([
            dotView.centerYAnchor.constraint(equalTo: centerYAnchor),
            dotView.heightAnchor.constraint(equalToConstant: 16),
            dotView.widthAnchor.constraint(equalToConstant: 16),
            dotView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            lblTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            lblTitle.leadingAnchor.constraint(equalTo: dotView.trailingAnchor, constant: 10),
            lblTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class HomeProfileViewCell: UITableViewCell{
    
    lazy var lblName: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ConfigurationManager.shared.usuarioUIAppDelegate.NombreCompleto
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = UIColor(hexFromString: "#FFFFFF")
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    lazy var lblUser: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ConfigurationManager.shared.usuarioUIAppDelegate.User
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = UIColor(hexFromString: "#FFFFFF")
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        addSubview(lblName)
        addSubview(lblUser)
        NSLayoutConstraint.activate([
            lblName.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            lblName.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            lblName.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            
            lblUser.topAnchor.constraint(equalTo: lblName.bottomAnchor, constant: 5),
            lblUser.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            lblUser.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            lblUser.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

open class HomeLeftMenuViewController: UITableViewController {
    
    public var navController : UINavigationController?
    lazy var buttonClose: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.setTitle("CERRAR SESIÓN", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.layer.cornerRadius = 8
        button.addTarget(self, action:#selector(self.onCloseSession), for: .touchUpInside)
        return button
    }()
    lazy var versionLabel: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = UIColor.init(hexFromString: "#FFFFFF")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.text = "V. \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "").\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")"
        return lbl
    }()
    private var rootViewController: UIViewController?{
        get{
            return UIApplication.shared.windows.first?.rootViewController
        }
    }
    
    public override init(style: UITableView.Style) {
        super.init(style: .grouped)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.addSubview(buttonClose)
        tableView.addSubview(versionLabel)
        view.backgroundColor = .clear
        tableView.register(HomeProfileViewCell.self, forCellReuseIdentifier: "HomeProfileViewCell")
        tableView.register(HomeOptionViewCell.self, forCellReuseIdentifier: "HomeOptionViewCell")
        tableView.separatorColor = UIColor(hexFromString: "#FFFFFF")
        tableView.tableFooterView =  UIView()
        tableView.isScrollEnabled = false
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        NSLayoutConstraint.activate([
            buttonClose.heightAnchor.constraint(equalToConstant: 50),
            buttonClose.widthAnchor.constraint(equalToConstant: 150),
            buttonClose.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            buttonClose.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            versionLabel.topAnchor.constraint(equalTo: buttonClose.bottomAnchor, constant: 10),
            versionLabel.centerXAnchor.constraint(equalTo: buttonClose.centerXAnchor)
            
        ])
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 180
    }
    
    open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = HomeMenuHeaderView()
        view.delegate = self
        return view
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeProfileViewCell", for: indexPath) as? HomeProfileViewCell
            return cell ?? UITableViewCell()
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HomeOptionViewCell", for: indexPath) as? HomeOptionViewCell
            cell?.lblTitle.text = "Log de Errores"
            return cell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row{
        case 0:
            break
        case 1:
            let destination = BugsViewController.init(nibName: "BugsViewController", bundle: Cnstnt.Path.framework)
            destination.auxLogsGeol = true
            self.navigationController?.pushViewController(destination, animated: true)
            break
        default:
            break
        }
    }
    
    @objc func onCloseSession(){
        ConfigurationManager.shared.utilities.restartAllServices()
        self.navController?.popViewController(animated: true)
    }

}

extension HomeLeftMenuViewController: HomeMenuHeaderViewProtocol{
    
    func onEditMenu() {
        let menu = ProfileViewController()
        navigationController?.pushViewController(menu, animated: true)
    }
    
}
