-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('Cuser_pb')


local CUSER = protobuf.Descriptor();
local CUSER_ID_FIELD = protobuf.FieldDescriptor();
local CUSER_USERNAME_FIELD = protobuf.FieldDescriptor();
local CUSER_PASSWORD_FIELD = protobuf.FieldDescriptor();

CUSER_ID_FIELD.name = "id"
CUSER_ID_FIELD.full_name = ".msg.CUser.id"
CUSER_ID_FIELD.number = 1
CUSER_ID_FIELD.index = 0
CUSER_ID_FIELD.label = 1
CUSER_ID_FIELD.has_default_value = false
CUSER_ID_FIELD.default_value = 0
CUSER_ID_FIELD.type = 5
CUSER_ID_FIELD.cpp_type = 1

CUSER_USERNAME_FIELD.name = "username"
CUSER_USERNAME_FIELD.full_name = ".msg.CUser.username"
CUSER_USERNAME_FIELD.number = 2
CUSER_USERNAME_FIELD.index = 1
CUSER_USERNAME_FIELD.label = 1
CUSER_USERNAME_FIELD.has_default_value = false
CUSER_USERNAME_FIELD.default_value = ""
CUSER_USERNAME_FIELD.type = 9
CUSER_USERNAME_FIELD.cpp_type = 9

CUSER_PASSWORD_FIELD.name = "password"
CUSER_PASSWORD_FIELD.full_name = ".msg.CUser.password"
CUSER_PASSWORD_FIELD.number = 3
CUSER_PASSWORD_FIELD.index = 2
CUSER_PASSWORD_FIELD.label = 1
CUSER_PASSWORD_FIELD.has_default_value = false
CUSER_PASSWORD_FIELD.default_value = ""
CUSER_PASSWORD_FIELD.type = 9
CUSER_PASSWORD_FIELD.cpp_type = 9

CUSER.name = "CUser"
CUSER.full_name = ".msg.CUser"
CUSER.nested_types = {}
CUSER.enum_types = {}
CUSER.fields = {CUSER_ID_FIELD, CUSER_USERNAME_FIELD, CUSER_PASSWORD_FIELD}
CUSER.is_extendable = false
CUSER.extensions = {}

CUser = protobuf.Message(CUSER)
