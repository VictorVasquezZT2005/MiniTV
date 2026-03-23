sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' Leer URL del registro o usar default
    reg = CreateObject("roRegistrySection", "profile")
    url = "https://raw.githubusercontent.com/VictorVasquezZT2005/IPTV/refs/heads/main/index.m3u"
    if reg.Exists("primaryfeed") then url = reg.Read("primaryfeed")

    m.global = screen.getGlobalNode()
    m.global.addFields({
        feedurl: url
    })

    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        end if
    end while
end sub