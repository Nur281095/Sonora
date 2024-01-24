//
//  instructionViewController.swift
//

import UIKit
import WebKit
import PDFKit

class instructionViewController: UIViewController {
    
    @IBOutlet var myWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let pdf = Bundle.main.url(forResource: "ShowCues7Manual", withExtension: "pdf", subdirectory: nil, localization: nil)  {
            let req = NSURLRequest(url: pdf)
            myWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            myWebView.load(req as URLRequest)
            self.view.addSubview(myWebView)
        }
    }
}
