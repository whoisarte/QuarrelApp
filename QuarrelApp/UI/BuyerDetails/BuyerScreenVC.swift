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
    
    var viewModel: BuyerInformationViewModel?
    func setViewModel(viewModel: BuyerInformationViewModel) {
        self.viewModel = viewModel
    }
    
    var index: IndexPath?
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
        self.checkIfItIsAlreadyPaid()
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
        if let number = self.viewModel?.number {
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
            self.buttonModifyData.tintColor = self.self.viewModel?.number.state.colorValue
        }
    }
    
    func checkFields() {
        self.textFieldBuyerName.isEnabled = self.numberWillBeModified
        self.textFieldBuyerName.isUserInteractionEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.isEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.isUserInteractionEnabled = self.numberWillBeModified
        self.textFieldPaidTotal.text = self.numberWillBeModified ? "" : "$\(self.viewModel?.number.buyerInformation.paidQuantity ?? 0.0)"
        self.switchUserDidPayTotal.isEnabled = self.numberWillBeModified
        self.switchUserDidPayTotal.isUserInteractionEnabled = self.numberWillBeModified
    }
    
    func checkIfItIsAlreadyPaid() {
        if let number = self.viewModel?.number,
           number.state == .paid {
            DispatchQueue.main.async {
                self.switchUserDidPayTotal.isOn = true
                self.navigationItem.rightBarButtonItem?.isEnabled = false
            }
        }
    }
    
    func configureNumberComponents() {
        if let number = self.viewModel?.number {
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
        self.textFieldBuyerName.text = self.viewModel?.number.buyerInformation.name
        self.textFieldPaidTotal.text = "$\(self.viewModel?.number.buyerInformation.paidQuantity ?? 0.0)"
    }
    
    @IBAction func modifyData(_ sender: Any) {
        if self.fieldsAreFilled() {
            self.buttonModifyData.loadingIndicator(true)
            self.buttonModifyData.isEnabled = false
            if let number = self.viewModel?.number {
                self.buttonModifyData.isEnabled = false
                if self.switchUserDidPayTotal.isOn {
                    Task {
                        let name = self.fieldsAreFilled() ? self.textFieldBuyerName.text ?? number.buyerInformation.name : number.buyerInformation.name
                        let quantity = 100.0
                        let newNumber = AssignedNumber(state: .paid, buyerInformation: BuyerInformation(name: name, selectedNumber: number.buyerInformation.selectedNumber, paidQuantity: quantity))
                        newNumber.documentID = number.getDocumentId()
                        self.viewModel?.updateNumber(number: newNumber, completion: { error in
                            if let error {
                                print("Error updating document: \(error)")
                                return
                            }
                            self.didUpdateNumber?(newNumber)
                            self.navigationController?.popViewController(animated: true)
                        })
                    }
                    return
                }
                Task {
                    let totalPaid = Double(self.textFieldPaidTotal.text ?? "0.0") ?? 0.0
                    let name = self.textFieldBuyerName.text ?? ""
                    let newNumber = AssignedNumber(state: totalPaid > 0 ? .partialPaid : .nonPaid,
                                                   buyerInformation: BuyerInformation(name: name,
                                                                                      selectedNumber: number.buyerInformation.selectedNumber,
                                                                                      paidQuantity: totalPaid))
                    newNumber.documentID = number.getDocumentId()
                    self.viewModel?.updateNumber(number: newNumber, completion: { error in
                        if let error {
                            print("Error updating document: \(error)")
                            return
                        }
                        self.didUpdateNumber?(newNumber)
                        self.navigationController?.popViewController(animated: true)
                    })
                }
            }
        } else {
            self.buttonModifyData.loadingIndicator(false)
            self.buttonModifyData.isEnabled = true
        }
    }
    
    func fieldsAreFilled() -> Bool {
        guard let name = self.textFieldBuyerName.text,
           name.count > 0 else {
            self.showErrorAlert(with: "El campo de nombre está vacío")
            return false
        }
        if !self.switchUserDidPayTotal.isOn {
            guard let quantity = self.textFieldPaidTotal.text,
                  quantity.count > 0 else {
                self.showErrorAlert(with: "El campo de total está vacío")
                return false
            }
        }
        return true
    }
    
    func showErrorAlert(with error: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Cerrar", style: .destructive, handler: { _ in
                alertController.dismiss(animated: true)
            }))
            self.present(alertController, animated: true)
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

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            self.isEnabled = true
            self.alpha = 1.0
            if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
            }
        }
    }
}
