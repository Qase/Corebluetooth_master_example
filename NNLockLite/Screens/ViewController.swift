//
//  ViewController.swift
//  NNLockLite
//
//  Created by David Nemec on 08/11/2017.
//  Copyright © 2017 Quanti. All rights reserved.
//

import UIKit
import SnapKit
import QuantiBase
import CoreData
import QuantiLogger
import CoreBluetooth

class ViewController: UIViewController {

    var tableView = UITableView()
    var bluetoothLabel = UILabel()
    var lastEventLabel = UILabel()
    
    var noDevicesLabel = UILabel()
    
    lazy var fetchResultController: NSFetchedResultsController<Device> = {
        let fetchController = CoreDataStack.shared.devicesFetchedResultsController()
        fetchController.delegate = self
        return fetchController
    }()
    
    var controllerHasResults: Bool {
        return self.fetchResultController.fetchedObjects?.count ?? 0 > 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "2N Lock Lite"
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        self.tableView.refreshControl = UIRefreshControl()
        self.tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
        self.tableView.tableFooterView = UIView()
        
        self.view.addSubview(noDevicesLabel)
        noDevicesLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        noDevicesLabel.text = "No Devices found"
        noDevicesLabel.textAlignment = .center
        
        
        
        let bottomView = UIView()
        let bottomStackView = UIStackView()
        view.addSubview(bottomView)
        bottomView.addSubview(bottomStackView)
        
        bottomView.backgroundColor = .lightGray
        
        bottomView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
        }
        
        bottomStackView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(8)
        }
        
        let bleStaticLabel = UILabel()
        bleStaticLabel.text = "BLE Status:"
        bleStaticLabel.font = UIFont.boldSystemFont(ofSize: 16)
        bleStaticLabel.setContentHuggingPriority(UILayoutPriority.defaultHigh, for: UILayoutConstraintAxis.horizontal)
        
        let bleStackView = UIStackView()
        bleStackView.alignment = .fill
        bleStackView.axis = .horizontal
        bleStackView.distribution = .fill
        
        bleStackView.addArrangedSubview(bleStaticLabel)
        bleStackView.addArrangedSubview(self.bluetoothLabel)
        
        
        self.updateBluetoothState(state: AppDelegate.shared.bluetoothManager.centralState)
        
        bottomStackView.addArrangedSubview(bleStackView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: Constants.TableCells.deviceCell)
        self.tableView.estimatedRowHeight = 310
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        do {
            try fetchResultController.performFetch()
        } catch {
            QLog("Fetch controller: \(fetchResultController) fetch failed with error \(error)", onLevel: .error)
        }
        
        noDevicesLabel.isHidden = controllerHasResults
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        QLog("didReceiveMemoryWarning", onLevel: .warn)
        // Dispose of any resources that can be recreated.
    }
    
    @objc func pullToRefresh() {
        QLog("pullToRefresh refresh ", onLevel: .info)
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
}

// MARK: - TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCells.deviceCell, for: indexPath)
        
        guard let myCell = cell as? DeviceTableViewCell else {
            return cell
        }
        myCell.entry = fetchResultController.object(at: indexPath)
        return myCell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        guard let myCell = cell as? DeviceTableViewCell else {
////            return
////        }
////
////        myCell.entry = fetchResultController.object(at: indexPath)
//    }
}

extension ViewController: BluetoothManagerDelegate{
    func scanManagerDidUpdateState(_ manager: BluetoothManager) {
        updateBluetoothState(state: manager.centralState)
        
    }
    
    func updateBluetoothState(state: CBManagerState) {
        self.bluetoothLabel.text = "\(state)"
        
        if state == .poweredOn {
            self.bluetoothLabel.textColor = UIColor.darkGreen
        } else {
            self.bluetoothLabel.textColor = UIColor.black
        }
        
        switch state {
        case .poweredOff:
            self.bluetoothLabel.text = "Powered Off"
        case .poweredOn:
            self.bluetoothLabel.text = "Powered On"
        case .resetting:
            self.bluetoothLabel.text = "Resseting"
        case .unauthorized:
            self.bluetoothLabel.text = "Unauthorized"
        case .unknown:
            self.bluetoothLabel.text = "Unknown"
        case .unsupported:
            self.bluetoothLabel.text = "Unsopported"
        }
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate methods
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //QLog("CallLog controllerWillChangeContent", onLevel: .debug)
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            //QLog("CallLog didChange insert \(String(describing: newIndexPath))", onLevel: .debug)
            self.tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.fade)
        case .delete:
            //QLog("CallLog didChange delete \(String(describing: indexPath))", onLevel: .debug)
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            //QLog("CallLog didChange update \(String(describing: indexPath))", onLevel: .debug)
            guard let indexPathU = indexPath, let cell = tableView.cellForRow(at: indexPathU) as? DeviceTableViewCell else {
                break
            }
            cell.entry = fetchResultController.object(at: indexPathU)
        case .move:
            //QLog("CallLog didChange move \(String(describing: newIndexPath))", onLevel: .debug)
            tableView.deleteRows(at: [indexPath!], with: UITableViewRowAnimation.fade)
            tableView.insertRows(at: [newIndexPath!], with: UITableViewRowAnimation.none)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //QLog("CallLog controllerDidChangeContent", onLevel: .debug)

        noDevicesLabel.isHiddenGuarded = controllerHasResults
        self.tableView.endUpdates()
    }
}

