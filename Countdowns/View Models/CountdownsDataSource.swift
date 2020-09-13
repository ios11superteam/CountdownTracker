//
//  CountdownsDataSource.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-13.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import UIKit
import CoreData


class CountdownsDataSource: UITableViewDiffableDataSource<Int, Event> {
   /// Closure determines whether provided event should be deleted.
   /// If closure is nil, event will be deleted.
   var didConfirmDelete: ((Event) -> Bool)?

   var viewModel: CountdownsViewModeling

   init(viewModel: CountdownsViewModeling, tableView: UITableView) {
      self.viewModel = viewModel

      super.init(tableView: tableView) { tv, idx, event -> UITableViewCell? in
         let cell = tv.dequeueReusableCell(
            withIdentifier: .countdownCellReuseID,
            for: idx
            ) as? CountdownTableViewCell
         cell?.configure(with: viewModel.eventViewModel(event), indexPath: idx)
         return cell
      }
   }
}

extension CountdownsDataSource: NSFetchedResultsControllerDelegate {
   func controller(
      _ controller: NSFetchedResultsController<NSFetchRequestResult>,
      didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference
   ) {
      apply(snapshot as NSDiffableDataSourceSnapshot<Int, Event>)
   }
}

