//
//  DetialViewController.swift
//  lopol
//
//  Created by Cesar Ibarra on 11/15/16.
//  Copyright © 2016 Cesar Ibarra. All rights reserved.
//

import UIKit

class DetialViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    
    var repDetail = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = repDetail[0]

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
