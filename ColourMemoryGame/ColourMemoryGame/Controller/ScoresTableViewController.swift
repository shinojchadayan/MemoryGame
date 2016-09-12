//
//  ScoresTableViewController.swift
//  ColourMemoryGame
//
//  Created by Shinoj Chadayan on 11/09/16.
//  Copyright © 2016 Shinoj Chadayan. All rights reserved.
//

import UIKit
import CoreData

class ScoresTableViewController: UIViewController,UITableViewDataSource {

    // MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var score = [NSManagedObject]()


    //var scores: Array<Dictionary<String,String>> = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        //scores = Highscores.sharedInstance.getHighscores()
        tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Score")
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            let results =
                try managedContext.executeFetchRequest(fetchRequest)
            score = results as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // MARK: - UITableViewDataSource

     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return score.count == 0 ? 0 : 1
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return score.count
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("scoreCell", forIndexPath: indexPath) as! ScoreCell

        // Configure the cell...
        let val = score[indexPath.row]
        let scoreV = val.valueForKey("score") as! intmax_t
        cell.name.text = val.valueForKey("name") as? String
        cell.score.text = String(scoreV)
        cell.rank.text = String(indexPath.row+1)

        return cell
    }

    // MARK: - UITableViewDelegate
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.detailTextLabel?.hidden = false
    }

    @IBAction func closeTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {});

    }

}
