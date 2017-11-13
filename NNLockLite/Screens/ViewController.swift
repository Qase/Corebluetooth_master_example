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

class ViewController: UITableViewController {

    lazy var fetchResultController: NSFetchedResultsController<Device> = {
        let fetchController = CoreDataStack.shared.devicesFetchedResultsController()
        fetchController.delegate = self
        return fetchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "2N Lock Lite"
        
        self.tableView.register(DeviceTableViewCell.self, forCellReuseIdentifier: Constants.TableCells.deviceCell)
        self.tableView.estimatedRowHeight = 310
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        do {
            try fetchResultController.performFetch()
        } catch {
            QLog("Fetch controller: \(fetchResultController) fetch failed with error \(error)", onLevel: .error)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - TableViewDelegate
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[0].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        self.tableView.endUpdates()
    }
}

