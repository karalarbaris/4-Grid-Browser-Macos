//
//  ViewController.swift
//  4-Grid Browser Macos
//
//  Created by Baris Karalar on 27.12.2021.
//

import Cocoa
import WebKit

class ViewController: NSViewController {
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1: Create the stack view and add it to our view
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
        
        // 2: Create Auto Layout constraints that pin the stack view to the edges of its container
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // 3: Create an initial column that contains a single web view
        let column = NSStackView(views: [makeWebView()])
        
        // 4: Add this column to the rows stack view
        rows.addArrangedSubview(column)
        
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func urlEntered(_ sender: NSTextField) {
        
        // check if there is a web view that is selected
        guard let selected = selectedWebView else { return }
        
        // try to convert text entered into a URL
        if let url = URL(string: sender.stringValue) {
            //load the URL
            selected.load(URLRequest(url: url))
        }
        
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        
        // check if there is a web view that is selected
        guard let selected = selectedWebView else { return }
        
        if sender.selectedSegment == 0 {
            //back tapped
            selected.goBack()
        } else {
            selected.goForward()
        }

    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            // add row
            
            // count the columns
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            // make a new arr of web views with correct no of cols
            let viewArray = (0 ..< columnCount).map { _ in
                makeWebView()
            }
            
            // create a stack view with web view array
            let row = NSStackView(views: viewArray)
            
            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
        } else {
            // delete row
            
            // check if we have at least two rows
            guard rows.arrangedSubviews.count > 1 else { return }
            
            // get the last row
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            
            // loop through each web view in the row, remove it
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
            }
            
            // remove the stack view row
            rows.removeArrangedSubview(rowToRemove)
            
        }
        
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 {
            // add column
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        } else {
            // delete column
            
            // get first row
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else { return }
            
            // make sure it has at least two columns
            guard firstRow.arrangedSubviews.count > 1 else { return }
            
            for case let row as NSStackView in rows.arrangedSubviews {
                if let last = row.arrangedSubviews.last {
                    row.removeArrangedSubview(last)
                    last.removeFromSuperview()
                }
                
            }
        }
    }
    
    func makeWebView() -> NSView {
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true
        webView.load(URLRequest(url: URL(string: "https://www.apple.com/")!))
        
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        if selectedWebView == nil {
            select(webView: webView)
        }
        
        return webView
    }
    
    func select(webView: WKWebView) {
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 4
        selectedWebView.layer?.borderColor = NSColor.blue.cgColor
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        // get the web view that triggered this method
        guard let newSelectedWebView = recognizer.view as? WKWebView else { return }
        
        // deselect the currently selected webview if there is one
        if let selected = selectedWebView  {
            selected.layer?.borderWidth = 0
        }
        
        // select the new one
        select(webView: newSelectedWebView)
        
    }
    
}

extension ViewController: NSGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        if gestureRecognizer.view == selectedWebView {
            return false
        } else {
            return true
        }
    }
    
}

extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        guard webView == selectedWebView else { return }
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.addressEntry.stringValue = webView.url?.absoluteString ?? ""
        }
    }
}
