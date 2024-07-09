//
//  AssignedNumbersViewModel.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import Foundation

class AssignedNumbersViewModel {
    private let dataNumberLocalRetrieveKey: String = "AssignedNumbersViewModel_dataNumberLocalRetrieveKey"
    weak var onChangedNumberStatusDelegate: OnChangedNumberStatus?
    var numbers: [AssignedNumber] = [] {
        didSet {
            do {
                let dataNumbers = try JSONEncoder().encode(numbers)
                UserDefaults.standard.setValue(dataNumbers, forKey: self.dataNumberLocalRetrieveKey)
                print("New products saved locally...")
            } catch {
                print("Error saving products: \(error)")
            }
            self.getShowableItems()
        }
    }
    var showableNumbers: [AssignedNumber] = [] {
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
        return self.showableNumbers
    }
    
    func getShowableItems(sortedBy sortType: CurrentNumberState = .nonSelected) {
        self.showableNumbers = self.getSortedNumbers(by: sortType)
    }
    
    func getSortedNumbers(by sortType: CurrentNumberState) -> [AssignedNumber] {
        var temporaryNumbers = self.numbers
        switch sortType {
        case .paid:
            let paidItems = temporaryNumbers.filter({ $0.state == .paid })
            temporaryNumbers.removeAll(where: { $0.state == .paid })
            temporaryNumbers.insert(contentsOf: paidItems, at: 0)
            return temporaryNumbers
        case .partialPaid:
            let partialPaidItems = temporaryNumbers.filter({ $0.state == .partialPaid })
            temporaryNumbers.removeAll(where: { $0.state == .partialPaid })
            temporaryNumbers.insert(contentsOf: partialPaidItems, at: 0)
            return temporaryNumbers
        case .nonPaid:
            let nonPaidItems = temporaryNumbers.filter({ $0.state == .nonPaid })
            temporaryNumbers.removeAll(where: { $0.state == .nonPaid })
            temporaryNumbers.insert(contentsOf: nonPaidItems, at: 0)
            return temporaryNumbers
        case .nonSelected:
            return self.numbers
        }
        return []
    }
    
    func sortNumbers(by type: CurrentNumberState) {
        self.showableNumbers = self.getSortedNumbers(by: type)
    }
    
    func modifyNumberWithNewOne(at index: IndexPath, with number: AssignedNumber) {
        if self.showableNumbers.count > 0 &&
            self.showableNumbers.indices.contains(index.row) {
                self.numbers[index.row] = number
                self.onChangedNumberStatusDelegate?.onChangedNumberStatus(at: index)
            return
            }
        print("Number can't be modified. Arrays is empty or doesn't contain index")
    }
    
    func getNumber(at index: Int) -> AssignedNumber {
        if self.showableNumbers.count > 0 &&
            self.showableNumbers.indices.contains(index) {
            return self.showableNumbers[index]
        }
        return AssignedNumber(state: .nonSelected, buyerInformation: BuyerInformation(name: "", selectedNumber: 100000, paidQuantity: 0.0))
    }
    
    func changeNumberStatus(at index: IndexPath, to status: CurrentNumberState) async {
        let indx = index.row
        if self.showableNumbers.count > 0 &&
            self.showableNumbers.indices.contains(indx) {
            self.showableNumbers[indx].changeStatus(to: status)
            self.onChangedNumberStatusDelegate?.onChangedNumberStatus(at: index)
            //Verify index to update
            await FirestoreHandler.updateNumber(with: indx, of: self.numbers[indx])
        }
    }
}
