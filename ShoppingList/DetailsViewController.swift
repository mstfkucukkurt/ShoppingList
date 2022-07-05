//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Mustafa Kucukkurt on 7/4/22.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var SaveButtons: UIButton!
    
    var selectProductName = ""
    var selectProductUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectProductName != "" {
            SaveButtons.isHidden = true
            // Core Data seçilen ürün bilgilerini göster
            if let uuidString = selectProductUUID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@ ", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do {
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        for result in results as! [NSManagedObject]{
                            
                            if let name = result.value(forKey: "name") as? String {
                                nameTextField.text = name
                            }
                            
                            if let price = result.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                            }
                            
                            if let size = result.value(forKey: "size") as? String {
                                sizeTextField.text = size
                            }
                            
                            if let imgdata = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imgdata)
                                imageView.image = image
                            }
                        }
                    }
                } catch {
                    print("error")
                }
            }
        } else {
            SaveButtons.isHidden = false
            SaveButtons.isEnabled = false
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imgselect))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    @objc func imgselect(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        SaveButtons.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        
        shopping.setValue(nameTextField.text!, forKey: "name")
        shopping.setValue(sizeTextField.text!, forKey: "size")
        
        if let price = Int(priceTextField.text!){
            shopping.setValue(price, forKey: "price")
        }
        //universal unique id
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        shopping.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("save")
        } catch{
            print("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("dataent"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
