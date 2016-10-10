//
//  SubjectViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/03.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit

class SubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var selectedRow:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonTapped(_ sender: AnyObject) {
        let ac = UIAlertController(title: "Add subject", message: "Please input subject title.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            NSLog("OK")
            let textField = ac.textFields?.first
            if textField?.text != "" {
                self.ad.subjectName.append((textField?.text)!)
            }
            self.tableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            NSLog("Cancel")
        })
        
        ac.addTextField(configurationHandler: { textField in
            textField.placeholder = "math"
        })
        
        ac.addAction(okAction)
        ac.addAction(cancelAction)
        present(ac, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "toCollection", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ad.subjectName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ad.subjectName[indexPath.row]
        return cell
    }
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toCollection" {
            let nextVC = segue.destination as! CollectionViewController
            nextVC.selectedSubjectName = ad.subjectName[selectedRow]
        }
    }
    

}
