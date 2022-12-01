//
//  WaveView.swift
//  CustomAudioTrimmer
//
//  Created by Ahmad's MacMini on 01/12/22.
//


class WavedProgressView: UIView {
    
    var lineMargin:CGFloat = 4
    var volumes:[CGFloat] = [0.1,0.2,0.3,0.5,0.7,0.9,0.7,0.5,0.3,0.2,0.1]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.darkGray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkGray
    }
    
    override var frame: CGRect {
        didSet{
            self.drawVerticalLines()
        }
    }
    
    var lineWidth:CGFloat = 2.0{
        didSet{
            self.drawVerticalLines()
        }
    }
    
    func drawVerticalLines() {
        let linePath = CGMutablePath()
        for i in 0..<self.volumes.count {
            let height = self.frame.height * volumes[i]
            let y = (self.frame.height - height) / 2.0
            linePath.addRect(CGRect(x: lineMargin + (lineMargin + lineWidth) * CGFloat(i), y: y, width: lineWidth, height: height))
        }
        
        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = UIColor(cgColor: CGColor(red: 193/255.0, green: 25/255.0, blue: 127/255.0, alpha: 1.0)).cgColor
        lineLayer.fillColor = UIColor(cgColor: CGColor(red: 193/255.0, green: 25/255.0, blue: 127/255.0, alpha: 1.0)).cgColor
        self.layer.sublayers?.removeAll()
        self.layer.addSublayer(lineLayer)
    }
}
