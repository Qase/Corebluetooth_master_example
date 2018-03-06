//
//  ViewController.swift
//  CoreBluetoothMaster
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
import MessageUI

class ViewController: UIViewController {

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: UIControlEvents.valueChanged)
        tableView.tableFooterView = UIView()
        tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: Constants.TableCells.deviceCell)
        tableView.estimatedRowHeight = 310
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    
    let noDevicesLabel = UILabel.make(text: "No Devices found", textAlignment: .center)
    let bottomView = BluetoothStatusView()
    
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
        
        self.title = "CoreBluetoothMaster"
        self.view.backgroundColor = .white
        self.view.addSubview(tableView)
        self.view.addSubview(noDevicesLabel)
        self.view.addSubview(bottomView)

        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }

        noDevicesLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.right.left.bottom.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
        }
        
        self.bottomView.killSwitch.addTarget(self, action: #selector(changeKillSwitch), for: UIControlEvents.valueChanged)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send logs", style: UIBarButtonItemStyle.plain, target: self, action: #selector(sendLogs))
        
        self.updateBluetoothState(state: AppDelegate.shared.bluetoothManager.centralState)
        
        do {
            try fetchResultController.performFetch()
        } catch {
            QLog("Fetch controller: \(fetchResultController) fetch failed with error \(error)", onLevel: .error)
        }
        noDevicesLabel.isHidden = controllerHasResults
    }
    
    @objc func changeKillSwitch() {
        UserDefaults.standard.set(bottomView.killSwitch.isOn, forKey: Constants.UserDefaults.killIdentifier)
        UserDefaults.standard.synchronize()
    }
    
    @objc func sendLogs()  {
        if !MFMailComposeViewController.canSendMail() {
            return
        }
        let receipient = "ios@quanti.cz"
        
        UINavigationBar.appearance().backgroundColor = UIColor.red
        let mailController = LogFilesViaMailViewController(withRecipients: [receipient])
        mailController.mailComposeDelegate = self
        mailController.navigationBar.tintColor = UIColor.white
        self.present(mailController, animated: true, completion: nil)
    }
    
    @objc func pullToRefresh() {
        QLog("pullToRefresh refresh ", onLevel: .info)
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
    }
}

extension ViewController: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
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
}

extension ViewController: BluetoothManagerDelegate {
    func scanManagerDidUpdateState(_ manager: BluetoothManager) {
        updateBluetoothState(state: manager.centralState)
    }
    
    func updateBluetoothState(state: CBManagerState) {
        if state == .poweredOn {
            self.bottomView.bluetoothLabel.textColor = UIColor.darkGreen
        } else {
            self.bottomView.bluetoothLabel.textColor = UIColor.black
        }
        self.bottomView.bluetoothLabel.text = state.text
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

