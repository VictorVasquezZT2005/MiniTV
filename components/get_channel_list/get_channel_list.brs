sub init()
    m.top.functionName = "runTask"
end sub

sub runTask()
    url = m.global.feedurl
    utrans = CreateObject("roUrlTransfer")
    utrans.setCertificatesFile("common:/certs/ca-bundle.crt")
    utrans.initClientCertificates()
    utrans.setUrl(url)
    
    rawStr = utrans.getToString()
    if rawStr = "" or rawStr = invalid then return

    rawStr = rawStr.Replace(Chr(13), "")
    lines = rawStr.Split(Chr(10))
    
    container = CreateObject("roSGNode", "ContentNode")
    tempTitle = ""

    for each line in lines
        ln = line.Trim()
        if Left(ln, 7) = "#EXTINF"
            parts = ln.Split(",")
            if parts.Count() > 1
                tempTitle = parts[parts.Count() - 1].Trim()
            end if
        else if Left(ln, 4) = "http"
            if tempTitle = "" then tempTitle = "Canal " + (container.getChildCount() + 1).ToStr()
            node = container.CreateChild("ContentNode")
            node.title = tempTitle
            node.url = ln
            node.streamFormat = "hls"
            tempTitle = ""
        end if
    end for
    
    m.top.content = container
end sub