//
//  ComboElementsViewController.swift
//  DIGIPROSDK
//
//  Created by Jose Eduardo Rodriguez on 31/01/23.
//

import UIKit

protocol ComboElementsViewControllerDelegate : AnyObject {
    func didTapElementAtIndexPath(_ row: Int)
}

class ComboElementsViewController: UIViewController {
    
    private var elements: [(id: String, type: String, kind: Any?, element: Elemento?)] = []
    weak var delegate: ComboElementsViewControllerDelegate?
    
    lazy var wordsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    init(elements: [(id: String, type: String, kind: Any?, element: Elemento?)], delegate: ComboElementsViewControllerDelegate?) {
        self.elements = elements
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(wordsTableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            if let presentationController = presentationController as? UISheetPresentationController {
                if #available(iOS 16.0, *) {
                    presentationController.detents = [
                        .custom(resolver: { _ in
                            return 250
                        }),
                    ]
                } else {
                    presentationController.detents = [
                        .medium(),
                    ]
                }
                presentationController.prefersGrabberVisible = true
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            wordsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            wordsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            wordsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            wordsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension ComboElementsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = elements[indexPath.row].element?.atributos as? Atributos_Generales
        cell.textLabel?.text = model?.titulo
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didTapElementAtIndexPath(indexPath.row)
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65.0
    }
}
