//
//  BuyerInformationViewModel.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 05/07/24.
//

import Foundation

class BuyerInformationViewModel {
    let number: AssignedNumber
    
    init(number: AssignedNumber) {
        self.number = number
    }
    
    func updateNumber(number: AssignedNumber, completion: @escaping (Error?) -> Void) {
        FirestoreHandler.updateNumber(with: number, completion: completion)
    }
}
