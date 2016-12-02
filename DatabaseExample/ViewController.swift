//
//  ViewController.swift
//  DatabaseExample
//
//  Created by Russell Gordon on 11/8/16.
//  Copyright © 2016 Russell Gordon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    // Will save path to database file
    var databasePath = NSString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Handle name text field, use callbacks for user input
        name.delegate = self
        // Identify the app's Documents directory and build a path to "contacts.db"
        let fileManager = FileManager.default
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = directoryPaths[0]
        databasePath = documentsDirectory.appending("contacts.db") as NSString
        
        // Initialize (create) the database if it doesn't already exist
        if !fileManager.fileExists(atPath: databasePath as String) {
            
            // Create the database
            if let contactDB = FMDatabase(path: databasePath as String) {
                
                // Try to open the empty database and create the table structure required
                if contactDB.open() {
                    
                    // Define the SQL statement to be run
                    let SQL = "CREATE TABLE IF NOT EXISTS CONTACTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, NAME TEXT, ADDRESS TEXT, PHONE TEXT)"
                    
                    // Attempt to run the SQL statement
                    if !contactDB.executeStatements(SQL) {
                        print("Error: \(contactDB.lastErrorMessage())")
                    }
                    
                    // Close the database connection
                    contactDB.close()
                    
                } else {
                    
                    // We couldn't open the database, so throw an error
                    print("Error: \(contactDB.lastErrorMessage())")
                    
                }
                
            }
            
        } else {
            print("Error: Could not create DB.")
        }
    }
    
    // MARK: Actions
    
    @IBAction func saveData(_ sender: Any) {
        
        // Establish path to database through FMDatabase wrapper
        if let contactDB = FMDatabase(path: databasePath as String) {
            
            // We know database should exist now (since viewDidLoad runs at startup)
            // Now, open the database and insert data from the view (the user interface)
            if contactDB.open() {
                
                // Get data from the form fields on the view (user interface)
                guard let nameValue : String = name.text else {
                    status.text = "Hey, we need a name here."
                    return
                }
                guard let addressValue : String = address.text else {
                    status.text = "Hey, we need an address!"
                    return
                }
                guard let phoneValue : String = phone.text else {
                    status.text = "Please provide a phone number."
                    return
                }
                
                // Create SQL statement to insert data
                let SQL = "INSERT INTO CONTACTS (name, address, phone) VALUES ('\(nameValue)', '\(addressValue)', '\(phoneValue)')"
                
                // Try to run the statement
                let result = contactDB.executeUpdate(SQL, withArgumentsIn: nil)
                
                // See what happened and react accordingly
                if !result {
                    status.text = "Failed to add contact"
                } else {
                    status.text = "Contact added"
                    
                    // Clear out the form fields
                    name.text = ""
                    address.text = ""
                    phone.text = ""
                }
                
            }
            
        } else {
            
            // We couldn't open the database, so throw an error
            print("Error: Could not save data to database.")
            
        }
        
    }
    
    @IBAction func lastResult(_ sender: AnyObject) {
    }
    
    @IBAction func nextResult(_ sender: AnyObject) {
    }
    
    @IBAction func findContact(_ sender: Any) {
        guard let searchString = search.text else {return}
        
        if searchString == "" {
            name.text = ""
            address.text = ""
            phone.text = ""
            forwardButton.isEnabled = false
            backButton.isEnabled = false
        } else {
            
            // Establish path to database through FMDatabase wrapper
            if let contactDB = FMDatabase(path: databasePath as String) {
                
                // We know database should exist now (since viewDidLoad runs at startup)
                // Now, open the database and insert data from the view (the user interface)
                if contactDB.open() {
                    
                    // Get form field value
                    guard let nameValue : String = name.text else {
                        status.text = "Please provide a name."
                        return
                    }
                    
                    // Create SQL statement to find data
                    let SQL = "SELECT address, phone FROM CONTACTS WHERE name = '\(nameValue)'"
                    
                    // Run query
                    do {
                        
                        // Try to run the query
                        let results : FMResultSet? = try contactDB.executeQuery(SQL, values: nil)
                        
                        // We know database should exist now (since viewDidLoad runs at startup)
                        // Now, open the database and select data using value given for name in the view (user interface)
                        if results?.next() == true {    // Something was found for this query
                            
                            guard let addressValue : String = results?.string(forColumn: "address") else {
                                print("Nil value returned from query for the address, that's odd.")
                                return
                            }
                            guard let phoneValue : String = results?.string(forColumn: "phone") else {
                                print("Nil value returned from query for the phone number, that's odd.")
                                return
                            }
                            
                            // Load the results in the view (user interface)
                            address.text = addressValue
                            phone.text = phoneValue
                            status.text = "Record found!"
                            
                        } else {
                            
                            // Nothing was found for this query
                            status.text = "Record not found"
                            address.text = ""
                            phone.text = ""
                            
                        }
                        
                        // Close the database
                        contactDB.close()
                        
                    } catch {
                        
                        // Query did not run, so report an error
                        print("Error: \(contactDB.lastErrorMessage())")
                    }
                    
                }
                
            } else {
                
                // Database could not be opened, report an error
                print("Error: Database could not be opened.")
                
            }
        }
    }
    
    //MARK: UITextFieldDelagate
    
    @IBAction func findOnParitalName(_ sender: UITextField) {
        findContact(self)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Name: \(name.text)")
    }
}

