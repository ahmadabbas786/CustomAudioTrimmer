//
//  ViewController.swift
//  CustomAudioTrimmer
//
//  Created by Ahmad's MacMini on 25/11/22.
//

import UIKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }

    @IBAction func btnSelectScrubberAction(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AudioScrubberVC") as! AudioScrubberVC
        //vc.modalPresentationStyle = .currentContext
        self.present(vc, animated: true)
    }
    
}

