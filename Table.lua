local function copyTable(t)
    local newTbl = {}

    for k, v in pairs(t) do
        newTbl[k] = v
    end

    return newTbl
end

local function deepCopyTable(t)
    local newTbl = {}

    for k, v in pairs(t) do
        if type(v) == "table" then
            newTbl[k] = deepCopyTable(v)
        end

        newTbl[k] = v
    end

    return newTbl
end

local Table = {
    new = function(self, tbl)
        local __PROTOTYPE__ 
        local __CURSOR__ = {
            currentKey = nil;
            first = nil;
            last = nil;
            keysStack = {
                push = function(self, value)
                    self[#self + 1] = value
                end;

                pop = function(self)
                    local value = self[#self]
                    self[#self] = nil

                    return value
                end;
            };

            hasNext = function(self)
                if tbl:isAssociative() then
                    local k = next(tbl, currentKey)
                    return k ~= nil
                end

                if self.currentKey then
                    return tbl[self.currentKey + 1] ~= nil
                end

                if not self.currentKey then
                    return tbl[1] ~= nil
                end

                return false
            end;

            next = function(self)
                if tbl:isAssociative() then
                    local k = next(tbl, self.currentKey)
                    self.keysStack:push(k)
                    return tbl[k]
                end

                if self.currentKey then
                    return tbl[self.currentKey + 1]
                end

                if not self.currentKey  then
                    return tbl[1]
                end
            end;

            prev = function(self)
                if tbl:isAssociative() then
                    return tbl[self.keysStack:pop()]
                end

                if self.currentKey then
                    return tbl[self.currentKey - 1]
                end

                if not self.currentKey  then
                    return nil
                end
            end;

            getLast = function(self)
                if not self.last then
                    local lastKey = self.currentKey

                    while self:hasNext() do
                        lastKey = self:next()
                    end

                    self.last = lastKey
                end

                return tbl[self.last]
            end;

            reset = function(self)
                if self.currentKey then
                    self.currentKey = nil
                end
            end;

            getCurrent = function(self)
                if self.currentKey then
                    return tbl[self.currentKey]
                end

                return nil
            end;
        }

        local __ITERATORS__ = {
            ITERATOR = pairs;
            INDEX_PAIRS_ITERATOR = ipairs;
            KEYS_ITERATOR = ipairs;
            VALUES_ITERATOR = ipairs;
            NON_NUMERIC_KEYS_ITERATOR = ipairs;
            NON_NUMERIC_VALUES_ITERATOR = ipairs;
            NON_NUMERIC_KEY_PAIRS_ITERATOR = ipairs;
        }

        local customMetatable = {
            customIndex = {},
            customCall = nil,
            customNewIndex = nil
        }

        __PROTOTYPE__ = {
            isAssocCached = nil;

            onModified = function(self, index)
                isAssocCached = type(index) ~= "number" and true or isAssocCached
                --update Cursor data
            end;

            setMetatable = function(self, mt)
                customMetatable = mt
            end;

            getMetatable = function(self)
                return customMetatable
            end;

            setCustomIndex = function(self, index)
                customMetatable.customIndex = index
            end;

            setCustomCall = function(self, call)
                customMetatable.customCall = call
            end;

            setCustomNewIndex = function(self, newIndex)
                customMetatable.customNewIndex = newIndex
            end;

            sort = function(self, order, comparator)
                table.sort(self, comparator)
                
                if order then
                    return self:reverse()
                end

                return self
            end;

            insert = function(self, a, b)
                local key = b and a or #self + 1
                local value = not b and a or b

                self[key] = value
            end;

            remove = function(self, key)
                if type(key) == "number" then
                    return table.remove(self, key)
                end

                self[key] = nil
                return 
            end;

            toList = function(self)

            end;

            toMap = function(self)

            end;

            toQueue = function(self)

            end;

            toStack = function(self)

            end;

            contains = function(self, element)
                self:forEach(function(e)
                    if e == element then
                        return true
                    end
                end)
            end;

            indexOf = function(self, element)
                if self:isAssociative() then
                    for k, v in self:iterate() do
                        if v == element then
                            return k
                        end
                    end
                else
                    for i, v in self:iterateIndexPairs() do
                        if v == element then
                            return i
                        end
                    end
                end
            end;

            binarySearch = function(self, element)

            end;

            toJson = function(self)
                return json.encode(self)
            end;

            toString = function(self)
                local str = tostring(self) .. ": { "

                for k, v in pairs(self) do
                    str = str .. k .. " => " .. v 
                end

                return str .. " }"
            end;

            copy = function(self)
                return copyTable(self)
            end;

            deepCopy = function(self)
                return deepCopyTable(self) 
            end;

            equals = function(self, t)
                return self == t
            end;

            concat = function(self, t, pos)
                local count = 0
                
                if pos then
                    for _, v in pairs(t) do
                        self:insert(pos + count, v)
                        count = count + 1
                    end

                    return self
                end

                for k, v in pairs(t) do
                    pos = type(k) == "number" and #self + 1 or k
                    self:insert(pos, v)
                end

                return self
            end;

            collectAsString = function(self, separator)
                return table.concat(self, separator)
            end;

            reverse = function(self)
                for i = 1, math.floor(#self / 2) do
                    local tmp = self[i]
                    local reverseIndex = #self - i + 1
                    self[i] = self[reverseIndex]
                    self[reverseIndex] = tmp
                end

                return self
            end;

            chunk = function(self, startPos, endPos)
                local elements = {}
                for i = startPos, endPos do
                    elements[#elements + 1] = self[i]
                end

                return Table(elements)
            end;

            replaceChunk = function(self, startPos, endPos, replacement)
                for i = startPos, endPos do
                    self:remove(i)
                end

                if type(replacement) ~= "table" then
                    self[startPos] = replacement
                    return self
                end

                for i, v in ipairs(replacement) do
                    self:insert(startPos + 1 - 1, replacement[i])
                end

                return self
            end;

            fillToFit = function(self, size, value)
                if size > #self then
                    for i = #self + 1, size do
                        self[i] = value
                    end
                end
            end;

            isAssociative = function(self)
                if self.isAssocCached ~= nil then
                    return self.isAssocCached
                end

                local prev = 0
                for k, _ in pairs(self) do
                    if type(k) ~= "number" then
                        return true
                    end

                    if k ~= prev + 1 then
                        return true
                    end

                    prev = k
                end

                return false
            end;

            getPrototype = function(self)
                return __PROTOTYPE__
            end;

            forEach = function(self, handler)
                if self:isAssociative() then
                    for _, v in self:iterate() do
                        handler(v)
                    end
                else
                    for _, v in self:iterateIndexPairs() do
                        handler(v)
                    end
                end
            end;

            iterate = function(self)
                return __ITERATORS__.ITERATOR(self)
            end;

            iterateIndexPairs = function(self)
                return __ITERATORS__.INDEX_PAIRS_ITERATOR(self)
            end;

            iterateKeys = function(self)
                local keysTable = {}

                for k, _ in pairs(self) do
                    keysTable[#keysTable + 1] = k
                end

                return __ITERATORS__.KEYS_ITERATOR(keysTable)
            end;

            iterateValues = function(self)
                local valuesTable = {}

                for _, v in pairs(self) do
                    valuesTable[#valuesTable + 1] = v
                end

                return __ITERATORS__.VALUES_ITERATOR(valuesTable)
            end;

            iterateNonNumericKeys = function(self)
                local keysTable = {}

                for k, _ in pairs(self) do
                    if type(k) ~= "number" then
                        keysTable[#keysTable + 1] = k
                    end
                end

                return __ITERATORS__.NON_NUMERIC_KEYS_ITERATOR(keysTable)
            end;

            iterateNonNumericKeyValues = function(self)
                local valuesTable = {}

                for _, v in pairs(self) do
                    if type(k) ~= "number" then
                        valuesTable[#valuesTable + 1] = v
                    end
                end

                return __ITERATORS__.NON_NUMERIC_VALUES_ITERATOR(valuesTable)
            end;
            
            iterateNonNumericKeyPairs = function(self)
                local pairsTable = {}

                for k, v in pairs(self) do
                    if type(k) ~= "number" then
                        pairsTable[k] = v
                    end
                end

                return __ITERATORS__.NON_NUMERIC_KEY_PAIRS_ITERATOR(pairsTable)
            end;

            setIterator = function(self, iterator)
                __ITERATORS__.ITERATOR = iterator
            end;

            setIndexPairsIterator = function(self, indexPairsIterator)
                __ITERATORS__.INDEX_PAIRS_ITERATOR = indexPairsIterator
            end;

            setKeysIterator = function(self, keysIterator)

            end;

            setValuesIterator = function(self, valuesIterator)
                __ITERATORS__.VALUES_ITERATOR = valuesIterator
            end;

            setNonNumericKeysIterator = function(self, nonNumericKeysiterator)
                __ITERATORS__.NON_NUMERIC_KEYS_ITERATOR = nonNumericKeysiterator
            end;

            setNonNumericKeyValuesIterator = function(self, nonNumericKeyValuesIterator)
                __ITERATORS__.NON_NUMERIC_VALUES_ITERATOR = nonNumericKeyValuesIterator
            end;

            setNonNumericKeyPairsIterator = function(self, nonNumericKeyPairsIterator)
                __ITERATORS__.NON_NUMERIC_KEY_VALUES_ITERATOR = nonNumericKeyPairsIterator
            end;

            setPointer = function(self, pos)
                return __CURSOR__:setAt(pos)
            end;

            next = function(self)
                return __CURSOR__:next()
            end;

            hasNext = function(self)
                return __CURSOR__:hasNext()
            end;

            prev = function(self)
                return __CURSOR__:prev()
            end;

            last = function(self)
                return __CURSOR__:getLast()
            end;

            reset = function(self)
                __CURSOR__:reset()
            end;
            
            current = function(self)
                __CURSOR__:getCurrent()
            end;
        }

        local table = tbl or {}
        setmetatable(table, {
            __index = function(t, k)
                if __PROTOTYPE__[k] then
                    return __PROTOTYPE__[k]
                end

                if type(customMetatable.customIndex) == "function" then
                    return customMetatable.customIndex(t, k)
                end

                return customMetatable.customIndex[k]
            end;

            __call = function(t, ...)
                if type(customMetatable.customCall) == "function" then
                    return customMetatable.customCall(t, ...)
                end 

                return
            end;
            
            __newindex = function(t, k, v)
                if type(customMetatable.customNewIndex) == "function" then
                    return customMetatable.customNewIndex(t, k, v)
                end

                tbl:onModified(k)
                return rawset(t, k, v)
            end;
        })

        return table
    end;

    fromRange = function(self, rangeStart, rangeEnd, step)
        local tbl = {}
        step = step or 1

        for i = rangeStart, rangeEnd, step do
            tbl[#tbl + 1] = i
        end

        return self:new(tbl)
    end;

    fromString = function(self, str, splitter)
        local tbl = {}

        for capture in utf8.gmatch(str, splitter) do
            tbl[#tbl + 1] = capture
        end

        return self:new(tbl)
    end;

    fromMap = function(self, map)
        
    end;

    fromList = function(self, list)

    end;

    fromQueue = function(self, queue)

    end;

    fromStack = function(self, stack)

    end;
}

setmetatable(Table, { __call = function(t, ...) return Table:new(...) end })

return Table