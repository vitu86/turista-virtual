//
//  PhotoAlbumViewController.swift
//  Turista Virtual
//
//  Created by Vitor Costa on 05/01/19.
//  Copyright © 2019 Vitor Costa. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    
    // MARK: Private properties
    private var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    // MARK: Public properties
    var annotationToShow:MKPointAnnotation!
    
    // MARK: Override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        centerMap()
        loadData()
        configureLayout()
        checkForChangeNewCollectionButtonState()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    // MARK: Private functions
    private func centerMap() {
        let newCenter:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: annotationToShow.coordinate.latitude, longitude: annotationToShow.coordinate.longitude)
        let newSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let newRegion:MKCoordinateRegion = MKCoordinateRegion(center: newCenter , span: newSpan)
        let regionThatFits = mapView.regionThatFits(newRegion)
        mapView.setRegion(regionThatFits, animated: true)
        mapView.addAnnotation(annotationToShow)
    }
    
    private func loadData() {
        fetchedResultsController = DataHelper.shared.getFetchedResultControllerFromAnnotation(annotationToShow)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    private func configureLayout() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let space: CGFloat
        let dimension: CGFloat
        if (UIDevice.current.orientation.isPortrait) {
            space = 3.0
            dimension = (view.frame.size.width - (2 * space)) / 3
        } else {
            space = 1.0
            dimension = (view.frame.size.width - (1 * space)) / 5
        }
        collectionViewFlowLayout.minimumInteritemSpacing = space
        collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        collectionView.reloadData()
    }
    
    private func checkForChangeNewCollectionButtonState() {
        for item in fetchedResultsController.sections![0].objects! {
            if let item = item as? Photo {
                if item.image == nil {
                    newCollectionButton.isEnabled = false
                    return
                }
            }
        }
        newCollectionButton.isEnabled = true
    }
    
    // MARK: IBActions
    @IBAction func newCollectionTapped(_ sender: Any) {
        DataHelper.shared.reloadAnnotation(annotationToShow)
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: Collection view functions
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:PhotoAlbumCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoAlbumCell", for: indexPath) as! PhotoAlbumCell
        let photo = fetchedResultsController.object(at: indexPath)
        if let imageData = photo.image {
            cell.imageView.image = UIImage(data: imageData)
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.clipsToBounds = true
        } else {
            cell.imageView.image = #imageLiteral(resourceName: "ImageIcon")
            ImageDownloadManager.shared.downloadImage(from: photo, toShowIn: collectionView, at: indexPath)
        }
        checkForChangeNewCollectionButtonState()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !newCollectionButton.isEnabled {
            // still loading
            return
        }
//        showAlert(title: "Atenção", message: "Você deseja remover esta imagem?", okFunction: { (_) in
            DataHelper.shared.deletePhoto(self.fetchedResultsController.object(at: indexPath))
//        }) { (_) in
            // Do nothing, popup dismiss itself.
//        }
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            print("Moving item?")
        }
    }
}

class PhotoAlbumCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}

