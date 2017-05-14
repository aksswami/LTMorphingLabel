//
//  AKTimer.swift
//
//  Created by Amit kumar Swami on 09/01/17.
//  Copyright © 2017 lexrus.com. All rights reserved.
//

import Foundation
import UIKit

class AKTimer {
    
    typealias AKTimerTick = (UInt) -> ()
    typealias AKTimerCompletion = () -> ()
    
    var numberOfTicks: UInt = 0
    var totalDuration: TimeInterval = 0
    var tickBlock: ((UInt) -> ())?
    var completionBlock: (() -> ())?
    var absoluteTickTimings = [TimeInterval]()
    
    init(ticks tickCount: UInt, totalDuration duration: TimeInterval, controlPoint1 cp1: CGPoint, controlPoint2 cp2: CGPoint, onEachTickCompletion eachTickBlock: ((UInt) -> ())? = nil, onCompletion completion: ((() -> ()))? = nil) {
        self.numberOfTicks = tickCount
        self.totalDuration = duration
        self.tickBlock = eachTickBlock
        self.completionBlock = completion
        let timings = AKBezierTimings().timingsForTicks(tickCount: tickCount, cp1: cp1, cp2: cp2)
        self.absoluteTickTimings = Array(timings[0..<Int(self.numberOfTicks)])
        
    }
    
    class func accelerationTimerWithTicks(tickCount: UInt, totalDuration duration: TimeInterval, controlPoint1 cp1: CGPoint, controlPoint2 cp2: CGPoint, onEachTickCompletion eachTickBlock: ((UInt) -> ())? = nil, onCompletion completion: ((() -> ()))? = nil) -> AKTimer {
        return AKTimer(ticks: tickCount, totalDuration: duration, controlPoint1: cp1, controlPoint2: cp2, onEachTickCompletion: eachTickBlock, onCompletion: completion)
    }
    
    func run() {
        runTick(tickIndexNumber: 0)
    }
    
    func runTick(tickIndexNumber: UInt) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let tickIndex: UInt = tickIndexNumber
        
        let simulationCompleted = (tickIndex >= self.numberOfTicks)
        if simulationCompleted {
            completionBlock?()
            return
        } else {
            tickBlock?(tickIndex)
        }
        let nextTickTiming: Double = (tickIndex == numberOfTicks - 1 ? 1.0 : absoluteTickTimings[Int(tickIndex)])
        let currentTickTiming = (tickIndex == 0 ? 0.0 : absoluteTickTimings[Int(tickIndex - 1)])
        let currentTickDuration = nextTickTiming - currentTickTiming
        let nextTickDelay = totalDuration * currentTickDuration
        
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.asyncAfter(deadline: .now() + nextTickDelay) {
                self.runTick(tickIndexNumber: tickIndex + 1)
            }
        }
    }
}

func slopeFromT(t: CGFloat, A: CGFloat, B: CGFloat, C: CGFloat) -> CGFloat {
    let dtdx = 1.0/(3.0*A*t*t + 2.0*B*t + C)
    return dtdx
}

func xFromT(t: CGFloat, A: CGFloat, B: CGFloat, C: CGFloat, D: CGFloat) -> CGFloat {
    let x = A*(t*t*t) + B*(t*t) + C*t + D
    return x
}

func yFromT(t: CGFloat, E: CGFloat, F: CGFloat, G: CGFloat, H: CGFloat) -> CGFloat {
    let y = E*(t*t*t) + F*(t*t) + G*t + H
    return y
}

func cubicBezier(x: CGFloat, a: CGFloat, b: CGFloat, c: CGFloat, d: CGFloat) -> CGFloat {
    
    let y0a: CGFloat = 0.00 // initial y
    let x0a: CGFloat = 0.00 // initial x
    let y1a: CGFloat = b    // 1st influence y
    let x1a: CGFloat = a    // 1st influence x
    let y2a: CGFloat = d    // 2nd influence y
    let x2a: CGFloat = c    // 2nd influence x
    let y3a: CGFloat = 1.00 // final y
    let x3a: CGFloat = 1.00 // final x
    
    let A =   x3a - 3*x2a + 3*x1a - x0a
    let B = 3*x2a - 6*x1a + 3*x0a
    let C = 3*x1a - 3*x0a
    let D =   x0a
    
    let E =   y3a - 3*y2a + 3*y1a - y0a
    let F = 3*y2a - 6*y1a + 3*y0a
    let G = 3*y1a - 3*y0a
    let H =   y0a
    
    // Solve for t given x (using Newton-Raphelson), then solve for y given t.
    // Assume for the first guess that t = x.
    var currentt = x
    let nRefinementIterations = 5
    for _ in 0..<nRefinementIterations {
        let currentx = xFromT (t: currentt, A: A, B: B, C: C, D: D)
        let currentslope = slopeFromT (t: currentt, A: A, B: B, C: C)
        currentt -= (currentx - x)*(currentslope)
        //		currentt = constrain(currentt, 0,1)
    }
    
    let y = yFromT (t: currentt, E: E, F: F, G: G, H: H)
    return y
}



class AKBezierTimings {
    var absoluteDelays = [TimeInterval]()
    var bezierCubicPathFirst = CGPoint.zero
    var bezierCubicPathSecond = CGPoint.zero
    
    func timingsForTicks(tickCount: UInt, cp1: CGPoint, cp2: CGPoint) -> [TimeInterval] {
        let calculator = AKBezierTimings()
        calculator.bezierCubicPathFirst = cp1
        calculator.bezierCubicPathSecond = cp2
        return calculator.timingsForTicks(tickCount: tickCount)
    }
    
    func timingsForTicks(tickCount: UInt) -> [TimeInterval] {
        assert(!__CGPointEqualToPoint(self.bezierCubicPathFirst, self.bezierCubicPathSecond), "The control points must be different from one another.")
        var lastMultiples: UInt = 0
        var lastMilestoneTime: TimeInterval = 0.0
        let thisMilestoneTime: TimeInterval = 0.0
        var thisIntervalFromLast: TimeInterval = 0.0
        var x: Double = 0
        let step: Double = 0.001
        while x < (1.0 - step) {
            let y: CGFloat = cubicBezier(x: CGFloat(x), a: bezierCubicPathFirst.x, b: bezierCubicPathFirst.y, c: bezierCubicPathSecond.x, d: bezierCubicPathSecond.y)
            let milestonesPassed: UInt = UInt(y * CGFloat(tickCount))
            let crossedAMilestone = milestonesPassed > lastMultiples
            if crossedAMilestone {
                thisIntervalFromLast = x - lastMilestoneTime
                lastMilestoneTime = thisMilestoneTime
                self.absoluteDelays.append(thisIntervalFromLast)
            }
            lastMultiples = milestonesPassed
            x += step
        }
        
        while absoluteDelays.count < Int(tickCount) {
            self.absoluteDelays.append(absoluteDelays.last ?? 0)
        }
        
        return absoluteDelays
    }
}
