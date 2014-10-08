//
//  CallViewController.swift
//  learnAddrBook
//
//  Created by Stanley Chiang on 10/7/14.
//  Copyright (c) 2014 Stanley Chiang. All rights reserved.
//

import UIKit
import CoreData

class CallViewController: UIViewController, NSFetchedResultsControllerDelegate {
	
	@IBOutlet weak var numberField: UITextField!
	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func dialPressed(sender: UIButton) {
		let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
		
		let entityDescription = NSEntityDescription.entityForName("Contacts", inManagedObjectContext: managedObjectContext!)
		let contact = Contacts(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
		
		contact.name = numberField.text
		appDelegate.saveContext()
		
		UIApplication.sharedApplication().openURL(NSURL(string: "tel://3143230873"))
	}
}