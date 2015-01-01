//
//  LoadingView.swift
//  MHacks
//
//  Created by Russell Ladd on 12/31/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        
        activityIndicatorView = UIActivityIndicatorView()
        
        errorLabel = UILabel()
        
        super.init(frame: frame)
        
        activityIndicatorView.activityIndicatorViewStyle = .Gray
        
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        errorLabel.text = NSLocalizedString("Error", comment: "Error label")
        errorLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 24.0)
        errorLabel.textColor = UIColor(white: 0.5, alpha: 1.0)
        
        addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: errorLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0.0))
        
        addSubview(activityIndicatorView)
        addSubview(errorLabel)
    }

    required init(coder aDecoder: NSCoder) {
        assertionFailure("Must be instantiated programmatically")
    }
    
    // MARK: State
    
    enum State {
        case Content
        case Loading
        case Error
    }
    
    var state: State = .Content {
        didSet {
            updateViewsHidden()
        }
    }
    
    // MARK: Views
    
    var contentView: UIView? {
        didSet {
            
            contentViewConstraints = nil
            oldValue?.removeFromSuperview()
            
            if let contentView = contentView {
                addSubview(contentView)
                setNeedsUpdateConstraints()
            }
        }
    }
    
    let activityIndicatorView: UIActivityIndicatorView
    
    let errorLabel: UILabel
    
    private func updateViewsHidden() {
        
        contentView?.hidden = (state != .Content)
        
        (state == .Loading) ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
        
        errorLabel.hidden = (state != .Error)
    }
    
    // MARK: Constraints
    
    var contentViewConstraints: [NSLayoutConstraint]?
    
    override func updateConstraints() {
        
        if contentViewConstraints == nil && contentView != nil {
            
            let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[content]|", options: nil, metrics: nil, views: ["activity": contentView!]) as [NSLayoutConstraint]
            let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[content]|", options: nil, metrics: nil, views: ["activity": contentView!]) as [NSLayoutConstraint]
            
            let constraints = horizontalConstraints + verticalConstraints
            
            contentViewConstraints = constraints
            
            addConstraints(constraints)
        }
        
        super.updateConstraints()
    }
}
