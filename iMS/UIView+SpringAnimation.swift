//
//  UIView+SpringAnimation.swift
//  iMS
//
//  Created by Migration to Swift 6
//  用於替代 Spring 套件的原生動畫功能
//

import UIKit

// MARK: - Spring Animation Extension
extension UIView {
    
    /// 執行彈性動畫
    /// - Parameters:
    ///   - animation: 動畫名稱（"pop", "fadeIn", "swing" 等）
    ///   - duration: 動畫持續時間
    ///   - damping: 阻尼比例（0-1）
    ///   - velocity: 初始速度
    ///   - scaleX: X軸縮放
    ///   - scaleY: Y軸縮放
    ///   - completion: 完成回調
    func performSpringAnimation(
        animation: String,
        duration: TimeInterval = 0.7,
        damping: CGFloat = 0.7,
        velocity: CGFloat = 0.7,
        scaleX: CGFloat = 1.0,
        scaleY: CGFloat = 1.0,
        completion: (@Sendable (Bool) -> Void)? = nil
    ) {
        switch animation {
        case "pop":
            animatePop(duration: duration, damping: damping, velocity: velocity, scaleX: scaleX, scaleY: scaleY, completion: completion)
        case "fadeIn":
            animateFadeIn(duration: duration, completion: completion)
        case "swing":
            animateSwing(duration: duration, scaleX: scaleX, scaleY: scaleY, completion: completion)
        default:
            break
        }
    }
    
    // MARK: - Pop Animation
    private func animatePop(duration: TimeInterval, damping: CGFloat, velocity: CGFloat, scaleX: CGFloat, scaleY: CGFloat, completion: (@Sendable (Bool) -> Void)?) {
        // 移除所有現有動畫，防止動畫累積
        self.layer.removeAllAnimations()
        
        // 確保從原始狀態開始
        self.transform = .identity
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: [.curveEaseInOut],
            animations: {
                self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
            },
            completion: { finished in
                UIView.animate(withDuration: duration * 0.5) {
                    self.transform = .identity
                }
                completion?(finished)
            }
        )
    }
    
    // MARK: - Fade In Animation
    private func animateFadeIn(duration: TimeInterval, completion: (@Sendable (Bool) -> Void)?) {
        // 移除現有動畫
        self.layer.removeAllAnimations()
        
        self.alpha = 0
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                self.alpha = 1.0
            },
            completion: completion
        )
    }
    
    // MARK: - Swing Animation
    private func animateSwing(duration: TimeInterval, scaleX: CGFloat, scaleY: CGFloat, completion: (@Sendable (Bool) -> Void)?) {
        // 移除所有現有動畫
        self.layer.removeAllAnimations()
        
        // 確保從原始狀態開始
        self.transform = .identity
        
        UIView.animateKeyframes(
            withDuration: duration,
            delay: 0,
            options: [],
            animations: {
                // 第一階段：向右旋轉並放大
                UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25) {
                    self.transform = CGAffineTransform(scaleX: scaleX * 0.8, y: scaleY * 0.8)
                        .rotated(by: .pi / 12)
                }
                
                // 第二階段：向左旋轉
                UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                    self.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
                        .rotated(by: -.pi / 12)
                }
                
                // 第三階段：再次向右旋轉
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                    self.transform = CGAffineTransform(scaleX: scaleX * 0.9, y: scaleY * 0.9)
                        .rotated(by: .pi / 16)
                }
                
                // 第四階段：回到原位
                UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                    self.transform = .identity
                }
            },
            completion: completion
        )
    }
}

// MARK: - UIButton Extension
extension UIButton {
    /// 便利方法：設定標題並保持狀態
    func setTitleForAllStates(_ title: String?) {
        setTitle(title, for: .normal)
        setTitle(title, for: .highlighted)
        setTitle(title, for: .selected)
    }
}

