sub init()
    m.poster = m.top.findNode("poster")
    m.header = m.top.findNode("header")
    m.footer1 = m.top.findNode("footer1")
    m.footer2 = m.top.findNode("footer2")
    m.footer3 = m.top.findNode("footer3")
end sub

sub itemContentChanged()
    m.poster.uri = m.top.itemContent.HDPOSTERURL
    m.header.text = m.top.itemContent.title
    m.footer1.text = m.top.itemContent.description
    m.footer2.text = m.top.itemContent.releaseDate
    m.footer3.text = m.top.itemContent.ShortDescriptionLine1
    updateLayout()
end sub

sub showFocus()
    scale = 1 + (m.top.focusPercent * 0.25)
    m.poster.scale = [scale, scale]
    m.header.opacity = m.top.focusPercent
    m.footer1.opacity = m.top.focusPercent
    m.footer2.opacity = m.top.focusPercent
    m.footer3.opacity = m.top.focusPercent
end sub

sub updateLayout()
    if m.top.height > 0 and m.top.width > 0 
        m.poster.width = m.top.width
        m.poster.height = m.top.height
    end if
end sub