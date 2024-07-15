//
//  ViewController+UIContextMenuConfigurationExtension.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 15/07/24.
//

import Foundation
import UIKit

//MARK: Context Menu Configuration
extension ViewController {
    func configureContextMenu(index: IndexPath, number: AssignedNumber) -> UIContextMenuConfiguration{
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            let edit = UIAction(title: "Editar información", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                self.navigateToBuyerDetailsWithNumber(number: number, with: index)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return self.configureContextMenu(index: indexPath, number: self.viewModel.getSelectedNumber(at: indexPath))
    }
}
