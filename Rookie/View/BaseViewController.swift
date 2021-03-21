//
//  BaseViewController.swift
//  Rookie
//
//  Created by 유연주 on 2021/03/21.
//  Copyright © 2021 yookie. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    func actionSheetStyleAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .actionSheet
        )
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX,
                                                      y: self.view.bounds.midY,
                                                      width: 0,
                                                      height: 0)
                
                popoverController.permittedArrowDirections = []
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            self.present(alert, animated: true, completion: nil)
        }
        
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when) {
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
}
