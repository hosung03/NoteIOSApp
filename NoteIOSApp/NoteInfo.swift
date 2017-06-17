//
//  NoteInfo.swift
//  NoteIOSApp
//
//  Created by Hosung, Lee on 2016. 12. 10..
//  Copyright © 2016년 hosung. All rights reserved.
//

import UIKit

class NoteInfo: NSObject {
    
    private var noteno : Int
    private var note : String
    private var photofile : String
    private var latitude : Double
    private var longitude : Double
    private var address : String
    
    public func getNoteno() -> Int {
        return self.noteno
    }
    
    public func setNoteno(noteno : Int) {
        self.noteno = noteno
    }
    
    public func getNote() -> String {
        return note
    }
    
    public func setNote(note : String) {
        self.note = note
    }
    
    public func getPhotofile() -> String {
        return self.photofile
    }
    
    public func setPhotofile(photofile : String) {
        self.photofile = photofile
    }
    
    public func getLatitude() -> Double {
        return self.latitude
    }
    
    public func setLatitude(latitude : Double) {
        self.latitude = latitude
    }
    
    public func getLongitude() -> Double {
        return self.longitude
    }
    
    public func setLongitude(longitude : Double) {
        self.longitude = longitude
    }
    
    public func getAddress() -> String {
        return self.address
    }
    
    public func setAddress(address : String) {
        self.address = address
    }
    
    override init() {
        self.noteno = 0
        self.note = ""
        self.photofile = ""
        self.latitude = 0
        self.longitude = 0
        self.address = ""
    }
    
}
