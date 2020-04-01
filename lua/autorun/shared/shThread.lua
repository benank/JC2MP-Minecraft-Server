class 'Thread'

function Thread:__init(func)
    self.finished = false

    local modified_func = function()
        func()
        self.finished = true
    end
    self.status, self.error = pcall(coroutine.wrap(modified_func)) -- runs the thread
end

function Thread:IsFinished()
    return self.finished
end

function Thread:GetStatus()
    return self.status
end

function Thread:GetError()
    return self.error
end