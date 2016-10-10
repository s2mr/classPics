//
//  CollectionViewController.swift
//  classPics
//
//  Created by Kazumasa Shimomura on 2016/10/03.
//  Copyright © 2016年 Kazumasa Shimomura. All rights reserved.
//

import UIKit
import JTSImageViewController

class CollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let ad = UIApplication.shared.delegate as! AppDelegate
    var selectedSubjectName = "未分類"
    var photosNameToShow = [String]()
    var thumbnailImage = [UIImage]()
    var selectedPhotos:NSMutableArray = []
    var selectedMode = false
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var moveButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
       setup()
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        photosNameToShow.removeAll()
    }
    
    @IBAction func cameraButtonTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "toCamera", sender: self)
    }
    
    @IBAction func selectButtonTapped(_ sender: AnyObject) {
        print("Select Button Tapped")
        navigationItem.hidesBackButton = true
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelSelect))
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        navigationItem.setHidesBackButton(true, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        
        selectedMode = true
        navigationItem.title = "Select Mode"
        selectButton.isEnabled = false
        
    }
    
    @IBAction func moveButtonTapped(_ sender: AnyObject) {
        print("Move Button Tapped")
        if selectedPhotos.count > 0{
            
            performSegue(withIdentifier: "movePics", sender: self)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        print("Save Button Tapped")
    }
    
    @IBAction func deleteButtonTapped(_ sender: AnyObject) {
        let fm = FileManager()
        let path = NSHomeDirectory() + "/Library/"
        
        let array = selectedPhotos as NSArray as? [IndexPath]
        
        for index in array!{
            let row = index.row
            let fileName = photosNameToShow[row]
            let filePath = path + fileName
            try! fm.removeItem(atPath: filePath)
            ad.name.removeValue(forKey: fileName)
        }
        
        photosNameToShow.removeAll()
        
        setup()
        collectionView.reloadData()
        ad.save(object: ad.name as AnyObject, key: "PHOTOINFO")

    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosNameToShow.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        
//        let path = NSHomeDirectory() + "/Library/"
        
//        let fileName = photosNameToShow[indexPath.row]
//        let filePath = path + fileName
        
//        let width = (view.frame.size.width / 4 - 2) * 2
        
  
            cell.imageView.image = thumbnailImage[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.size.width / 4 - 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //画像選択モードになっている時
        if selectedMode{
            //配列がindexPathを含んでいない時は配列に追加
            if !selectedPhotos.contains(indexPath){
                selectedPhotos.add(indexPath)
            }else {
                //含んでいる時は削除
                selectedPhotos.remove(indexPath)
            }
            
            print(selectedPhotos.description)
            
            //選択した画像が１以上の時はボタンを有効化
            if selectedPhotos.count > 0 {
                moveButton.isEnabled = true
                saveButton.isEnabled = true
                deleteButton.isEnabled = true
            }else {
                moveButton.isEnabled = false
                saveButton.isEnabled = false
                deleteButton.isEnabled = false
            }
            DispatchQueue.main.async {
                collectionView.reloadData()
            }
        }else{
        
            print(photosNameToShow[indexPath.row])
            
            let imageInfo = JTSImageInfo()
            
            imageInfo.image = UIImage(contentsOfFile: NSHomeDirectory()+"/Library/\(photosNameToShow[indexPath.row])")
            imageInfo.referenceRect = view.frame
            imageInfo.referenceView = view.superview
            
            let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.image, backgroundStyle: JTSImageViewControllerBackgroundOptions.blurred)
            imageViewer?.show(from: self, transition: JTSImageViewControllerTransition.fromOffscreen)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! CustomCell
        if selectedPhotos.contains(indexPath) {
            //            cell.imageView.layer.masksToBounds = false
            DispatchQueue.main.async {
                cell.imageView.layer.borderWidth = 5
                cell.imageView.layer.borderColor = UIColor.green.cgColor
            }
        
        }else {
            //            cell.imageView.layer.masksToBounds = false
            DispatchQueue.main.async {
                cell.imageView.layer.borderWidth = 5
                cell.imageView.layer.borderColor = UIColor.clear.cgColor
            }
            
        }
    }
    
    func cancelSelect() {
        print("Cancel Button Tapped")
        selectedPhotos.removeAllObjects()
        collectionView.reloadData()
        navigationItem.setHidesBackButton(false, animated: true)
        
        navigationItem.setLeftBarButton(nil, animated: false)
        selectedMode = false
        navigationItem.rightBarButtonItem?.isEnabled = true
        selectButton.isEnabled = true
        moveButton.isEnabled = false
        saveButton.isEnabled = false
    }
    
    func cropThumbnailImage(image :UIImage, w:Int, h:Int) ->UIImage
    {
        // リサイズ処理
        
        let origRef    = image.cgImage;
        let origWidth  = Int(origRef!.width)
        let origHeight = Int(origRef!.height)
        var resizeWidth:Int = 0, resizeHeight:Int = 0
        
        if (origWidth < origHeight) {
            resizeWidth = w
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = h
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSize(width:CGFloat(resizeWidth), height:CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        image.draw(in: CGRect(x:0, y:0, width:CGFloat(resizeWidth), height:CGFloat(resizeHeight)))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        
        let cropRect  = CGRect(x:
            CGFloat((resizeWidth - w) / 2),
           y:CGFloat((resizeHeight - h) / 2),
           width:CGFloat(w), height:CGFloat(h))
        let cropRef   = (resizeImage?.cgImage!)!.cropping(to: cropRect)
        let cropImage = UIImage(cgImage: cropRef!)
        
        return cropImage
    }

    func setup() {
        if selectedSubjectName != ""{
            
            navigationItem.title = selectedSubjectName
            
            for picName in ad.name {
                if picName.value == selectedSubjectName {
                    photosNameToShow.append(picName.key)
                }
            }
        }
        
        photosNameToShow = photosNameToShow.sorted()
        print(photosNameToShow)
        
        selectButton.isEnabled = true
        moveButton.isEnabled = false
        saveButton.isEnabled = false
        deleteButton.isEnabled = false
        
        print("count : \(photosNameToShow.count)")
        let size = (view.frame.size.width/4) * 2
        
        for name in photosNameToShow{
            let image = UIImage(contentsOfFile: NSHomeDirectory() + "/Library/\(name)")
            thumbnailImage.append(cropThumbnailImage(image: image!, w: Int(size), h: Int(size)))
            print(image)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "movePics" {
            let vc = segue.destination as! MovePhotosViewController
            let array = selectedPhotos as NSArray as? [IndexPath]
            
            vc.photosToMove = []
            
            for index in array!{
                vc.photosToMove.append(photosNameToShow[index.row])
            }
            
//            vc.photosToMove = selectedPhotos
        }
    }
 

}

class CustomCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
