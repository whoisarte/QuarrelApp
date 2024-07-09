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
        let list = UIAction(title: "Lista", image: UIImage(systemName: "list.bullet"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.layoutType = .list
        }
        
        let grid = UIAction(title: "Cuadrícula", image: UIImage(systemName: "circle.grid.2x2.fill"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
            self.layoutType = .grid
        }
        
        let menu = UIMenu(title: "Ver como",
                          image: nil,
                          identifier: nil,
                          options: .displayInline,
                          preferredElementSize: .automatic,
                          children: [list, grid])
        let button = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), menu: menu)
        button.tintColor = self.navigationController?.navigationBar.barTintColor
        self.navigationItem.rightBarButtonItem = button
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
    
    func navigateToBuyerDetailsWithNumber(number: AssignedNumber, at index: IndexPath) {
        if let vc = UIStoryboard(name: BuyerScreenVC.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: BuyerScreenVC.identifier) as? BuyerScreenVC {
            let number = self.viewModel.getNumber(at: index.row)
            vc.setViewModel(viewModel: BuyerInformationViewModel(number: number, index: index))
            vc.didUpdateNumber = { [weak self] number in
                self?.viewModel.modifyNumberWithNewOne(at: index, with: number)
            }
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.prefersLargeTitles = false
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}

//MARK: Extension to reload sections in collectionView

extension ViewController: OnChangedNumberStatus {
    func onChangedNumberStatus(at index: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [index])
        }
    }
    
    func onRetrieveNumbers() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.animate(withDuration: 0.3) {
                    self.viewActivityIndicator.alpha = 0.0
                } completion: { _ in
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

//MARK: Context Menu Configuration
extension ViewController {
    func configureContextMenu(index: IndexPath, number: AssignedNumber) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let edit = UIAction(title: "Editar información", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.navigateToBuyerDetailsWithNumber(number: number, at: index)
            }
            
            let paidStateAction = UIAction(title: "Pagado", image: UIImage(systemName: "oval.fill"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: .paid)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            let partialPaidStateAction = UIAction(title: "Pagado parcialmente", image: UIImage(systemName: "oval.lefthalf.filled"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: .partialPaid)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            let nonPaidStateAction = UIAction(title: "Sin pagar", image: UIImage(systemName: "oval"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: .nonPaid)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            
            let menu = UIMenu(title: "Cambiar status", image: nil, identifier: nil, options: .displayInline, children: [paidStateAction, partialPaidStateAction, nonPaidStateAction])
            let childrenMenu = number.state != .nonSelected ? [edit,menu] : [edit]
            return UIMenu(image: nil, identifier: nil, options: .displayInline, children: childrenMenu)
        }
        return context
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumbers().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch self.layoutType {
            
        case .grid:
            if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: AssignedNumberCell.identifier, for: indexPath) as? AssignedNumberCell {
                let number = self.viewModel.getNumbers()[indexPath.row]
                cell.configureCell(with: number.state, number: "\(number.buyerInformation.selectedNumber)")
                return cell
            }
        case .list:
            if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: ListAssignedNumberCell.identifier, for: indexPath) as? ListAssignedNumberCell {
                let number = self.viewModel.getNumbers()[indexPath.row]
                cell.configureListCell(with: "\(number.buyerInformation.selectedNumber)", buyer: number.buyerInformation.name, currentNumberState: number.state)
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigateToBuyerDetailsWithNumber(number: self.viewModel.getNumber(at: indexPath.row), at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.configureContextMenu(index: indexPath, number: self.viewModel.getNumber(at: indexPath.row))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 8.0, bottom: 1.0, right: 8.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch self.layoutType {
        case .grid:
            return CGSize(width: 45.0, height: 45.0)
        case .list:
            return CGSize(width: self.collectionView.frame.size.width, height: 55.0)
        }
    }
}

