//
//  QueueTableViewController.swift
//  learnAddrBook
//
//  Created by Stanley Chiang on 10/4/14.
//  Copyright (c) 2014 Stanley Chiang. All rights reserved.
//

import UIKit
import AddressBookUI
import CoreData

class QueueTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, ABPeoplePickerNavigationControllerDelegate, NSFetchedResultsControllerDelegate, UITextFieldDelegate {

	var contact: ABMultiValueRef!
	var phone: ABMultiValueRef!
	let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext!
	var fetchedResultsController:NSFetchedResultsController = NSFetchedResultsController()
	var person: Contacts!
	var simpleEdit: Bool = false
	var actionRow: NSIndexPath!
	var action:Bool = false
	@IBOutlet weak var textField: UITextField!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		textField.delegate = self
		fetchedResultsController = getFetchResultsController()
		fetchedResultsController.delegate = self
		fetchedResultsController.performFetch(nil)
    }
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		super.touchesBegan(touches, withEvent: event)
		let touch = event.allTouches()?.anyObject() as UITouch
		self.tableView.endEditing(true)

	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showAddManual" {
			
			println("showAddmanual")
			let destVC: ManualViewController = segue.destinationViewController as ManualViewController
			destVC.rstring = textField.text
			destVC.isNew = true//case 1
			destVC.isEdit = false
		} else if segue.identifier == "showEdit" {
			println("showedit")
			let destVC: ManualViewController = segue.destinationViewController as ManualViewController
			destVC.isNew = false
			let indexPath = tableView.indexPathForSelectedRow()
			if indexPath? == nil {
				if action {
					if simpleEdit {
						println("case4--pass cell & simple edit true")
						let cell = fetchedResultsController.objectAtIndexPath(actionRow) as Contacts
						destVC.contact = cell
						destVC.isEdit = true//case4
						simpleEdit = false
					}
				} else {
					println("case2--directly send person--no cell")
					destVC.contact = person//case2
					destVC.isEdit = false
				}
			} else {
				let cell = fetchedResultsController.objectAtIndexPath(indexPath!) as Contacts
				println("case3--send in a cell")
				destVC.contact = cell//case3
				destVC.isEdit = false
				//if everything else is false then case5
			}
		} else if segue.identifier == "callNow" {
			let CallVC: CallViewController = segue.destinationViewController as CallViewController
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
	
	@IBAction func addManuallyPressed(sender: UIButton) {
	}
    // MARK: - Table view data source
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		let numberOfSections = fetchedResultsController.sections?.count
		return numberOfSections!
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let numberOfRowsInSection = fetchedResultsController.sections![section].numberOfObjects
		return numberOfRowsInSection!
	}

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let theContact = fetchedResultsController.objectAtIndexPath(indexPath) as Contacts
		var cell: ContactCell = tableView.dequeueReusableCellWithIdentifier("listCell") as ContactCell
		cell.nameLabel.text = theContact.name
		cell.memoLabel.text = theContact.memo
		return cell
    }

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
		let editAction = UITableViewRowAction(style: .Normal, title: "edit", handler: {
			(action, indexPath) -> Void in
			self.simpleEdit = true
			self.action = true
			self.actionRow = indexPath
			self.performSegueWithIdentifier("showEdit", sender: self)
			self.action = false
			}
		)
		editAction.backgroundColor = UIColor.greenColor()
		
		let deleteAction = UITableViewRowAction(style: .Normal, title: "delete", handler: {
			(action, indexPath) -> Void in
			self.tableView(self.tableView, commitEditingStyle: .Delete, forRowAtIndexPath: indexPath)
			}
		)
		deleteAction.backgroundColor = UIColor.redColor()
		
		let moreAction = UITableViewRowAction(style: .Normal, title: "more", handler: {
			(action, indexPath) -> Void in
			let actionSheetController: UIAlertController = UIAlertController(title: "More", message: "Extra Options--Now half off!", preferredStyle: .ActionSheet)
			let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
				//dismiss action sheet
				//doing nothing also makes it dismiss
			}
			actionSheetController.addAction(cancelAction)
			let blue: UIAlertAction = UIAlertAction(title: "Turn it blue", style: .Default) { action -> Void in
				//Turn the cell blue
				var cell: ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as ContactCell
				cell.backgroundColor = UIColor.blueColor()
			}
			actionSheetController.addAction(blue)
			let white: UIAlertAction = UIAlertAction(title: "Turn it white", style: .Default) { action -> Void in
				//Turn the cell white
				var cell: ContactCell = self.tableView.cellForRowAtIndexPath(indexPath) as ContactCell
				cell.backgroundColor = UIColor.whiteColor()
			}
			actionSheetController.addAction(white)
//			//We need to provide a popover sourceView when using it on iPad
//			actionSheetController.popoverPresentationController?.sourceView = tableView as UITableView;
			
			//Present the AlertController
			self.presentViewController(actionSheetController, animated: true, completion: nil)
		})
		moreAction.backgroundColor = UIColor.grayColor()
		//buttons get displayed in backwards order in app
		return [deleteAction, moreAction, editAction]
		
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
			let managedObject: NSManagedObject = fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
			managedObjectContext.deleteObject(managedObject)
			(UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
		}
	}
	
	@IBAction func call(sender: UIBarButtonItem) {
		performSegueWithIdentifier("callNow", sender: self)
	}

	@IBAction func addToQueuePressed(sender: UIBarButtonItem) {
		let picker = ABPeoplePickerNavigationController()
		picker.peoplePickerDelegate = self
		presentViewController(picker, animated: true, completion: nil)
	}

	func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, didSelectPerson person: ABRecordRef!) {
		contact = ABRecordCopyCompositeName(person).takeRetainedValue()
		var phones: ABMultiValueRef = ABRecordCopyValue(person, kABPersonPhoneProperty).takeRetainedValue()

		phone = ABMultiValueCopyValueAtIndex(phones, 0 as CFIndex).takeRetainedValue()
		
		let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
		let entityDescription = NSEntityDescription.entityForName("Contacts", inManagedObjectContext: managedObjectContext)
		var thePerson = Contacts(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext) as Contacts
		thePerson.name = contact as String
		thePerson.phone = phone as? String
		self.person = thePerson
		performSegueWithIdentifier("showEdit", sender: self)
	}
	
	func peoplePickerNavigationController(peoplePicker: ABPeoplePickerNavigationController!, shouldContinueAfterSelectingPerson person: ABRecordRef!) -> Bool {
		peoplePickerNavigationController(peoplePicker, didSelectPerson: person)
		peoplePicker.dismissViewControllerAnimated(true, completion: nil)
		
		return false;
	}
	
	func peoplePickerNavigationControllerDidCancel(peoplePicker: ABPeoplePickerNavigationController!) {
		peoplePicker.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func controllerDidChangeContent(controller: NSFetchedResultsController) {
		tableView.reloadData()
	}

	func contactFetchRequest() -> NSFetchRequest {
		let fetchRequest = NSFetchRequest(entityName: "Contacts")
		let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
		fetchRequest.sortDescriptors = [sortDescriptor]
		fetchRequest.predicate = NSPredicate(format: "hasCalled = false")
		return fetchRequest
	}

	
	func getFetchResultsController() -> NSFetchedResultsController {
		fetchedResultsController = NSFetchedResultsController(fetchRequest: contactFetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		return fetchedResultsController
	}
	
}
