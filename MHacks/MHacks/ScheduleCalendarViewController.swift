//
//  ScheduleCalendarViewController.swift
//  MHacks
//
//  Created by Russell Ladd on 10/4/14.
//  Copyright (c) 2014 MHacks. All rights reserved.
//

import UIKit

class ScheduleCalendarViewController: UIViewController, CalendarLayoutDelegate, UICollectionViewDataSource {
    
    // MARK: Initialization
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let observer = Observer<[Event]> { [unowned self] events in
            self.eventOrganizer = EventOrganizer(events: events)
        }
        
        fetchResultsManager.observerCollection.addObserver(observer)
    }
    
    // MARK: Event
    
    let fetchResultsManager: FetchResultsManager<Event> = {
        
        let query = PFQuery(className: "Event")
        
        query.includeKey("category")
        query.includeKey("locations")
        
        query.orderByAscending("startTime")
        query.addAscendingOrder("duration")
        query.addAscendingOrder("title")
        
        return FetchResultsManager<Event>(query: query, name: "Schedule")
    }()
    
    var eventOrganizer: EventOrganizer = EventOrganizer(events: []) {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private func fetch() {
        
        if !fetchResultsManager.fetched {
            fetch(.Local)
        } else {
            fetch(.Remote)
        }
    }
    
    private func fetch(source: FetchSource) {
        
        if !fetchResultsManager.fetching {
            
            errorLabel.hidden = true
            
            if fetchResultsManager.results.isEmpty {
                loadingIndicatorView.startAnimating()
            }
            
            fetchResultsManager.fetch(source) { error in
                
                self.loadingIndicatorView.stopAnimating()
                
                if self.fetchResultsManager.results.isEmpty && error != nil {
                    self.errorLabel.hidden = false
                }
                
                if source == .Local {
                    self.fetch(.Remote)
                }
            }
        }
    }
    
    // MARK: View
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var loadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
        collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
        
        let layout = collectionView.collectionViewLayout as CalendarLayout
        layout.rowInsets = UIEdgeInsets(top: 0.0, left: 52.0, bottom: 0.0, right: 0.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath
            
        transitionCoordinator()?.animateAlongsideTransition({ context in
            
            self.collectionView.deselectItemAtIndexPath(indexPath, animated: animated)
            
            }, completion: { context in
                
                if context.isCancelled() {
                    self.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetch()
    }
    
    // MARK: Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return eventOrganizer.days.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eventOrganizer.numberOfEventsInDay(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as ScheduleEventCell
        
        let event = eventOrganizer.eventAtIndex(indexPath.item, inDay: indexPath.section)
        
        cell.color = event.category.color.color
        cell.textLabel.text = event.name
        cell.detailTextLabel.text = event.locationsDescription
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
            
        case .Header:
            let dayHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayHeader", forIndexPath: indexPath) as ScheduleDayHeader
            dayHeader.textLabel.text = eventOrganizer.days[indexPath.section].weekdayTitle
            dayHeader.detailTextLabel.text = eventOrganizer.days[indexPath.section].dateTitle
            return dayHeader
            
        case .Separator:
            let hourSeparator = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourSeparator", forIndexPath: indexPath) as ScheduleHourSeparator
            hourSeparator.label.text = eventOrganizer.days[indexPath.section].hours[indexPath.item].title
            return hourSeparator
        }
    }
    
    // MARK: Calendar layout delegate
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
        return eventOrganizer.days[section].hours.count
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).start
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
        return eventOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).end
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: NSIndexPath) -> Int {
        return eventOrganizer.numberOfColumnsForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: NSIndexPath) -> Int {
        return eventOrganizer.columnForEventAtIndex(indexPath.item, inDay: indexPath.section)
    }
    
    // MARK: Segues
    
    func showDetailsForEventWithID(ID: String) {
        
        let IDs = fetchResultsManager.results.map { $0.ID }
        
        if let index = find(IDs, ID) {
            
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: index, inSection: 0), animated: false, scrollPosition: .CenteredVertically)
            
            performSegueWithIdentifier("Show Event", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "Show Event" {
            
            let indexPath = collectionView.indexPathsForSelectedItems().first as NSIndexPath
            
            let viewController = segue.destinationViewController as EventViewController
            viewController.event = eventOrganizer.eventAtIndex(indexPath.item, inDay: indexPath.section)
        }
    }
}
