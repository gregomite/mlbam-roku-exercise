sub init()
    m.top.backgroundUri = "pkg:/images/background.jpg"
    m.gamedate = m.top.findNode("gamedate")
    m.rowList = m.top.findNode("rowList")
    m.rowList.SetFocus(true)
    fetchContent()
End sub

sub fetchContent()
    day = getGameDate()
    m.gamedate.text = day.asDateStringNoParam()
    'Create task node to fetch score-board JSON
    m.jsonSlurperTask = CreateObject("roSGNode", "JsonSlurper") 
    feedUrl = buildUrl(day.getYear(), day.getMonth(), day.getDayOfMonth())
    print feedUrl
    m.jsonSlurperTask.jsonFeed = feedUrl
    m.jsonSlurperTask.control = "RUN"
    m.jsonSlurperTask.observeField("content","rowListContentChanged")
end sub

sub rowListContentChanged()
    m.rowList.content = m.jsonSlurperTask.content
end sub

function buildUrl(year as Integer, month as Integer, day as Integer) as String
    yearStr = addLeadingZero(year)
    monthStr = addLeadingZero(month)
    dayStr = addLeadingZero(day)
    templateUrl = "http://gdx.mlb.com/components/game/mlb/year_{0}/month_{1}/day_{2}/master_scoreboard.json"
    return Substitute(templateUrl, yearStr, monthStr, dayStr)
end function

function addLeadingZero(value as Integer) as String
    valueStr = Str(value).trim()
    if value < 10
        valueStr = "0" + valueStr
    end if
    return valueStr
end function

sub onDateChange()
    fetchContent()
end sub

sub resetDay(setting as String)
    gameday = getGameDate()
    if setting = "add"
        gameday.fromSeconds(gameday.asSeconds() + 86164) 'add # seconds in a day
    else if setting = "minus"
        gameday.fromSeconds(gameday.asSeconds() - 86164) 'subtract # seconds in a day
    else if setting = "today"
        gameday.mark()
        gameday.toLocalTime()
    end if
    m.top.epoch = gameday.asSeconds()
end sub

function getGameDate() as Object
    gameday = CreateObject("roDateTime")
    gameday.fromSeconds(m.top.epoch)
    return gameday
end function

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "up"
            resetDay("minus")
            result = true
        else if key = "down"
            resetDay("add")
            result = true
        end if
    end if
    return result
end function
