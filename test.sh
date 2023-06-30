#!/bin/sh

(cd impl/whothm.lua/src && LUA_PATH="?.lua" lua test_whothm.lua)
