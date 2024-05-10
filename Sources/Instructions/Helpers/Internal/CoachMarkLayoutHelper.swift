// Copyright (c) 2016-present Frédéric Maquin <fred@ephread.com> and contributors.
// Licensed under the terms of the MIT License.

import UIKit

class CoachMarkLayoutHelper {
    var layoutDirection: UIUserInterfaceLayoutDirection = .leftToRight

    // TODO: Improve the layout system. Make it smarter.
    func constraints(
        for coachMarkView: CoachMarkView,
        coachMark: CoachMark,
        parentView: UIView,
        layoutDirection: UIUserInterfaceLayoutDirection? = nil,
        passNumber: Int = 0
    ) -> [NSLayoutConstraint] {
        if coachMarkView.superview != parentView {
            print(ErrorMessage.Error.notAChild)
            return []
        }

        self.layoutDirection = UIView.userInterfaceLayoutDirection(
            for: parentView.semanticContentAttribute
        )

        let computedProperties: CoachMarkComputedProperties
        let offset: CGFloat

        if passNumber == 0 {
            computedProperties = CoachMarkComputedProperties(layoutDirection: self.layoutDirection,
                                                             horizontalAlignment: .centered,
                                                             verticalAlignment: .centered)
            offset = 0
        } else {
            computedProperties = computeProperties(for: coachMark, inParentView: parentView)
            offset = arrowOffset(for: coachMark, withProperties: computedProperties,
                                 inParentView: parentView)
        }

        if coachMark.arrowOrientation == .top || coachMark.arrowOrientation == .bottom {
            switch computedProperties.horizontalAlignment {
                case .leading:
                    coachMarkView.changeArrowPosition(to: .leading, offset: offset)
                    return leadingConstraints(for: coachMarkView, withCoachMark: coachMark,
                                              inParentView: parentView)
                case .centered, .none:
                    coachMarkView.changeArrowPosition(to: .center, offset: offset)
                    return middleConstraints(for: coachMarkView, withCoachMark: coachMark,
                                             inParentView: parentView)
                case .trailing:
                    coachMarkView.changeArrowPosition(to: .trailing, offset: offset)
                    return trailingConstraints(for: coachMarkView, withCoachMark: coachMark,
                                               inParentView: parentView)
            }
        } else {
            switch computedProperties.verticalAlignment {
                case .centered:
                    coachMarkView.changeArrowPosition(to: .verticalCenter, offset: offset)
                    
                    return verticalMiddleConstraints(for: coachMarkView, withCoachMark: coachMark, inParentView: parentView)
                case .none:
                    return []
            }
        }
    }
    
    func verticalMiddleConstraints(for coachMarkView: CoachMarkView, withCoachMark coachMark: CoachMark, inParentView parentView: UIView) -> [NSLayoutConstraint] {
        let maxWidth = min(coachMark.maxWidth, parentView.bounds.width - 2 * coachMark.horizontalMargin)
        
        let visualFormat = "H:[currentCoachMarkView(<=\(maxWidth)@1000)]"
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                                         options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                         metrics: nil,
                                                         views: ["currentCoachMarkView": coachMarkView])
        
        var offset: CGFloat = 0
        
        if let pointOfInterest = coachMark.pointOfInterest {
            offset = parentView.center.y - pointOfInterest.y
        }
        
        constraints.append(NSLayoutConstraint(
            item: coachMarkView, attribute: .centerY, relatedBy: .equal,
            toItem: parentView, attribute: .centerY,
            multiplier: 1, constant: -offset
        ))
        
        guard let arrowOrientation = coachMark.arrowOrientation else { return constraints }
        
        if arrowOrientation == .trailing {
            let pointOfInterestX = coachMark.pointOfInterest?.x ?? 0
            let cutoutPathWidth = coachMark.cutoutPath?.bounds.width ?? 0
            let trailingOffset = -(parentView.bounds.maxX - pointOfInterestX) - (cutoutPathWidth / 2)
            
            constraints.append(NSLayoutConstraint(
                item: coachMarkView, attribute: .trailing, relatedBy: .equal,
                toItem: parentView, attribute: .trailing,
                multiplier: 1, constant: trailingOffset))
            
            constraints.append(NSLayoutConstraint(
                item: coachMarkView, attribute: .leading, relatedBy: .greaterThanOrEqual,
                toItem: parentView, attribute: .leading,
                multiplier: 1, constant: 0))
        } else if arrowOrientation == .leading {
            let leadingOffset = coachMark.cutoutPath?.bounds.maxX ?? 0
            
            constraints.append(NSLayoutConstraint(
                item: coachMarkView, attribute: .leading, relatedBy: .equal,
                toItem: parentView, attribute: .leading,
                multiplier: 1, constant: leadingOffset))
            
            constraints.append(NSLayoutConstraint(
                item: coachMarkView, attribute: .trailing, relatedBy: .lessThanOrEqual,
                toItem: parentView, attribute: .trailing,
                multiplier: 1, constant: 0))
        }
        return constraints
    }

    private func leadingConstraints(for coachMarkView: CoachMarkView,
                                    withCoachMark coachMark: CoachMark,
                                    inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {

        if #available(iOS 11.0, *) {
            let layoutGuide = parentView.safeAreaLayoutGuide

            return [
                coachMarkView.leadingAnchor
                             .constraint(equalTo: layoutGuide.leadingAnchor,
                                         constant: coachMark.horizontalMargin),
                coachMarkView.widthAnchor
                             .constraint(lessThanOrEqualToConstant: coachMark.maxWidth),
                coachMarkView.trailingAnchor
                             .constraint(lessThanOrEqualTo: layoutGuide.trailingAnchor,
                                         constant: -coachMark.horizontalMargin)
            ]
        }

        let visualFormat = """
                           H:|-(==\(coachMark.horizontalMargin))-\
                           [currentCoachMarkView(<=\(coachMark.maxWidth))]-\
                           (>=\(coachMark.horizontalMargin))-|
                           """

        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["currentCoachMarkView": coachMarkView])
    }

    private func middleConstraints(for coachMarkView: CoachMarkView,
                                   withCoachMark coachMark: CoachMark,
                                   inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {
        let maxWidth = min(coachMark.maxWidth, (parentView.bounds.width - 2 *
                                                coachMark.horizontalMargin))

        let visualFormat = "H:[currentCoachMarkView(<=\(maxWidth)@1000)]"

        var constraints =
            NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                           options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                           metrics: nil,
                                           views: ["currentCoachMarkView": coachMarkView])

        var offset: CGFloat = 0

        if let pointOfInterest = coachMark.pointOfInterest {
            if layoutDirection == .leftToRight {
                offset = parentView.center.x - pointOfInterest.x
            } else {
                offset = pointOfInterest.x - parentView.center.x
            }
        }

        constraints.append(NSLayoutConstraint(
            item: coachMarkView, attribute: .centerX, relatedBy: .equal,
            toItem: parentView, attribute: .centerX,
            multiplier: 1, constant: -offset
        ))

        return constraints
    }

    private func trailingConstraints(for coachMarkView: CoachMarkView,
                                     withCoachMark coachMark: CoachMark,
                                     inParentView parentView: UIView
    ) -> [NSLayoutConstraint] {
        if #available(iOS 11.0, *) {
            let layoutGuide = parentView.safeAreaLayoutGuide

            return [
                coachMarkView.leadingAnchor
                    .constraint(greaterThanOrEqualTo: layoutGuide.leadingAnchor,
                                constant: coachMark.horizontalMargin),
                coachMarkView.widthAnchor
                    .constraint(lessThanOrEqualToConstant: coachMark.maxWidth),
                coachMarkView.trailingAnchor
                    .constraint(equalTo: layoutGuide.trailingAnchor,
                                constant: -coachMark.horizontalMargin)
            ]
        }

        let visualFormat = """
                           H:|-(>=\(coachMark.horizontalMargin))-\
                           [currentCoachMarkView(<=\(coachMark.maxWidth))]-\
                           (==\(coachMark.horizontalMargin))-|
                           """

        return NSLayoutConstraint.constraints(withVisualFormat: visualFormat,
                                              options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                              metrics: nil,
                                              views: ["currentCoachMarkView": coachMarkView])
    }

    /// Returns the arrow offset, based on the layout and the
    /// segment in which the coach mark will be.
    ///
    /// - Parameter coachMark: coachmark data.
    /// - Parameter properties: precomputed properties.
    /// - Parameter parentView: view showing the coachmarks.
    private func arrowOffset(for coachMark: CoachMark,
                             withProperties properties: CoachMarkComputedProperties,
                             inParentView parentView: UIView) -> CGFloat {
        var arrowOffset: CGFloat

        if coachMark.arrowOrientation! == .top || coachMark.arrowOrientation! == .bottom {
            switch properties.horizontalAlignment {
                case .centered, .none:
                    arrowOffset = middleArrowOffset(for: coachMark, withProperties: properties,
                                                    inParentView: parentView)
                case .leading:
                    arrowOffset = leadingArrowOffset(for: coachMark, withProperties: properties,
                                                     inParentView: parentView)
                case .trailing:
                    arrowOffset = trailingArrowOffset(for: coachMark, withProperties: properties,
                                                      inParentView: parentView)
            }
        } else {
            switch properties.verticalAlignment {
                case .centered, .none:
                    arrowOffset = verticalMiddleArrowOffset(for: coachMark, withProperties: properties, inParentView: parentView)
            }
        }

        return arrowOffset
    }

    private func leadingArrowOffset(for coachMark: CoachMark,
                                    withProperties properties: CoachMarkComputedProperties,
                                    inParentView parentView: UIView) -> CGFloat {
        guard let pointOfInterest = coachMark.pointOfInterest else {
            print(ErrorMessage.Info.nilPointOfInterestZeroOffset)
            return 0
        }

        let compensation = safeAreaCompensation(for: parentView, with: properties)

        if properties.layoutDirection == .leftToRight {
            return pointOfInterest.x - coachMark.horizontalMargin - compensation
        } else {
            return parentView.bounds.size.width - pointOfInterest.x -
                   coachMark.horizontalMargin - compensation
        }
    }

    private func middleArrowOffset(for coachMark: CoachMark,
                                   withProperties properties: CoachMarkComputedProperties,
                                   inParentView parentView: UIView) -> CGFloat {
        guard let pointOfInterest = coachMark.pointOfInterest else {
            print(ErrorMessage.Info.nilPointOfInterestZeroOffset)
            return 0
        }

        if properties.layoutDirection == .leftToRight {
            return parentView.center.x - pointOfInterest.x
        } else {
            return pointOfInterest.x - parentView.center.x
        }
    }

    private func trailingArrowOffset(for coachMark: CoachMark,
                                     withProperties properties: CoachMarkComputedProperties,
                                     inParentView parentView: UIView) -> CGFloat {
        guard let pointOfInterest = coachMark.pointOfInterest else {
            print(ErrorMessage.Info.nilPointOfInterestZeroOffset)
            return 0
        }

        let compensation = safeAreaCompensation(for: parentView, with: properties)

        if properties.layoutDirection == .leftToRight {
            return parentView.bounds.size.width - pointOfInterest.x -
                   coachMark.horizontalMargin - compensation
        } else {
            return pointOfInterest.x - coachMark.horizontalMargin - compensation
        }
    }
    
    private func verticalMiddleArrowOffset(for coachMark: CoachMark, withProperties properties: CoachMarkComputedProperties, inParentView parentView: UIView) -> CGFloat {
        guard let pointOfInterest = coachMark.pointOfInterest else {
            print(ErrorMessage.Info.nilPointOfInterestZeroOffset)
            return 0
        }
        return parentView.center.y - pointOfInterest.y
    }

    private func safeAreaCompensation(for parentView: UIView,
                                      with properties: CoachMarkComputedProperties) -> CGFloat {
        if #available(iOS 11.0, *) {
            switch (properties.horizontalAlignment, properties.layoutDirection) {

            case (.leading, .leftToRight), (.trailing, .rightToLeft):
                return parentView.safeAreaInsets.left
            case (.leading, .rightToLeft), (.trailing, .leftToRight):
                return parentView.safeAreaInsets.right
            default: break
            }
        }

        return 0
    }

    /// Compute the segment index (for now the screen is separated
    /// in two horizontal areas and depending in which one the coach
    /// mark stand, it will be laid out in a different way.
    ///
    /// - Parameters:
    ///   - coachMark: coachmark data.
    ///   - layoutDirection: the layout direction (LTR or RTL)
    ///   - frame: frame of the parent view
    ///
    /// - Returns: the alignment
    private func computeHorizontalAlignment(
        of coachMark: CoachMark,
        forLayoutDirection layoutDirection: UIUserInterfaceLayoutDirection,
        inFrame frame: CGRect
    ) -> CoachMarkHorizontalAlignment {
        if let pointOfInterest = coachMark.pointOfInterest, frame.size.width > 0 {
            let segmentIndex = Int(ceil(2 * pointOfInterest.x / frame.size.width))

            switch (segmentIndex, layoutDirection) {
            case (1, .leftToRight): return .leading
            case (2, .leftToRight): return .trailing
            case (1, .rightToLeft): return .trailing
            case (2, .rightToLeft): return .leading
            default: return .centered
            }
        } else {
            if coachMark.pointOfInterest == nil {
                print(ErrorMessage.Info.nilPointOfInterestCenterAlignment)
            } else {
                print(ErrorMessage.Warning.frameWithNoWidth)
            }

            return .centered
        }
    }
    
    private func computeVerticalAlingment(of coachMark: CoachMark, inFrame frame: CGRect) -> CoachMarkVerticalAlignment {
        if let pointOfInterest = coachMark.pointOfInterest, frame.size.height > 0 {
            return .centered
        } else {
            if coachMark.pointOfInterest == nil {
                print(ErrorMessage.Info.nilPointOfInterestCenterAlignment)
            } else {
                print(ErrorMessage.Warning.frameWithNoWidth)
            }
            return .centered
        }
    }

    private func computeProperties(for coachMark: CoachMark,
                                   inParentView parentView: UIView)
    -> CoachMarkComputedProperties {
        var horizontalAlignment: CoachMarkHorizontalAlignment?
        var verticalAlignment: CoachMarkVerticalAlignment?
        
        switch coachMark.arrowOrientation {
            case .top, .bottom:
                horizontalAlignment = computeHorizontalAlignment(of: coachMark,
                                                                 forLayoutDirection: layoutDirection,
                                                                 inFrame: parentView.frame)
            case .leading, .trailing:
                verticalAlignment = computeVerticalAlingment(of: coachMark,
                                                             inFrame: parentView.frame)
            case .none:
                break
        }

        return CoachMarkComputedProperties(
            layoutDirection: layoutDirection,
            horizontalAlignment: horizontalAlignment,
            verticalAlignment: verticalAlignment
        )
    }
}

struct CoachMarkComputedProperties {
    let layoutDirection: UIUserInterfaceLayoutDirection
    let horizontalAlignment: CoachMarkHorizontalAlignment?
    let verticalAlignment: CoachMarkVerticalAlignment?
}

enum CoachMarkHorizontalAlignment {
    case leading, centered, trailing
}

enum CoachMarkVerticalAlignment {
    case centered
}
