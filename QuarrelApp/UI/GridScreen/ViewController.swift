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
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    func configureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: AssignedNumberCell.identifier, bundle: nil), forCellWithReuseIdentifier: AssignedNumberCell.identifier)
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
            vc.number = number
            vc.indexPath = index
            vc.didUpdateNumber = { [weak self] number in
                Task {
                    await self?.viewModel.changeNumberStatus(at: index,
                                                             to: number.state)
                }
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
        if let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: AssignedNumberCell.identifier, for: indexPath) as? AssignedNumberCell {
            let number = self.viewModel.getNumbers()[indexPath.row]
            cell.configureCell(with: number.state, number: "\(number.buyerInformation.selectedNumber)")
            return cell
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
}

