//
//  WindowController.swift
//  4-Grid Browser Macos
//
//  Created by Baris Karalar on 27.12.2021.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet var addressEntry: NSTextField!
    
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
