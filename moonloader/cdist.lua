script_name("CDIST")
local activation = false

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    sampRegisterChatCommand("cdist", cdist_cmd)
    while true do
        wait(-1)
    end
end



function cdist_cmd()
    if activation then
        writeMemory(0x52C9EE, 1, 0, true)
        activation = false
        printStringNow("CDIST: Off", 2000)
    else
        writeMemory(0x52C9EE, 1, 1, true)
        activation = true
        printStringNow("CDIST: On", 2000)
    end
end

