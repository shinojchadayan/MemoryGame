//
//  ViewController.swift
//  ColourMemoryGame
//
//  Created by Shinoj Chadayan on 11/09/16.
//  Copyright © 2016 Shinoj Chadayan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,MemoryGameDelegate{
    
    // MARK: Properties
    
    @IBOutlet weak var scoreLable: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let gameController = MemoryGame()
    var timer:NSTimer?
    var totalScore : intmax_t = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameController.delegate = self
        resetGame()
        setupNewGame()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //        if gameController.isPlaying {
        //            resetGame()
        //        }
    }
    
    // MARK: - Methods
    
    func resetGame() {
        gameController.stopGame()
        if timer?.valid == true {
            timer?.invalidate()
            timer = nil
        }
        collectionView.userInteractionEnabled = false
        collectionView.reloadData()
        
    }
    
    
    func setupNewGame() {
        let cardsData:[UIImage] = MemoryGame.defaultCardImages
        gameController.newGame(cardsData)
    }
    
    func gameTimerAction() {
        //timerLabel.text = String(format: "%@: %.0fs", NSLocalizedString("TIME", comment: "time"), gameController.elapsedTime)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return gameController.numberOfCards
        return gameController.numberOfCards > 0 ? gameController.numberOfCards : 12
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        cell.showCard(false, animted: false)
        
        guard let card = gameController.cardAtIndex(indexPath.item) else { return cell }
        cell.card = card
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CardCell
        
        if cell.shown { return }
        gameController.didSelectCard(cell.card)
        
        collectionView.deselectItemAtIndexPath(indexPath, animated:true)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let picDimension = self.view.frame.size.width / 5.0
        return CGSizeMake(picDimension, picDimension)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let leftRightInset = self.view.frame.size.width / 14.0
        return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
    }
    // MARK: - MemoryGameDelegate
    
    func memoryGameDidStart(game: MemoryGame) {
        collectionView.reloadData()
        collectionView.userInteractionEnabled = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(ViewController.gameTimerAction), userInfo: nil, repeats: true)
        
    }
    
    func memoryGame(game: MemoryGame, showCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection:0)) as! CardCell
            cell.showCard(true, animted: true)
        }
    }
    
    func memoryGame(game: MemoryGame, hideCards cards: [Card]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: index, inSection:0)) as! CardCell
            cell.showCard(false, animted: true)
        }
    }
    
    
    func memoryGame(game: MemoryGame, count :intmax_t ,foundMatch : Bool){
        if(foundMatch){
            totalScore = totalScore + 2
        }
        else{
            totalScore = totalScore + -1
            
        }
        let aStr = String(format: "Current Score: %d", totalScore)
        scoreLable.text = aStr;
        
    }
    
    
    func memoryGameDidEnd(game: MemoryGame, points: intmax_t) {
        timer?.invalidate()
        
        let alertController = UIAlertController(
            title: NSLocalizedString("Hurrah!", comment: "title"),
            message: String(format: "%@ %d ", NSLocalizedString("Your total score is", comment: "message"), totalScore),
            preferredStyle: .Alert)
        
        let saveScoreAction = UIAlertAction(title: NSLocalizedString("Save Score", comment: "save score"), style: .Default) { [weak self] (_) in
            let nameTextField = alertController.textFields![0] as UITextField
            guard let name = nameTextField.text else { return }
            self?.savePlayerScore(name, score: self!.totalScore)
            self?.resetGame()
            self?.setupNewGame()
            self!.totalScore = 0;
            
        }
        saveScoreAction.enabled = false
        alertController.addAction(saveScoreAction)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = NSLocalizedString("Your name", comment: "your name")
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification,
                object: textField,
            queue: NSOperationQueue.mainQueue()) { (notification) in
                saveScoreAction.enabled = textField.text != ""
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .Cancel) { [weak self] (action) in
            self?.resetGame()
            self?.setupNewGame()
            self!.totalScore = 0;
        }
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true) { }
    }
    
    /**
     savePlayerScore
     
     - parameter name:  name description
     - parameter score: score description
     */
    func savePlayerScore(name: String, score: intmax_t ) {
        
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Score",
                                                        inManagedObjectContext:managedContext)
        
        let val = NSManagedObject(entity: entity!,
                                  insertIntoManagedObjectContext: managedContext)
        
        val.setValue(name, forKey: "name")
        val.setValue(score, forKey: "score")
        
        do {
            try managedContext.save()
            //5
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
}

