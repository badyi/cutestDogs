//
//  BreedsListViewController.swift
//  cutestDogs
//
//  Created by Бадый Шагаалан on 19.12.2019.
//  Copyright © 2019 badyi. All rights reserved.
//

import UIKit
import ResourceNetworking

class FakeReachability: ReachabilityProtocol {
    var isReachable: Bool = true
}

class BreedsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let semaphore = DispatchSemaphore(value: 1)
    let networkHelper = NetworkHelper(reachability: FakeReachability())
    var dogViewDictionary : [String : [DogView]] = [:]
    var breeds : [String] = []
    var BreedsDictionary : [String : [String]] = [:]
    
    struct CellIdentifiers {
        static let breedCell = "DogTableViewCell"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "DogTableViewCell", bundle: nil), forCellReuseIdentifier: CellIdentifiers.breedCell)
        
        _ = networkHelper.load(resource: ResourceFactory().createResource()) { [weak self] result in
            switch result {
            case let .success(dogs):
                guard let self = self else { return }
                self.BreedsDictionary = dogs.message
                
                for i in dogs.message {
                    self.breeds.append(i.key)
                }
                
                for i in self.BreedsDictionary {
                    var tempDogViews : [DogView] = []
                    
                    if i.value.count == 0 {
                        let serverDog = ServerDog(breed: i.key, subBreed: "")
                        let dogView = DogView(dog: serverDog, networkHelper: self.networkHelper)
                        dogView.delegate = self
                        tempDogViews.append(dogView)
                    } else {
                        for j in i.value {
                            let serverDog = ServerDog(breed: i.key, subBreed: j)
                            let dogView = DogView(dog: serverDog, networkHelper: self.networkHelper)
                            dogView.delegate = self
                            tempDogViews.append(dogView)
                        }
                    }
                    self.dogViewDictionary[i.key] = tempDogViews
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            default:
                break
            }
        }
        tableView.reloadData()
    }
}

extension BreedsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dogViewDictionary.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dogViewsSection =  dogViewDictionary[breeds[section]] {
            let count = dogViewsSection.count
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.breedCell) as! DogTableViewCell
        
        if let dogViewsSections = dogViewDictionary[breeds[indexPath.section]] {
            let dogView = dogViewsSections[indexPath.row]
            cell.config(with: dogView)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension BreedsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dogView = self.dogViewDictionary[self.breeds[indexPath.section]]?[indexPath.row]
        //dogView?.loadImgURL(networkHelper: networkHelper)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let dogView = dogViewDictionary[breeds[indexPath.section]]?[indexPath.row]
        dogView?.cancelLoadImage()
    }
}

extension BreedsListViewController {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame : CGRect = tableView.frame
        
        let headerView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.lightGray
        
        let label = UILabel(frame: CGRect(x: 10 , y: 0, width: 150, height: 34))
        label.text = breeds[section]
        label.textColor = UIColor(named: "#FF4500")
        headerView.addSubview(label)
        
        return headerView;
    }
}

extension BreedsListViewController: DogViewDelegate{
    func iconDidLoaded(for dog: DogView) {
        guard let section = breeds.firstIndex(of: dog.breed) else { return }
        guard let row = dogViewDictionary[dog.breed]?.firstIndex(of: dog) else { return }
        DispatchQueue.main.async {
            [weak self] in
            self?.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .none)
        }
    }
}

