//
//  TaskTableViewCell.swift
//  Tasks
//
//  Created by Alex Rupérez on 9/2/18.
//  Copyright © 2018 alexruperez. All rights reserved.
//

import UIKit

protocol TaskTableViewCellDelegate: class {
    func taskTableViewCell(_ taskTableViewCell: TaskTableViewCell, isOn: Bool)
    func taskTableViewCellDidChange(_ taskTableViewCell: TaskTableViewCell, text: String)
}

class TaskTableViewCell: UITableViewCell {
    @IBOutlet private weak var textField: UITextField!
    private weak var delegate: TaskTableViewCellDelegate?
    var isAddCellType: Bool {
        return editingAccessoryType == .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textField.textColor = .black
        (accessoryView as? UISwitch)?.isOn = false
    }

    func config(_ text: String? = nil, delegate: TaskTableViewCellDelegate? = nil) {
        textField.text = text
        self.delegate = delegate
        if text != nil {
            configAsTaskCellType()
        } else {
            configAsAddCellType()
        }
    }

    func configAsTaskCellType() {
        editingAccessoryType = .detailButton
        if !(accessoryView is UISwitch) {
            let switchView = UISwitch()
            switchView.onTintColor = tintColor
            switchView.addTarget(self, action: #selector(switchAction(_:)), for: .valueChanged)
            accessoryView = switchView
        }
    }

    func configAsAddCellType() {
        editingAccessoryType = .none
        if !(accessoryView is UIButton) {
            let buttonView = UIButton(type: .contactAdd)
            buttonView.frame = CGRect(x: 0, y: 0, width: 51, height: 22)
            buttonView.addTarget(self, action: #selector(addAction(_:)), for: .touchUpInside)
            accessoryView = buttonView
        }
    }

    @objc private func addAction(_ sender: Any? = nil) {
        if textField.isFirstResponder {
            _ = textFieldShouldReturn(textField)
        } else {
            textField.becomeFirstResponder()
        }
    }

    @objc private func switchAction(_ switchView: UISwitch) {
        textField.textColor = switchView.isOn ? .gray : .black
        delegate?.taskTableViewCell(self, isOn: switchView.isOn)
    }
}

extension TaskTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.taskTableViewCellDidChange(self, text: textField.text ?? "")
        if isAddCellType {
            if !(textField.text?.isEmpty == true) {
                textField.becomeFirstResponder()
            }
            textField.text = nil
        }
        return true
    }
}
