//
//  PreviewViewController.swift
//  DemoTest
//
//  Created by TienVu on 3/5/19.
//

import UIKit
import QuickLook
import RxSwift
import RxCocoa
import TVNExtensions

class PreviewViewController: UIViewController {
    
    let fileNames = ["README.md"]
    var fileURLs = [NSURL]()
    
    var showBtn: UIButton = {
        let btn = UIButton(type: UIButton.ButtonType.system)
        btn.setTitle("Show", for: .normal)
        return btn
    }()
    
    var bag = DisposeBag()
    
    let previewController = QLPreviewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Do any additional setup after loading the view.
        view.addSubview(showBtn)
        showBtn.topMargin(to: view, by: 30)
        showBtn.centerX(to: view)
        showBtn.setRelativeWidth(to: view, ratio: 0.7)
        showBtn.setHeight(40)
        
//        setupPreviewDefault()
        setupPreviewRx()
    }
    
    func prepareFileURLs(from fileNames: [String]) -> [NSURL] {
        var fileURLs = [NSURL]()
        
        for file in fileNames {
            let fileParts = file.components(separatedBy: ".")
            if let fileURL = Bundle.main.url(forResource: fileParts[0], withExtension: fileParts[1]) {
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    fileURLs.append(fileURL as NSURL)
                }
            }
        }
        return fileURLs
    }
    
    func setupPreviewDefault() {
        fileURLs = prepareFileURLs(from: fileNames)
        showBtn.addTarget(self, action: #selector(showBtnTouch(_:)), for: .touchUpInside)
    }
    
    @objc func showBtnTouch(_ sender: UIButton) {
        let quickLookController = QLPreviewController()
        quickLookController.dataSource = self
        
        if QLPreviewController.canPreview(self.fileURLs[0]) {
            quickLookController.currentPreviewItemIndex = 0
            self.navigationController?.pushViewController(quickLookController, animated: true)
        }
    }
    
    func setupPreviewRx() {
        rx.sentMessage(#selector(viewWillAppear(_:)))
            .mapToVoid()
            .map { [weak self] in
                guard let self = self else { return [] }
                return self.prepareFileURLs(from: self.fileNames)
            }
            .asDriver(onErrorJustReturn: [])
            .drive(previewController.rx.items(dataSource: RxQLPreviewControllerDataSource<NSURL>()))
            .disposed(by: bag)
        
        showBtn.rx.tap
            .throttle(0.5, latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self, previewController = self.previewController] in
                self?.present(previewController, animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
}

extension PreviewViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
}
