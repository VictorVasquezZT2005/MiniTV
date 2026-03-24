sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' Also listen for roInput events (required for deep linking - Roku cert 5.2)
    input = CreateObject("roInput")
    input.setMessagePort(m.port)

    reg = CreateObject("roRegistrySection", "profile")
    url = "https://raw.githubusercontent.com/VictorVasquezZT2005/IPTV/refs/heads/main/index.m3u"
    if reg.Exists("primaryfeed") then url = reg.Read("primaryfeed")

    m.global = screen.getGlobalNode()
    m.global.addFields({
        feedurl: url,
        inputUrl: ""       ' field for deep-link URL passed via roInput
    })

    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return

        else if msgType = "roInputEvent"
            ' Deep-link: extract contentId / mediaType from the input params
            info = msg.getInfo()
            if info <> invalid
                contentId = info.Lookup("contentId")
                mediaType = info.Lookup("mediaType")
                if contentId <> invalid and contentId <> ""
                    ' Pass the deep-link URL down to the scene via a global field
                    m.global.inputUrl = contentId
                end if
            end if
        end if
    end while
end sub