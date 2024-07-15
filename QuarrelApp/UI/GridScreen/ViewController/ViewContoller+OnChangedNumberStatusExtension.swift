//
//  ViewContoller+OnChangedNumberStatusExtension.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 15/07/24.
//

import Foundation
import UIKit

//MARK: Extension to reload sections in collectionView
extension ViewController: OnChangedNumberStatus {
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
    
    func onChangedNumberStatus(at index: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.performBatchUpdates {
                self.collectionView.reloadItems(at: [index])
            }
        }
    }
}
