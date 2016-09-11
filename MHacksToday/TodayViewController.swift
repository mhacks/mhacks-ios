//
//  TodayViewController.swift
//  MHacksToday
//
//  Created by Manav Gabhawala on 2/6/16.
//  Copyright © 2016 MHacks. All rights reserved.
//

import UIKit
import NotificationCenter
import CoreLocation

typealias CompletionHandler = ((NCUpdateResult) -> Void)

class TodayViewController: UIViewController, NCWidgetProviding {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var segmentedControl: UISegmentedControl!
	@IBOutlet var collectionView: UICollectionView!
	
	let completionHandlerLock = NSLock()
	var completionHandlers = [CompletionHandler]()
	
	var myEventOrganizer = EventOrganizer(events: MHacksArray<Event>())
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorEffect = UIVibrancyEffect.notificationCenter()
		tableView.separatorColor = UIColor(white: 1.0, alpha: 0.5)
		tableView.separatorInset = .zero
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
		tableView.tableFooterView?.backgroundColor = UIColor.clear
		
		collectionView.register(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
		collectionView.register(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
		
		let layout = collectionView.collectionViewLayout as! CalendarLayout
		layout.rowInsets = UIEdgeInsets(top: 0.0, left: 52.0, bottom: 0.0, right: 0.0)

		segmentedControl.addTarget(self, action: #selector(TodayViewController.changeView(_:)), for: .valueChanged)
    }
	override func viewWillAppear(_ animated: Bool)
	{
		super.viewWillAppear(animated)
		eventsUpdated()
		NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.announcementsUpdated(_:)), name: APIManager.EventsUpdatedNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(TodayViewController.failed(_:)), name: APIManager.FailureNotification, object: nil)
		
		APIManager.shared.updateAnnouncements()
		APIManager.shared.updateEvents()
		tableView.reloadData()
		collectionView.reloadData()
		segmentedControl.selectedSegmentIndex = tableView.isHidden ? 1 : 0
		updatePreferredContentSize()
	}
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	func widgetPerformUpdate(completionHandler: @escaping (NCUpdateResult) -> Void) {
		APIManager.shared.updateAnnouncements {
			guard $0
			else {
				completionHandler(.failed)
				return
			}
			completionHandler(.newData)
		}
		APIManager.shared.updateEvents()
	}
	
	func widgetMarginInsets(forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		defer { tableView.setNeedsUpdateConstraints() }
		return .zero
	}
	
	func announcementsUpdated(_ notification: Notification)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		let returnVal = notification.object == nil ? NCUpdateResult.noData : .newData
		for completionHandler in completionHandlers
		{
			completionHandler(returnVal)
		}
		completionHandlers.removeAll(keepingCapacity: true)
		if returnVal == .newData
		{
			DispatchQueue.main.async(execute: {
				self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
				self.updatePreferredContentSize()
			})
		}
	}
	func eventsUpdated(_: Notification? = nil)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		for completionHandler in completionHandlers
		{
			completionHandler(.newData)
		}
		completionHandlers.removeAll(keepingCapacity: true)
//		myEventOrganizer = EventOrganizer(events: APIManager.shared.eventsOrganizer.next5Events)
		DispatchQueue.main.async(execute: {
			self.collectionView.reloadData()
			self.updatePreferredContentSize()
		})
	}
	func failed(_: Notification)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		for completionHandler in completionHandlers
		{
			completionHandler(.failed)
		}
		completionHandlers.removeAll(keepingCapacity: true)
	}
	
	
	func transitionFromView(_ from: UIView, toView to: UIView, moveInFromLeft: Bool)
	{
		to.frame.origin.x = to.frame.width * (moveInFromLeft ? -1 : 1)
		to.isHidden = false
		from.isHidden = true
		UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: UIViewAnimationOptions(), animations: {
			to.frame.origin.x = 0.0
		}, completion: nil)
	}
	
	func changeView(_ sender: UISegmentedControl)
	{
		if sender.selectedSegmentIndex == 0
		{
			transitionFromView(collectionView, toView: tableView, moveInFromLeft: true)
		}
		else
		{
			transitionFromView(tableView, toView: collectionView, moveInFromLeft: false)
		}
		updatePreferredContentSize()
	}
	
	func updatePreferredContentSize()
	{
		var baseHeight = 16 + segmentedControl.frame.height
		if segmentedControl.selectedSegmentIndex == 0
		{
			baseHeight += CGFloat(tableView(tableView, numberOfRowsInSection: 0)) * tableView.rowHeight
		}
		else
		{
			baseHeight += collectionView.frame.height
		}
		preferredContentSize = CGSize(width: preferredContentSize.width, height: baseHeight)
	}
}

extension TodayViewController: UITableViewDelegate, UITableViewDataSource
{
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return min(5, APIManager.shared.announcements.count)
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCell(withIdentifier: "announcementCell") as! AnnouncementCell
		let announcement = APIManager.shared.announcements[(indexPath as NSIndexPath).row]
		cell.titleLabel.text = announcement.title
		cell.dateLabel.text = announcement.localizedDate
		cell.colorView.layer.borderColor = announcement.category.color.cgColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width
		
		let effect = UIVibrancyEffect.notificationCenter()
		let effectView = UIVisualEffectView(effect: effect)
		
		effectView.autoresizingMask = UIViewAutoresizing.flexibleHeight.intersection(UIViewAutoresizing.flexibleWidth)
		effectView.frame = self.view.bounds
		let view = UIView(frame: effectView.bounds)
		view.backgroundColor = self.tableView.separatorColor
		view.autoresizingMask = UIViewAutoresizing.flexibleHeight.intersection(UIViewAutoresizing.flexibleWidth)
		effectView.contentView.addSubview(view)
		cell.selectedBackgroundView = effectView;
		cell.selectionStyle = .default
		
		return cell
	}
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
		tableView.deselectRow(at: indexPath, animated: false)
		extensionContext?.open(URL(string: "mhacks://")!, completionHandler: nil)
	}
}

extension TodayViewController : UICollectionViewDataSource, CalendarLayoutDelegate
{
	func numberOfSections(in collectionView: UICollectionView) -> Int
	{
		return myEventOrganizer.days.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return myEventOrganizer.numberOfEventsInDay(section)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCell", for: indexPath) as! ScheduleEventCell
		
		let event = myEventOrganizer.eventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
		cell.color = event.category.color
		cell.textLabel.text = event.name
		cell.detailTextLabel.text = event.locationsDescription
		
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
			
		case .Header:
			let dayHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DayHeader", for: indexPath) as! ScheduleDayHeader
			dayHeader.textLabel.text = myEventOrganizer.days[(indexPath as NSIndexPath).section].weekdayTitle
			dayHeader.detailTextLabel.text = myEventOrganizer.days[(indexPath as NSIndexPath).section].dateTitle
			return dayHeader
			
		case .Separator:
			let hourSeparator = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HourSeparator", for: indexPath) as! ScheduleHourSeparator
			hourSeparator.label.text = myEventOrganizer.days[(indexPath as NSIndexPath).section].hours[(indexPath as NSIndexPath).item].title
			return hourSeparator
            
        case .NowIndicator:
            fatalError()
            
        case .NowLabel:
            fatalError()
		}
	}
	
	// MARK: Calendar layout delegate
	
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
		return myEventOrganizer.days[section].hours.count
	}
	
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: IndexPath) -> Double {
		return myEventOrganizer.partialHoursForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section).lowerBound
	}
	
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: IndexPath) -> Double {
		return myEventOrganizer.partialHoursForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section).upperBound
	}
	
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: IndexPath) -> Int {
		return myEventOrganizer.numberOfColumnsForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: IndexPath) -> Int {
		return myEventOrganizer.columnForEventAtIndex((indexPath as NSIndexPath).item, inDay: (indexPath as NSIndexPath).section)
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
	{
		collectionView.deselectItem(at: indexPath, animated: true)
		let event = myEventOrganizer.eventAtIndex((indexPath as NSIndexPath).row, inDay: (indexPath as NSIndexPath).section)
		extensionContext?.open(URL(string: "mhacks://\(event.ID)")!, completionHandler: nil)
	}
}

