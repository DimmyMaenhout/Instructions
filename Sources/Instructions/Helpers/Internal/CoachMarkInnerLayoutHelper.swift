// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

class CoachMarkInnerLayoutHelper {
    func horizontalArrowConstraints(for coachMarkViews: CoachMarkViews,
                                    withPosition position: ArrowPosition,
                                    horizontalOffset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: coachMarkViews.arrowView, attribute: .centerX, relatedBy: .equal,
            toItem: coachMarkViews.bodyView, attribute: position.layoutAttribute,
            multiplier: 1, constant: adaptedOffset(for: position, offset: horizontalOffset)
        )
    }
    
    func verticalArrowConstraints(for coachMarkViews: CoachMarkViews,
                                  withPosition position: ArrowPosition,
                                  verticalOffset: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: coachMarkViews.arrowView, attribute: .centerY, relatedBy: .equal,
                                  toItem: coachMarkViews.bodyView, attribute: position.layoutAttribute,
                                  multiplier: 1, constant: adaptedOffset(for: position, offset: verticalOffset))
    }

    func verticalConstraints(for coachMarkViews: CoachMarkViews, in parentView: UIView,
                             withProperties properties: CoachMarkViewProperties)
    -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()

        let verticalArrowOffset = properties.verticalArrowOffset

        if properties.orientation == .top {
            constraints = topOrientationConstraints(for: coachMarkViews, in: parentView,
                                                    verticalArrowOffset: verticalArrowOffset)
        } else if properties.orientation == .bottom {
            constraints = bottomOrientationConstraints(for: coachMarkViews, in: parentView,
                                                       verticalArrowOffset: verticalArrowOffset)
        }

        return constraints
    }
    
    func horizontalConstraints(for coachMarkViews: CoachMarkViews, in parentView: UIView,
                               withProperties properties: CoachMarkViewProperties) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        
        let horizontalOffset = properties.verticalArrowOffset
        
        if properties.orientation == .leading {
            constraints = leadingOrientationConstraints(for: coachMarkViews, in: parentView,
                                                        verticalArrowOffset: horizontalOffset )
        } else if properties.orientation == .trailing {
            constraints = trailingOrientationConstraints(for: coachMarkViews, in: parentView, verticalArrowOffset: horizontalOffset)
        }
        
        return constraints
    }

    private func topOrientationConstraints(for coachMarkViews: CoachMarkViews,
                                           in parentView: UIView, verticalArrowOffset: CGFloat)
    -> [NSLayoutConstraint] {

        let offset = adaptedOffset(for: .top, offset: verticalArrowOffset)

        return [
            coachMarkViews.arrowView.bottomAnchor
                          .constraint(equalTo: coachMarkViews.bodyView.topAnchor,
                                      constant: offset),
            parentView.topAnchor.constraint(equalTo: coachMarkViews.arrowView.topAnchor),
            coachMarkViews.bodyView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
        ]
    }

    private func bottomOrientationConstraints(for coachMarkViews: CoachMarkViews,
                                              in parentView: UIView, verticalArrowOffset: CGFloat)
    -> [NSLayoutConstraint] {
            let offset = adaptedOffset(for: .bottom, offset: verticalArrowOffset)

            return [
                coachMarkViews.arrowView.topAnchor
                    .constraint(equalTo: coachMarkViews.bodyView.bottomAnchor,
                                constant: offset),
                parentView.bottomAnchor.constraint(equalTo: coachMarkViews.arrowView.bottomAnchor),
                coachMarkViews.bodyView.topAnchor.constraint(equalTo: parentView.topAnchor)
            ]
    }
    
    private func leadingOrientationConstraints(for coachMarkViews: CoachMarkViews, in parentView: UIView, verticalArrowOffset: CGFloat) -> [NSLayoutConstraint] {
        let offset = adaptedOffset(for: CoachMarkArrowOrientation.leading, offset: verticalArrowOffset)
        
        return [
            coachMarkViews.arrowView.trailingAnchor.constraint(equalTo: coachMarkViews.bodyView.leadingAnchor, constant: offset),
            coachMarkViews.bodyView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
        ]
    }
    
    private func trailingOrientationConstraints(for coachMarkViews: CoachMarkViews, in parentView: UIView, verticalArrowOffset: CGFloat) -> [NSLayoutConstraint] {
        let offset = adaptedOffset(for: CoachMarkArrowOrientation.leading, offset: verticalArrowOffset)
        
        return [
            coachMarkViews.arrowView.leadingAnchor.constraint(equalTo: coachMarkViews.bodyView.trailingAnchor, constant: offset),
            coachMarkViews.bodyView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor)
        ]
    }

    private func adaptedOffset(for arrowPosition: ArrowPosition, offset: CGFloat) -> CGFloat {
        switch arrowPosition {
        case .leading: return offset
        case .center: return -offset
        case .trailing: return -offset
        case .verticalCenter: return offset
        }
    }

    private func adaptedOffset(for arrowOrientation: CoachMarkArrowOrientation,
                               offset: CGFloat) -> CGFloat {
        switch arrowOrientation {
            case .top: return offset
            case .bottom: return -offset
            case .leading: return offset
            case .trailing: return -offset
        }
    }
}

typealias CoachMarkViews = (bodyView: UIView, arrowView: UIView)
typealias CoachMarkViewProperties = (orientation: CoachMarkArrowOrientation,
                                     verticalArrowOffset: CGFloat)
