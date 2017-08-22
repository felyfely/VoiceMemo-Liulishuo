//
//  CustomizedViews.swift
//  VoiceMemo
//
//  Created by 付 旦 on 8/22/17.
//  Copyright © 2017 付 旦. All rights reserved.
//

import UIKit

protocol RecordingStateDelegate : NSObjectProtocol {
    func didStartRecording()
    func didEndRecording()
    func didCancellRecording()
}

class RecordButton : ButtonWithBorder {

    weak var delegate : RecordingStateDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = min(self.bounds.height,self.bounds.width) / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)}
        delegate?.didStartRecording()
        super.touchesBegan(touches, with: event)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {self.transform = CGAffineTransform.identity}
        delegate?.didEndRecording()
        super.touchesEnded(touches, with: event)
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        UIView.animate(withDuration: 0.15) {self.transform = CGAffineTransform.identity}
        delegate?.didCancellRecording()
        super.touchesCancelled(touches, with: event)
    }
    
}

class ButtonWithBorder : UIButton {
    
    @IBInspectable
    var borderUIColor : UIColor = UIColor.blue
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.borderColor = borderUIColor.cgColor
    }
    
    
    
}
