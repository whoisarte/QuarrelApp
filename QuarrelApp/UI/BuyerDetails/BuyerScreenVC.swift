//
//  BuyerScreenVC.swift
//  QuarrelApp
//
//  Created by Artemio Pánuco on 02/07/24.
//

import UIKit

class BuyerScreenVC: UIViewController {
    static let identifier: String = "BuyerScreenVC"
    static let storyboard: String = "Main"
    
    @IBOutlet weak var viewNumber: UIView!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var viewStatus: UIView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var viewBuyerName: UIView!
    @IBOutlet weak var viewPaidTotal: UIView!
    @IBOutlet weak var textFieldBuyerName: UITextField!
    @IBOutlet weak var textFieldPaidTotal: UITextField!
    @IBOutlet weak var buttonModifyData: UIButton!
    @IBOutlet weak var switchUserDidPayTotal: UISwitch!
    
    var indexPath: IndexPath?
    var number: AssignedNumber?
    var didUpdateNumber: ((AssignedNumber) -> Void)?
    var numberWillBeModified: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.checkFields()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignKeyboard)))
        self.buttonModifyData.isHidden = !self.numberWillBeModified
        self.configureNumberComponents()
        self.configureFields()
        self.checkFields()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configurateNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @objc func resignKeyboard() {
        self.view.endEditing(true)
    }
    
    func configurateNavigationBar() {
        if let number = self.number {
            self.navigationController?.navigationBar.tintColor = number.state.colorValue
            self.navigationController?.navigationBar.barTintColor = number.state.colorValue
            let textAttributes = [NSAttributedString.Key.foregroundColor: number.state.colorValue]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationItem.title = "Número \(number.buyerInformation.selectedNumber)"
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector((enableDataModification)))
        }
    }
    
    @objc func enableDataModification() {
        self.numberWillBeModified.toggle()
        UIView.animate(withDuration: 0.2) {
            self.buttonModifyData.layer.isHidden = !self.numberWillBeModified
            self.buttonModifyData.layer.backgroundColor = UIColor.clear.cgColor
            self.buttonModifyData.tintColor = self.number?.state.colorValue
        }
    }
    
    func checkFields() {
        self.textFieldBuyerName.isEnabled = self.numberWillBeModified
        self.textFieldBuyerName.isUserInteractionEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.isEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.isUserInteractionEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.text = self.numberWillBeModified ? "" : "$\(self.number?.buyerInformation.paidQuantity ?? 0.0)"
        self.switchUserDidPayTotal.isEnabled = self.numberWillBeModified
        self.switchUserDidPayTotal.isUserInteractionEnabled = self.numberWillBeModified
    }
    
    
    func configureNumberComponents() {
        if let number = self.number {
            self.labelNumber.text = "\(number.buyerInformation.selectedNumber)"
            let dominantColor: CGColor = number.state.colorValue.cgColor
            self.labelStatus.text = number.state.statusValue
            self.viewBuyerName.layer.borderColor = dominantColor
            self.viewPaidTotal.layer.borderColor = dominantColor
            self.buttonModifyData.layer.backgroundColor = UIColor.clear.cgColor
            self.buttonModifyData.tintColor = number.state.colorValue
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                UIView.animate(withDuration: 0.5) {
                    self.viewNumber.layer.cornerRadius = 21.0
                    self.viewNumber.layer.backgroundColor = dominantColor
                    self.viewStatus.layer.cornerRadius = 18.0
                    self.viewStatus.layer.backgroundColor = dominantColor
                    self.switchUserDidPayTotal.onTintColor = number.state.colorValue
                }
            }
        }
    }
    
    func configureFields() {
        self.textFieldBuyerName.delegate = self
        self.textFieldPaidTotal.delegate = self
        self.viewBuyerName.layer.borderWidth = 0.5
        self.viewBuyerName.layer.cornerRadius = 12
        self.viewPaidTotal.layer.borderWidth = 0.5
        self.viewPaidTotal.layer.cornerRadius = 12
        self.textFieldPaidTotal.keyboardType = .decimalPad
        self.textFieldBuyerName.text = self.number?.buyerInformation.name
        self.textFieldPaidTotal.text = "$\(self.number?.buyerInformation.paidQuantity ?? 0.0)"
    }
    
    @IBAction func modifyData(_ sender: Any) {
        if let number = self.number,
           let row = indexPath?.row {
            self.buttonModifyData.isEnabled = false
            //If switch is on, then user paid total amount
            if self.switchUserDidPayTotal.isOn {
                Task {
                    let newNumber = AssignedNumber(state: .paid, buyerInformation: number.buyerInformation)
                    await FirestoreHandler.updateNumber(with: row, of: newNumber)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        self.didUpdateNumber?(newNumber)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                return
            }
            Task {
                let newNumber = AssignedNumber(state: Double(self.textFieldPaidTotal.text ?? "0.0") ?? 0.0 > 0 ? .partialPaid : .nonPaid, buyerInformation:
                                                BuyerInformation(name: self.textFieldBuyerName.text ?? "",
                                                                 selectedNumber: number.buyerInformation.selectedNumber,
                                                                 paidQuantity: Double(self.textFieldPaidTotal.text ?? "0.0") ?? 0.0))
                await FirestoreHandler.updateNumber(with: row, of: newNumber)
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.didUpdateNumber?(newNumber)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}

extension BuyerScreenVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textFieldBuyerName {
            self.textFieldPaidTotal.becomeFirstResponder()
            return true
        }
        textField.resignFirstResponder()
        return true
    }
}
