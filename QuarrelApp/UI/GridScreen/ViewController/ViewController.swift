//
//  ViewController.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewActivityIndicator: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    internal var viewModel: AssignedNumbersViewModel = AssignedNumbersViewModel()
    var layoutType: NumbersLayoutType = .grid {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    //    func setViewModel(viewModel: AssignedNumbersViewModel) {
    //        self.viewModel = viewModel
    //    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.startAnimating()
        self.viewModel.onChangedNumberStatusDelegate = self
        self.configureCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    func configureNavigationBar() {
        self.navigationItem.title = "Lista de números"
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.barTintColor = .systemPink
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.configureBarButton()
    }
    
    func configureBarButton() {
        let layoutButton = UIBarButtonItem(image: UIImage(systemName: "circle.grid.2x2.fill"), menu: self.getLayoutMenu())
        layoutButton.tintColor = self.navigationController?.navigationBar.barTintColor
        let sortButton = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: self.getSortMenu())
        sortButton.tintColor = self.navigationController?.navigationBar.barTintColor
        self.navigationItem.rightBarButtonItems = [layoutButton, sortButton]
    }
    
    func getLayoutMenu() -> UIMenu {
        let list = UIAction(title: "Lista", image: UIImage(systemName: "list.bullet"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.layoutType = .list
        }
        
        let grid = UIAction(title: "Cuadrícula", image: UIImage(systemName: "circle.grid.2x2.fill"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.layoutType = .grid
        }
        
        return UIMenu(title: "Ver como",
                      image: nil,
                      identifier: nil,
                      options: .displayInline,
                      preferredElementSize: .automatic,
                      children: [list, grid])
    }
    
    func getSortMenu() -> UIMenu {
        let resetToDefault = UIAction(title: "Sin ordenar", image: nil, identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.viewModel.sortNumbers(by: .nonSelected)
        }
        let byPaid = UIAction(title: "Pagado", image: nil, identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.viewModel.sortNumbers(by: .paid)
        }
        let byPartialPaid = UIAction(title: "Pagado parcial", image: nil, identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.viewModel.sortNumbers(by: .partialPaid)
        }
        
        let byNonPaid = UIAction(title: "Sin pagar", image: nil, identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.viewModel.sortNumbers(by: .nonPaid)
        }
        
        let byFree = UIAction(title: "Disponibles", image: nil, identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.viewModel.sortNumbers(by: .free)
        }
        
        return UIMenu(title: "Ordenar por",
                      image: nil,
                      identifier: nil,
                      options: .displayInline,
                      preferredElementSize: .automatic,
                      children: [byPaid, byPartialPaid, byNonPaid, byFree, resetToDefault])
    }
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: AssignedNumberCell.identifier, bundle: nil), forCellWithReuseIdentifier: AssignedNumberCell.identifier)
        self.collectionView.register(UINib(nibName: ListAssignedNumberCell.identifier, bundle: nil), forCellWithReuseIdentifier: ListAssignedNumberCell.identifier)
        self.collectionView.contentInset = UIEdgeInsets(top: 10.0, left: 5.0, bottom: 1.0, right: 5.0)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 4
        self.collectionView.setCollectionViewLayout(layout, animated: true)
    }
    
    func navigateToBuyerDetailsWithNumber(number: AssignedNumber, with index: IndexPath) {
        if let vc = UIStoryboard(name: BuyerScreenVC.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: BuyerScreenVC.identifier) as? BuyerScreenVC {
            let number = self.viewModel.getNumber(with: number.getDocumentId())
            vc.setViewModel(viewModel: BuyerInformationViewModel(number: number))
            vc.index = index
            vc.didUpdateNumber = { [weak self] number in
                self?.viewModel.modifyNumberWithNewOne(with: number, at: index)
            }
            DispatchQueue.main.async {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

