local Table = require(_FRAMEWORK .. "util.solarTable.Table")

local function getExceptionType(e)
    return "Exception"
end

function passOrFail(value)
    return value or error()
end

function try(block)
    local targetFunction = block[1]

    if type(targetFunction) == "function" then
        local status, result = pcall(targetFunction)

        return Table {
            catch = function(self, exception)
                if not status then
                    if exception == getExceptionType(result) then
                        print("exception found")
                    end
                end

                return function(catchBlock)
                    local catchHandler = catchBlock[1]

                    if type(catchHandler) == "function" then
                        if not status then
                            catchHandler(exception)
                        end

                        return Table {
                            finally = function(self, finallyBlock)
                                local finallyHandler = catchBlock[1]
                            end;
                        }
                    end
                end
            end
        }
    end
end


return {}