local utils = require "apenode.dao.sqlite.utils"

local Apis = {}
Apis.__index = Apis

setmetatable(Apis, {
  __call = function (cls, ...)
    local self = setmetatable({}, cls)
    self:_init(...)
    return self
  end
})

function Apis:_init(database)
  self._db = database

  self.insert_stmt = database:prepare [[
    INSERT INTO apis
    VALUES(NULL,
           :name,
           :public_dns,
           :target_url,
           :authentication_type)
  ]]

  self.update_stmt = database:prepare [[
    UPDATE apis
    SET name = :name,
        public_dns = :public_dns,
        target_url = :target_url,
        authentication_type = :authentication_type
    WHERE id = :id
  ]]

  self.delete_stmt = database:prepare [[
    DELETE FROM apis WHERE id = ?
  ]]

  self.select_all_stmt = database:prepare [[
    SELECT * FROM apis LIMIT :page, :size
  ]]

  self.select_by_id_stmt = database:prepare [[
    SELECT * FROM apis WHERE id = ?
  ]]

  self.select_by_host_stmt = database:prepare [[
    SELECT * FROM apis WHERE public_dns = ?
  ]]
end

function Apis:save(api)
  self.insert_stmt:bind_names(api)
  return utils.exec_stmt(self.insert_stmt)
end

function Apis:update(api)
  self.update_stmt:bind_names(api)
  return utils.exec_stmt(self.update_stmt)
end

function Apis:delete(id)
  self.delete_stmt:bind_values(id)
  return utils.exec_stmt(self.delete_stmt)
end

function Apis:get_all(page, size)
  return utils.exec_paginated_stmt(self.select_all_stmt, page, size)
end

function Apis:get_by_id(id)
  self.select_by_id_stmt:bind_values(id)
  return utils.exec_select_stmt(self.select_by_id_stmt)
end

function Apis:get_by_host(public_dns)
  self.select_by_host_stmt:bind_values(public_dns)
  return utils.exec_select_stmt(self.select_by_host_stmt)
end

return Apis
