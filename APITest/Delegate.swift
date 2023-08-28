//
//  Delegate.swift
//  APITest
//
//  Created by Krit Verma on 7/24/23.
//

import Foundation
import SwiftUI
import SpotifyWebAPI
import Cocoa
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    
var showing = true

  var newEntryPanel: FloatingPanel!
  @StateObject var vm = SpotifyDriver()

  func applicationDidFinishLaunching(_ aNotification: Notification) {
      SpotifyAPILogHandler.bootstrap()
      createFloatingPanel()

      // Center doesn't place it in the absolute center, see the documentation for more details
      newEntryPanel.center()

      // Shows the panel and makes it active
      newEntryPanel.orderFront(nil)
      newEntryPanel.makeKey()
      
      KeyboardShortcuts.onKeyUp(for: .showFloatingPanel, action: {
          print(self.showing)
          self.showorNah()
          print(self.showing)
        })
  }

    func showorNah() {
        if self.showing == true {
            newEntryPanel.close()
            self.showing = false
        }
        else {
            newEntryPanel.orderFront(nil)
            self.showing = true
        }
        
    }
  func applicationWillTerminate(_ aNotification: Notification) {
      // Insert code here to tear down your application
  }

  private func createFloatingPanel() {
      // Create the SwiftUI view that provides the window contents.
      // I've opted to ignore top safe area as well, since we're hiding the traffic icons
      let contentView = ControllerView().environmentObject(vm)
          .edgesIgnoringSafeArea(.top)

      // Create the window and set the content view.
      newEntryPanel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 512, height: 80), backing: .buffered, defer: false)

      newEntryPanel.title = "Floating Panel Title"
      newEntryPanel.contentView = NSHostingView(rootView: contentView)
  }
}

extension KeyboardShortcuts.Name {
  // **NOTE**: It is not recommended to set a default keyboard shortcut. Instead opt to show a setup on first app-launch to let the user define a shortcut
  static let showFloatingPanel = Self("showFloatingPanel", default: .init(.return, modifiers: [.command, .shift]))
}
