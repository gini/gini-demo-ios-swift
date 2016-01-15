//
//  GINIDemoViewController.swift
//  gini-swift-demo-ios
//
//  Created by Gini on 05/01/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

// Import Gini Vision Library to use the photo module
// The Gini Vision Library is imported in the Bridging Header file

// Import Gini SDK to communicate with the Gini API
import Gini_iOS_SDK

class GINIDemoViewController: UIViewController, GiniVisionDelegate {

    private var userDefaults: NSUserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @IBAction
    func startGiniVisionModule(sender: AnyObject) {
        /**
        * If you'd like to configure the module check out the [documentation](http://developer.gini.net/ginivision-ios/guides/style-the-module.html) for more information.
        * There it will be described how to use the `GiniConfiguration` class.
        *
        * To keep this code clean and simple we'll go with the standard configuration.
        */
        GiniVision.setLogLevel(GINILogLevel.None)
        GiniVision.captureImageWithViewController(self, delegate: self)
    }
    
    func useCustomGiniConfiguration() {
        let configuration = GiniConfiguration()
        
        // Options
        configuration.launchDocumentType = .Default // Remember 'GINIDocumentTypeDefault' does NOT skip the choice screen.
        configuration.showHelp = false
        configuration.disableInteractiveSwipeGesture = false
        configuration.navigationShadowImage = nil
        configuration.navigationBackButtonImage = nil
        configuration.choiceHeadingTextSize = 34.0
        configuration.outlineWidth = 5.0
        configuration.helpButtonImage = nil
        configuration.helpCloseButtonPosition = .NavBarRight
        configuration.helpCloseButtonRemoveSpacing = false
        configuration.closeButtonImage = nil
        configuration.uploadActivityIndicatorPosition = .NavBarLeft
        configuration.customActivityIndicatorImage = nil
        
        // Colors
        configuration.navigationTintColor = UIColor(red: (28/255.0), green: (141/255.0), blue: (214/255.0), alpha: 1.0)
        configuration.navigationButtonsTintColor = nil
        configuration.lightFontColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 1.0)
        configuration.darkFontColor = UIColor(red: (76/255.0), green: (76/255.0), blue: (76/255.0), alpha: 1.0)
        configuration.actionFontColor = UIColor(red: (28/255.0), green: (141/255.0), blue: (214/255.0), alpha: 1.0)
        configuration.backgroundColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 1.0)
        configuration.outlineColor = UIColor(red: (0/255.0), green: (255/255.0), blue: (0/255.0), alpha: 1.0)
        configuration.helpViewBackgroundColor = UIColor(red: (255/255.0), green: (255/255.0), blue: (255/255.0), alpha: 1.0)
        configuration.uploadCancelButtonBackgroundColor = UIColor(red: (28/255.0), green: (141/255.0), blue: (214/255.0), alpha: 1.0)
        
        // Fonts
        configuration.navigationFont = UIFont(name: "HelveticaNeue-Light", size: 16.0)
        configuration.textFont = UIFont(name: "HelveticaNeue", size: 16.0)
        configuration.buttonFont = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        
        // Texts
        configuration.choiceTitle = "Foto-Überweisung"
        configuration.scannerTitle = "Foto-Überweisung"
        configuration.scannerTitleInvoice = "Foto-Überweisung"
        configuration.scannerTitleRemittance = "Foto-Überweisung"
        configuration.scannerTitleIntegratedRemittance = "Foto-Überweisung"
        configuration.helpTitle = "Hilfe"
        configuration.uploadTitle = "Foto-Überweisung"
        configuration.choiceHeadingText = "Welcher Dokument-Typ?"
        configuration.help1Text = "Foto wird automatisch ausgelöst sobald Dokument an Ecken ausgerichtet ist."
        configuration.help2Text = "Gerät parallel über das Dokument halten."
        configuration.help3Text = "Dokument auf dunklen Hintergrund platzieren."
        configuration.help4Text = "Dokument muss glatt sein, damit Text gut ausgelesen werden kann."
        configuration.uploadCancelButtonTitle = "Abbrechen"
        configuration.cameraAuthErrorTitle = "Kein Kamerazugriff erlaubt"
        configuration.cameraAuthErrorText = "Bitte aktivieren Sie unter Einstellungen > Datenschutz > Kamera die Zugriffsrechte für diese Anwendung."
        
        GiniVision.captureImageWithViewController(self, delegate: self, configuration: configuration)
    }

    // MARK: GiniVisionDelegate
    func didScan(document: UIImage!, documentType docType: GINIDocumentType, uploadDelegate delegate: GINIVisionUploadDelegate!) {
        // Rectified and processed image created by the Gini Vision Module
        
        // If set, save the processed image
        if (self.userDefaults!.boolForKey("storeRectifiedImageSetting")) {
            self.storeImage(document, condition: "processed")
        }
        
        /*********************************************
        * UPLOAD DOCUMENT WITH THE GINI SDK FOR IOS *
        *********************************************/
        
        delegate.didProgressWithMessage("Prepare document")
        
        // Get current Gini SDK instance to upload image and process exctraction
        let sdk = (UIApplication.sharedApplication().delegate as! GINIDemoAppDelegate).giniSDK
        
        // Create a document task manager to handle document tasks on the Gini API
        let manager = sdk?.documentTaskManager
        
        // Create a file name for the document
        let fileName = "your_filename";
        
        var giniDocument: GINIDocument?
        var documentId: String?
        var extractions: Dictionary<String, GINIExtraction>?
        
        sdk?.sessionManager.getSession().continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if (task.error != nil) {
                return sdk?.sessionManager.logIn()
            }
            return task.result
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            return manager?.createDocumentWithFilename(fileName, fromImage: document)
        }).continueWithSuccessBlock({ (task: BFTask!) -> AnyObject! in
            delegate.didProgressWithMessage("Analyse document")
            giniDocument = task.result as? GINIDocument
            documentId = giniDocument?.documentId
            print("documentId: \(documentId)")
            return giniDocument?.extractions
        }).continueWithBlock({ (task: BFTask!) -> AnyObject! in
            if (task.error != nil) {
                print("Error while handling documentation upload and extraction.")
                return nil
            }
            extractions = task.result as? Dictionary<String, GINIExtraction>
            // Make something with the extractions
            // In this demo we will simply show the results
            return nil
        }).continueWithExecutor(BFExecutor.mainThreadExecutor(), withBlock: { (task: BFTask!) -> AnyObject! in
            if (extractions != nil) {
                self.showDocumentDetailViewController(extractions!)
            }
            // Notify delegate that upload is finished, so Gini Vision UI gets dismissed
            delegate.didEndUpload()
            return nil
        })
    }
    
    func didScanOriginal(image: UIImage!) {
        // Original image taken by the Gini Vision Module
        
        // If set, save the original image
        if (self.userDefaults!.boolForKey("storeOriginalImageSetting")) {
            self.storeImage(image, condition: "original")
        }
    }
    
    func didFinishCapturing(success: Bool) {
        // Gini Vision Module UI was dismissed
    }
    
    func didCancelUpload() {
        // User wants to cancel the document upload
    }
    
    // MARK: Save images
    func storeImage(image: UIImage, condition: String) {
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy-HH-mm-ss"
        let dateString = dateFormatter.stringFromDate(date)
        let fileName = "\(dateString)_\(condition).jpg"
        self.storeImage(image, fileName: fileName, compression: Float(100))
    }
    
    func storeImage(image: UIImage, fileName: String, compression: Float) {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let filePath = paths[0].stringByAppendingString("/\(fileName)")
        let compressionStandardized = CGFloat(compression / Float(100))
        if let imageData = UIImageJPEGRepresentation(image, compressionStandardized) {
            if !imageData.writeToFile(filePath, atomically: true) {
                print("Error writing image data to disk. (\(fileName))")
            }
        } else {
            print("Error creating image data.")
        }
    }
    
    // MARK: Navigation
    func showDocumentDetailViewController(extractions: Dictionary<String, GINIExtraction>) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("documentDetailViewController") as! GINIDemoDocumentTableViewController
        vc.extractions = self.rawValuesFromGiniExtractions(extractions)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    // MARK: Helper method
    func rawValuesFromGiniExtractions(extractions: Dictionary<String, GINIExtraction>) -> [String:String] {
        var dict = Dictionary<String, String>()
        for (key, extraction) in extractions {
            dict[key] = extraction.value
        }
        return dict
    }
    
    // MARK: Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

