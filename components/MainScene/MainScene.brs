' ============================================================
'  components/MainScene/MainScene.brs
'  MiniTV – Roku Channel
'  Correcciones: AppLaunchComplete beacon, deep-link (roInput)
' ============================================================

sub init()
    m.channelList = m.top.findNode("channelList")
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.statusLabel = m.top.findNode("statusLabel")
    m.loadTask    = m.top.findNode("loadTask")

    ' Cargar lista de canales
    m.loadTask.observeField("content", "onContentFinished")
    m.loadTask.control = "RUN"

    ' Selección de canal
    m.channelList.observeField("itemSelected", "onChannelSelect")

    ' Deep-link via roInput (cert 5.2)
    m.global.observeField("inputUrl", "onInputUrl")
end sub

' ------------------------------------------------------------------
'  Callback: tarea de carga terminó
' ------------------------------------------------------------------
sub onContentFinished()
    if m.loadTask.content <> invalid
        m.channelList.content = m.loadTask.content
        m.channelList.setFocus(true)
        m.statusLabel.text = ""
    end if

    ' Beacon requerido para certificación (Performance 3.2)
    m.top.signalBeacon("AppLaunchComplete")
end sub

' ------------------------------------------------------------------
'  Callback: usuario seleccionó un canal de la lista
' ------------------------------------------------------------------
sub onChannelSelect()
    item = m.channelList.content.getChild(m.channelList.itemSelected)
    if item = invalid then return

    if m.videoPlayer.content <> invalid and m.videoPlayer.content.url = item.url
        ' El mismo canal ya está cargado → expandir a pantalla completa
        showFullscreen()
    else
        playUrl(item.url)
    end if
end sub

' ------------------------------------------------------------------
'  Callback: llegó una URL por deep-link (roInputEvent)
' ------------------------------------------------------------------
sub onInputUrl()
    inputUrl = m.global.inputUrl
    if inputUrl = "" or inputUrl = invalid then return

    playUrl(inputUrl)
end sub

' ------------------------------------------------------------------
'  Helper: reproducir una URL HLS
' ------------------------------------------------------------------
sub playUrl(url as String)
    vidContent = CreateObject("roSGNode", "ContentNode")
    vidContent.url          = url
    vidContent.streamFormat = "hls"

    m.videoPlayer.content = vidContent
    m.videoPlayer.control = "play"
    m.statusLabel.text    = ""

    showFullscreen()
end sub

' ------------------------------------------------------------------
'  Helper: video en pantalla completa
' ------------------------------------------------------------------
sub showFullscreen()
    m.videoPlayer.translation = [0, 0]
    m.videoPlayer.width       = 1280
    m.videoPlayer.height      = 720
    m.videoPlayer.setFocus(true)
end sub

' ------------------------------------------------------------------
'  Helper: video en modo PIP
' ------------------------------------------------------------------
sub showPIP()
    m.videoPlayer.translation = [520, 50]
    m.videoPlayer.width       = 710
    m.videoPlayer.height      = 400
end sub

' ------------------------------------------------------------------
'  Manejo de teclas
' ------------------------------------------------------------------
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    ' "Back" con video en pantalla completa → PIP + foco a lista
    if key = "back" and m.videoPlayer.width = 1280
        showPIP()
        m.channelList.setFocus(true)
        return true
    end if

    return false
end function