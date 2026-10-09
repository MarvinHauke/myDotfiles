-- Screenshots and recordings. macOS saves them to /tmp/shots (com.apple.screencapture
-- location). Each new file gets a short name without spaces. A screenshot is also put
-- on the clipboard as an image; for a recording its path is copied.
local M = {}

local dir = "/private/tmp/shots" -- /tmp is a symlink; the watcher needs the real path

-- /tmp is emptied on reboot and cleaned daily; without the folder macOS saves to the Desktop
local function ensureDir()
	hs.fs.mkdir(dir)
end

local function handle(paths)
	for _, path in ipairs(paths) do
		local name = path:match("([^/]+)$")
		local fresh = name and name:sub(1, 1) ~= "." and not name:match("^%d%d%d%d%-%d%d%-%d%d_%d%d%d%d%d%d[%._]")
		if fresh and hs.fs.attributes(path, "mode") == "file" then
			local stamp, ext = os.date("%Y-%m-%d_%H%M%S"), name:match("%.(%w+)$") or "png"
			local target = string.format("/tmp/shots/%s.%s", stamp, ext)
			-- two screens give two files in the same second
			local n = 1
			while hs.fs.attributes(target) do
				n = n + 1
				target = string.format("/tmp/shots/%s_%d.%s", stamp, n, ext)
			end
			if os.rename(path, target) then
				-- screenshots go to the clipboard as an image, recordings as their path
				local image = target:match("%.png$") and hs.image.imageFromPath(target)
				if image then
					hs.pasteboard.writeObjects(image)
				else
					hs.pasteboard.setContents(target)
				end
				hs.alert.show(target)
			end
		end
	end
end

ensureDir()
M.watcher = hs.pathwatcher.new(dir, handle):start()
M.timer = hs.timer.doEvery(3600, ensureDir)

return M
