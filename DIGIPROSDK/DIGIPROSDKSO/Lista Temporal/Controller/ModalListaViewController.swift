//
//  ModalListaViewController.swift
//  DIGIPROSDKSO
//
//  Created by Desarrollo on 13/08/21.
//  Copyright © 2021 Jonathan Viloria M. All rights reserved.
//

import UIKit

public class ModalListaViewController: UIViewController, UINavigationControllerDelegate {
    lazy var heightTable : CGFloat = 0.0
    // MARK: UI
    lazy var tblItems : UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.translatesAutoresizingMaskIntoConstraints = false
        search.backgroundColor = .blue
        search.placeholder = "Buscar"
        return search
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.color = UIColor.darkGray
        return indicatorView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = UIColor.clear
        return scroll
    }()
    
    // PUBLIC
    public var rowListT: ListaTemporalCell?
    public var rowCombo: ComboDinamicoCell?
    public var rowLista: ListaCell?
    public var onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)?
    public var listItems: [String] = []
    
    var atributosListaT: Atributos_listatemporal?
    var atributosComboD: Atributos_comboDinamico?
    var atributosLista: Atributos_lista?
    var formDelegate: FormularioDelegate?
    var valueItemsSelect : String = ""
    var idsItemsSelect : String = ""
    var buscar: Bool = false
    
    // MARK: Life Cycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(scrollView)
        scrollView.addSubview(tblItems)
        scrollView.addSubview(searchBar)
        scrollView.addSubview(activityIndicatorView)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        heightTable = CGFloat(listItems.count) * 70 + 15
        
        self.searchBar.delegate = self
        self.tblItems.delegate = self
        self.tblItems.dataSource = self
        self.tblItems.register(CellItemsListCombo.self, forCellReuseIdentifier: CellItemsListCombo.ID)
        self.searchBar.isHidden = !self.buscar
        activityIndicatorView.isHidden = true
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CloseSession))
        gesture.delegate = self
        scrollView.addGestureRecognizer(gesture)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 185),
            searchBar.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            searchBar.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            searchBar.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            searchBar.heightAnchor.constraint(equalToConstant: 40),
            
            tblItems.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            tblItems.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            tblItems.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            tblItems.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            tblItems.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            tblItems.heightAnchor.constraint(equalToConstant: heightTable),
            
            activityIndicatorView.heightAnchor.constraint(equalToConstant: 80),
            activityIndicatorView.widthAnchor.constraint(equalToConstant: 80),
            activityIndicatorView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            activityIndicatorView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
        ])
    }
    
    deinit {
        heightTable = 0.0
    }
    
    func configure(onFinishedAction: ((_ result: Result<Bool, Error>) -> Void)? = nil) {
        self.onFinishedAction = onFinishedAction
    }
    
    @objc func CloseSession() {
        
        self.searchBar.resignFirstResponder()
        
        let filtrosCombo = ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros
        if ((filtrosCombo.last)?.Tabla == self.atributosComboD?.campobusqueda ?? "") && ((filtrosCombo.last)?.Valor == self.searchBar.text ?? "") && (self.searchBar.text != "") {
            (filtrosCombo.last)?.Valor = ""
            self.searchBar.text = ""
            ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros = filtrosCombo
        }
        self.dismiss(animated: true) {
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
        }
    }
}

// MARK: UITableViewDelegate & UITableViewDataSource
extension ModalListaViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.listItems.count + 1)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellItemsListCombo.ID, for: indexPath) as! CellItemsListCombo
        cell.containerCell.isHidden = true
        if indexPath.row == 0{
            cell.nameItem.text = "Sin selección"
            if self.idsItemsSelect == "" { cell.containerCell.isHidden = false }
        } else {
            // seleccionaste un valor, vuelves a levantar y el filtro se hace correctamente, y deja una Paloma de que fue seleccionada.
            let item = self.listItems[indexPath.row - 1]
            let val = String(item.split(separator: "|").first ?? "")
            let id = String(item.split(separator: "|").last ?? "")
            cell.nameItem.text = val
            self.idsItemsSelect.split(separator: ",").forEach ({
                if self.atributosListaT != nil {
                    cell.containerCell.isHidden = String($0) == id ? false : true
                } else if let auxAtrib = self.atributosComboD {
                    let auxValor = auxAtrib.tipoasociacion.first == "d" ? val : id
                    cell.containerCell.isHidden = String($0) == auxValor ? false : true
                } else if let auxAtrib = self.atributosLista {
                    let auxValor = auxAtrib.tipoasociacion.first == "d" ? val : id
                    cell.containerCell.isHidden = String($0) == auxValor ? false : true
                }
            })
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 { return 40 }
        let label = UILabel()
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont(name: ConfigurationManager.shared.fontLatoRegular, size: CGFloat(12))
        let item = self.listItems[indexPath.row - 1]
        label.text = String(item.split(separator: "|").first ?? "")
        let ttl = label.calculateMaxLines(tableView.frame.width - 50)
        label.numberOfLines = ttl
        let httl: CGFloat = (CGFloat(ttl) * label.font.lineHeight)
        return (httl + 5) < 40 ? 40 : (httl + 5)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellItemsListCombo.ID, for: indexPath) as! CellItemsListCombo
        if indexPath.row == 0 {
            //inhabilitar back
            let alert = UIAlertController(
                title: "alrt_warning".langlocalized(),
                message: "rules_select".langlocalized(),
                preferredStyle: UIAlertController.Style.alert
            )
            alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            self.tblItems.reloadData()
        } else {
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            cell.containerCell.isHidden = !cell.isSelected
            let item = self.listItems[indexPath.row - 1]
            self.valueItemsSelect = String(item.split(separator: "|").first ?? "")
            self.idsItemsSelect = String(item.split(separator: "|").last ?? "")
            self.onFinishedAction?(.success(true))
            self.CloseSession()
        }
    }
}

// MARK: UISearchBarDelegate
extension ModalListaViewController : UISearchBarDelegate {
    // Searchbar
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        if self.searchBar.text!.count > 0 {
            if self.atributosComboD?.campobusqueda ?? "" != "" {
                let filtrosCombo = rowCombo?.filtrosOK
                if (filtrosCombo?.last)?.Tabla == self.atributosComboD?.campobusqueda ?? "" {
                    (filtrosCombo?.last)?.Valor = self.searchBar.text ?? ""
                    ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros = filtrosCombo ?? Array<FECatRemotoFiltros>()
                    rowCombo?.queryValue()
                    self.listItems = rowCombo?.listItemsCombo ?? []
                    self.tblItems.reloadData()
                    if rowCombo?.msjErrorCat != ""
                    {
                        let alert = UIAlertController(
                            title: "alrt_warning".langlocalized(),
                        message: rowCombo?.msjErrorCat,
                        preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "alrt_accept".langlocalized(), style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        rowCombo?.msjErrorCat = ""
                    }
                }
            }else if self.atributosLista != nil {
                let listItemsfiltrados = self.rowLista?.listItemsLista.filter { (valor: String) -> Bool in
                    let val = String(valor.split(separator: "|").first ?? "")
                    return val.lowercased().contains(searchBar.text!.lowercased())
                }
                self.listItems = listItemsfiltrados ?? (self.rowLista?.listItemsLista ?? [])
                self.tblItems.reloadData()
            }
        }else if self.atributosLista != nil {
            if searchBar.text == "" { self.listItems = self.rowLista?.listItemsLista ?? []; self.tblItems.reloadData() }
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if self.atributosComboD?.campobusqueda ?? "" != "" {
            let filtrosCombo = rowCombo?.filtrosOK
            if (filtrosCombo?.last)?.Tabla == self.atributosComboD?.campobusqueda ?? "" {
                (filtrosCombo?.last)?.Valor = searchText
                ConfigurationManager.shared.catRemotoUIAppDelegate.Filtros = filtrosCombo ?? Array<FECatRemotoFiltros>()
                rowCombo?.queryValue()
                self.listItems = rowCombo?.listItemsCombo ?? []
                self.tblItems.reloadData()
            }
        }
    }
}

// MARK: UIGestureRecognizerDelegate
extension ModalListaViewController : UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let touchLocation = touch.location(in: tblItems)
        guard let _ = tblItems.indexPathForRow(at: touchLocation) else { return true }
        
        return false
    }
}
