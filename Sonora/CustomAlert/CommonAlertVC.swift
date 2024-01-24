//
//  CommonAlertVC.swift
//  WeMinder
//
//  Created by Krishna on 21/05/19.
//  Copyright © 2019 Krishna All rights reserved.
//

import UIKit

class CommonAlertVC: UIViewController {

    
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var buttonOkay: UIButton!
    @IBOutlet weak var heightViewContainer: NSLayoutConstraint!
    
    //var descriptionMessage: String = ""
    var message: String = ""
    var imageItem: UIImage?
    var arrayAction: [[String: () -> Void]]?
    var okButtonAct: (() ->())?
    var isContactNumberHidden: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        buttonOkay.layer.shadowColor = UIColor.gray.cgColor
        buttonOkay.layer.shadowOffset = CGSize(width: 5, height: 5)
        buttonOkay.layer.shadowRadius = 5
        buttonOkay.layer.shadowOpacity = 1.0

        viewContainer.layer.cornerRadius = 20.0
        viewContainer.layer.masksToBounds = true
       // buttonOkay.addCornerRadiusWithShadow(color: .lightGray, borderColor: .clear, cornerRadius: 0)//25
//        buttonCancel.setCornerRadiusWith(radius: 25, borderWidth: 1.0, borderColor: #colorLiteral(red: 0.03529411765, green: 0.2274509804, blue: 0.9333333333, alpha: 1))
        
        self.labelMessage.text = message
        //    self.labelDescription.text = descriptionMessage
        //        if imageItem == nil {
        //            imageViewItem.isHidden = true
        //        } else {
        //            imageViewItem.isHidden = false
        //            imageViewItem.image = imageItem!
        //        }
        //          heightViewContainer.constant = 350
        //        if (descriptionMessage.count) > 0 && (imageItem != nil) {
        //            heightViewContainer.constant = 400
        //        } else if (descriptionMessage.count) > 0 && (imageItem == nil) {
        //            heightViewContainer.constant = 350
        //        }

        if arrayAction == nil {
//            buttonCancel.isHidden = true
        } else {
            var count = 0
            for dic in arrayAction! {
                if count > 1 {
                    return
                }
                let allKeys = Array(dic.keys)
                let buttonTitle: String = allKeys[0].uppercased()
                if count == 0 {
                    buttonOkay.setTitle(buttonTitle, for: .normal)
                } else {
                 //   buttonCancel.setTitle(buttonTitle, for: .normal)
                }
                count += 1
            }
        }       
    }

    // MARK: - IBAction Methods
    @IBAction func contactButtonAction(sender: UIButton) {
        if let url = URL(string: "tel://\(sender.titleLabel?.text ?? "")") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func cancelButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if arrayAction != nil {
            let dic = arrayAction![1]
            for (_, value) in dic {
                let action: () -> Void = value
                action()
            }
        } else {
            okButtonAct?()
        }
    }
    
    @IBAction func okayButtonAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        if arrayAction != nil {
            let dic = arrayAction![0]
            for (_, value) in dic {
                let action: () -> Void = value
                action()
            }
        } else {
             buttonOkay.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            okButtonAct?()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    static func showAlertWithTitle(_ title: String?, message : String?, actionDic : [String: (UIAlertAction) -> Void]) {
        var alertTitle : String = title!
        if title == nil {
            alertTitle = ""
        }
        let alert : UIAlertController = UIAlertController.init(title: alertTitle, message: message, preferredStyle: .alert)
        
        for (key, value) in actionDic {
            let buttonTitle : String = key
            let action: (UIAlertAction) -> Void = value
            alert.addAction(UIAlertAction.init(title: buttonTitle, style: .default, handler: action))
        }
        
        let keyWindow = UIApplication.shared.connectedScenes
        .filter({$0.activationState == .foregroundActive})
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first

        keyWindow?.endEditing(true)
    }
}
