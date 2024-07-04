//
//  AssignedNumbersViewModel.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

class AssignedNumbersViewModel {
    weak var onChangedNumberStatusDelegate: OnChangedNumberStatus?
    var numbers: [AssignedNumber] = [] {
        didSet {
            self.onChangedNumberStatusDelegate?.onRetrieveNumbers()
        }
    }
    
    init() {
        Task {
            self.numbers = await FirestoreHandler.getNumbers()
        }
    }
    
    func getNumbers() -> [AssignedNumber] {
        return self.numbers
    }
    
    func getNumber(at index: Int) -> AssignedNumber {
        if self.numbers.count > 0 &&
            self.numbers.indices.contains(index) {
            return self.numbers[index]
        }
        return AssignedNumber(state: .nonSelected, buyerInformation: BuyerInformation(name: "", selectedNumber: 100000, paidQuantity: 0.0))
    }
    
    func changeNumberStatus(at index: IndexPath, to status: CurrentNumberState) async {
        let indx = index.row
        if self.numbers.count > 0 &&
            self.numbers.indices.contains(indx) {
            self.numbers[indx].changeStatus(to: status)
            self.onChangedNumberStatusDelegate?.onChangedNumberStatus(at: index)
            await FirestoreHandler.updateNumber(with: indx, of: self.numbers[indx])
        }
    }
}
