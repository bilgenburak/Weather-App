//
//  PlacesVC.swift
//  Weather
//
//  Created by Burak on 24.10.2021.
//

import UIKit
import Kingfisher

class PlacesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cityName = String()
    
    var latData : Double?
    var lonData : Double?
    var nameData : String?
    
    var latArray = [36.778259]
    var lonArray = [-119.417931]
    var nameArray = ["California"]
    
    var imageURL = URL(string: "")
    
    let defaults = UserDefaults.standard
    
    var savedLatArray : [Double]?
    var savedLonArray : [Double]?
    var savedNameArray : [String]?
    
    var selectedIndex = Int()

    @IBOutlet var addButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Hide Status Bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() == false {
            showAlert()
        }
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        collectionView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        latArray = defaults.object(forKey: "lat") as? [Double] ?? [Double]()
        lonArray = defaults.object(forKey: "lon") as? [Double] ?? [Double]()
        nameArray = defaults.object(forKey: "name") as? [String] ?? [String]()
        if let getLat = latData {
            if let getLon = lonData {
                if let getName = nameData {
                    self.latArray.append(getLat)
                    self.lonArray.append(getLon)
                    self.nameArray.append(getName)
                    defaults.set(latArray, forKey: "lat")
                    defaults.set(lonArray, forKey: "lon")
                    defaults.set(nameArray, forKey: "name")
                }
            }
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        addButton.layer.cornerRadius = 15
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "placeCell", for: indexPath) as! PlaceCell
        imageURL = URL(string: "https://source.unsplash.com/335x202/?\(nameArray[indexPath.row])")
        cell.image.kf.setImage(with: imageURL)
        cell.label.text = nameArray[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showFavoritePlace", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFavoritePlace" {
            let destinationVC = segue.destination as! MainVC
            destinationVC.showFavorite = true
            destinationVC.favoriteLon = lonArray[selectedIndex]
            destinationVC.favoriteLat = latArray[selectedIndex]
        }
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Caution", message: "You must have internet connection to use Weather app.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

class PlaceCell: UICollectionViewCell {
    @IBOutlet weak var background : UIView!
    @IBOutlet weak var image : UIImageView!
    @IBOutlet weak var label : UILabel!
    @IBOutlet weak var blur : UIVisualEffectView!
    override func awakeFromNib() {
        background.layer.cornerRadius = 12
        image.layer.cornerRadius = 12
        blur.layer.cornerRadius = 12
        blur.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        blur.clipsToBounds = true
    }
}
