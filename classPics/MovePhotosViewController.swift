//
//  MovePhotosViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/09.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit

class MovePhotosViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ad = UIApplication.shared.delegate as! AppDelegate
    var photosToMove:[String]!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(photosToMove)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ad.subjectName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ad.subjectName[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //動かすようの名前の配列
        for photo in photosToMove{
            //元々の名前が入っている辞書
            for name in ad.name{
                //キーが一致した場合に、まずキーを元に削除した上で、キーを元に値を更新
                if name.key == photo{
                    
                    let key = name.key
                    ad.name.removeValue(forKey: key)
                    ad.name[key] = ad.subjectName[indexPath.row]
                }
                
            }
        }
        
        dismiss(animated: true, completion: {
            let vc = self.ad.window?.rootViewController?.childViewControllers.last as! CollectionViewController
            vc.collectionView.reloadData()
        })
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
