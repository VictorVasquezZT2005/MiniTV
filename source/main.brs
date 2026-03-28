' ============================================================
'  source/main.brs
'  Punto de entrada de MiniTV - Soporta Certificación 5.2 (Deep Link)
' ============================================================

sub Main(args as Dynamic)
    ' 1. Crear la pantalla y el puerto de mensajes
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)

    ' 2. Configurar soporte para Deep Linking (roInput)
    input = CreateObject("roInput")
    input.setMessagePort(m.port)

    ' 3. Determinar la URL del feed (M3U)
    ' Si Roku envía un parámetro de inicio (args), lo capturamos aquí
    inputUrl = ""
    if args.contentId <> invalid and args.contentId <> ""
        inputUrl = args.contentId
    end if

    ' URL por defecto del repositorio
    url = "https://raw.githubusercontent.com/VictorVasquezZT2005/IPTV/refs/heads/main/index.m3u"

    ' Leer del registro si el usuario cambió la URL manualmente
    reg = CreateObject("roRegistrySection", "profile")
    if reg.Exists("primaryfeed") then url = reg.Read("primaryfeed")

    ' 4. Configurar variables globales
    m.global = screen.getGlobalNode()
    m.global.addFields({
        feedurl: url,
        inputUrl: inputUrl ' Este campo será observado por MainScene.brs
    })

    ' 5. Crear la escena principal
    scene = screen.CreateScene("MainScene")
    screen.show()

    ' 6. BUCLE PRINCIPAL DE EVENTOS (Evita que la app se trabe)
    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)

        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return

        else if msgType = "roInputEvent"
            ' Manejo de eventos Deep Link mientras la app ya está abierta
            info = msg.getInfo()
            if info <> invalid
                contentId = info.Lookup("contentId")
                if contentId <> invalid and contentId <> ""
                    ' Actualizamos el campo global para que MainScene reaccione
                    m.global.inputUrl = contentId
                end if
            end if
        end if
    end while
end sub
