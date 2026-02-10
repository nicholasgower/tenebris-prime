--- Composite Entity Library Entry Point
--- Provides convenient access to all library modules.
---
--- @module composite_entity

local composite_entity = {
    registry = require("lib.composite_entity.registry"),
    lifecycle = require("lib.composite_entity.lifecycle"),
    storage = require("lib.composite_entity.storage")
}

--- Quick registration shortcut
--- @see registry.register
composite_entity.register = composite_entity.registry.register

--- Quick check if entity is an interface entity
--- @see lifecycle.is_interface_entity
composite_entity.is_interface = composite_entity.lifecycle.is_interface_entity

--- Quick create shortcut
--- @see lifecycle.create
composite_entity.create = composite_entity.lifecycle.create

--- Quick destroy shortcut
--- @see lifecycle.destroy
composite_entity.destroy = composite_entity.lifecycle.destroy

--- Quick get shortcut
--- @see lifecycle.get
composite_entity.get = composite_entity.lifecycle.get

--- Quick get_entity shortcut
--- @see lifecycle.get_entity
composite_entity.get_entity = composite_entity.lifecycle.get_entity

--- Quick get_by_interface shortcut
--- @see lifecycle.get_by_interface
composite_entity.get_by_interface = composite_entity.lifecycle.get_by_interface

return composite_entity
