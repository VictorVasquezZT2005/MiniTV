' ============================================================
'  components/MainScene/MainScene.brs
'  MiniTV – Versión Optimizada FHD con Beacons de Certificación
' ============================================================

sub init()
    ' Mapeo de nodos desde el XML
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

    ' Configuración inicial del reproductor
    m.videoContent = CreateObject("roSGNode", "ContentNode")
    m.videoContent.streamFormat = "hls"
    m.videoPlayer.content = m.videoContent

    ' Observadores
    m.videoPlayer.observeField("state",        "onVideoStateChange")
    m.loadTask.observeField("content",         "onContentFinished")
    m.channelList.observeField("itemSelected", "onChannelSelect")
    m.global.observeField("inputUrl",          "onInputUrl")

    m.fullContent = invalid
    m.currentUrl  = ""
    m.focusState  = "list"

    ' Lanzar carga de datos
    m.loadTask.control = "RUN"
    showPIP()
    m.channelList.setFocus(true)
end sub

' ──────────────────────────────────────────────────────────
' Manejo de estados de video y feedback visual
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
        m.statusOverlayText.text = "Error de señal"
        m.statusOverlay.visible  = true
        m.liveBadgeBg.color      = "#3A1420"

    else if state = "stopped"
        m.statusLabel.text      = "Detenido"
        m.signalDetail.text     = "Sin reproducción activa"
        m.statusOverlay.visible = false
        m.liveBadgeBg.color     = "#1E1E28"
    end if
end sub

' ──────────────────────────────────────────────────────────
' Finalización de carga - SOLUCIONA ERROR DE CERTIFICACIÓN 3.2
sub onContentFinished()
    if m.loadTask.content <> invalid
        m.fullContent         = m.loadTask.content
        m.channelList.content = m.fullContent
        m.channelList.setFocus(true)
        m.focusState = "list"

        ' AVISO CRÍTICO A ROKU: La app ya es interactiva
        m.top.signalBeacon("AppLaunchComplete")
    end if
end sub

' ──────────────────────────────────────────────────────────
' Selección de canal
sub onChannelSelect()
    content = m.channelList.content
    if content = invalid then return

    item = content.getChild(m.channelList.itemSelected)
    if item = invalid then return

    ' Actualizar textos de información
    m.curChanLab.text = item.title
    m.curCatLab.text  = ""
    if item.description <> invalid and item.description <> ""
        m.curCatLab.text = UCase(item.description)
    end if

    ' Evitar recargar si ya se está reproduciendo
    if m.currentUrl = item.url
        showFullscreen()
    else
        m.currentUrl = item.url
        m.videoPlayer.control = "stop"

        ' Validar que la URL no esté vacía antes de dar PLAY
        if item.url <> "" and item.url <> invalid
            m.videoContent.url    = item.url
            m.videoPlayer.content = m.videoContent
            m.videoPlayer.control = "play"
        end if

        showPIP()
        m.channelList.setFocus(true)
        m.focusState = "list"
    end if
end sub

' ──────────────────────────────────────────────────────────
' Deep Linking - Soporte Certificación 5.2
sub onInputUrl()
    inputUrl = m.global.inputUrl
    if inputUrl <> "" and inputUrl <> invalid
        m.videoPlayer.control = "stop"
        m.videoContent.url    = inputUrl
        m.videoPlayer.content = m.videoContent
        m.videoPlayer.control = "play"
        showFullscreen() ' Usualmente los Deep Links abren en pantalla completa
    end if
end sub

' ──────────────────────────────────────────────────────────
' Modos de Pantalla
sub showFullscreen()
    m.focusState = "video"
    m.top.findNode("channelBrowser").visible    = false
    m.top.findNode("header").visible            = false
    m.top.findNode("divider").visible           = false
    m.top.findNode("playerSection").translation = [0, 0]

    ' Resolución FHD Completa
    m.videoPlayer.setFields({ width: 1920, height: 1080, translation: [0, 0] })

    m.top.findNode("infoPanel").visible = false
    m.statusOverlay.visible             = false
    m.videoPlayer.setFocus(true)
end sub

sub showPIP()
    m.focusState = "list"
    m.top.findNode("channelBrowser").visible    = true
    m.top.findNode("header").visible            = true
    m.top.findNode("divider").visible           = true

    ' Ajustado a tus coordenadas FHD y línea divisora
    m.top.findNode("playerSection").translation = [702, 82]
    m.videoPlayer.setFields({ width: 1218, height: 685, translation: [0, 0] })

    m.top.findNode("infoPanel").visible = true
    m.channelList.setFocus(true)
end sub

' ──────────────────────────────────────────────────────────
' Control remoto
function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false

    if key = "back"
        if m.focusState = "video"
            showPIP()
            return true
        end if
    end if

    return false
end function
