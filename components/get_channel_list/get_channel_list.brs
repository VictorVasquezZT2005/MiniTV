' ============================================================
'  components/get_channel_list/get_channel_list.brs
'  MiniTV – Task: Parseo de feed M3U / M3U8
' ============================================================

sub init()
    m.top.functionName = "runTask"
end sub

sub runTask()
    url = m.global.feedurl
    if url = "" or url = invalid
        print "MiniTV [get_channel_list]: feedurl no configurado"
        return
    end if

    utrans = CreateObject("roUrlTransfer")
    utrans.setCertificatesFile("common:/certs/ca-bundle.crt")
    utrans.initClientCertificates()
    utrans.setUrl(url)
    utrans.AddHeader("User-Agent", "MiniTV/2.0 Roku")

    rawStr = utrans.getToString()
    if rawStr = "" or rawStr = invalid
        print "MiniTV [get_channel_list]: respuesta vacía"
        return
    end if

    rawStr = rawStr.Replace(Chr(13), "")
    lines  = rawStr.Split(Chr(10))

    container    = CreateObject("roSGNode", "ContentNode")
    lastTitle    = ""
    lastLogo     = ""
    lastCategory = "General"
    channelNum   = 0

    for each line in lines
        ln = line.Trim()

        if Left(ln, 7) = "#EXTINF"
            parts = ln.Split(",")
            if parts.Count() > 1
                lastTitle = parts[parts.Count() - 1].Trim()
            end if
            if ln.Instr("tvg-logo=""") <> -1
                logoSplit = ln.Split("tvg-logo=""")
                if logoSplit.Count() > 1
                    lastLogo = logoSplit[1].Split("""")[0]
                end if
            else if ln.Instr("tvg-logo=") <> -1
                lastLogo = ln.Split("tvg-logo=")[1].Split(" ")[0]
            end if
            if ln.Instr("group-title=""") <> -1
                catSplit = ln.Split("group-title=""")
                if catSplit.Count() > 1
                    lastCategory = catSplit[1].Split("""")[0]
                end if
            else if ln.Instr("group-title=") <> -1
                lastCategory = ln.Split("group-title=")[1].Split(" ")[0]
            end if

        else if Left(ln, 4) = "http"
            channelNum = channelNum + 1
            if lastTitle = "" then lastTitle = "Canal " + channelNum.ToStr()
            node = container.CreateChild("ContentNode")
            node.title        = lastTitle
            node.url          = ln
            node.hdPosterUrl  = lastLogo
            node.description  = lastCategory
            node.streamFormat = "hls"
            lastTitle    = ""
            lastLogo     = ""
            lastCategory = "General"
        end if
    end for

    print "MiniTV [get_channel_list]: " + channelNum.ToStr() + " canales cargados"
    m.top.content = container
end sub
