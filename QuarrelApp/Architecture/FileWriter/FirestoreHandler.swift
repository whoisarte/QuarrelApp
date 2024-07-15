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
        print("Uploading numbers...")
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
            } catch {
                print("Error adding document: \(error)")
            }
        }
    }
    
    static func updateNumber(with number: AssignedNumber, completion: @escaping(Error?) -> Void) {
        let reference = FirestoreHandler.instance.collection("AssignedNumbers").document(number.getDocumentId())
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
        reference.updateData(updateDictionary, completion: completion)
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
                return await self.getNumbers()
            }
            for document in querySnapshot.documents {
                let documentData = document.data()
                let json = try JSONSerialization.data(withJSONObject: documentData)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let number = try decoder.decode(AssignedNumber.self, from: json)
                number.documentID = document.documentID
                numbers.append(number)
            }
            numbers.sort(by: { $0.buyerInformation.selectedNumber < $1.buyerInformation.selectedNumber })
            return numbers
        } catch {
            print("Error getting documents: \(error)")
        }
        return numbers
    }

    static func getAssignedNumbersIds() -> [String] {
        if let ids = UserDefaults.standard.array(forKey: "AssignedNumbersPersistenceId") {
            return ids as? [String] ?? []
        }
        return []
    }
}
