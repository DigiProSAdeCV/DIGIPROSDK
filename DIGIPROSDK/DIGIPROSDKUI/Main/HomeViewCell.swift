//
//  HomeViewCell.swift
//  DIGIPROSDK
//
//  Created by Jorge Alfredo Cruz Acuña on 30/01/23.
//  Copyright © 2023 Jonathan Viloria M. All rights reserved.
//

import UIKit

enum HomeViewCellOptions{
    case Look
    case Delete
    case Edit
    case PDF
    
}

protocol HomeViewCellProtocol: AnyObject{
  //  func notifyShow(tag:Int)
    func notifyOptionSelected(option: HomeViewCellOptions, tag: Int)
}

class HomeViewCell: UITableViewCell {

    lazy var titleTemplate: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = Cnstnt.Color.blue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var descriptionTemplate: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var moreDescription: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 7
        view.layer.shadowOpacity = 1
        view.layer.cornerRadius = 8
        view.clipsToBounds = false
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var pdfBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "pdf_ic", in: Cnstnt.Path.framework, with: nil), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.addTarget(self, action: #selector(self.onPDFAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "delete_ic", in: Cnstnt.Path.framework, with: nil), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.addTarget(self, action: #selector(self.onDeleteAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "edit_ic", in: Cnstnt.Path.framework, with: nil), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.addTarget(self, action: #selector(self.onEditAction(_:)), for: .touchUpInside)
        return btn
    }()
    lazy var lookBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "look_ic", in: Cnstnt.Path.framework, with: nil), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        btn.addTarget(self, action: #selector(self.onLookAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var containerStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 10
        stack.addArrangedSubview(pdfBtn)
        stack.addArrangedSubview(lookBtn)
        stack.addArrangedSubview(editBtn)
        stack.addArrangedSubview(deleteBtn)
        return stack
    }()
    
   /* lazy var moreView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var moreText: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = Cnstnt.Color.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var moreImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "expand_more_ic", in: Cnstnt.Path.framework, with: nil)
        return image
    }()
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(self.toogleAction(_:)), for: .touchUpInside)
        return btn
    }()
    
    lazy var listAnexos: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.backgroundColor = .clear
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    var arrayAnexos:[String] = []{
        didSet{
            listAnexos.reloadData()
        }
    }
    var dynamicHeightConstraint: NSLayoutConstraint?*/
    weak var delegate : HomeViewCellProtocol?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        onBuildUI()
        onBuildConstraint()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func onBuildUI(){
        contentView.backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.addSubview(titleTemplate)
        cardView.addSubview(descriptionTemplate)
        cardView.addSubview(moreDescription)
        cardView.addSubview(containerStack)
       /* cardView.addSubview(moreView)
        moreView.addSubview(moreText)
        moreView.addSubview(moreBtn)
        moreView.addSubview(moreImage)
        moreView.addSubview(listAnexos)*/
    }
    private func onBuildConstraint(){
        NSLayoutConstraint.activate([
            
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            titleTemplate.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 10),
            titleTemplate.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            titleTemplate.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            
            descriptionTemplate.topAnchor.constraint(equalTo: titleTemplate.bottomAnchor, constant: 3),
            descriptionTemplate.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            descriptionTemplate.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            
            moreDescription.topAnchor.constraint(equalTo: descriptionTemplate.bottomAnchor, constant: 8),
            moreDescription.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 8),
            moreDescription.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            
            containerStack.topAnchor.constraint(equalTo: descriptionTemplate.bottomAnchor,constant: 40),
            containerStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -8),
            containerStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
         /*   moreView.topAnchor.constraint(equalTo: containerStack.bottomAnchor, constant: 5),
            moreView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            moreView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            moreView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -10),
            
            moreImage.heightAnchor.constraint(equalToConstant: 20),
            moreImage.widthAnchor.constraint(equalToConstant: 20),
            moreImage.centerXAnchor.constraint(equalTo: moreView.centerXAnchor),
            moreImage.topAnchor.constraint(equalTo: moreView.topAnchor, constant: 5),
            
            moreText.topAnchor.constraint(equalTo: moreView.topAnchor, constant: 5),
            moreText.leadingAnchor.constraint(equalTo: moreView.leadingAnchor, constant: 10),
            moreText.trailingAnchor.constraint(equalTo: moreImage.leadingAnchor, constant: -5),
            
            moreBtn.topAnchor.constraint(equalTo: moreView.topAnchor),
            moreBtn.leadingAnchor.constraint(equalTo: moreView.leadingAnchor),
            moreBtn.trailingAnchor.constraint(equalTo: moreView.trailingAnchor),
            moreBtn.heightAnchor.constraint(equalToConstant: 25),
            
            listAnexos.topAnchor.constraint(equalTo: moreImage.bottomAnchor, constant: 5),
            listAnexos.leadingAnchor.constraint(equalTo: moreView.leadingAnchor),
            listAnexos.trailingAnchor.constraint(equalTo: moreView.trailingAnchor),
            listAnexos.bottomAnchor.constraint(equalTo: moreView.bottomAnchor),
            */
            lookBtn.heightAnchor.constraint(equalToConstant: 40),
            lookBtn.widthAnchor.constraint(equalToConstant: 40),
            deleteBtn.heightAnchor.constraint(equalToConstant: 40),
            deleteBtn.widthAnchor.constraint(equalToConstant: 40),
            editBtn.heightAnchor.constraint(equalToConstant: 40),
            editBtn.widthAnchor.constraint(equalToConstant: 40),
        ])
        
      /*  dynamicHeightConstraint = NSLayoutConstraint.init(item: moreView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 25)
        dynamicHeightConstraint!.isActive = true*/
    }
    
  /*  @objc func toogleAction(_ sender: UIButton){
        delegate?.notifyShow(tag: self.tag)
    }*/
    
    @objc func onLookAction(_ sender: UIButton){
        
        delegate?.notifyOptionSelected(option: .Look, tag: self.tag)
    }
    @objc func onEditAction(_ sender: UIButton){
        delegate?.notifyOptionSelected(option: .Edit,  tag: self.tag)
    }
    @objc func onDeleteAction(_ sender: UIButton){
        delegate?.notifyOptionSelected(option: .Delete,  tag: self.tag)
    }
    @objc func onPDFAction(_ sender: UIButton){
        delegate?.notifyOptionSelected(option: .PDF, tag: self.tag)
    }
}
/*
extension HomeViewCell: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayAnexos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let view = tableView.dequeueReusableCell(withIdentifier: "cell"){
            view.textLabel?.text = "Documento: \(arrayAnexos[indexPath.row])"
            view.selectionStyle = .none
            view.contentView.backgroundColor = .clear
            view.backgroundView = nil
            view.textLabel?.textColor = .black
            view.textLabel?.font = UIFont(name: ConfigurationManager.shared.fontApp, size: 12.0)
            return view
        }
        return UITableViewCell()
    }
}
*/
