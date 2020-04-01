class 'cLoadingIndicator'

function cLoadingIndicator:__init()

    self.size = 25
    self.position = Vector2(Render.Size.x - 5 - self.size, self.size + 40)

    self.progress_indicator = CircleBar(self.position, self.size, {
        {
            amount = 0,
            max_amount = 100,
            color = Color(220, 220, 220)
        }
    }, 0, true)

    self.rotating_circle = CircleBar(self.position, self.size, {
        {
            amount = 20,
            max_amount = 100,
            color = Color.White
        }
    }, 0.8)
    self.rotating_circle.rotating = true
    self.rotating_circle.background_color = Color(0,0,0,0)

    self.frames = 0

    Events:Subscribe("Render", self, self.Render)
end

function cLoadingIndicator:Render(args)
    if self.progress_indicator.data[1].amount < 100 then
        self.progress_indicator:Render(args)
        self.rotating_circle:Render(args)
    end

    self.frames = self.frames + 1
    if self.frames >= 10 then
        self.frames = 0
        if ChunkManager then
            self.progress_indicator.data[1].amount = (1 - ChunkManager.processing_chunks / ChunkManager.max_chunks) * 100
            self.progress_indicator:Update()
        end
    end
end

cLoadingIndicator = cLoadingIndicator()