//
//  ViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/03.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let ad = UIApplication.shared.delegate as! AppDelegate
    override func viewDidLoad() {
        super.viewDidLoad()
        ad.load(key: "PHOTOINFO")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

