//
//  MasterViewController.swift
//  NoteIOSApp
//
//  Created by Hosung, Lee on 2016. 12. 5..
//  Copyright © 2016년 hosung. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    public static let BLANK_NOTE:String = "(New Note)"

    public static var arrNoteList : [NoteInfo]? = NoteListDB.getInstance().getList()
    public static var currentIndex:Int = 0
    
    public var detailViewController: DetailViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let edditButton = self.editButtonItem
        self.navigationItem.leftBarButtonItem = edditButton

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        if MasterViewController.arrNoteList?.count == 0 {
            insertNewObject(self)
        }
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        if self.detailViewController != nil && detailViewController?.txtNote?.isEditable == false {
            return
        }
        
        if MasterViewController.arrNoteList?.count == 0
            || MasterViewController.arrNoteList?[0].getNote() != MasterViewController.BLANK_NOTE {
            let noteinfo = NoteInfo();
            noteinfo.setNote(note: MasterViewController.BLANK_NOTE)
            MasterViewController.arrNoteList?.insert(noteinfo, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        MasterViewController.currentIndex = 0
        self.performSegue(withIdentifier: "showDetail", sender: self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                MasterViewController.currentIndex = indexPath.row
            }
            let noteinfo = MasterViewController.arrNoteList?[MasterViewController.currentIndex]
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

            self.detailViewController = controller
            self.detailViewController?.txtNote?.isEditable = true
                
            controller.masterView = self
            controller.detailItem = noteinfo
            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MasterViewController.arrNoteList!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteTableViewCell", for: indexPath) as! NoteTableViewCell
        cell.lbNote.text = MasterViewController.arrNoteList?[indexPath.row].getNote()
        
        let lbLocation : String = (MasterViewController.arrNoteList?[indexPath.row].getAddress())!
        if lbLocation.characters.count > 40 {
            let index = lbLocation.index(lbLocation.startIndex, offsetBy: 40)
            cell.lbLocation.text = lbLocation.substring(to: index) + ".."
        } else {
            cell.lbLocation.text = lbLocation
        }
        
        if MasterViewController.arrNoteList?[indexPath.row].getPhotofile() != "" {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let file_name = (MasterViewController.arrNoteList?[indexPath.row].getPhotofile())!
            let imageURL = URL(fileURLWithPath: "\(paths[0])/\(file_name)")
            //print ("Detail imageURL: \(imageURL.path)");
            if imageURL.isFileURL {
                cell.ivThumbnail.image = UIImage(contentsOfFile: imageURL.path)
            }
        }
        return cell
    }

//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let noteinfo = (MasterViewController.arrNoteList?[indexPath.row])!
            if noteinfo.getNoteno() > 0 {
                let isDelete = NoteListDB.getInstance().deleteNoteInfo(noteinfo)
                if !isDelete {
                    print("Fail to delete db")
                } else {
                    MasterViewController.arrNoteList?.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                if MasterViewController.arrNoteList?[indexPath.row] != nil {
                    MasterViewController.arrNoteList?.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    public static func saveTODB(noteinfo : NoteInfo){
        if MasterViewController.currentIndex < -1 {
            return
        }
        
        if (MasterViewController.arrNoteList?[currentIndex].getNoteno())! > 0 {
            let isUpdate = NoteListDB.getInstance().updateNoteInfo(noteinfo)
            if !isUpdate {
                print("Fail to update db")
            }
        } else {
            let isInsert = NoteListDB.getInstance().insertNoteInfo(noteinfo)
            if !isInsert {
                print("Fail to insert db")
            }
            else {
                let noteno =  NoteListDB.getInstance().getNoteno()
                if noteno > 0 {
                    MasterViewController.arrNoteList?[currentIndex].setNoteno(noteno: noteno)
                }
            }
        }
    }
}

