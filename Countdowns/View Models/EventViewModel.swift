//
//  EventViewModel.swift
//  Countdowns
//
//  Created by Jon Bash on 2020-09-12.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation


class EventViewModel: EventViewModeling, EditEventViewModeling, EventDetailViewModeling {
   private(set) var event: Event

   lazy var newName: String = event.name
   lazy var newDateTime: Date = event.dateTime
   lazy var newNote: String = event.note
   lazy var newTagText: String = event.tags.lazy.map { $0.name }
      .joined(separator: Character.tagSeparator + " ")
   lazy var hasCustomTime: Bool = event.hasTime

   var updateViewsFromEvent: ((Event) -> Void)?
   private(set) var countdownDidEnd: (Event) -> Void

   var tags: [Tag] { (try? controller.fetchTags(.all)) ?? [] }

   var editViewModel: EditEventViewModeling { self }

   private var countdownTimer: Timer?
   private let controller: EventController

   init(
      _ event: Event,
      controller: EventController,
      countdownDidEnd: @escaping (Event) -> Void
   ) {
      self.event = event
      self.controller = controller
      self.countdownDidEnd = countdownDidEnd

      updateTimer()
   }

   func newTag(name: String) throws -> Tag {
      try controller.createTag(name)
   }

   func saveEvent() throws {
      try controller.update(event,
                            withName: newName,
                            dateTime: newDateTime,
                            tags: tags,
                            note: newNote,
                            hasTime: hasCustomTime)
   }

   private func updateTimer() {
      // if time remaining < 1 day, update in a minute
      let update: (Timer) -> Void = { [weak self] _ in self?.updateTimer() }

      if !event.archived && event.timeInterval < 1 {
         countdownDidEnd(event)
      } else if abs(event.timeInterval) < 3660 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: false,
            block: update)
      } else if abs(event.timeInterval) < 86_460 {
         countdownTimer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: false,
            block: update)
      }

      updateViewsFromEvent?(event)
   }
}