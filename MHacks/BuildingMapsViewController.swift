//
//  BuildingMapsViewController.swift
//  MHacks
//
//  Created by Gurnoor Singh on 9/16/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit

class BuildingMapsViewController: UIViewController, UIScrollViewDelegate {
    let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow]
    var frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //1
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        //3
        let imgOne = UIImageView(frame: CGRect(x:50, y:40,width:scrollViewWidth-100, height:scrollViewHeight-200))
        imgOne.image = UIImage(named: "image1")
        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth+50, y:40,width:scrollViewWidth-100, height:scrollViewHeight-200))
        imgTwo.image = UIImage(named: "image2")
        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2+50, y:40,width:scrollViewWidth-100, height:scrollViewHeight-200))
        imgThree.image = UIImage(named: "image3")
        let imgFour = UIImageView(frame: CGRect(x:scrollViewWidth*3+50, y:40,width:scrollViewWidth-100, height:scrollViewHeight-200))
        imgFour.image = UIImage(named: "image4")
        
        self.scrollView.addSubview(imgOne)
        self.scrollView.addSubview(imgTwo)
        self.scrollView.addSubview(imgThree)
        self.scrollView.addSubview(imgFour)
        //4
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 4, height:1.0)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        // Change the text accordingly
        if Int(currentPage) == 0{
            self.navigationItem.title = "First Floor"
        }else if Int(currentPage) == 1{
            self.navigationItem.title = "Second Floor"
        }else if Int(currentPage) == 2{
            self.navigationItem.title = "Third Floor"
        }else{
            self.navigationItem.title = "Fourth Floor"
        }
    }


}
