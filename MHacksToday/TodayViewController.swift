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
	
	var myEventOrganizer = EventOrganizer(events: [])
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tableView.delegate = self
		tableView.dataSource = self
		tableView.separatorEffect = UIVibrancyEffect.notificationCenterVibrancyEffect()
		tableView.separatorColor = UIColor(white: 1.0, alpha: 0.5)
		tableView.separatorInset = UIEdgeInsetsZero
		
		tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 1))
		tableView.tableFooterView?.backgroundColor = UIColor.clearColor()
		
		collectionView.registerNib(UINib(nibName: "ScheduleDayHeader", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Header.rawValue, withReuseIdentifier: "DayHeader")
		collectionView.registerNib(UINib(nibName: "ScheduleHourSeparator", bundle: nil), forSupplementaryViewOfKind: CalendarLayout.SupplementaryViewKind.Separator.rawValue, withReuseIdentifier: "HourSeparator")
		
		let layout = collectionView.collectionViewLayout as! CalendarLayout
		layout.rowInsets = UIEdgeInsets(top: 0.0, left: 52.0, bottom: 0.0, right: 0.0)

		segmentedControl.addTarget(self, action: "changeView:", forControlEvents: .ValueChanged)
    }
	override func viewWillAppear(animated: Bool)
	{
		super.viewWillAppear(animated)
		eventsUpdated()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "announcementsUpdated:", name: APIManager.announcementsUpdatedNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "eventsUpdated:", name: APIManager.eventsUpdatedNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "failed:", name: APIManager.connectionFailedNotification, object: nil)
		APIManager.sharedManager.updateAnnouncements()
		APIManager.sharedManager.updateEvents()
		tableView.reloadData()
		collectionView.reloadData()
		segmentedControl.selectedSegmentIndex = Int(tableView.hidden)
		updatePreferredContentSize()
	}
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void))
	{
        APIManager.sharedManager.updateAnnouncements()
		APIManager.sharedManager.updateEvents()
    }
	
	func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
		defer { tableView.setNeedsUpdateConstraints() }
		return UIEdgeInsetsZero
	}
	
	func announcementsUpdated(notification: NSNotification)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		let returnVal = notification.object == nil ? NCUpdateResult.NoData : .NewData
		for completionHandler in completionHandlers
		{
			completionHandler(returnVal)
		}
		completionHandlers.removeAll(keepCapacity: true)
		if returnVal == .NewData
		{
			dispatch_async(dispatch_get_main_queue(), {
				self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
				self.updatePreferredContentSize()
			})
		}
	}
	func eventsUpdated(_: NSNotification? = nil)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		for completionHandler in completionHandlers
		{
			completionHandler(.NewData)
		}
		completionHandlers.removeAll(keepCapacity: true)
		myEventOrganizer = EventOrganizer(events: APIManager.sharedManager.eventsOrganizer.next5Events)
		dispatch_async(dispatch_get_main_queue(), {
			self.collectionView.reloadData()
			self.updatePreferredContentSize()
		})
	}
	func failed(_: NSNotification)
	{
		completionHandlerLock.lock()
		defer { completionHandlerLock.unlock() }
		for completionHandler in completionHandlers
		{
			completionHandler(.Failed)
		}
		completionHandlers.removeAll(keepCapacity: true)
	}
	
	
	func transitionFromView(from: UIView, toView to: UIView, moveInFromLeft: Bool)
	{
		to.frame.origin.x = to.frame.width * (moveInFromLeft ? -1 : 1)
		to.hidden = false
		from.hidden = true
		UIView.animateWithDuration(1.0, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1.0, options: .CurveEaseInOut, animations: {
			to.frame.origin.x = 0.0
		}, completion: nil)
	}
	
	func changeView(sender: UISegmentedControl)
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
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
	{
		return min(5, APIManager.sharedManager.announcements.count)
	}
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
	{
		let cell = tableView.dequeueReusableCellWithIdentifier("announcementCell") as! AnnouncementCell
		let announcement = APIManager.sharedManager.announcements[indexPath.row]
		cell.titleLabel.text = announcement.title
		cell.dateLabel.text = announcement.localizedDate
		cell.dateLabel.font = Announcement.dateFont
		cell.colorView.layer.borderColor = announcement.category.color.CGColor
		cell.colorView.layer.borderWidth = cell.colorView.frame.width
		
		let effect = UIVibrancyEffect.notificationCenterVibrancyEffect()
		let effectView = UIVisualEffectView(effect: effect)
		
		effectView.autoresizingMask = UIViewAutoresizing.FlexibleHeight.intersect(UIViewAutoresizing.FlexibleWidth)
		effectView.frame = self.view.bounds
		let view = UIView(frame: effectView.bounds)
		view.backgroundColor = self.tableView.separatorColor
		view.autoresizingMask = UIViewAutoresizing.FlexibleHeight.intersect(UIViewAutoresizing.FlexibleWidth)
		effectView.contentView.addSubview(view)
		cell.selectedBackgroundView = effectView;
		cell.selectionStyle = .Default
		
		return cell
	}
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
	{
		tableView.deselectRowAtIndexPath(indexPath, animated: false)
		extensionContext?.openURL(NSURL(string: "mhacks://")!, completionHandler: nil)
	}
}

extension TodayViewController : UICollectionViewDataSource, CalendarLayoutDelegate
{
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
	{
		return myEventOrganizer.days.count
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return myEventOrganizer.numberOfEventsInDay(section)
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EventCell", forIndexPath: indexPath) as! ScheduleEventCell
		
		let event = myEventOrganizer.eventAtIndex(indexPath.item, inDay: indexPath.section)
		cell.color = event.category.color
		cell.textLabel.text = event.name
		cell.detailTextLabel.text = event.locationsDescription
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		
		switch CalendarLayout.SupplementaryViewKind(rawValue: kind)! {
			
		case .Header:
			let dayHeader = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DayHeader", forIndexPath: indexPath) as! ScheduleDayHeader
			dayHeader.textLabel.text = myEventOrganizer.days[indexPath.section].weekdayTitle
			dayHeader.detailTextLabel.text = myEventOrganizer.days[indexPath.section].dateTitle
			return dayHeader
			
		case .Separator:
			let hourSeparator = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HourSeparator", forIndexPath: indexPath) as! ScheduleHourSeparator
			hourSeparator.label.text = myEventOrganizer.days[indexPath.section].hours[indexPath.item].title
			return hourSeparator
		}
	}
	
	// MARK: Calendar layout delegate
	
	func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfRowsInSection section: Int) -> Int {
		return myEventOrganizer.days[section].hours.count
	}
	
	func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, startRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
		return myEventOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).start
	}
	
	func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, endRowForItemAtIndexPath indexPath: NSIndexPath) -> Double {
		return myEventOrganizer.partialHoursForEventAtIndex(indexPath.item, inDay: indexPath.section).end
	}
	
	func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, numberOfColumnsForItemAtIndexPath indexPath: NSIndexPath) -> Int {
		return myEventOrganizer.numberOfColumnsForEventAtIndex(indexPath.item, inDay: indexPath.section)
	}
	
	func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, columnForItemAtIndexPath indexPath: NSIndexPath) -> Int {
		return myEventOrganizer.columnForEventAtIndex(indexPath.item, inDay: indexPath.section)
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
	{
		collectionView.deselectItemAtIndexPath(indexPath, animated: true)
		let event = myEventOrganizer.eventAtIndex(indexPath.row, inDay: indexPath.section)
		extensionContext?.openURL(NSURL(string: "mhacks://\(event.ID)")!, completionHandler: nil)
	}
}

