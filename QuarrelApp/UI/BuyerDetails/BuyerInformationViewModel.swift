//
//  BuyerInformationViewModel.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 05/07/24.
//

import Foundation

class BuyerInformationViewModel {
    let number: AssignedNumber
    let index: IndexPath
    
    init(number: AssignedNumber, index: IndexPath) {
        self.number = number
        self.index = index
    }
    
    func updateNumber(number: AssignedNumber, index: Int, completion: @escaping () -> Void) async {
        await FirestoreHandler.updateNumber(with: index, of: number)
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            completion()
        }
    }
}
