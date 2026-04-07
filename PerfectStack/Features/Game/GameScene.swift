import SpriteKit
import SwiftUI

@MainActor
final class GameScene: SKScene {
    private let theme: Theme
    private let reducedMotionEnabled: Bool
    private let worldNode = SKNode()
    private let cameraNode = SKCameraNode()
    private let blockHeight: CGFloat = 28
    private let blockGap: CGFloat = 9
    private let baseY: CGFloat = 144
    private let horizontalPadding: CGFloat = 56

    private var towerNodes: [SKShapeNode] = []
    private var movingBlock: SKShapeNode?

    init(theme: Theme, reducedMotionEnabled: Bool) {
        self.theme = theme
        self.reducedMotionEnabled = reducedMotionEnabled
        super.init(size: UIScreen.main.bounds.size)
        scaleMode = .resizeFill
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    var currentMovingBlockCenterX: CGFloat {
        movingBlock?.position.x ?? frame.midX
    }

    func bootstrap(initialWidth: CGFloat) {
        removeAllChildren()
        worldNode.removeAllChildren()
        towerNodes.removeAll()
        movingBlock = nil

        addChild(worldNode)
        addChild(cameraNode)
        camera = cameraNode
        cameraNode.position = CGPoint(x: frame.midX, y: frame.midY)

        let platform = SKShapeNode(
            rectOf: CGSize(width: 240, height: 24),
            cornerRadius: 12
        )
        platform.fillColor = UIColor.white.withAlphaComponent(0.08)
        platform.strokeColor = UIColor(theme.accent.opacity(0.2))
        platform.lineWidth = 1
        platform.position = CGPoint(x: frame.midX, y: baseY - 30)
        worldNode.addChild(platform)

        let foundation = makeBlock(width: initialWidth, color: UIColor(theme.towerFill), glow: 0)
        foundation.position = CGPoint(x: frame.midX, y: baseY)
        worldNode.addChild(foundation)
        towerNodes.append(foundation)
    }

    func spawnMovingBlock(width: CGFloat, level: Int, speedMultiplier: Double) {
        movingBlock?.removeFromParent()

        let y = baseY + CGFloat(level) * (blockHeight + blockGap)
        let block = makeBlock(width: width, color: UIColor(theme.accent), glow: reducedMotionEnabled ? 4 : 12)
        let leftBound = frame.minX + horizontalPadding + (width / 2)
        let rightBound = frame.maxX - horizontalPadding - (width / 2)
        let startsFromLeft = level % 2 == 0
        let startX = startsFromLeft ? leftBound : rightBound
        let destinationX = startsFromLeft ? rightBound : leftBound
        let duration = max(0.78, 1.7 / speedMultiplier)

        block.position = CGPoint(x: startX, y: y)
        block.alpha = 0
        block.run(.fadeIn(withDuration: 0.16))
        block.run(
            .repeatForever(
                .sequence([
                    .moveTo(x: destinationX, duration: duration),
                    .moveTo(x: startX, duration: duration)
                ])
            ),
            withKey: "glide"
        )

        worldNode.addChild(block)
        movingBlock = block
        updateCamera(forTopY: y)
    }

    func applyDrop(_ outcome: GameDropOutcome, completion: @escaping () -> Void) {
        guard let movingBlock else {
            completion()
            return
        }

        movingBlock.removeAction(forKey: "glide")

        let landingDuration = reducedMotionEnabled ? 0.08 : 0.14
        let resizeAction = SKAction.run { [weak self, weak movingBlock] in
            guard let self, let movingBlock else { return }
            self.updatePath(of: movingBlock, width: max(outcome.newWidth, 16))
        }
        let moveAction = SKAction.moveTo(x: outcome.newCenterX, duration: landingDuration)
        moveAction.timingMode = .easeOut

        if outcome.kind == .perfect, !reducedMotionEnabled {
            speed = 0.28
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in
                self?.speed = 1
            }
        }

        if outcome.trimmedWidth > 0.5, outcome.kind != .perfect {
            let overhang = makeBlock(width: outcome.trimmedWidth, color: UIColor(theme.accent).withAlphaComponent(0.8), glow: 4)
            let overhangX = outcome.newCenterX + outcome.overhangDirection * ((outcome.newWidth + outcome.trimmedWidth) / 2)
            overhang.position = CGPoint(x: overhangX, y: movingBlock.position.y)
            worldNode.addChild(overhang)

            let fall = SKAction.group([
                .moveBy(x: outcome.overhangDirection * 28, y: -190, duration: 0.6),
                .rotate(byAngle: outcome.overhangDirection * 0.2, duration: 0.6),
                .fadeOut(withDuration: 0.54)
            ])
            fall.timingMode = .easeIn
            overhang.run(.sequence([fall, .removeFromParent()]))
        }

        movingBlock.run(
            .sequence([
                .group([moveAction, resizeAction]),
                .run { [weak self] in
                    guard let self else { return }
                    movingBlock.fillColor = UIColor(theme.towerFill)
                    movingBlock.strokeColor = UIColor(theme.towerEdge)
                    movingBlock.glowWidth = 0
                    self.towerNodes.append(movingBlock)
                    if outcome.kind == .perfect {
                        self.pulseTower()
                    } else {
                        self.landSettle(on: movingBlock)
                    }
                    self.movingBlock = nil
                },
                .wait(forDuration: reducedMotionEnabled ? 0.03 : 0.08),
                .run(completion)
            ])
        )

        updateCamera(forTopY: movingBlock.position.y)
    }

    func animateFailure(completion: @escaping () -> Void) {
        guard let movingBlock else {
            completion()
            return
        }

        movingBlock.removeAction(forKey: "glide")
        let failAction = SKAction.group([
            .moveBy(x: 0, y: -240, duration: 0.5),
            .rotate(byAngle: 0.14, duration: 0.5),
            .fadeOut(withDuration: 0.44)
        ])
        failAction.timingMode = .easeIn

        movingBlock.run(
            .sequence([
                failAction,
                .removeFromParent(),
                .wait(forDuration: 0.12),
                .run(completion)
            ])
        )
        self.movingBlock = nil
    }

    private func pulseTower() {
        let targets = towerNodes.suffix(5)
        for node in targets {
            let pulse = SKAction.sequence([
                .scaleX(to: 1.015, duration: 0.08),
                .scaleX(to: 1, duration: 0.14)
            ])
            pulse.timingMode = .easeOut
            node.run(pulse)
            node.run(
                .customAction(withDuration: 0.2) { target, elapsed in
                    guard let shape = target as? SKShapeNode else { return }
                    let progress = elapsed / 0.2
                    let glow = sin(progress * .pi) * 14
                    shape.glowWidth = glow
                }
            )
        }
    }

    private func landSettle(on node: SKShapeNode) {
        let settle = SKAction.sequence([
            .moveBy(x: 0, y: -2, duration: 0.04),
            .moveBy(x: 0, y: 2, duration: 0.08)
        ])
        settle.timingMode = .easeOut
        node.run(settle)
    }

    private func updateCamera(forTopY topY: CGFloat) {
        let desiredY = max(frame.midY, topY - 180)
        cameraNode.run(.moveTo(y: desiredY, duration: reducedMotionEnabled ? 0.06 : 0.16))
    }

    private func makeBlock(width: CGFloat, color: UIColor, glow: CGFloat) -> SKShapeNode {
        let block = SKShapeNode(rectOf: CGSize(width: max(width, 16), height: blockHeight), cornerRadius: 10)
        block.fillColor = color
        block.strokeColor = UIColor(theme.towerEdge)
        block.lineWidth = 1
        block.glowWidth = glow
        return block
    }

    private func updatePath(of node: SKShapeNode, width: CGFloat) {
        node.path = CGPath(
            roundedRect: CGRect(
                x: -width / 2,
                y: -blockHeight / 2,
                width: width,
                height: blockHeight
            ),
            cornerWidth: 10,
            cornerHeight: 10,
            transform: nil
        )
    }
}
