//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

let sharedInstance = NoteListDB()

class NoteListDB: NSObject {
    
    var db: FMDatabase? = nil

    class func getInstance() -> NoteListDB {
        if(sharedInstance.db == nil) {
            sharedInstance.db = FMDatabase(path: getPath("notelist.sqlite"))
        }
        return sharedInstance
    }
    
    class func getPath(_ fileName: String) -> String {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        print(fileURL.path)
        return fileURL.path
    }
    
    class func copyFile(_ fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
            } catch let nserror as NSError {
                error = nserror
            }
            
            let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
            } else {
                alert.title = "Successfully Copy"
                alert.message = "Your database copy successfully"
            }
            alert.delegate = nil
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
    }
    
    public func getList() -> [NoteInfo] {
        sharedInstance.db!.open()
        let resultSet: FMResultSet! = sharedInstance.db!.executeQuery("SELECT * FROM NoteInfo ORDER BY noteno DESC ", withArgumentsIn: nil)
        var list : [NoteInfo] = [NoteInfo]()
        if (resultSet != nil) {
            while resultSet.next() {
                let noteinfo : NoteInfo = NoteInfo()
                noteinfo.setNoteno(noteno: Int(resultSet.string(forColumn: "noteno"))!)
                noteinfo.setNote(note: resultSet.string(forColumn: "note"))
                noteinfo.setPhotofile(photofile: resultSet.string(forColumn: "photofile"))
                noteinfo.setLatitude(latitude: Double(resultSet.string(forColumn: "latitude"))!)
                noteinfo.setLongitude(longitude: Double(resultSet.string(forColumn: "longitude"))!)
                noteinfo.setAddress(address: resultSet.string(forColumn: "address"))
                list.append(noteinfo)
            }
        }
        sharedInstance.db!.close()
        return list
    }
    
    public func getNote(noteno : Int) -> NoteInfo? {
        sharedInstance.db!.open()
        var noteinfo : NoteInfo? = nil
        let resultSet: FMResultSet! = sharedInstance.db!.executeQuery("SELECT * FROM NoteInfo WHERE noteno=? ", withArgumentsIn: [noteno])
        if (resultSet != nil) {
            while resultSet.next() {
                noteinfo = NoteInfo()
                noteinfo?.setNoteno(noteno: Int(resultSet.string(forColumn: "noteno"))!)
                noteinfo?.setNote(note: resultSet.string(forColumn: "note"))
                noteinfo?.setPhotofile(photofile: resultSet.string(forColumn: "photofile"))
                noteinfo?.setLatitude(latitude: Double(resultSet.string(forColumn: "latitude"))!)
                noteinfo?.setLongitude(longitude: Double(resultSet.string(forColumn: "longitude"))!)
                noteinfo?.setAddress(address: resultSet.string(forColumn: "address"))
            }
        }
        sharedInstance.db!.close()
        return noteinfo
    }
    
    public func insertNoteInfo(_ noteinfo: NoteInfo) -> Bool {
        sharedInstance.db!.open()
        var isInserted = false
        isInserted = sharedInstance.db!.executeUpdate(
            "INSERT INTO NoteInfo(note, photofile, latitude, longitude, address) VALUES(?,?,?,?,?)",
            withArgumentsIn: [noteinfo.getNote(), noteinfo.getPhotofile(), noteinfo.getLatitude(), noteinfo.getLongitude(), noteinfo.getAddress()])
        if !isInserted {
            print("error \(sharedInstance.db!.lastErrorMessage()!)")
        }
        sharedInstance.db!.close()
        return isInserted
    }
   
    public func updateNoteInfo(_ noteinfo: NoteInfo) -> Bool {
        sharedInstance.db!.open()
        var isUpdated = false
            isUpdated = sharedInstance.db!.executeUpdate(
                "UPDATE NoteInfo SET note=?, photofile=?, latitude=?, longitude=?, address=? WHERE noteno=? ",
                withArgumentsIn: [noteinfo.getNote(), noteinfo.getPhotofile(), noteinfo.getLatitude(), noteinfo.getLongitude(), noteinfo.getAddress(), noteinfo.getNoteno()])
        if !isUpdated {
            print("error \(sharedInstance.db!.lastErrorMessage()!)")
        }
        sharedInstance.db!.close()
        return isUpdated
    }
    
    public func deleteNoteInfo(_ noteinfo: NoteInfo) -> Bool {
        sharedInstance.db!.open()
        let isDeleted = sharedInstance.db!.executeUpdate("DELETE FROM NoteInfo WHERE noteno=? ", withArgumentsIn: [noteinfo.getNoteno()])
        sharedInstance.db!.close()
        return isDeleted
    }
    
    public func getNoteno() -> Int {
        sharedInstance.db!.open()
        var noteno : Int = 0
        let resultSet: FMResultSet! = sharedInstance.db!.executeQuery("SELECT noteno FROM NoteInfo WHERE rowid = (SELECT max(rowid) FROM NoteInfo) ", withArgumentsIn: nil)
        if (resultSet != nil) {
            while resultSet.next() {
                noteno = Int(resultSet.string(forColumn: "noteno"))!
            }
        }
        sharedInstance.db!.close()
        return noteno
    }
    
}
