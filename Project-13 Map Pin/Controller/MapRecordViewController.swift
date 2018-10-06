//
//  MapRecordViewController.swift
//  Project-13 Map Pin
//
//  Created by Chris on 2/10/2018.
//  Copyright © 2018 Chris. All rights reserved.
//

import UIKit
import MapKit

class MapRecordViewController: UITableViewController, DidSelectLocationCallback {

    var model = MapPins()
    var addCityTF: UITextField?
    var addDetailTF: UITextField?
    var addDialog: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: .UIApplicationDidEnterBackground, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let addDialog = addDialog{
            present(addDialog, animated: true, completion: nil)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.pins.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let pin = model.pins[indexPath.item]
        
        cell.textLabel?.text = pin.title
        cell.detailTextLabel?.text = pin.subtitle

        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.performBatchUpdates({
                self.model.pins.remove(at: indexPath.item)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }, completion: nil)
        }    
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let removedPin = model.pins.remove(at: fromIndexPath.item)
        model.pins.insert(removedPin, at: to.item)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let mapVC = segue.destination as? MapViewController{
            
            mapVC.model = model
            mapVC.callback = self
            
            if segue.identifier == "openMap",
                let senderCell = sender as? UITableViewCell,
                let index = tableView.indexPath(for: senderCell){
                
                let targetPin = model.pins[index.item]
                mapVC.targetLocation = CLLocationCoordinate2D(latitude: targetPin.latitude, longitude: targetPin.longitude)
                
            }
            
        }
    }
    
    func didSelect(locationAt location: CLLocationCoordinate2D, withAdditionalInfo info: [CLPlacemark]?) {
        
        addDialog = UIAlertController(title: "Add", message: "Please enter location details", preferredStyle: .alert)
        addDialog!.addTextField { (tf) in
            tf.placeholder = "City"
            tf.borderStyle = .none
            if let info = info, info.count > 0{
                tf.text = info.first!.name
            }
            self.addCityTF = tf
        }
        addDialog!.addTextField { (tf) in
            tf.placeholder = "Details"
            tf.borderStyle = .none
            self.addDetailTF = tf
        }
        addDialog!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            self.addCityTF = nil
            self.addDetailTF = nil
            self.addDialog!.dismiss(animated: true, completion: nil)
            self.addDialog = nil
        }))
        addDialog!.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
            self.model.pins.append(Pin(coordinate: location, title: self.addCityTF?.text ?? "", subtitle: self.addDetailTF?.text ?? ""))
            self.tableView.insertRows(at: [IndexPath(item: self.model.pins.count - 1, section: 0)], with: .automatic)
            self.addCityTF = nil
            self.addDetailTF = nil
            self.addDialog!.dismiss(animated: true, completion: nil)
            self.addDialog = nil
            
        }))
        
    }
    
    @objc func didEnterBackground(){
        model.save()
    }

}
