//
//  CollectionViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/03.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let ad = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ad.name.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
        let path = NSHomeDirectory() + "/Library/"
        let fileName = ad.name[indexPath.row]
        let filePath = path + fileName
        
        if let img = UIImage(contentsOfFile: filePath) {
            cell.imageView.image = img
        }else {
            print("画像がありません")
        }
        
        return cell
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

class CustomCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
