sub init()
    m.channelList = m.top.findNode("channelList")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.statusLabel = m.top.findNode("statusLabel")
    m.loadTask    = m.top.findNode("loadTask")

    m.loadTask.observeField("content", "onContentFinished")
    m.loadTask.control = "RUN"
    
    m.channelList.observeField("itemSelected", "onChannelSelect")
end sub

sub onContentFinished()
    if m.loadTask.content <> invalid
        m.channelList.content = m.loadTask.content
        m.channelList.setFocus(true)
        ' Se quitó el texto de canales cargados
        m.statusLabel.text = "" 
    end if
end sub

sub onChannelSelect()
    item = m.channelList.content.getChild(m.channelList.itemSelected)
    
    if m.videoPlayer.content <> invalid and m.videoPlayer.content.url = item.url
        m.videoPlayer.translation = [0, 0]
        m.videoPlayer.width = 1280
        m.videoPlayer.height = 720
        m.videoPlayer.setFocus(true)
    else
        vidContent = CreateObject("roSGNode", "ContentNode")
        vidContent.url = item.url
        vidContent.streamFormat = "hls"
        m.videoPlayer.content = vidContent
        m.videoPlayer.control = "play"
        ' Se quitó el texto de "Viendo: nombre"
        m.statusLabel.text = "" 
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    
    if key = "back" and m.videoPlayer.width = 1280
        m.videoPlayer.translation = [520, 50]
        m.videoPlayer.width = 710
        m.videoPlayer.height = 400
        m.channelList.setFocus(true)
        return true
    end if
    
    return false
end function