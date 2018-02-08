//
//  KeyboardAlignmentHandler.swift
//  MandelPlay-iOS
//
//  Created by Patrik Sjöberg on 2017-10-18.
//  Copyright © 2017 Com Hem AB. All rights reserved.
//

import UIKit

/**
 A class that can be dropped in to InterfaceBuilder to handle keyboard animations
 
 Drop a view (keyboard animation wrapper) into your viewcontrollers view and constraint it to it's superviews edges.
 Drop an Object reference and set it's class to KeyboardAlignmentHandler
 Bind the keyboard animation wrapper view to KeyboardAlignmentHandler's view
 Bind the keyboard animation wrapper views bottom constraint to the KeyboardAlignmentHandler's constraints collection
 */
class KeyboardAlignmentHandler: NSObject {
    /// The view that will be pushed up by the keyboard
    @IBOutlet weak var view: UIView? = nil
    /// The bottom constraint for the view
    @IBOutlet var constraints: [NSLayoutConstraint] = []
    
    
    
    var notificationObservers: [NSObjectProtocol] = []
    
    var notificationCenter: NotificationCenter {
        return NotificationCenter.default
    }
    
    override init() {
        super.init()
        
        notificationObservers = [
            notificationCenter.addObserver(forName: .UIKeyboardWillChangeFrame, object: nil, queue: nil, using: keyboardFrameDidChange)
        ]
    }
    
    convenience init(view: UIView, constraints: [NSLayoutConstraint]) {
        self.init()
        self.constraints = constraints
        self.view = view
    }
    
    func keyboardFrameDidChange(_ notification: Notification) {
        guard
            let view = view,
            let superview = view.superview,
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect
            else { return }
        
        let targetRect = view.convert(keyboardFrame, from: nil)
        let calculatedHeight = targetRect.intersection(superview.bounds).height
        for constraint in constraints {
            if constraint.firstItem === view {
                constraint.constant = -calculatedHeight
            }
            if constraint.secondItem === view {
                constraint.constant = calculatedHeight
            }
        }
        
        let animated = view.window != nil
        
        if animated, let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            view.setNeedsLayout()
            UIView.animate(withDuration: duration, animations: {
                view.superview?.layoutIfNeeded()
            })
        }
    }
}
