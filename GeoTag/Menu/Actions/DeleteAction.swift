//
// Copyright 2022 Marco S Hyman
// See LICENSE file for info
// https://www.snafu.org/
//

import AppKit

// Program "Delete" action removes location information for all
// selected images

extension AppState {

    // should the delete action be disabled for a specific item or for
    // all selected items

    func deleteDisabled(
        context: ImageModel? = nil,
        textfield: Bool = false
    ) -> Bool {
        if textfield {
            return false
        }
        if let image = context {
            return image.location == nil
        }
        return tvm.selected.allSatisfy { $0.location == nil }
    }

    // when textfield is non-nil a textfield is being edited and delete is
    // limited to the field.  Otherwise delete location info from the image
    // in the given context or all selected images when the context is nil.

    func deleteAction(
        context: ImageModel? = nil,
        textfield: Bool = false
    ) {
        if textfield {
            NSApp.sendAction(#selector(NSText.delete(_:)), to: nil, from: nil)
        } else {
            if let context {
                tvm.select(context: context)
            }
            if !tvm.selected.isEmpty {
                undoManager.beginUndoGrouping()
                for image in tvm.selected.filter({ $0.location != nil }) {
                    update(image, location: nil)
                }
                undoManager.endUndoGrouping()
                undoManager.setActionName("delete locations")
            }
        }
    }
}
