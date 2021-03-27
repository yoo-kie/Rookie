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
                popoverController.sourceView = view
                popoverController.sourceRect = CGRect(
                    x: view.bounds.midX,
                    y: view.bounds.midY,
                    width: 0,
                    height: 0
                )
                popoverController.permittedArrowDirections = []
                
                present(alert, animated: true, completion: nil)
            }
        } else {
            present(alert, animated: true, completion: nil)
        }
        
        let timer = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: timer) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
}
