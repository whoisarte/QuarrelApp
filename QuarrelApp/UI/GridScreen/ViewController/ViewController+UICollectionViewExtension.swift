//
//  ViewController+UICollectionViewExtension.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 15/07/24.
//

import Foundation
import UIKit

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
        self.navigateToBuyerDetailsWithNumber(number: self.viewModel.getSelectedNumber(at: indexPath), with: indexPath)
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
