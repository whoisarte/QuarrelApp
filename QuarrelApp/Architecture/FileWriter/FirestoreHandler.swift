//
//  FirestoreHandler.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 03/07/24.
//

import Foundation
import FirebaseFirestore

class FirestoreHandler {
    static let instance: Firestore = Firestore.firestore()
    init() {}
    
    static func uploadNumbers(numbers: [AssignedNumber]) async {
        var ids: [String] = []
        for number in numbers {
            let buyerInformation = number.buyerInformation
            let buyerDictionary: [String : Any] = [
                "buyerName" : buyerInformation.name,
                "buyerPaidQuantity" : buyerInformation.paidQuantity,
                "buyerSelectedNumber" : buyerInformation.selectedNumber
            ]
            let uploadableDictionary: [String : Any] = [
                "numberState" : "\(number.state)",
                "buyerInformation" : buyerDictionary
                ]
            do {
                let reference = try await FirestoreHandler.instance.collection("AssignedNumbers").addDocument(data: uploadableDictionary)
                print("Element added to collection AssignedNumbers with id: \(reference.documentID)")
                ids.append(reference.documentID)
            } catch {
                print("Error adding document: \(error)")
            }
        }
        FirestoreHandler.saveIds(ids: ids)
    }
    
    static func updateNumber(with arrayIndex: Int, of number: AssignedNumber) async {
        let ids = FirestoreHandler.getAssignedNumbersIds()
        let reference = FirestoreHandler.instance.collection("AssignedNumbers").document(ids[arrayIndex])
        let buyerInformation = number.buyerInformation
        let buyerDictionary: [String : Any] = [
            "buyerName" : buyerInformation.name,
            "buyerPaidQuantity" : buyerInformation.paidQuantity,
            "buyerSelectedNumber" : buyerInformation.selectedNumber
        ]
        let updateDictionary: [String : Any] = [
            "numberState" : "\(number.state)",
            "buyerInformation" : buyerDictionary
            ]
        do {
            try await reference.updateData(updateDictionary)
        } catch {
            print("Error updating document with id: \(ids[arrayIndex]): \(error)")
        }
    }
    
    static func getNumbers() async -> [AssignedNumber] {
        var numbers: [AssignedNumber] = []
        do {
            let querySnapshot = try await FirestoreHandler.instance.collection("AssignedNumbers").getDocuments()
            if querySnapshot.documents.count == 0 {
                var numbers: [AssignedNumber] = []
                for indx in 0...99 {
                    numbers.append(AssignedNumber(state: .nonSelected, buyerInformation: BuyerInformation(name: "",
                                                                                                          selectedNumber: indx,
                                                                                                          paidQuantity: 0.0)))
                }
                await self.uploadNumbers(numbers: numbers)
                return numbers
            }
            for document in querySnapshot.documents {
                let documentData = document.data()
                
                let json = try JSONSerialization.data(withJSONObject: documentData)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let number = try decoder.decode(AssignedNumber.self, from: json)
                numbers.append(number)
            }
            numbers.sort(by: { $0.buyerInformation.selectedNumber < $1.buyerInformation.selectedNumber })
            return numbers
        } catch {
            print("Error getting documents: \(error)")
        }
        return numbers
    }
    
    static func saveIds(ids: [String]) {
        UserDefaults.standard.setValue(ids, forKey: "AssignedNumbersPersistenceId")
    }
    
    static func getAssignedNumbersIds() -> [String] {
        if let ids = UserDefaults.standard.array(forKey: "AssignedNumbersPersistenceId") {
            return ids as? [String] ?? []
        }
        return []
    }
}
