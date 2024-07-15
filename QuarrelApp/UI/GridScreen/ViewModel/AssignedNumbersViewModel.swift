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
                if let data = UserDefaults.standard.data(forKey: self.dataNumberLocalRetrieveKey) {
                    let data = String(data: data, encoding: .utf8) ?? ""
                    print("New products saved locally...")
                    print("\n\(data)\n")
                }
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
    var currentSortType: NumbersSortType? = .nonSelected
    
    init() {
        Task {
            self.numbers = await FirestoreHandler.getNumbers()
        }
    }
    
    func getNumbers() -> [AssignedNumber] {
        return self.showableNumbers
    }
    
    func getShowableItems(sortedBy sortType: NumbersSortType = .nonSelected) {
        self.currentSortType = sortType
        self.showableNumbers = self.getSortedNumbers(by: sortType)
    }
    
    func getSortedNumbers(by sortType: NumbersSortType) -> [AssignedNumber] {
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
        case .free:
            let freeItems = temporaryNumbers.filter({ $0.state == .nonSelected })
            temporaryNumbers.removeAll(where: { $0.state == .nonSelected })
            temporaryNumbers.insert(contentsOf: freeItems, at: 0)
            return temporaryNumbers
        case .nonSelected:
            return self.numbers
        }
    }
    
    func sortNumbers(by type: NumbersSortType) {
        self.currentSortType = type
        self.showableNumbers = self.getSortedNumbers(by: type)
    }
    
    func modifyNumberWithNewOne(with number: AssignedNumber, at index: IndexPath) {
        if let matchedIndex = self.showableNumbers.firstIndex(where: { $0.documentID == number.getDocumentId() }) {
            self.showableNumbers[matchedIndex] = number
            if let index = self.numbers.firstIndex(where: { $0.documentID == self.showableNumbers[matchedIndex].getDocumentId() }) {
                self.numbers[index] = self.showableNumbers[matchedIndex]
            }
            self.onChangedNumberStatusDelegate?.onChangedNumberStatus(at: index)
            return
        }
        print("Number can't be modified. Arrays is empty or doesn't contain index")
    }
    
    func getNumber(with id: String) -> AssignedNumber {
        if let number = self.showableNumbers.first(where: {$0.documentID == id }) {
            return number
        }
        return AssignedNumber(state: .nonSelected, buyerInformation: BuyerInformation(name: "", selectedNumber: 100000, paidQuantity: 0.0))
    }
    
    func getSelectedNumber(at index: IndexPath) -> AssignedNumber {
        return self.showableNumbers[index.row]
    }
    
    func changeNumberStatus(at index: IndexPath, to status: CurrentNumberState) async {
        let indx = index.row
        if self.showableNumbers.count > 0 &&
            self.showableNumbers.indices.contains(indx) {
            self.showableNumbers[indx].changeStatus(to: status)
            if status == .paid {
                self.showableNumbers[indx].setQuantity(quantity: 100.0)
            }
            if let matchedNumber = self.numbers.first(where: { $0.getDocumentId() == self.showableNumbers[indx].getDocumentId() }) {
                FirestoreHandler.updateNumber(with: matchedNumber) { [weak self] error in
                    if let error {
                        print("Error updating document: \(error)")
                        return
                    }
                    self?.onChangedNumberStatusDelegate?.onChangedNumberStatus(at: index)
                }
            }
        }
    }
}
