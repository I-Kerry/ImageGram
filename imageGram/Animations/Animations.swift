
import UIKit

final class ColorControls {
    
    var animationLayers: Set<CALayer> = []
        
    func makeUploadingAnimation(view: UIView) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = view.layer.cornerRadius
        gradient.masksToBounds = true
        animationLayers.insert(gradient)
        
        return gradient
    }
    
    func startAnimation(on gradient: CAGradientLayer) {
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.0, 1]
        gradient.add(gradientChangeAnimation, forKey: "locationsChange")
    }
    
    func stopAnimations() {
        for animationLayer in animationLayers {
            animationLayer.removeFromSuperlayer()
        }
        animationLayers.removeAll()
    }
}
