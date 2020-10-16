//
//  CardViewController.swift
//  RPG
//
//  Created by 유연주 on 2020/09/10.
//  Copyright © 2020 yookie. All rights reserved.
//

import UIKit

protocol CardDelegate {
    func closeCardView(_ sender: UIButton)
    func clickActionButton(_ sender: UIButton)
}

class BottomCardView: UIView {
    
    private let xibName = "BottomCardView"
    
    var delegate: CardDelegate?

    @IBOutlet var backView: UIView!
    @IBOutlet var cardView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var taskTextField: UITextField!
    @IBOutlet var actionButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    private func setLayout() {
        self.addKeyboardNotification()
        cardView.layer.cornerRadius = 10
        actionButton.layer.cornerRadius = 10
    }

    private func addKeyboardNotification() {
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
      
      NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keybaordRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keybaordRectangle.height
            backView.frame.origin.y -= (keyboardHeight - 25)
            
        }
    }
      
    @objc private func keyboardWillHide(_ notification: Notification) {
      if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
        let keybaordRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keybaordRectangle.height
        backView.frame.origin.y += keyboardHeight
      }
    }
    
    @IBAction func closeBottomCardView(_ sender: UIButton) {
        delegate?.closeCardView(sender)
    }
    
    @IBAction func clickActionButton(_ sender: UIButton) {
        delegate?.clickActionButton(sender)
    }
    
}

class MonthPickerView: UIView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let xibName = "MonthPickerView"
    
    var delegate: CardDelegate?
    
    @IBOutlet var backView: UIView!
    @IBOutlet var cardView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var monthPickerView: UIPickerView!
    @IBOutlet var actionButton: UIButton!
    
    var pickedMonth = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.setLayout()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func commonInit(){
        let view = Bundle.main.loadNibNamed(xibName, owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        
        monthPickerView.delegate = self
        monthPickerView.dataSource = self
        
        if let defaultMonthRow = DBManager.shared.lastMonths.firstIndex(of: DBManager.shared.lastMonthPicked) {
            monthPickerView.selectRow(defaultMonthRow, inComponent: 0, animated: true)
            pickedMonth = DBManager.shared.lastMonthPicked
        } else {
            if DBManager.shared.lastMonths.count != 0 {
                monthPickerView.selectRow(0, inComponent: 0, animated: true)
                pickedMonth = DBManager.shared.lastMonths[0]
            }
        }
    }
    
    private func setLayout() {
        cardView.layer.cornerRadius = 10
        actionButton.layer.cornerRadius = 10
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DBManager.shared.lastMonths.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DBManager.shared.lastMonths[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if DBManager.shared.lastMonths.count != 0 {
            pickedMonth = DBManager.shared.lastMonths[row]
        }
    }
    
    @IBAction func closeMonthPickerView(_ sender: UIButton) {
        delegate?.closeCardView(sender)
    }
    
    @IBAction func clickActionButton(_ sender: UIButton) {
        delegate?.clickActionButton(sender)
    }
    
}

class CardViewController: UIViewController, CardDelegate {
    
    var cardType = ""
    var bottomCardView = BottomCardView()
    var monthPickerView = MonthPickerView()
    
    var textInputHandler: ((String?) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if cardType == "BottomCardView" {
            bottomCardView = BottomCardView.init(frame: self.view.frame)
            bottomCardView.titleLabel.text = "추가하기"
            bottomCardView.actionButton.setTitle("완료", for: .normal)
            self.view.addSubview(bottomCardView)
            
            bottomCardView.delegate = self
        } else if cardType == "MonthPickerView" {
            monthPickerView = MonthPickerView.init(frame: self.view.frame)
            monthPickerView.titleLabel.text = "날짜 선택하기"
            monthPickerView.actionButton.setTitle("선택", for: .normal)
            self.view.addSubview(monthPickerView)
            
            monthPickerView.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if cardType == "BottomCardView" {
            UIView.animate(withDuration: 0.25) {
                self.bottomCardView.backView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            }
        } else if cardType == "MonthPickerView" {
            UIView.animate(withDuration: 0.25) {
                self.monthPickerView.backView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if cardType == "BottomCardView" {
             self.bottomCardView.backView.backgroundColor = .clear
        } else if cardType == "MonthPickerView" {
            self.monthPickerView.backView.backgroundColor = .clear
        }
    }
    
    func closeCardView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func clickActionButton(_ sender: UIButton) {
        if cardType == "BottomCardView" {
            if let text = bottomCardView.taskTextField.text {
                if !text.isEmpty {
                    self.textInputHandler?(text)
                }
            }
        } else if cardType == "MonthPickerView" {
            if monthPickerView.pickedMonth != "" {
                self.textInputHandler?(monthPickerView.pickedMonth)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

