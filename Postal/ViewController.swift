//
//  ViewController.swift
//  Postal
//

import UIKit

enum ErrorMessage: String {
    case lengthError = "7桁で入力してください"
    case unAbailableError = "住所が探せませんでした"
}

class ViewController: UIViewController, UITextFieldDelegate, HttpRequestDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var postalCodeTextField: UITextField!
    
    @IBOutlet weak var addressTextField1: UITextField!    
    @IBOutlet weak var addressTextField2: UITextField!
    @IBOutlet weak var addressTextField3: UITextField!

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    var httpClient = HttpClient()
    
    var textField1Text = ""
    var textField2Text = ""
    var textField3Text = ""
    
    var pickerViewRows = 1
    
    var postalCode = PostalCode()
    
    // 最大20件まで用意しておく。一応APIの仕様として最高20件までとあるため。
    let pickerViewDataList = ["住所1", "住所2", "住所3", "住所4", "住所5", "住所6", "住所7", "住所8", "住所9", "住所10",
    "住所11", "住所12", "住所13", "住所14", "住所15", "住所16", "住所17", "住所18", "住所19", "住所20", ]
    
    var addresses: [Address]? = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let didTapView = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        self.view.addGestureRecognizer(didTapView)
    
        httpClient.delegate = self
        
        indicator.color = .black
        indicator.style = .large
        indicator.hidesWhenStopped = true
        
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.isHidden = true
        
        addresses?.removeAll()
    }

    @IBAction func searchAddress(_ sender: UIButton) {
        
        // indicatorを表示する
        indicator.startAnimating()
        // キーボードを非表示にする
        postalCodeTextField.resignFirstResponder()
        
        let inputString = (postalCodeTextField?.text)!
        postalCode.setCode(inputString: inputString)
        
        if postalCode.codeString == "" {
            self.indicator.stopAnimating()
            showAlert(error: ErrorMessage.lengthError.rawValue)
            return
        }
        
        self.httpClient.searchAddress(postalCode.codeString)
    }
    
    // MARK:- textField Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 数字のみの許可
        return  string.isEmpty ||
            (string.range(of: "^[0-9]+$", options: .regularExpression, range: nil, locale: nil) != nil)
    }
    
    // MARK:- private methods
    func showAlert(error message:String) {
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.updateUI(hidePickerView: true, clearTextFields: true)
        })
        alertController.addAction(alertAction)
        
        // メインキューでやる
        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
    
    @objc func closeKeyboard() {
        // キーボードの非表示
        postalCodeTextField.resignFirstResponder()
        addressTextField1.resignFirstResponder()
        addressTextField2.resignFirstResponder()
        addressTextField3.resignFirstResponder()
    }
    
    
    func updateTextField() {
        DispatchQueue.main.async {
            self.addressTextField1.text = self.textField1Text
            self.addressTextField2.text = self.textField2Text
            self.addressTextField3.text = self.textField3Text
        }
    }
    
    func clearTextFieldText() {
        self.textField1Text = ""
        self.textField2Text = ""
        self.textField3Text = ""
    }
    
    func hideIndicator() {
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
        }
    }
        
    func updateUI(hidePickerView pickerView: Bool, clearTextFields clear: Bool) {
        DispatchQueue.main.async {
            
            // PickerViewの表示
            self.pickerView.isHidden = pickerView
            
            // TextFieldのクリア
            if clear {
                self.clearTextFieldText()
            }
            
            self.pickerView.selectRow(0, inComponent: 0, animated: true)
            self.pickerView.reloadAllComponents()
            
            self.updateTextField()
        }
    }
    
    func setAddressTextFields(_ row: Int) {
        let address = self.addresses![row]
        self.textField1Text = address.address1
        self.textField2Text = address.address2
        self.textField3Text = address.address3
    }
    
    // MARK:- HttpClient Delegates
    func didReceiveJsonData(jsonData data: Data?) {
        
        self.hideIndicator()
        
        let parser = JsonParser()
                
        self.addresses = parser.parse(data: data)
        
        if let addresses = self.addresses {
            
            self.pickerViewRows = addresses.count
            // 住所が複数あった場合には、最初の住所をデフォルト表示させる
            self.setAddressTextFields(0)
            if addresses.count == 1 {
                self.updateUI(hidePickerView: true, clearTextFields: false)
            } else {
                self.updateUI(hidePickerView: false, clearTextFields: false)
            }
        } else {
            // 取得失敗
            self.showAlert(error: ErrorMessage.unAbailableError.rawValue)
            
        }
    }
    
    func didReceiveError(_ error: Error) {
        self.hideIndicator()
        print("error: \(error.localizedDescription)")
    }
    
    
    // MARK:- DataPickerView Delegates
    // 行数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // 検索結果によって変わる
        return pickerViewRows
    }
    // 列数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // 1固定
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerViewDataList[row]
    }
    
    // 選択されたときの挙動
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.setAddressTextFields(row)
        updateTextField()
    }
    
}

