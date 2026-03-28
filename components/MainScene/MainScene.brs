sub init()
    m.channelList       = m.top.findNode("channelList")
    m.videoPlayer       = m.top.findNode("videoPlayer")
    m.statusLabel       = m.top.findNode("statusLabel")
    m.signalDetail      = m.top.findNode("signalDetail")
    m.statusOverlay     = m.top.findNode("statusOverlay")
    m.statusOverlayText = m.top.findNode("statusOverlayText")
    m.loadTask          = m.top.findNode("loadTask")
    m.curChanLab        = m.top.findNode("currentChannelLabel")
    m.curCatLab         = m.top.findNode("currentCategoryLabel")
    m.liveBadgeBg       = m.top.findNode("liveBadgeBg")

    m.videoContent = CreateObject("roSGNode", "ContentNode")
    m.videoContent.streamFormat = "hls"
    m.videoPlayer.content = m.videoContent

    m.videoPlayer.observeField("state",        "onVideoStateChange")
    m.loadTask.observeField("content",         "onContentFinished")
    m.channelList.observeField("itemSelected", "onChannelSelect")
    m.global.observeField("inputUrl",          "onInputUrl")

    m.fullContent = invalid
    m.currentUrl  = ""
    m.focusState  = "list"

    m.loadTask.control = "RUN"
    showPIP()
    m.channelList.setFocus(true)
end sub

sub onVideoStateChange()
    state = m.videoPlayer.state

    if state = "buffering"
        m.statusLabel.text       = "Sincronizando..."
        m.signalDetail.text      = "Conectando"
        m.statusOverlayText.text = "Conectando..."
        m.statusOverlay.visible  = true
        m.liveBadgeBg.color      = "#5A4400"
    else if state = "playing"
        m.statusLabel.text      = "En directo"
        m.signalDetail.text     = "Señal activa"
        m.statusOverlay.visible = false
        m.liveBadgeBg.color     = "#C0304A"
    else if state = "error"
        m.statusLabel.text       = "Sin señal"
        m.signalDetail.text      = "Canal no disponible"
        m.statusOverlayText.text = "Sin señal"
        m.statusOverlay.visible  = true
        m.liveBadgeBg.color      = "#3A1420"
    else if state = "stopped"
        m.statusLabel.text      = "Detenido"
        m.signalDetail.text     = "Sin reproducción activa"
        m.statusOverlay.visible = false
        m.liveBadgeBg.color     = "#1E1E28"
    end if
end sub

sub onContentFinished()
    if m.loadTask.content <> invalid
        m.fullContent         = m.loadTask.content
        m.channelList.content = m.fullContent
        m.channelList.setFocus(true)
        m.focusState = "list"
    end if
end sub

sub onChannelSelect()
    item = m.channelList.content.getChild(m.channelList.itemSelected)
    if item = invalid then return

    m.curChanLab.text = item.title
    m.curCatLab.text  = ""
    if item.description <> invalid and item.description <> ""
        m.curCatLab.text = UCase(item.description)
    end if

    if m.currentUrl = item.url
        showFullscreen()
    else
        m.currentUrl = item.url
        m.videoPlayer.control = "stop"
        m.videoContent.url    = item.url
        m.videoPlayer.content = m.videoContent
        m.videoPlayer.control = "play"
        showPIP()
        m.channelList.setFocus(true)
        m.focusState = "list"
    end if
end sub

sub showFullscreen()
    m.focusState = "video"
    m.top.findNode("channelBrowser").visible    = false
    m.top.findNode("header").visible            = false
    m.top.findNode("divider").visible           = false
    m.top.findNode("playerSection").translation = [0, 0]
    m.videoPlayer.setFields({ width: 1920, height: 1080, translation: [0, 0] })
    m.top.findNode("infoPanel").visible = false
    m.statusOverlay.visible             = false
    m.videoPlayer.setFocus(true)
end sub

sub showPIP()
    m.top.findNode("channelBrowser").visible    = true
    m.top.findNode("header").visible            = true
    m.top.findNode("divider").visible           = true
    ' Ajustado para cuadrar con el divisor en 700
    m.top.findNode("playerSection").translation = [702, 82]
    ' Ancho de 1218 para llegar al borde derecho (1920 - 702)
    m.videoPlayer.setFields({ width: 1218, height: 685, translation: [0, 0] })
    m.top.findNode("infoPanel").visible = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if m.focusState = "video"
        if key = "back"
            showPIP()
            m.channelList.setFocus(true)
            m.focusState = "list"
            return true
        end if
        return false
    end if
    return false
end function
