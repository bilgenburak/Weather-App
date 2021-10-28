//
//  ErrorVC.swift
//  Weather
//
//  Created by Burak on 24.10.2021.
//

import UIKit

class ErrorVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
