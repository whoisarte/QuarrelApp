//
//  ViewController.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    internal var viewModel: AssignedNumbersViewModel = AssignedNumbersViewModel()
//    func setViewModel(viewModel: AssignedNumbersViewModel) {
//        self.viewModel = viewModel
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        }
    }
}

//MARK: Context Menu Configuration
extension ViewController {
    func configureContextMenu(index: IndexPath) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let edit = UIAction(title: "Editar información", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                print("Editar información tapped")
            }
            let paidStateAction = UIAction(title: "Pagado", image: UIImage(systemName: "oval.fill"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                let modifiedNumber = self.viewModel.getNumber(at: index.row)
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: AssignedNumber(state: .paid,
                                                                               buyerInformation: modifiedNumber.buyerInformation))
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            let partialPaidStateAction = UIAction(title: "Pagado parcialmente", image: UIImage(systemName: "oval.lefthalf.filled"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                let modifiedNumber = self.viewModel.getNumber(at: index.row)
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: AssignedNumber(state: .partialPaid,
                                                                               buyerInformation: modifiedNumber.buyerInformation))
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            let nonPaidStateAction = UIAction(title: "Sin pagar", image: UIImage(systemName: "oval"), identifier: nil, discoverabilityTitle: nil,attributes: .keepsMenuPresented, state: .off) { (_) in
                let modifiedNumber = self.viewModel.getNumber(at: index.row)
                Task {
                    await self.viewModel.changeNumberStatus(at: index,
                                                            to: AssignedNumber(state: .nonPaid,
                                                                               buyerInformation: modifiedNumber.buyerInformation))
                }
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.collectionView.contextMenuInteraction?.dismissMenu()
                }
            }
            
            let menu = UIMenu(title: "Cambiar status", image: nil, identifier: nil, options: .displayInline, children: [paidStateAction, partialPaidStateAction, nonPaidStateAction])
            return UIMenu(image: nil, identifier: nil, options: .displayInline, children: [edit,menu])
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
        if let vc = UIStoryboard(name: BuyerScreenVC.storyboard, bundle: nil)
            .instantiateViewController(withIdentifier: BuyerScreenVC.identifier) as? BuyerScreenVC {
            let number = self.viewModel.getNumber(at: indexPath.row)
            vc.number = number
            vc.indexPath = indexPath
            vc.didUpdateNumber = { [weak self] number in
                Task {
                    await self?.viewModel.changeNumberStatus(at: indexPath,
                                                            to: AssignedNumber(state: .paid,
                                                                               buyerInformation: number.buyerInformation))
                }
            }
            DispatchQueue.main.async {
                self.navigationController?.navigationBar.prefersLargeTitles = false
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        print("Go to user detail")
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.configureContextMenu(index: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1.0, left: 8.0, bottom: 1.0, right: 8.0)
    }
}

