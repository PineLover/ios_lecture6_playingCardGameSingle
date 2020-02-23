//
//  PlayingCardView.swift
//  PlayingCardGame
//
//  Created by 김동환 on 21/02/2020.
//  Copyright © 2020 김동환. All rights reserved.
//

import UIKit

@IBDesignable
class PlayingCardView: UIView{
    
    /*
     setNeedslayout과 setNeedsDisplay가
     setNeedsDisplay는 뷰의 실제 컨텐츠가 변경될 때, 뷰를 다시 그려야 함을 시스템에 알리는 메소드이빈다.
     setNeedsLayout은 수신자의 현재 레이아웃을 무효화하고, 다음 업데이트 주기 동안 레이아웃 업데이트를 한다.
     */
    @IBInspectable
    var rank: Int = 11 { didSet{updateView()}}
    
    @IBInspectable
    var suit: String = "♥️" { didSet{updateView()}}
    
    @IBInspectable
    var isFaceUp: Bool = false { didSet{updateView()}}
    
    var faceCardScale : CGFloat = SizeRatio.faceCardImageSizeToBoundsSize { didSet{updateView()}}
    
    @objc func adjustableCardScale(gestureRecognizer: UIPinchGestureRecognizer){
        switch gestureRecognizer.state{
        case .changed , .ended:
            faceCardScale *= gestureRecognizer.scale
            gestureRecognizer.scale = 1.0
        default:
            break;
        }
    }
    
    override func draw (_ rect: CGRect){
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        UIColor.white.setFill()
        UIColor.lightGray.setStroke()
        roundedRect.fill()
        roundedRect.stroke()
        
        if isFaceUp{
            if let faceCardImage = namedImage(name: "\(rankString)\(suit)"){
                faceCardImage.draw(in : bounds.zoom(by: faceCardScale))
            }else{
                drawPips()
            }
        }
        else{
            if let cardBackImage = namedImage(name: "cardback"){
                cardBackImage.draw(in: bounds)
            }
        }
    }
    
    //load image from prepareForInterfaceBuilder
    private func namedImage(name : String)->UIImage?{
        //
        return UIImage(named:name, in : Bundle(for:self.classForCoder) , compatibleWith: traitCollection)
    }
    
    private func drawPips(){
        //한 행에 있는 pip의 갯수.
        let pipsPerRowForRank = [[0],[1],[1,1],[1,1,1],[2,2],[2,1,2],[2,2,2],[2,1,2,2,],[2,2,2,2],[2,2,1,2,2],[2,2,2,2,2]]
        func createPipsString(thatFits pipRect: CGRect) -> NSAttributedString{
            //이걸 왜 구하는거지?
            let maxVerticalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.count,$0)})
            let maxHorizontalPipCount = CGFloat(pipsPerRowForRank.reduce(0){max($1.max() ?? 0,$0)})
            //한개 핍이 세로축으로 차지하는 스페이스 크기인듯.
            let verticalPipRowSpacing = pipRect.size.height / maxVerticalPipCount
            
            //suit 1개를 NSAttributedString으로 구한다.
            let attemptedPipString = centeredAttributedString(string: suit, fontSize: verticalPipRowSpacing)
            
            //뭘 구한거지. 폰트 사이즈인듯
            let probablyOkayPipStringFontSize = verticalPipRowSpacing / (attemptedPipString.size().height / verticalPipRowSpacing)
            let probablyOkayPipString = centeredAttributedString(string: suit, fontSize: probablyOkayPipStringFontSize)
            
            if probablyOkayPipString.size().width > pipRect.size.width / maxHorizontalPipCount{
                return centeredAttributedString(string: suit, fontSize: probablyOkayPipStringFontSize /
                    (probablyOkayPipString.size().width / (pipRect.size.width / maxHorizontalPipCount)))
            }else{
                return probablyOkayPipString
            }
        }
        //pipsPerRowForRank가 rank라는 인덱스를 갖는다면 , 안가질수도있나?
        if pipsPerRowForRank.indices.contains(rank){
            let pipsPerRow = pipsPerRowForRank[rank]
            //bounds와 frame의 차이!
            //insetBy가 크기를 줄이거나 늘이는거 같은데 왜 그러지?
            var pipRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx :cornerString.size().width , dy: cornerString.size().height/2)
            let pipString = createPipsString(thatFits : pipRect)
            let pipRowSpacing = pipRect.size.height / CGFloat(pipsPerRow.count)
            pipRect.size.height = pipString.size().height
            //??
            pipRect.origin.y += (pipRowSpacing - pipRect.size.height) / 2
            
            for pipCount in pipsPerRow{
                switch pipCount{
                case 1:
                    pipString.draw(in: pipRect)
                case 2:
                    //한쪽씩 그린다는건가
                    pipString.draw(in : pipRect.leftHalf)
                    pipString.draw(in : pipRect.rightHalf)
                default:
                    break
                }
                pipRect.origin.y += pipRowSpacing
            }
        }
        
    }
    
    
    //get an NSAttributedString with the string and size
    private func centeredAttributedString(string: String, fontSize: CGFloat) -> NSAttributedString{
        var font = UIFont.preferredFont(forTextStyle : .body).withSize(fontSize)
        font = UIFontMetrics(forTextStyle: .body).scaledFont(for: font)
        
        //NSAttributedString에서 paragraph는 무슨 의미이지?
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes : [NSAttributedString.Key : Any] = [
            .paragraphStyle : paragraphStyle,
            .font : font
        ]
        
        return NSAttributedString(string : string, attributes: attributes)
    }
    
    //Returns the String that goes on the card's corner
    private var cornerString : NSAttributedString{
        return centeredAttributedString(string: "\(rankString)\n\(suit)", fontSize: cornerFontSize)
    }
    
    
    private func updateView(){
        setNeedsDisplay()
        setNeedsLayout()
    }

}

extension PlayingCardView{
    private struct SizeRatio{
        //모서리 폰트 사이즈 대비 바운드
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        //CGRect의 반지름.
        static let cornerRadiusToBoundHeight : CGFloat = 0.06
        //??
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        //bounds대비 카드 이미지의 비율
        static let faceCardImageSizeToBoundsSize : CGFloat = 0.95
        
    }
    //코너에 대한 디자인은 어떻게 정한거지??
    private var cornerRadius : CGFloat{
        return bounds.size.height * SizeRatio.cornerRadiusToBoundHeight
    }
    private var cornerOffset : CGFloat{
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize : CGFloat{
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    
    //int인 rank를 String으로 변환시켜준다.
    private var rankString: String{
        switch rank{
        case 1: return "A"
        case 2...10:return String(rank)
        case 11: return "J"
        case 12: return "Q"
        case 13: return "K"
        default : return "?"
        }
    }
}

extension CGRect{
    func zoom(by zoomFactor : CGFloat)->CGRect{
        //CGRect size는 height,width를 갖는다.
        let zoomedWidth = size.width * zoomFactor
        let zoomedHeight = size.height * zoomFactor
        //기존 CGRect의 중간으로 이동시켜준다.
        let originX = origin.x + (size.width - zoomedWidth)/2
        let originY = origin.y + (size.height - zoomedHeight)/2
        return CGRect (origin : CGPoint(x:originX,y: originY), size: CGSize(width : zoomedWidth, height: zoomedHeight))
    }
    
    var leftHalf : CGRect {
        let width = size.width / 2
        return CGRect(origin : origin , size : CGSize ( width : width, height : size.height))
    }
    
    var rightHalf : CGRect{
        let width = size.width / 2
        return CGRect(origin : CGPoint(x: origin.x + width, y : origin.y) ,size : CGSize(width : width ,height : size.height) )
    }
    
}
